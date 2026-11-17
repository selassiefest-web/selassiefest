// Builds the self-contained "Thank you" page that goes to a donor (one .html file, PDFs and photos embedded).
// Used by index.html in the browser and by test-build.js in node. Nothing is sent anywhere.
//
// d = {
//   donor: "Shure Incorporated", contact: "Cheryl Jennison Daproza", requestNo: "CQ-1076",
//   items: [{ name, qty, unit, desc }],            // unit: "pairs", "microphones", ...
//   useLine: "the 12 student stations ...",        // after "will be used for"
//   next: [{ h, p }],                              // "What's next" steps
//   tracking: "multi-line text" | "",
//   docs: [{ title, desc, fileName, dataUri }],    // PDFs
//   photos: [{ caption, fileName, dataUri }],
//   org: { name, ein, addr, status, signer, title, phone, email }
// }
function buildDonorPage(d) {
  const esc = (s) => String(s == null ? "" : s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
  const o = d.org;
  const first = (d.contact || "").trim().split(/\s+/)[0] || "";
  const donorShort = (d.donor || "").replace(/\s+(incorporated|inc\.?|llc|corp\.?|corporation|company|co\.?)$/i, "");
  const list = d.items.map((i) => i.qty + " " + i.name).join(" and ");
  const hero = d.photos[0] ? d.photos[0].dataUri : "";

  const itemsHtml = d.items.map((i) => `
      <article class="item">
        <div class="qty">${esc(i.qty)}<small>${esc(i.unit || "")}</small></div>
        <h3>${esc(i.name)}</h3>
        ${i.desc ? `<p>${esc(i.desc)}</p>` : ""}
        <span class="tick">Received in good working order</span>
      </article>`).join("");

  const docsHtml = d.docs.map((x, n) => `
      <article class="doc">
        <span class="num">0${n + 1}</span>
        <h3>${esc(x.title)}</h3>
        <p>${esc(x.desc)}</p>
        <div class="row">
          <a class="btn solid" href="${x.dataUri}" download="${esc(x.fileName)}">Download PDF</a>
          <a class="btn ghost" href="${x.dataUri}" target="_blank" rel="noopener">View</a>
        </div>
      </article>`).join("");

  const copy = (v) => `<button class="copy" data-copy="${esc(v)}">Copy</button>`;
  const facts = [
    ["Request", d.requestNo, false],
    ["Recipient", o.name, true],
    ["EIN", o.ein, true],
    ["Address", o.addr, true],
    ["Status", o.status, false],
    ["Signatory", o.signer + ", " + o.title, false],
    ["Contact", o.phone + " · " + o.email, false],
  ].filter((f) => f[1]).map((f) => `<dt>${f[0]}</dt><dd>${esc(f[1])}${f[2] ? " " + copy(f[1]) : ""}</dd>`).join("");

  const photosHtml = d.photos.map((p, n) => `
      <figure${n === 0 && d.photos.length > 2 ? ' class="wide"' : ""}>
        <button class="open" data-src="${p.dataUri}" data-cap="${esc(p.caption)}"><img src="${p.dataUri}" alt="${esc(p.caption || "Donated equipment as it arrived")}" loading="lazy"></button>
        <figcaption><span>${esc(p.caption)}</span><a href="${p.dataUri}" download="${esc(p.fileName)}">Download</a></figcaption>
      </figure>`).join("");

  const nextHtml = d.next.map((s) => `<li><h3>${esc(s.h)}</h3><p>${esc(s.p)}</p></li>`).join("");
  const trackHtml = d.tracking && d.tracking.trim()
    ? `<p class="ship"><strong>Shipment record.</strong> ${esc(d.tracking.trim()).replace(/\n/g, "<br>")}</p>` : "";
  const title = "Thank You, " + donorShort + " | " + o.name;

  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="noindex, nofollow">
<title>${esc(title)}</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,500;1,9..144,500&family=Inter:wght@400;500;600;700&display=swap">
<style>
:root{color-scheme:dark;--ink:#0f120c;--panel:#1b2115;--line:#38422d;--paper:#f6f5ea;--muted:#bcc4ae;--lime:#d6f465;
--sheet:#f1f3e6;--sheet-ink:#18200f;--sheet-line:#cfd7bf;--sheet-muted:#4b5a38;--green:#2f4a10;
--rd-red:#D2292D;--rd-gold:#EDBB2E;--rd-blue:#2F6AC0;--serif:"Fraunces",Georgia,serif;--sans:"Inter",system-ui,-apple-system,"Segoe UI",Arial,sans-serif}
*{box-sizing:border-box}html{scroll-behavior:smooth;scroll-padding-top:4.5rem}
body{margin:0;background:var(--ink);color:var(--paper);font:400 1rem/1.7 var(--sans);-webkit-font-smoothing:antialiased}
h1,h2,h3,p,figure,ul,ol,dl,dd{margin:0}img{max-width:100%;display:block}a{color:var(--lime)}
.wrap{width:min(1100px,calc(100% - 2.5rem));margin-inline:auto}
.eyebrow{font-size:.74rem;font-weight:700;letter-spacing:.16em;text-transform:uppercase;color:var(--lime)}
.sheet .eyebrow{color:#42631a}.sheet{background:var(--sheet);color:var(--sheet-ink);color-scheme:light}
h2{font:500 clamp(2rem,4.4vw,3.1rem)/1.1 var(--serif);letter-spacing:-.02em;margin:.5rem 0 .9rem}
h3{font:700 1.05rem/1.3 var(--sans);margin-bottom:.3rem}
.lede{font-size:clamp(1.05rem,1.8vw,1.25rem);max-width:60ch}.muted{color:var(--muted)}.sheet .muted{color:var(--sheet-muted)}
.section{padding-block:clamp(3rem,7vw,5rem)}
.tri{height:6px;background:linear-gradient(90deg,var(--rd-red) 0 33.3%,var(--rd-gold) 0 66.6%,var(--rd-blue) 0)}
.nav{position:sticky;top:0;z-index:20;background:rgba(15,18,12,.93);backdrop-filter:blur(10px);border-bottom:1px solid var(--line)}
.nav .wrap{display:flex;align-items:center;justify-content:space-between;gap:1rem;min-height:3.3rem}
.nav b{white-space:nowrap}.nav ul{list-style:none;padding:0;display:flex;gap:.2rem;overflow-x:auto;scrollbar-width:none}
.nav a{display:block;padding:.45rem .8rem;border-radius:99px;color:var(--muted);text-decoration:none;font-size:.88rem;font-weight:600;white-space:nowrap}
.nav a:hover,.nav a:focus-visible{background:var(--panel);color:var(--paper)}
.hero{position:relative;overflow:hidden;isolation:isolate;padding-block:clamp(4rem,11vw,8rem)}
.hero::before{content:"";position:absolute;inset:0;z-index:-2;background:url("${hero}") center 30%/cover no-repeat;opacity:.4}
.hero::after{content:"";position:absolute;inset:0;z-index:-1;background:linear-gradient(90deg,var(--ink) 8%,rgba(15,18,12,.86) 48%,rgba(15,18,12,.35)),linear-gradient(0deg,var(--ink),transparent 38%)}
h1{font:500 clamp(3.4rem,10.5vw,8rem)/.92 var(--serif);letter-spacing:-.035em;margin:.7rem 0 1.4rem}h1 em{color:var(--lime)}
.to{font:italic 500 clamp(1.1rem,2.3vw,1.5rem)/1.4 var(--serif);margin-bottom:1rem}
.cta{display:flex;flex-wrap:wrap;gap:.75rem;margin-top:1.8rem}
.btn{display:inline-flex;align-items:center;padding:.8rem 1.25rem;border-radius:.7rem;font:700 .95rem/1.2 var(--sans);text-decoration:none;border:1.5px solid var(--lime);cursor:pointer}
.btn.solid{background:var(--lime);color:#11160a}.btn.ghost{background:transparent;color:var(--lime)}
.btn:hover,.btn:focus-visible{filter:brightness(1.1)}
.sheet .btn.solid{background:var(--green);border-color:var(--green);color:#f1f6d8}.sheet .btn.ghost{color:var(--green);border-color:#5d8a1c}
.items,.records{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:1.1rem;margin-top:1.6rem}
.item{background:#fff;border:1px solid var(--sheet-line);border-radius:1rem;padding:1.5rem}
.item .qty{font:500 3rem/1 var(--serif);color:#385717}.item .qty small{font:600 .95rem var(--sans);color:var(--sheet-muted);margin-left:.4rem}
.item h3{margin-top:.6rem;font-size:1.2rem}.item p{color:#3f4a2f}
.tick{display:inline-flex;gap:.45rem;align-items:center;margin-top:.9rem;font-size:.88rem;font-weight:600;color:#2f5a0e}
.tick::before{content:"✓";display:inline-grid;place-items:center;width:1.3rem;height:1.3rem;border-radius:50%;background:#2f5a0e;color:#fff;font-size:.78rem}
.assure{margin-top:1.4rem;font-weight:600}
.doc{display:flex;flex-direction:column;background:var(--panel);border:1px solid var(--line);border-radius:1rem;padding:1.5rem}
.doc .num{font:500 .9rem var(--serif);color:var(--lime);letter-spacing:.1em}.doc h3{margin-top:.4rem;font-size:1.12rem}
.doc p{color:var(--muted);font-size:.95rem;flex:1;margin-bottom:1.1rem}.doc .row{display:flex;gap:.6rem;flex-wrap:wrap}.doc .btn{padding:.6rem .95rem;font-size:.88rem}
.facts{display:grid;grid-template-columns:9rem 1fr;margin-top:2rem;max-width:820px}
.facts dt,.facts dd{padding:.7rem 0;border-top:1px solid var(--line)}
.facts dt{font-size:.78rem;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:var(--muted)}.facts dd{font-weight:500;word-break:break-word}
.copy{margin-left:.5rem;border:1px solid var(--line);background:var(--panel);border-radius:.4rem;font:600 .72rem var(--sans);padding:.1rem .45rem;cursor:pointer;color:var(--lime)}
.ship{margin-top:1.4rem;padding:1rem 1.2rem;border-left:4px solid var(--lime);background:var(--panel);border-radius:.2rem .6rem .6rem .2rem;font-size:.93rem;max-width:820px}
.gallery{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:.9rem;margin-top:1.6rem}
.gallery figure{overflow:hidden;border-radius:1rem;border:1px solid var(--line);background:var(--panel)}.gallery .wide{grid-column:span 2}
.gallery button.open{all:unset;display:block;width:100%;cursor:zoom-in}
.gallery img{width:100%;height:clamp(220px,26vw,320px);object-fit:cover;object-position:center 30%}
.gallery figcaption{display:flex;justify-content:space-between;gap:.8rem;padding:.75rem 1rem;font-size:.9rem;color:var(--muted)}
.gallery figcaption a{font-weight:700;font-size:.82rem;text-decoration:none}
dialog{border:0;padding:0;background:transparent;max-width:min(94vw,1000px);width:100%;color:var(--paper)}dialog::backdrop{background:rgba(5,7,3,.88)}
dialog img{max-height:82vh;width:auto;margin-inline:auto;border-radius:.6rem}
dialog form{display:flex;justify-content:space-between;align-items:center;gap:1rem;padding:.8rem .2rem}
dialog button{font:700 .9rem var(--sans);padding:.55rem 1rem;border-radius:.6rem;border:0;background:var(--lime);color:#11160a;cursor:pointer}
.steps{list-style:none;padding:0;margin:1.8rem 0 0;display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:1.1rem;counter-reset:s}
.steps li{counter-increment:s;color:var(--sheet-ink);background:#fff;border:1px solid var(--sheet-line);border-radius:1rem;padding:1.3rem}
.steps li::before{content:counter(s);display:grid;place-items:center;width:2rem;height:2rem;border-radius:50%;background:var(--green);color:#f1f6d8;font-weight:700;margin-bottom:.7rem}
.steps p{font-size:.94rem;color:#3f4a2f}
.close .body{max-width:62ch}.close .body p+p{margin-top:1rem}
.close .lede{font:italic 500 clamp(1.25rem,2.5vw,1.7rem)/1.4 var(--serif)}
.ask{margin-top:2.2rem;max-width:640px;padding:1.4rem;border:1px solid var(--line);border-radius:1rem;background:var(--panel)}.ask h3{font:500 1.5rem var(--serif);margin-bottom:.3rem}.ask p{color:var(--muted);font-size:.95rem}.ask input,.ask textarea{width:100%;margin-top:.7rem;padding:.7rem .8rem;border-radius:.6rem;border:1px solid var(--line);background:var(--ink);color:var(--paper);font:inherit}.ask textarea{min-height:110px}.ask .btn{margin-top:.8rem}
.sign{margin-top:1.8rem;font:italic 500 1.6rem var(--serif);color:var(--lime)}.contact{margin-top:1.6rem;display:flex;flex-wrap:wrap;gap:.7rem}
footer{padding-block:1.4rem 2.2rem;border-top:1px solid var(--line);font-size:.86rem;color:var(--muted)}footer .wrap{display:flex;flex-wrap:wrap;justify-content:space-between;gap:.5rem 2rem}
@media(max-width:560px){.wrap{width:calc(100% - 2rem)}.nav b{display:none}.facts{grid-template-columns:1fr}.facts dt{border-bottom:0;padding-bottom:0}.facts dd{border-top:0;padding-top:.1rem}.gallery .wide{grid-column:span 1}}
@media(prefers-reduced-motion:reduce){html{scroll-behavior:auto}}
@media print{:root{color-scheme:light}body,.hero,.sheet,.doc,.item,.steps li,.ship{background:#fff!important;color:#111!important}
.nav,.cta,.btn,.copy,dialog,.gallery figcaption a{display:none!important}.hero::before,.hero::after{display:none}.hero,.section{padding-block:1.2rem}
h1{font-size:3.2rem}h1 em,.eyebrow,.sign,.item .qty,.doc .num{color:#2f4a10!important}.section,.item,.doc{break-inside:avoid}.gallery img{height:2in}}
</style>
</head>
<body>
<div class="tri" aria-hidden="true"></div>
<nav class="nav" aria-label="Page sections"><div class="wrap"><b>${esc(o.name)}</b>
<ul><li><a href="#arrived">What arrived</a></li><li><a href="#records">Your records</a></li>${d.photos.length ? '<li><a href="#photos">Photos</a></li>' : ""}<li><a href="#next">What's next</a></li><li><a href="#contact">Contact</a></li></ul></div></nav>

<header class="hero">
  <div class="wrap">
    <p class="eyebrow">With gratitude from ${esc(o.name)}</p>
    <h1>Thank you,<br><em>${esc(donorShort)}.</em></h1>
    <p class="to">To ${esc(d.contact)}, and to every person at ${esc(donorShort)} who had a hand in this.</p>
    <p class="lede">Everything arrived, and our whole team is grateful. The ${esc(list)} will be put to work for ${esc(d.useLine)}. Every record you need, and a few photos, are on this page to read, copy and download at any time.</p>
    <div class="cta"><a class="btn solid" href="#records">Open your records</a>${d.photos.length ? '<a class="btn ghost" href="#photos">See the photos</a>' : ""}</div>
  </div>
</header>

<section class="section sheet" id="arrived">
  <div class="wrap">
    <p class="eyebrow">Donation request ${esc(d.requestNo)}</p>
    <h2>What arrived</h2>
    <div class="items">${itemsHtml}
    </div>
    <p class="assure">No goods or services were received in exchange for this donation.</p>
  </div>
</section>

<section class="section" id="records">
  <div class="wrap">
    <p class="eyebrow">Your records</p>
    <h2>Ready to download</h2>
    <p class="lede muted">Each document is a PDF. No sign-in, nothing to request.</p>
    <div class="records">${docsHtml}
    </div>
    <dl class="facts">${facts}</dl>
    ${trackHtml}
  </div>
</section>
${d.photos.length ? `
<section class="section sheet" id="photos">
  <div class="wrap">
    <p class="eyebrow">Photos</p>
    <h2>As it arrived</h2>
    <p class="lede muted">Select a photo to enlarge it. Each has its own download link, and you are welcome to use them internally.</p>
    <div class="gallery">${photosHtml}
    </div>
  </div>
</section>` : ""}

<section class="section${d.photos.length ? "" : " sheet"}" id="next">
  <div class="wrap">
    <p class="eyebrow">What's next</p>
    <h2>What we promised</h2>
    <ol class="steps">${nextHtml}</ol>
  </div>
</section>

<section class="section close" id="contact" style="border-top:1px solid var(--line)">
  <div class="wrap">
    <div class="body">
      <p class="lede">${esc(first ? first + ", t" : "T")}hank you. You made this possible with kindness and care, and we will look after this gift, and the people it serves, the way it deserves.</p>
      <p>If you need anything more from us, now or later, write or call and we will answer the same day.</p>
    </div>
    <div class="ask" id="ask">
      <h3>Questions or concerns?</h3>
      <p>Write them here and your email app will open with the message ready to send to ${esc(o.signer)}. We will answer the same day.</p>
      <input id="qn" type="text" placeholder="Your name" autocomplete="name">
      <textarea id="qt" placeholder="Your question, concern, or anything you need us to correct or add"></textarea>
      <button class="btn solid" id="qb" type="button">Send to ${esc(first ? o.signer : o.signer)}</button>
    </div>
    <p class="sign">With gratitude, ${esc(o.signer)}</p>
    <p class="muted">${esc(o.title)}, ${esc(o.name)}</p>
    <div class="contact">
      <a class="btn solid" href="mailto:${esc(o.email)}?subject=${encodeURIComponent("Donation " + d.requestNo)}">${esc(o.email)}</a>
      <a class="btn ghost" href="tel:${esc(o.phone.replace(/[^\d+]/g, ""))}">${esc(o.phone)}</a>
    </div>
  </div>
</section>

<footer><div class="wrap"><span>${esc(o.name)} · ${esc(o.addr)} · EIN ${esc(o.ein)}</span><span>Prepared for ${esc(d.donor)} · ${esc(d.requestNo)}</span></div></footer>

<dialog id="lb" aria-label="Photo viewer"><img id="lbi" alt=""><form method="dialog"><span id="lbc"></span><button>Close</button></form></dialog>
<script>
(function(){var NL=String.fromCharCode(10),MAILTO=${JSON.stringify(o.email)},REQ=${JSON.stringify(d.requestNo)},donor=${JSON.stringify(d.donor)};var lb=document.getElementById('lb'),im=document.getElementById('lbi'),cp=document.getElementById('lbc');
document.querySelectorAll('button.open').forEach(function(b){b.addEventListener('click',function(){im.src=b.dataset.src;im.alt=b.querySelector('img').alt;cp.textContent=b.dataset.cap||'';if(lb.showModal)lb.showModal();});});
var qb=document.getElementById('qb');qb.addEventListener('click',function(){var t=document.getElementById('qt').value.trim(),n=document.getElementById('qn').value.trim();
if(!t){document.getElementById('qt').focus();return;}location.href='mailto:'+MAILTO+'?subject='+encodeURIComponent('Question about donation '+REQ)+'&body='+encodeURIComponent(t+NL+NL+(n?n+NL:'')+donor);});
lb.addEventListener('click',function(e){if(e.target===lb)lb.close();});
document.querySelectorAll('.copy').forEach(function(b){b.addEventListener('click',function(){var o=b.textContent;
if(navigator.clipboard&&navigator.clipboard.writeText){navigator.clipboard.writeText(b.dataset.copy).then(function(){b.textContent='Copied';setTimeout(function(){b.textContent=o},1400);},function(){});}});});})();
</script>
</body>
</html>
`;
}
if (typeof module !== "undefined") module.exports = { buildDonorPage };
