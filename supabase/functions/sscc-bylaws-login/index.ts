// Sign-in links for the SSCC Advisory Council bylaws workspace
// (/sscc-bylaws/). Called from the page with { email }. If the email is on
// sscc_bylaws_members, creates a pending sscc_bylaws_login_links row (the
// token is the credential) and emails the link; sscc_bylaws_verify
// activates it when clicked. See supabase/sscc-bylaws-schema.sql.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM = "SSCC Bylaws Workspace <hello@selassiefest.com>";
const PAGE = "https://selassiefest.com/sscc-bylaws/";
const MAX_LINKS_PER_HOUR = 5;

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function reply(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });
}

function escapeHtml(s: unknown) {
  return String(s == null ? "" : s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c] as string));
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return reply({ error: "method not allowed" }, 405);

  const { email: raw } = await req.json().catch(() => ({}));
  const email = String(raw ?? "").trim().toLowerCase();
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) return reply({ error: "invalid_email" }, 400);

  const admin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
  const { data: member, error: mErr } = await admin
    .from("sscc_bylaws_members").select("email, display_name").ilike("email", email).maybeSingle();
  if (mErr) return reply({ error: "server_error" }, 500);
  if (!member) return reply({ error: "not_a_member" }, 404);

  const hourAgo = new Date(Date.now() - 60 * 60 * 1000).toISOString();
  const { count } = await admin
    .from("sscc_bylaws_login_links").select("token", { count: "exact", head: true })
    .ilike("email", email).gte("created_at", hourAgo);
  if ((count ?? 0) >= MAX_LINKS_PER_HOUR) return reply({ error: "too_many_requests" }, 429);

  const { data: link, error: lErr } = await admin
    .from("sscc_bylaws_login_links").insert({ email: member.email }).select("token").single();
  if (lErr || !link) return reply({ error: "server_error" }, 500);

  const url = `${PAGE}?signin=${link.token}`;
  const first = escapeHtml(String(member.display_name).split(" ")[0]);
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({
      from: FROM,
      to: member.email,
      subject: "Your sign-in link: SSCC bylaws workspace",
      html: `
        <p>Hi ${first},</p>
        <p><a href="${url}" style="display:inline-block;background:#1a1712;color:#e9c46a;padding:10px 18px;border-radius:6px;text-decoration:none;font-weight:600;">Sign in to the bylaws workspace</a></p>
        <p style="color:#6b6255;font-size:0.9rem;">The link works for 30 minutes. After you use it, this browser stays signed in.
        If you didn't ask for it, you can ignore this email.</p>`,
    }),
  });
  if (!res.ok) return reply({ error: "email_failed" }, 502);
  return reply({ ok: true });
});
