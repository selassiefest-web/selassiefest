// One gate for every public form on selassiefest.com and trcevent.com
// (10/7/2026). Those forms used to insert straight into their tables with the
// public anon key, which let bots add rows (and trigger emails) at will. Now
// the browser posts { form, record, token, website } here; this checks a
// Cloudflare Turnstile token, the honeypot, a per-IP throttle and any
// "email must be verified first" rule the table's old insert policy had, then
// inserts with the service role. Only the columns listed in FORMS are kept.
// AFTER INSERT triggers (staff notifications, clrwf quote -> job) still fire.
//
// Anon INSERT on every table in FORMS is revoked once the sites use this.
// Deploy with --no-verify-jwt; secret TURNSTILE_SECRET_KEY.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const TURNSTILE_SECRET_KEY = Deno.env.get("TURNSTILE_SECRET_KEY");

const ALLOWED_ORIGINS = ["https://selassiefest.com", "https://trcevent.com"];
const ALLOWED_HOSTNAMES = ["selassiefest.com", "www.selassiefest.com", "trcevent.com", "www.trcevent.com"];
const PER_IP_PER_HOUR = 10;
const MAX_RECORD_BYTES = 60_000;
const MAX_STRING = 20_000;

type FormConfig = { columns: string[]; verified?: { rpc: string; column: string } };

const FORMS: Record<string, FormConfig> = {
  anansi_story_submissions: { columns: ["name", "email", "story_title", "story_text"] },
  volunteer_signups: {
    columns: ["full_name", "email", "phone", "age", "role_choice", "shift_preference", "tshirt_size", "emergency_contact", "accommodations", "referral_source", "waiver_accepted"],
    verified: { rpc: "volunteer_email_is_verified", column: "email" },
  },
  sponsor_inquiries: {
    columns: ["source_page", "email", "fields"],
    verified: { rpc: "sponsor_email_is_verified", column: "email" },
  },
  camp_registrations: { columns: ["camper_name", "guardian_name", "guardian_email", "guardian_phone", "registration_data"] },
  game_submissions: { columns: ["game_slug", "game_name", "submitter_name", "submitter_email", "story_text", "photo_path", "video_path"] },
  vendor_applications: { columns: ["business_name", "contact_email", "product_description", "webpage_highlight", "marketing_plan", "preferred_space", "logo_path", "photo_paths"] },
  security_guard_contracts: { columns: ["vendor_company_name", "vendor_address", "vendor_contact", "guard_names", "signer_name", "signer_title", "pdf_path"] },
  plates_for_purpose_responses: { columns: ["restaurant_slug", "business_name", "decision", "offer_details", "respondent_name", "respondent_title", "email", "contact_info", "message"] },
  bbpac_meeting_notify: { columns: ["email"] },
  bbpac_volunteer_signups: { columns: ["full_name", "email", "phone", "interest_area", "availability"] },
  bbpac_membership_signups: {
    columns: ["full_name", "email", "membership_level", "message"],
    verified: { rpc: "bbpac_membership_email_is_verified", column: "email" },
  },
  bbpac_sponsor_inquiries: { columns: ["business_name", "contact_name", "email", "message"] },
  bbpac_vendor_applications: { columns: ["business_name", "contact_name", "email", "product_description", "preferred_event"] },
  bbpac_contact_messages: { columns: ["name", "email", "topic", "message"] },
  bbpac_photo_submissions: { columns: ["name", "email", "description", "era"] },
  bbpac_formation_section_signup_requests: { columns: ["full_name", "email", "requested_sections", "message", "expertise_tags", "expertise_other"] },
  clrwf_quote_requests: { columns: ["full_name", "email", "phone", "category", "description", "budget_range", "timeline", "photo_paths", "pit_configuration", "voice_note_paths"] },
  clrwf_maintenance_agreement_requests: { columns: ["business_name", "contact_name", "email", "phone", "property_description", "service_needs", "message", "voice_note_paths"] },
  clrwf_contact_messages: { columns: ["name", "email", "message", "voice_note_paths"] },
  clrwf_job_applications: { columns: ["position", "full_name", "email", "phone", "cover_letter", "resume_path", "voice_note_paths"] },
  yawd_waitlist: { columns: ["full_name", "email", "phone", "zip", "customer_type", "business_name", "interests", "message", "source"] },
  // trcevent.com
  event_notify_signups: { columns: ["event_slug", "event_name", "brand", "email"] },
  dh101_signups: { columns: ["school_id", "full_name", "edu_email", "dob", "student_segment", "referral_code", "campaign_code"] },
};

function cors(req: Request) {
  const origin = req.headers.get("origin") || "";
  return {
    "Access-Control-Allow-Origin": ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0],
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    Vary: "Origin",
  };
}

// Keeps only listed columns, and only plain JSON values of sane size.
function clean(record: Record<string, unknown>, columns: string[]): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  for (const c of columns) {
    if (!(c in record)) continue;
    const v = record[c];
    out[c] = typeof v === "string" ? v.slice(0, MAX_STRING) : v;
  }
  return out;
}

async function turnstileOk(token: string, ip: string): Promise<boolean> {
  const form = new FormData();
  form.append("secret", TURNSTILE_SECRET_KEY || "");
  form.append("response", token);
  if (ip !== "unknown") form.append("remoteip", ip);
  const res = await fetch("https://challenges.cloudflare.com/turnstile/v0/siteverify", { method: "POST", body: form });
  const out = await res.json();
  if (!out.success) console.warn("public-submit: turnstile failed", out["error-codes"]);
  return out.success === true && ALLOWED_HOSTNAMES.includes(out.hostname);
}

Deno.serve(async (req) => {
  const headers = { ...cors(req), "Content-Type": "application/json" };
  const reply = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers });
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors(req) });
  if (req.method !== "POST") return reply({ error: "POST only" }, 405);
  if (!TURNSTILE_SECRET_KEY) {
    console.error("public-submit: TURNSTILE_SECRET_KEY is not set");
    return reply({ error: "This form is paused. Please try again later." }, 500);
  }

  try {
    const raw = await req.text();
    if (raw.length > MAX_RECORD_BYTES) return reply({ error: "That's too much text for one submission." }, 413);
    const body = JSON.parse(raw || "{}");
    if (String(body.website || "").trim() !== "") return reply({ ok: true });   // honeypot: pretend it worked

    const form = String(body.form || "");
    const config = FORMS[form];
    if (!config) return reply({ error: "Unknown form." }, 400);
    if (!body.record || typeof body.record !== "object" || Array.isArray(body.record)) return reply({ error: "Missing form data." }, 400);
    if (!body.token) return reply({ error: "Please wait for the security check to finish, then try again." }, 400);

    const ip = (req.headers.get("x-forwarded-for") || "").split(",")[0].trim() || "unknown";
    if (!(await turnstileOk(String(body.token), ip))) return reply({ error: "We couldn't verify you're a person. Please try again." }, 400);

    const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);
    const since = new Date(Date.now() - 60 * 60 * 1000).toISOString();
    const purpose = `form:${form}`;
    const { count } = await supabase.from("verification_ip_rate_limits").select("*", { count: "exact", head: true })
      .eq("purpose", purpose).eq("ip", ip).gte("created_at", since);
    if ((count || 0) >= PER_IP_PER_HOUR) return reply({ error: "Too many submissions from this network. Please try again later." }, 429);
    await supabase.from("verification_ip_rate_limits").insert({ ip, purpose });

    const record = clean(body.record, config.columns);
    if (config.verified) {
      const { data: ok, error } = await supabase.rpc(config.verified.rpc, { check_email: record[config.verified.column] });
      if (error) throw error;
      if (ok !== true) return reply({ error: "Please verify your email with the code we sent first.", code: "not_verified" }, 403);
    }

    const { error } = await supabase.from(form).insert(record);
    if (error) {
      // Same shape the pages already handle from direct inserts (e.g. 23505 = already signed up).
      if (error.code === "23505" || error.code === "23514" || error.code === "P0001") return reply({ error: error.message, code: error.code }, 409);
      throw error;
    }
    return reply({ ok: true });
  } catch (e) {
    console.error("public-submit error:", e);
    return reply({ error: "Something went wrong. Please try again." }, 500);
  }
});
