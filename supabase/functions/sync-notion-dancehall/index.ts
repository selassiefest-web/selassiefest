// Scheduled sync for the "Chicago Dancehall Scene" community-tracking
// Notion database (a project separate from SelassieFest's own calendar) into
// the read-only dancehall_occurrences table (see supabase/schema.sql), which
// feeds the password-gated /chicago-dancehall/ chart page. Not called from
// any client-side code -- triggered on a schedule via pg_cron calling
// net.http_post with the shared x-sync-secret header, same pattern as
// notify-submission's WEBHOOK_SECRET. Writes with the service role key
// (auto-injected into every Edge Function's env), which bypasses RLS.

const NOTION_TOKEN = Deno.env.get('NOTION_TOKEN')!;
const SYNC_SECRET = Deno.env.get('SYNC_SECRET')!;
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

const NOTION_VERSION = '2022-06-28';
const OCCURRENCES_DB = '39a0673a-32ac-81a3-b9f0-e4175919e214';
const VENUES_DB = '39a0673a-32ac-805a-87d8-c7675eb310b4';
const REGIONS_DB = '39a0673a-32ac-80d1-a312-eddbafaeb0ba';
const PROMOTERS_DB = '39a0673a-32ac-8133-a80f-ce51503d2c2d';

async function notionFetch(path: string, body: Record<string, unknown>) {
  const res = await fetch(`https://api.notion.com/v1/${path}`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${NOTION_TOKEN}`,
      'Notion-Version': NOTION_VERSION,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    throw new Error(`Notion API error (${path}): ${res.status} ${await res.text()}`);
  }
  return res.json();
}

async function queryAllPages(databaseId: string) {
  const results: any[] = [];
  let cursor: string | undefined;
  do {
    const json: any = await notionFetch(`databases/${databaseId}/query`, {
      page_size: 100,
      ...(cursor ? { start_cursor: cursor } : {}),
    });
    results.push(...json.results);
    cursor = json.has_more ? json.next_cursor : undefined;
  } while (cursor);
  return results;
}

function titleOf(page: any): string {
  const prop = Object.values(page.properties).find((p: any) => p.type === 'title') as any;
  return (prop?.title ?? []).map((t: any) => t.plain_text).join('');
}

function nameMap(pages: any[]): Map<string, string> {
  const map = new Map<string, string>();
  for (const page of pages) map.set(page.id, titleOf(page));
  return map;
}

function firstRelationName(prop: any, map: Map<string, string>): string | null {
  const id = prop?.relation?.[0]?.id;
  return id ? map.get(id) ?? null : null;
}

function richTextOf(prop: any): string | null {
  const text = (prop?.rich_text ?? []).map((t: any) => t.plain_text).join('');
  return text || null;
}

Deno.serve(async (req) => {
  if (req.headers.get('x-sync-secret') !== SYNC_SECRET) {
    return new Response(JSON.stringify({ error: 'unauthorized' }), { status: 401 });
  }

  try {
    const [venuePages, regionPages, promoterPages, occurrencePages] = await Promise.all([
      queryAllPages(VENUES_DB),
      queryAllPages(REGIONS_DB),
      queryAllPages(PROMOTERS_DB),
      queryAllPages(OCCURRENCES_DB),
    ]);

    const venueMap = nameMap(venuePages);
    const regionMap = nameMap(regionPages);
    const promoterMap = nameMap(promoterPages);

    const rows = occurrencePages.map((page: any) => {
      const props = page.properties;
      return {
        notion_page_id: page.id,
        name: titleOf(page),
        occurrence_date: props.Date?.date?.start ?? null,
        region: firstRelationName(props.Region, regionMap),
        venue: firstRelationName(props.Venue, venueMap),
        promoter: firstRelationName(props.Promoter, promoterMap),
        status: props.Status?.select?.name ?? null,
        notes: richTextOf(props.Notes),
        synced_at: new Date().toISOString(),
      };
    });

    const upsertRes = await fetch(
      `${SUPABASE_URL}/rest/v1/dancehall_occurrences?on_conflict=notion_page_id`,
      {
        method: 'POST',
        headers: {
          apikey: SUPABASE_SERVICE_ROLE_KEY,
          Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
          'Content-Type': 'application/json',
          Prefer: 'resolution=merge-duplicates,return=minimal',
        },
        body: JSON.stringify(rows),
      }
    );

    if (!upsertRes.ok) {
      const errText = await upsertRes.text();
      console.error('Supabase upsert failed:', upsertRes.status, errText);
      return new Response(JSON.stringify({ error: errText }), { status: 502 });
    }

    return new Response(JSON.stringify({ synced: rows.length }), { status: 200 });
  } catch (e) {
    console.error('sync-notion-dancehall error:', e);
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 });
  }
});
