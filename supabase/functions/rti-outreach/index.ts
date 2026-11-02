// Supabase Edge Function: rti-outreach
// CLI-only: sends one outreach email from Ras Tafari Inc. (e.g. a support request
// letter to an alderman or police district), optionally with a PDF attachment.
//
//   { secret, to: [..], cc?: [..], reply_to?, in_reply_to?, references?, subject, text, html, attachments?: [{ filename, content (base64) }] }
//
// Deploy with --no-verify-jwt. Secrets: RESEND_API_KEY, RTI_SIGN_ADMIN_SECRET.
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const ADMIN_SECRET = Deno.env.get("RTI_SIGN_ADMIN_SECRET") ?? "";
// From a real, monitored mailbox (stephen@) rather than hello@: better trust with Gmail and Outlook filters.
const FROM_EMAIL = "Stephen Henry, Ras Tafari Inc. <stephen@selassiefest.com>";
const isEmail = (s: string) => /^[^\s@<>()",;:]+@[^\s@<>()",;:]+\.[^\s@<>()",;:]+$/.test(s);

Deno.serve(async (req) => {
  const reply = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: { "Content-Type": "application/json" } });
  if (req.method !== "POST") return reply({ ok: false, error: "Use POST." }, 405);
  let b: Record<string, any>;
  try { b = await req.json(); } catch { return reply({ ok: false, error: "Bad JSON." }, 400); }
  if (!ADMIN_SECRET || String(b.secret ?? "") !== ADMIN_SECRET) return reply({ ok: false, error: "Not allowed." }, 403);
  // { secret, action: "usage" }: counts emails sent in the last 24 hours and today (UTC) across the whole Resend account.
  if (b.action === "usage") {
    const since = Date.now() - 24 * 3600 * 1000, today = new Date().toISOString().slice(0, 10);
    let last24 = 0, utcToday = 0, after: string | undefined, pages = 0, oldest = "";
    while (pages++ < 10) {
      const u = "https://api.resend.com/emails?limit=100" + (after ? "&after=" + after : "");
      const r = await fetch(u, { headers: { Authorization: `Bearer ${RESEND_API_KEY}` } });
      const j: any = await r.json().catch(() => ({}));
      if (!r.ok) return reply({ ok: false, error: j.message || r.status }, 502);
      const rows: any[] = j.data ?? [];
      for (const e of rows) {
        const t = Date.parse(String(e.created_at).replace(" ", "T").replace(/\+00$/, "Z"));
        oldest = e.created_at;
        if (t >= since) last24++;
        if (String(e.created_at).slice(0, 10) === today) utcToday++;
      }
      const lastT = rows.length ? Date.parse(String(rows[rows.length - 1].created_at).replace(" ", "T").replace(/\+00$/, "Z")) : 0;
      if (!j.has_more || !rows.length || lastT < since) break;
      after = rows[rows.length - 1].id;
    }
    if (b.debug) {
      const r = await fetch("https://api.resend.com/emails?limit=5", { headers: { Authorization: `Bearer ${RESEND_API_KEY}` } });
      const j: any = await r.json().catch(() => ({}));
      return reply({ ok: true, last24h: last24, utcToday, oldestSeen: oldest, pages, sample: (j.data ?? []).map((e: any) => e.created_at), has_more: j.has_more });
    }
    return reply({ ok: true, last24h: last24, utcToday, oldestSeen: oldest });
  }
  const to = (Array.isArray(b.to) ? b.to : []).map(String).filter(isEmail);
  const cc = (Array.isArray(b.cc) ? b.cc : []).map(String).filter(isEmail);
  if (!to.length || !b.subject || !b.html) return reply({ ok: false, error: "to, subject and html are required." }, 400);
  // Optional threading so a reply lands in the recipient's existing conversation: { in_reply_to, references } (Message-ID strings only)
  const mid = (v: unknown) => /^<[^\s<>@]+@[^\s<>]+>$/.test(String(v ?? "").trim()) ? String(v).trim() : "";
  const threadHeaders: Record<string, string> = {};
  if (mid(b.in_reply_to)) threadHeaders["In-Reply-To"] = mid(b.in_reply_to);
  if (mid(b.references)) threadHeaders["References"] = mid(b.references);
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({
      from: FROM_EMAIL, to, cc: cc.length ? cc : undefined, reply_to: b.reply_to || "stephen@selassiefest.com",
      subject: String(b.subject).slice(0, 200), text: b.text, html: b.html,
      attachments: Array.isArray(b.attachments) ? b.attachments.slice(0, 3) : undefined,
      headers: Object.keys(threadHeaders).length ? threadHeaders : undefined,
    }),
  });
  const out = await res.json().catch(() => ({}));
  return reply({ ok: res.ok, id: out.id, error: res.ok ? undefined : (out.message || res.status) }, res.ok ? 200 : 502);
});
