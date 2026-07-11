// Scheduled sync for the "Chicago Dancehall Oscars -- Master Production
// Bible" Notion workspace (internal team-planning tool, separate from the
// public dh101_*/dancehall_occurrences data) into the authenticated-only
// oscars_* tables (see supabase/schema.sql), which feed a password-gated
// production dashboard for the small event team. Not called from any
// client-side code -- triggered on a schedule via pg_cron calling
// net.http_post with the shared x-sync-secret header, same pattern as
// sync-notion-dancehall. Writes with the service role key (auto-injected
// into every Edge Function's env), which bypasses RLS.

const NOTION_TOKEN = Deno.env.get('NOTION_TOKEN')!;
const SYNC_SECRET = Deno.env.get('SYNC_SECRET')!;
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

const NOTION_VERSION = '2022-06-28';
const TIMELINE_DB = '39a0673a-32ac-8137-aca1-dd856a7751b4';
const TEAM_DB = '39a0673a-32ac-81dc-8094-ccec794f9dab';
const CATEGORIES_DB = '39a0673a-32ac-81ae-b38a-e51f9608ff2b';
const NOMINEES_DB = '39a0673a-32ac-8138-974e-c16716367476';
const SPONSORS_DB = '39a0673a-32ac-8185-a53e-f20765f55f91';
const RISKS_DB = '39a0673a-32ac-8120-93f5-d574f3466fd9';
const RUN_OF_SHOW_DB = '39a0673a-32ac-8165-8676-f9df18770c4e';

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
function richTextOf(prop: any): string | null {
  const text = (prop?.rich_text ?? []).map((t: any) => t.plain_text).join('');
  return text || null;
}
function selectOf(prop: any): string | null {
  return prop?.select?.name ?? null;
}

async function upsert(table: string, rows: any[]) {
  if (!rows.length) return { table, synced: 0 };
  const res = await fetch(`${SUPABASE_URL}/rest/v1/${table}?on_conflict=notion_page_id`, {
    method: 'POST',
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      'Content-Type': 'application/json',
      Prefer: 'resolution=merge-duplicates,return=minimal',
    },
    body: JSON.stringify(rows),
  });
  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`Supabase upsert failed for ${table}: ${res.status} ${errText}`);
  }
  return { table, synced: rows.length };
}

Deno.serve(async (req) => {
  if (req.headers.get('x-sync-secret') !== SYNC_SECRET) {
    return new Response(JSON.stringify({ error: 'unauthorized' }), { status: 401 });
  }

  try {
    const [timelinePages, teamPages, categoryPages, nomineePages, sponsorPages, riskPages, runOfShowPages] =
      await Promise.all([
        queryAllPages(TIMELINE_DB),
        queryAllPages(TEAM_DB),
        queryAllPages(CATEGORIES_DB),
        queryAllPages(NOMINEES_DB),
        queryAllPages(SPONSORS_DB),
        queryAllPages(RISKS_DB),
        queryAllPages(RUN_OF_SHOW_DB),
      ]);

    const categoryNames = new Map<string, string>();
    for (const page of categoryPages) categoryNames.set(page.id, titleOf(page));

    const timelineRows = timelinePages.map((p: any) => ({
      notion_page_id: p.id,
      task: titleOf(p),
      phase: selectOf(p.properties.Phase),
      owner: richTextOf(p.properties.Owner),
      due_date: p.properties['Due Date']?.date?.start ?? null,
      status: selectOf(p.properties.Status),
      notes: richTextOf(p.properties.Notes),
      synced_at: new Date().toISOString(),
    }));

    const teamRows = teamPages.map((p: any) => ({
      notion_page_id: p.id,
      name: titleOf(p),
      organization: richTextOf(p.properties.Organization),
      role: selectOf(p.properties.Role),
      email: p.properties.Email?.email ?? null,
      phone: p.properties.Phone?.phone_number ?? null,
      raci_nominations: selectOf(p.properties['RACI: Nominations']),
      raci_production: selectOf(p.properties['RACI: Production']),
      raci_marketing: selectOf(p.properties['RACI: Marketing']),
      raci_sponsors: selectOf(p.properties['RACI: Sponsors']),
      notes: richTextOf(p.properties.Notes),
      synced_at: new Date().toISOString(),
    }));

    const categoryRows = categoryPages.map((p: any) => ({
      notion_page_id: p.id,
      category: titleOf(p),
      segment: selectOf(p.properties.Segment),
      description: richTextOf(p.properties.Description),
      synced_at: new Date().toISOString(),
    }));

    const nomineeRows = nomineePages.map((p: any) => {
      const catId = p.properties.Category?.relation?.[0]?.id ?? null;
      return {
        notion_page_id: p.id,
        name: titleOf(p),
        category_notion_id: catId,
        category_name: catId ? categoryNames.get(catId) ?? null : null,
        is_finalist: p.properties['Is Finalist']?.checkbox ?? false,
        public_votes: p.properties['Public Votes']?.number ?? null,
        is_winner: p.properties['Is Winner']?.checkbox ?? false,
        notes: richTextOf(p.properties.Notes),
        synced_at: new Date().toISOString(),
      };
    });

    const sponsorRows = sponsorPages.map((p: any) => ({
      notion_page_id: p.id,
      sponsor: titleOf(p),
      touchpoint: richTextOf(p.properties.Touchpoint),
      status: selectOf(p.properties.Status),
      contact: richTextOf(p.properties.Contact),
      value: richTextOf(p.properties.Value),
      synced_at: new Date().toISOString(),
    }));

    const riskRows = riskPages.map((p: any) => ({
      notion_page_id: p.id,
      risk: titleOf(p),
      likelihood: selectOf(p.properties.Likelihood),
      impact: selectOf(p.properties.Impact),
      mitigation: richTextOf(p.properties.Mitigation),
      owner: richTextOf(p.properties.Owner),
      synced_at: new Date().toISOString(),
    }));

    const runOfShowRows = runOfShowPages.map((p: any) => ({
      notion_page_id: p.id,
      segment: titleOf(p),
      time_label: richTextOf(p.properties.Time),
      duration_min: p.properties['Duration (min)']?.number ?? null,
      owner: richTextOf(p.properties.Owner),
      notes: richTextOf(p.properties.Notes),
      synced_at: new Date().toISOString(),
    }));

    const results = await Promise.all([
      upsert('oscars_timeline', timelineRows),
      upsert('oscars_team', teamRows),
      upsert('oscars_categories', categoryRows),
      upsert('oscars_nominees', nomineeRows),
      upsert('oscars_sponsors', sponsorRows),
      upsert('oscars_risks', riskRows),
      upsert('oscars_run_of_show', runOfShowRows),
    ]);

    return new Response(JSON.stringify({ synced: results }), { status: 200 });
  } catch (e) {
    console.error('sync-notion-oscars error:', e);
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 });
  }
});
