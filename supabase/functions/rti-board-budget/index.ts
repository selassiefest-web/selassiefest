// Supabase Edge Function: rti-board-budget
// Behind /rti/board/budget/: the Ras Tafari Inc. board discusses and decides
// the budget of each Friday series (e.g. The Ultimate Friday Lime at ILU Club).
//
//   { action: "link", email }   Public: if the email belongs to a director on
//       rti_bb_members, emails them a personal link. Same reply either way.
//   { action: "load", token }   Every series with its budget, discussion, votes and
//       recent edit history. The page polls this every 20s, which also marks the
//       director as "on the page now".
//   { action: "comment", token, series_id, body }   Adds to the discussion and
//       emails the other directors that there is something new to read.
//   { action: "vote", token, series_id, vote, note }   approve | reject | abstain.
//   { action: "save", token, series, base_updated_at, new_series }   Any director:
//       create or change a series (title, venue, status, fridays_per_year, budget
//       lines, notes). Logged with before/after. Refused if someone else saved
//       since base_updated_at, so two people editing at once never overwrite.
//   { action: "set", token, series_id, key, status, note }   Any director: one venue
//       checklist finding ('A1'..'I6'), venue-record field ('meta.x') or board
//       decision field ('decision.x'). Logged to history with kind 'item'.
//   { action: "lookup", token, address }   New-venue form: Census match, municipality
//       and (from OpenStreetMap) the name of the business at that spot, if mapped.
//   { action: "area", token, series_id }   Area analysis from the venue's meta.address:
//       nearest homes and counts within 100/250/500 m, residential streets, Census
//       population/housing density, parking lots, schools/churches, other nightlife,
//       bus stops. Saved on rti_bb_series.area so every director sees one result.
//   { action: "invite", secret, emails? }   From the CLI (RTI_SIGN_ADMIN_SECRET):
//       emails a link to each listed director (or all of them).
//
// Links never expire; every link sent stays valid. Only hashes are stored.
// Deploy with --no-verify-jwt. Secrets: RESEND_API_KEY, RTI_SIGN_ADMIN_SECRET.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const ADMIN_SECRET = Deno.env.get("RTI_SIGN_ADMIN_SECRET") ?? "";

const FROM_EMAIL = "Ras Tafari Inc. <hello@selassiefest.com>";
const PAGE_URL = "https://selassiefest.com/rti/board/budget/";
const ALLOWED_ORIGINS = ["https://selassiefest.com", "https://www.selassiefest.com"];
const STATUSES = ["discussion", "approved", "rejected", "tabled"];
const VOTES = ["approve", "reject", "abstain"];

function cors(req: Request) {
  const origin = req.headers.get("origin") || "";
  return {
    "Access-Control-Allow-Origin": ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0],
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    Vary: "Origin",
  };
}

async function sha256(text: string) {
  const buf = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(text));
  return Array.from(new Uint8Array(buf)).map((b) => b.toString(16).padStart(2, "0")).join("");
}
const randomHex = (bytes: number) => Array.from(crypto.getRandomValues(new Uint8Array(bytes))).map((b) => b.toString(16).padStart(2, "0")).join("");
const esc = (s: string) => s.replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]!));
const maskEmail = (e: string) => e.replace(/^(.{2})[^@]*/, "$1***");
const firstName = (n: string) => n.split(/\s+/)[0];

async function sendEmail(to: string, subject: string, text: string, html: string) {
  if (!RESEND_API_KEY) return false;
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({ from: FROM_EMAIL, to: [to], subject, text, html }),
  });
  if (!res.ok) console.error("rti-board-budget: resend error", res.status);
  return res.ok;
}

async function sendLink(supabase: any, m: any) {
  const token = randomHex(32);
  const hashes = [...(m.token_hashes ?? []), await sha256(token)].slice(-20);
  const { error } = await supabase.from("rti_bb_members").update({ token_hashes: hashes, last_sent_at: new Date().toISOString() }).eq("id", m.id);
  if (error) { console.error("rti-board-budget: token save failed", error.code); return false; }
  const link = `${PAGE_URL}?t=${token}`;
  const first = firstName(m.full_name);
  const text = `Hello ${first},\n\nHere is your personal link to the Ras Tafari Inc. board budget room, where the board discusses and decides the budget for each Friday series:\n\n${link}\n\nThe link is personal to you as ${m.title}; please don't forward it. It keeps working, so you can bookmark it.\n\nQuestions: stephen@selassiefest.com or (872) 255-9333.\n`;
  const html = `<p>Hello ${esc(first)},</p><p>Here is your personal link to the <b>Ras Tafari Inc. board budget room</b>, where the board discusses and decides the budget for each Friday series.</p><p><a href="${link}" style="display:inline-block;background:#1f5b3a;color:#fff;padding:12px 18px;border-radius:8px;text-decoration:none;font-weight:700">Open the budget room</a></p><p>The link is personal to you as ${esc(m.title)}; please don't forward it. It keeps working, so you can bookmark it.</p><p style="color:#666;font-size:13px">Questions: stephen@selassiefest.com or (872) 255-9333.</p>`;
  return sendEmail(m.email, "Your link: RTI board budget room", text, html);
}

// ---- Address lookup and area analysis (public data only) ----
const UA = "RTI-Venue-Evaluation/1.0 (+https://selassiefest.com)";
const OVERPASS = ["https://overpass-api.de/api/interpreter", "https://overpass.kumi.systems/api/interpreter", "https://maps.mail.ru/osm/tools/overpass/api/interpreter"];

async function censusLookup(address: string) {
  const u = "https://geocoding.geo.census.gov/geocoder/geographies/onelineaddress?benchmark=Public_AR_Census2020&vintage=Census2020_Census2020&layers=all&format=json&address=" + encodeURIComponent(address);
  let res: Response | null = null;
  for (let i = 0; i < 3; i++) {
    try { res = await fetch(u, { headers: { "User-Agent": UA }, signal: AbortSignal.timeout(20000) }); } catch { res = null; }
    if (res?.ok) break;
    await new Promise((r) => setTimeout(r, 1500 * (i + 1)));
  }
  if (!res?.ok) throw new Error("census " + (res?.status ?? "timeout"));
  const m = (await res.json())?.result?.addressMatches?.[0];
  if (!m) return null;
  const g = m.geographies ?? {};
  const one = (k: string) => (g[k] ?? [])[0] ?? null;
  const geo = (x: any) => x ? { name: x.NAME, pop: x.POP100 ?? null, housing: x.HU100 ?? null, land_m2: x.AREALAND ?? null } : null;
  const place = one("Incorporated Places"), cousub = one("County Subdivisions"), county = one("Counties");
  return {
    matched: m.matchedAddress as string,
    lat: m.coordinates.y as number, lon: m.coordinates.x as number,
    municipality: place ? place.NAME : (cousub ? cousub.NAME + " (unincorporated)" : ""),
    is_chicago: !!place && /^Chicago city$/i.test(place.NAME),
    county: county?.NAME ?? "",
    place: geo(place), block_group: geo(one("Census Block Groups")), tract: geo(one("Census Tracts")), block: geo(one("Census Blocks")),
  };
}

async function overpass(q: string) {
  let last = "";
  for (const url of OVERPASS) {
    try {
      const res = await fetch(url, { method: "POST", headers: { "User-Agent": UA, "Content-Type": "application/x-www-form-urlencoded" }, body: "data=" + encodeURIComponent(q), signal: AbortSignal.timeout(45000) });
      const t = await res.text();
      if (res.ok && t.trimStart().startsWith("{")) return JSON.parse(t);
      last = String(res.status);
    } catch (e) { last = String(e); }
  }
  throw new Error("overpass unavailable: " + last);
}

// Flat-earth projection around the venue: fine at these distances.
function projector(lat0: number, lon0: number) {
  const ky = 111320, kx = 111320 * Math.cos(lat0 * Math.PI / 180);
  return (lat: number, lon: number) => [(lon - lon0) * kx, (lat - lat0) * ky] as [number, number];
}
const dist = (p: [number, number], q: [number, number] = [0, 0]) => Math.hypot(p[0] - q[0], p[1] - q[1]);
function segDist(p: [number, number], a: [number, number], b: [number, number]) {
  const dx = b[0] - a[0], dy = b[1] - a[1], L = dx * dx + dy * dy;
  const t = L ? Math.max(0, Math.min(1, ((p[0] - a[0]) * dx + (p[1] - a[1]) * dy) / L)) : 0;
  return dist(p, [a[0] + t * dx, a[1] + t * dy]);
}
function inRing(p: [number, number], ring: [number, number][]) {
  let inside = false;
  for (let i = 0, j = ring.length - 1; i < ring.length; j = i++) {
    const [xi, yi] = ring[i], [xj, yj] = ring[j];
    if ((yi > p[1]) !== (yj > p[1]) && p[0] < (xj - xi) * (p[1] - yi) / (yj - yi) + xi) inside = !inside;
  }
  return inside;
}
const RES_BUILDINGS = new Set(["house", "residential", "apartments", "detached", "semidetached_house", "terrace", "bungalow", "dormitory", "duplex", "townhouse", "cabin"]);
const SENSITIVE: Record<string, string> = { school: "School", kindergarten: "Kindergarten", childcare: "Childcare", place_of_worship: "Place of worship", hospital: "Hospital", nursing_home: "Nursing home", library: "Library", clinic: "Clinic" };

async function areaAnalysis(address: string) {
  const c = await censusLookup(address);
  if (!c) return { ok: false, error: "The Census geocoder couldn't match that address. Check the street, city and ZIP." };
  const { lat, lon } = c;
  const P = projector(lat, lon);
  const at = `(around:%R,${lat},${lon})`;
  const r = (n: number) => at.replace("%R", String(n));
  const q = `[out:json][timeout:40];
    (way[landuse=residential]${r(700)};relation[landuse=residential]${r(700)};)->.lr; .lr out geom;
    way[building]${r(500)}; out center tags;
    nwr[amenity=parking]${r(800)}; out center tags;
    nwr[amenity~"^(${Object.keys(SENSITIVE).join("|")})$"]${r(800)}; out center tags;
    nwr[amenity~"^(bar|pub|nightclub|events_venue|music_venue)$"]${r(1200)}; out center tags;
    node[highway=bus_stop]${r(500)}; out;
    way[highway=residential]${r(250)}; out geom;
    nwr[name][~"^(amenity|shop|leisure|club)$"~"."]${r(25)}; out center tags;`;
  const osm = await overpass(q);
  const els: any[] = osm.elements ?? [];
  const pt = (e: any): [number, number] | null => { const la = e.center?.lat ?? e.lat, lo = e.center?.lon ?? e.lon; return la == null ? null : P(la, lo); };
  const resRings: [number, number][][] = [];
  for (const e of els) {
    if (e.tags?.landuse !== "residential") continue;
    if (e.type === "way" && e.geometry) resRings.push(e.geometry.map((g: any) => P(g.lat, g.lon)));
    if (e.type === "relation") for (const m of e.members ?? []) if (m.role === "outer" && m.geometry) resRings.push(m.geometry.map((g: any) => P(g.lat, g.lon)));
  }
  const inResZone = (p: [number, number]) => resRings.some((ring) => inRing(p, ring));
  const homes: { d: number; lat: number; lon: number }[] = [];
  let buildingsAll = 0;
  for (const e of els) {
    const b = e.tags?.building; if (!b || e.type !== "way") continue;
    const p = pt(e); if (!p) continue;
    const d = dist(p);
    if (d < 20) continue; // the venue's own building
    buildingsAll++;
    const typed = RES_BUILDINGS.has(b);
    const commercial = e.tags.shop || e.tags.amenity || e.tags.office || e.tags.craft || ["commercial", "retail", "industrial", "warehouse", "church", "school", "garage", "garages", "shed", "roof", "carport"].includes(b);
    if (typed || (!commercial && inResZone(p))) homes.push({ d, lat: e.center.lat, lon: e.center.lon });
  }
  homes.sort((a, b) => a.d - b.d);
  const within = (n: number) => homes.filter((h) => h.d <= n).length;
  let resStreet: { d: number; name: string } | null = null;
  for (const e of els) {
    if (e.tags?.highway !== "residential" || !e.geometry) continue;
    const pts = e.geometry.map((g: any) => P(g.lat, g.lon));
    for (let i = 1; i < pts.length; i++) { const d = segDist([0, 0], pts[i - 1], pts[i]); if (!resStreet || d < resStreet.d) resStreet = { d, name: e.tags.name ?? "unnamed street" }; }
  }
  const list = (pred: (t: any) => boolean, label: (t: any) => string) => els.filter((e) => e.tags && pred(e.tags) && pt(e)).map((e) => {
    const p = pt(e)!; return { d: Math.round(dist(p)), name: e.tags.name ?? "", kind: label(e.tags), lat: e.center?.lat ?? e.lat, lon: e.center?.lon ?? e.lon, capacity: e.tags.capacity ? Number(e.tags.capacity) || e.tags.capacity : null, access: e.tags.access ?? null, fee: e.tags.fee ?? null, surface: e.tags.parking ?? null };
  }).sort((a, b) => a.d - b.d);
  const dedupe = (a: any[]) => a.filter((x, i) => a.findIndex((y) => y.name === x.name && y.kind === x.kind && Math.abs(y.d - x.d) < 30) === i);
  const parking = dedupe(list((t) => t.amenity === "parking", () => "Parking"));
  const sensitive = dedupe(list((t) => !!SENSITIVE[t.amenity], (t) => SENSITIVE[t.amenity]));
  const nightlife = dedupe(list((t) => /^(bar|pub|nightclub|events_venue|music_venue)$/.test(t.amenity ?? ""), (t) => t.amenity.replace("_", " ")));
  const bus = els.filter((e) => e.tags?.highway === "bus_stop").map((e) => ({ d: Math.round(dist(P(e.lat, e.lon))), name: e.tags.name ?? "", lat: e.lat, lon: e.lon })).sort((a, b) => a.d - b.d);
  const here = els.filter((e) => e.tags?.name && (e.tags.amenity || e.tags.shop || e.tags.leisure || e.tags.club) && pt(e)).map((e) => ({ name: e.tags.name, d: dist(pt(e)!) })).sort((a, b) => a.d - b.d)[0];
  const dens = (g: any) => g && g.land_m2 ? { pop: g.pop, housing: g.housing, pop_per_sqmi: Math.round(g.pop / (g.land_m2 / 2589988)), housing_per_sqmi: Math.round(g.housing / (g.land_m2 / 2589988)) } : null;
  return {
    ok: true,
    area: {
      address, matched: c.matched, lat, lon, municipality: c.municipality, is_chicago: c.is_chicago, county: c.county,
      venue_name_guess: here?.name ?? null,
      homes: { nearest_m: homes[0] ? Math.round(homes[0].d) : null, within_100: within(100), within_250: within(250), within_500: within(500), points: homes.slice(0, 400).map((h) => [Math.round(h.lat * 1e5) / 1e5, Math.round(h.lon * 1e5) / 1e5, Math.round(h.d)]) },
      buildings_within_500: buildingsAll,
      residential_zones_mapped: resRings.length,
      nearest_residential_street: resStreet ? { m: Math.round(resStreet.d), name: resStreet.name } : null,
      block: dens(c.block) ? { name: c.block!.name, ...dens(c.block) } : null,
      block_group: dens(c.block_group) ? { name: c.block_group!.name, ...dens(c.block_group) } : null,
      tract: dens(c.tract) ? { name: c.tract!.name, ...dens(c.tract) } : null,
      parking: parking.slice(0, 25), sensitive: sensitive.slice(0, 25), nightlife: nightlife.slice(0, 15), bus_stops: bus.slice(0, 12),
      sources: ["U.S. Census Bureau geocoder, 2020 Census blocks/block groups/tracts", "OpenStreetMap contributors via Overpass API"],
    },
  };
}

// Budget lines: [{label, amount|null, note}], capped and cleaned.
function cleanLines(v: unknown) {
  if (!Array.isArray(v)) return [];
  return v.slice(0, 60).map((l: any) => {
    const label = String(l?.label ?? "").trim().slice(0, 120);
    const raw = l?.amount;
    const n = raw === null || raw === "" || raw === undefined ? null : Number(raw);
    const amount = n === null || !Number.isFinite(n) ? null : Math.round(Math.min(Math.max(n, -10_000_000), 10_000_000) * 100) / 100;
    return { label, amount, note: String(l?.note ?? "").trim().slice(0, 300) };
  }).filter((l) => l.label);
}

Deno.serve(async (req) => {
  const headers = { ...cors(req), "Content-Type": "application/json" };
  const reply = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers });
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors(req) });
  if (req.method !== "POST") return reply({ ok: false, error: "Use POST." }, 405);

  let body: Record<string, any>;
  try { body = JSON.parse((await req.text()) || "{}"); } catch { return reply({ ok: false, error: "Couldn't read the request." }, 400); }
  const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  if (body.action === "link") {
    const email = String(body.email ?? "").trim().toLowerCase();
    if (/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
      const { data: m } = await supabase.from("rti_bb_members").select("*").eq("email", email).maybeSingle();
      if (m) await sendLink(supabase, m);
    }
    return reply({ ok: true, message: "If that email belongs to an RTI director, a link is on its way." });
  }

  if (body.action === "invite") {
    if (!ADMIN_SECRET || String(body.secret ?? "") !== ADMIN_SECRET) return reply({ ok: false, error: "Not allowed." }, 403);
    let q = supabase.from("rti_bb_members").select("*");
    if (Array.isArray(body.emails) && body.emails.length) q = q.in("email", body.emails.map((e: unknown) => String(e).toLowerCase()));
    const { data: list } = await q;
    const sent = [];
    for (const m of list ?? []) if (await sendLink(supabase, m)) sent.push(maskEmail(m.email));
    return reply({ ok: true, sent });
  }

  // Everything below needs a valid personal link.
  const token = String(body.token ?? "");
  const bad = () => reply({ ok: false, error: "This link isn't valid. Ask for a new one below." }, 401);
  if (!/^[0-9a-f]{64}$/.test(token)) return bad();
  const { data: me } = await supabase.from("rti_bb_members").select("id, full_name, title, email, is_editor").contains("token_hashes", [await sha256(token)]).maybeSingle();
  if (!me) return bad();

  const seriesExists = async (id: string) => {
    const { data } = await supabase.from("rti_bb_series").select("id, title").eq("id", id).maybeSingle();
    return data;
  };

  if (body.action === "load") {
    await supabase.from("rti_bb_members").update({ last_viewed_at: new Date().toISOString() }).eq("id", me.id);
    const [members, series, comments, votes, history, items] = await Promise.all([
      supabase.from("rti_bb_members").select("id, full_name, title, is_editor, last_viewed_at").order("id"),
      supabase.from("rti_bb_series").select("*").order("created_at"),
      supabase.from("rti_bb_comments").select("id, series_id, member_id, body, created_at").order("created_at"),
      supabase.from("rti_bb_votes").select("series_id, member_id, vote, note, updated_at"),
      supabase.from("rti_bb_history").select("id, series_id, member_id, kind, item_key, before, after, created_at").order("created_at", { ascending: false }).limit(400),
      supabase.from("rti_bb_items").select("series_id, key, status, note, member_id, updated_at"),
    ]);
    if (members.error || series.error || comments.error || votes.error || history.error || items.error) return reply({ ok: false, error: "Couldn't load the board room. Try again." }, 500);
    return reply({
      ok: true,
      me: { id: me.id, full_name: me.full_name, title: me.title, is_editor: me.is_editor },
      members: members.data, series: series.data, comments: comments.data, votes: votes.data, history: history.data, items: items.data,
    });
  }

  // Address lookup for the new-venue form: matched address, municipality, a name guess.
  if (body.action === "lookup") {
    const address = String(body.address ?? "").trim().slice(0, 300);
    if (address.length < 6) return reply({ ok: false, error: "Enter a full street address with city and state." }, 400);
    try {
      const c = await censusLookup(address);
      if (!c) return reply({ ok: false, error: "The Census geocoder couldn't match that address. Check the street, city and ZIP." }, 404);
      let name: string | null = null;
      try {
        const o = await overpass(`[out:json][timeout:15];nwr[name][~"^(amenity|shop|leisure|club)$"~"."](around:25,${c.lat},${c.lon});out center tags;`);
        name = (o.elements ?? [])[0]?.tags?.name ?? null;
      } catch { /* name is optional */ }
      return reply({ ok: true, matched: c.matched, municipality: c.municipality, is_chicago: c.is_chicago, county: c.county, name });
    } catch (e) {
      console.error("rti-board-budget: lookup", String(e));
      return reply({ ok: false, error: "The address service didn't answer. Try again in a minute." }, 502);
    }
  }

  // Area analysis for a venue: stored on the series so every director sees it.
  if (body.action === "area") {
    const s = await seriesExists(String(body.series_id ?? ""));
    if (!s) return reply({ ok: false, error: "Unknown venue." }, 400);
    const { data: a } = await supabase.from("rti_bb_items").select("note").eq("series_id", s.id).eq("key", "meta.address").maybeSingle();
    const address = String(a?.note ?? "").trim();
    if (!address) return reply({ ok: false, error: "Enter the venue's full street address on the Overview tab first." }, 400);
    try {
      const r = await areaAnalysis(address);
      if (!r.ok) return reply(r, 404);
      await supabase.from("rti_bb_series").update({ area: r.area, area_at: new Date().toISOString() }).eq("id", s.id);
      await supabase.from("rti_bb_history").insert({ series_id: s.id, member_id: me.id, kind: "area", item_key: null, before: null, after: { address: r.area!.matched, nearest_home_m: r.area!.homes.nearest_m, homes_250: r.area!.homes.within_250, parking: r.area!.parking.length } });
      return reply({ ok: true });
    } catch (e) {
      console.error("rti-board-budget: area", String(e));
      return reply({ ok: false, error: "The map data service is busy. Try again in a minute." }, 502);
    }
  }

  // One checklist finding, venue-record field or decision field. Logged.
  if (body.action === "set") {
    const s = await seriesExists(String(body.series_id ?? ""));
    const key = String(body.key ?? "");
    if (!s || !/^([A-I][0-9]{1,2}|meta\.[a-z_]{1,30}|decision\.[a-z_]{1,30})$/.test(key)) return reply({ ok: false, error: "Unknown item." }, 400);
    const status = key.includes(".") ? "" : String(body.status ?? "");
    if (!["", "pass", "issue", "fail", "na"].includes(status)) return reply({ ok: false, error: "Unknown finding." }, 400);
    const note = String(body.note ?? "").slice(0, 4000);
    const { data: prev } = await supabase.from("rti_bb_items").select("status, note").eq("series_id", s.id).eq("key", key).maybeSingle();
    if (prev && prev.status === status && prev.note === note) return reply({ ok: true, unchanged: true });
    const { error } = await supabase.from("rti_bb_items").upsert({ series_id: s.id, key, status, note, member_id: me.id, updated_at: new Date().toISOString() });
    if (error) return reply({ ok: false, error: "Couldn't save that. Try again." }, 500);
    await supabase.from("rti_bb_history").insert({ series_id: s.id, member_id: me.id, kind: "item", item_key: key, before: prev ?? null, after: { status, note } });
    return reply({ ok: true });
  }

  if (body.action === "comment") {
    const text = String(body.body ?? "").trim().slice(0, 4000);
    const s = await seriesExists(String(body.series_id ?? ""));
    if (!s || !text) return reply({ ok: false, error: "Write something first." }, 400);
    const { error } = await supabase.from("rti_bb_comments").insert({ series_id: s.id, member_id: me.id, body: text });
    if (error) return reply({ ok: false, error: "Couldn't post that. Try again." }, 500);
    // Let the rest of the board know (no link in the email: they use their bookmarked one).
    const { data: others } = await supabase.from("rti_bb_members").select("full_name, email").neq("id", me.id);
    const preview = text.length > 600 ? text.slice(0, 600) + "…" : text;
    await Promise.all((others ?? []).map((o: any) => sendEmail(
      o.email,
      `Board room: ${me.full_name} commented on ${s.title}`,
      `Hello ${firstName(o.full_name)},\n\n${me.full_name} (${me.title}) wrote on ${s.title}:\n\n${preview}\n\nRead and reply: ${PAGE_URL}\n(If the page asks, enter your email and a fresh link arrives.)\n`,
      `<p>Hello ${esc(firstName(o.full_name))},</p><p><b>${esc(me.full_name)}</b> (${esc(me.title)}) wrote on <b>${esc(s.title)}</b>:</p><blockquote style="border-left:3px solid #1f5b3a;margin:0;padding:6px 12px;color:#333;white-space:pre-wrap">${esc(preview)}</blockquote><p><a href="${PAGE_URL}">Read and reply in the budget room</a>. If the page asks, enter your email and a fresh link arrives.</p>`,
    )));
    return reply({ ok: true });
  }

  if (body.action === "vote") {
    const vote = String(body.vote ?? "");
    const s = await seriesExists(String(body.series_id ?? ""));
    if (!s || !VOTES.includes(vote)) return reply({ ok: false, error: "Choose approve, reject or abstain." }, 400);
    const { error } = await supabase.from("rti_bb_votes").upsert({ series_id: s.id, member_id: me.id, vote, note: String(body.note ?? "").trim().slice(0, 1000), updated_at: new Date().toISOString() });
    if (error) return reply({ ok: false, error: "Couldn't record your vote. Try again." }, 500);
    return reply({ ok: true });
  }

  if (body.action === "save") {
    const x = body.series ?? {};
    const id = String(x.id ?? "").trim().toLowerCase();
    if (!/^[a-z0-9][a-z0-9-]{1,59}$/.test(id)) return reply({ ok: false, error: "The series needs a short id (letters, numbers, dashes)." }, 400);
    const title = String(x.title ?? "").trim().slice(0, 140);
    if (!title) return reply({ ok: false, error: "The series needs a title." }, 400);
    const fridays = Math.round(Number(x.fridays_per_year));
    const row = {
      id, title,
      venue: String(x.venue ?? "").trim().slice(0, 200),
      status: STATUSES.includes(x.status) ? x.status : "discussion",
      fridays_per_year: fridays >= 1 && fridays <= 53 ? fridays : 52,
      budget: { income: cleanLines(x.budget?.income), expense: cleanLines(x.budget?.expense), one_time: cleanLines(x.budget?.one_time) },
      notes: String(x.notes ?? "").slice(0, 8000),
      updated_at: new Date().toISOString(),
      updated_by: me.id,
    };
    const { data: cur } = await supabase.from("rti_bb_series").select("title, venue, status, fridays_per_year, budget, notes, updated_at, updated_by").eq("id", id).maybeSingle();
    if (cur && body.new_series) return reply({ ok: false, error: "A series with that short id already exists. Pick another id." }, 409);
    if (cur && body.base_updated_at && new Date(cur.updated_at).getTime() !== new Date(String(body.base_updated_at)).getTime()) {
      const { data: who } = await supabase.from("rti_bb_members").select("full_name").eq("id", cur.updated_by).maybeSingle();
      return reply({ ok: false, conflict: true, error: `${who?.full_name ?? "Another director"} saved changes to this budget while you were editing, so yours were not saved. Note your changes, press Cancel to see the new numbers, then edit again.` }, 409);
    }
    const before = cur ? { title: cur.title, venue: cur.venue, status: cur.status, fridays_per_year: cur.fridays_per_year, budget: cur.budget, notes: cur.notes } : null;
    const { error } = await supabase.from("rti_bb_series").upsert(row);
    if (error) return reply({ ok: false, error: "Couldn't save. Try again." }, 500);
    const { id: _i, updated_at: _u, updated_by: _b, ...after } = row;
    await supabase.from("rti_bb_history").insert({ series_id: id, member_id: me.id, before: before ?? null, after });
    return reply({ ok: true });
  }

  return reply({ ok: false, error: "Unknown action." }, 400);
});
