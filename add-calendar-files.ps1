# ======================================================================
# add-calendar-files.ps1  (v2)
#
# Adds the full /calendar/ directory (festivals, special-events, weekly)
# with all 2027 event pages to your local selassiefest repo folder.
#
# Run from inside the repo folder:
#   cd C:\Users\mkepr\Documents\GitHub\selassiefest
#   powershell -ExecutionPolicy Bypass -File ".\add-calendar-files.ps1"
#
# This script ONLY writes files to disk. It does NOT run git
# add/commit/push. Review with `git status` / GitHub Desktop after.
# ======================================================================

$ErrorActionPreference = "Stop"
$repo = Get-Location

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Adding SelassieFest 2027 Calendar" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

New-Item -ItemType Directory -Force -Path "$repo\calendar" | Out-Null
New-Item -ItemType Directory -Force -Path "$repo\calendar\festivals" | Out-Null
New-Item -ItemType Directory -Force -Path "$repo\calendar\special-events" | Out-Null
New-Item -ItemType Directory -Force -Path "$repo\calendar\weekly" | Out-Null

$fileCount = 0

Set-Content -LiteralPath "$repo\calendar\festivals\emancipation-day.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Emancipation Day | SelassieFest Calendar</title>
<meta name="description" content="Commemorating the abolition of slavery throughout the British Empire. A day of remembrance, drumming, and storytelling honoring the ancestors and the ">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/" class="active">Festivals</a>
      <a href="/calendar/special-events/">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Festival</span>
  <h1>Emancipation Day</h1>
  <div class="date-line">Sunday, August 1, 2027</div>
</div>
<div class="event-body">
  <p>Commemorating the abolition of slavery throughout the British Empire. A day of remembrance, drumming, and storytelling honoring the ancestors and the long road to freedom.</p>
  <a href="/calendar/festivals/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Festival</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\festivals\emancipation-day.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\festivals\haile-selassie-birthday.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Haile Selassie I's Birthday | SelassieFest Calendar</title>
<meta name="description" content="Honoring the birth of His Imperial Majesty Haile Selassie I, marked with Nyabinghi drumming, reasoning sessions, and reflection — one of the most sacr">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/" class="active">Festivals</a>
      <a href="/calendar/special-events/">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Festival</span>
  <h1>Haile Selassie I's Birthday</h1>
  <div class="date-line">Friday, July 23, 2027</div>
</div>
<div class="event-body">
  <p>Honoring the birth of His Imperial Majesty Haile Selassie I, marked with Nyabinghi drumming, reasoning sessions, and reflection — one of the most sacred observances on the Rastafari calendar.</p>
  <a href="/calendar/festivals/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Festival</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\festivals\haile-selassie-birthday.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\festivals\independence-day.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Independence Day | SelassieFest Calendar</title>
<meta name="description" content="Celebrating Jamaica's independence from British rule in 1962 — flags, music, food, and community pride, often celebrated together with Emancipation Da">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/" class="active">Festivals</a>
      <a href="/calendar/special-events/">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Festival</span>
  <h1>Independence Day</h1>
  <div class="date-line">Friday, August 6, 2027</div>
</div>
<div class="event-body">
  <p>Celebrating Jamaica's independence from British rule in 1962 — flags, music, food, and community pride, often celebrated together with Emancipation Day as 'Emancipendence.'</p>
  <a href="/calendar/festivals/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Festival</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\festivals\independence-day.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\festivals\index.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>2027 Festivals | SelassieFest Calendar</title>
<meta name="description" content="2027 Festivals">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/" class="active">Festivals</a>
      <a href="/calendar/special-events/">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="hub-hero">
  <h1>2027 Festivals</h1>
  <p>Part of the SelassieFest annual calendar, organized by Ras Tafari Inc.</p>
</div>
<div class="container">
  <div class="event-grid">
  <div class="event-card">
    <span class="event-date-badge">Thursday, July 1, 2027</span>
    <h3>International Reggae Day</h3>
    <p>A global celebration of reggae music's roots, culture, and enduring influence, born in Jamaica in 1994. SelassieFest honors the genre that carried Rastafari's message of unity and resistance around the world.</p>
    <a href="/calendar/festivals/international-reggae-day.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Friday, July 23, 2027</span>
    <h3>Haile Selassie I's Birthday</h3>
    <p>Honoring the birth of His Imperial Majesty Haile Selassie I, marked with Nyabinghi drumming, reasoning sessions, and reflection — one of the most sacred observances on the Rastafari calendar.</p>
    <a href="/calendar/festivals/haile-selassie-birthday.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Sunday, August 1, 2027</span>
    <h3>Emancipation Day</h3>
    <p>Commemorating the abolition of slavery throughout the British Empire. A day of remembrance, drumming, and storytelling honoring the ancestors and the long road to freedom.</p>
    <a href="/calendar/festivals/emancipation-day.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Friday, August 6, 2027</span>
    <h3>Independence Day</h3>
    <p>Celebrating Jamaica's independence from British rule in 1962 — flags, music, food, and community pride, often celebrated together with Emancipation Day as 'Emancipendence.'</p>
    <a href="/calendar/festivals/independence-day.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Tuesday, August 17, 2027</span>
    <h3>Marcus Garvey's Birthday</h3>
    <p>Honoring Jamaica's National Hero and father of Pan-Africanism, whose vision of Black self-determination and unity shaped movements across the African diaspora.</p>
    <a href="/calendar/festivals/marcus-garvey-birthday.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  </div>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\festivals\index.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\festivals\international-reggae-day.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>International Reggae Day | SelassieFest Calendar</title>
<meta name="description" content="A global celebration of reggae music's roots, culture, and enduring influence, born in Jamaica in 1994. SelassieFest honors the genre that carried Ras">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/" class="active">Festivals</a>
      <a href="/calendar/special-events/">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Festival</span>
  <h1>International Reggae Day</h1>
  <div class="date-line">Thursday, July 1, 2027</div>
</div>
<div class="event-body">
  <p>A global celebration of reggae music's roots, culture, and enduring influence, born in Jamaica in 1994. SelassieFest honors the genre that carried Rastafari's message of unity and resistance around the world.</p>
  <a href="/calendar/festivals/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Festival</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\festivals\international-reggae-day.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\festivals\marcus-garvey-birthday.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Marcus Garvey's Birthday | SelassieFest Calendar</title>
<meta name="description" content="Honoring Jamaica's National Hero and father of Pan-Africanism, whose vision of Black self-determination and unity shaped movements across the African ">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/" class="active">Festivals</a>
      <a href="/calendar/special-events/">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Festival</span>
  <h1>Marcus Garvey's Birthday</h1>
  <div class="date-line">Tuesday, August 17, 2027</div>
</div>
<div class="event-body">
  <p>Honoring Jamaica's National Hero and father of Pan-Africanism, whose vision of Black self-determination and unity shaped movements across the African diaspora.</p>
  <a href="/calendar/festivals/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Festival</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\festivals\marcus-garvey-birthday.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\index.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>2027 Calendar | SelassieFest Calendar</title>
<meta name="description" content="SelassieFest 2027 full-year event calendar">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/" class="active">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="hub-hero">
  <h1>SelassieFest 2027 Calendar</h1>
  <p>A full year of programming from Ras Tafari Inc — flagship summer festivals, annual cultural observances, and weekly recurring community events.</p>
  <div class="category-grid">
    <div class="category-card">
      <i class="fas fa-sun"></i>
      <h2>Festivals</h2>
      <p>Summer (June–August) flagship celebrations, including SelassieFest, Emancipendence, and more. 5 events.</p>
      <a href="/calendar/festivals/" class="btn">View Festivals</a>
    </div>
    <div class="category-card">
      <i class="fas fa-star"></i>
      <h2>Annual Special Events</h2>
      <p>Cultural, spiritual, and commemorative observances held outside the summer season. 17 events.</p>
      <a href="/calendar/special-events/" class="btn">View Special Events</a>
    </div>
    <div class="category-card">
      <i class="fas fa-sync-alt"></i>
      <h2>Weekly Events</h2>
      <p>Recurring weekly programming, every day of the week, year-round. 7 events.</p>
      <a href="/calendar/weekly/" class="btn">View Weekly Events</a>
    </div>
  </div>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\index.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\special-events\accompong-maroon-festival.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Accompong Maroon Festival | SelassieFest Calendar</title>
<meta name="description" content="Honoring the historic 1739 peace treaty between the Leeward Maroons and the British, this day celebrates Maroon heritage, resistance, and self-governa">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/" class="active">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Special Event</span>
  <h1>Accompong Maroon Festival</h1>
  <div class="date-line">Wednesday, January 6, 2027</div>
</div>
<div class="event-body">
  <p>Honoring the historic 1739 peace treaty between the Leeward Maroons and the British, this day celebrates Maroon heritage, resistance, and self-governance.</p>
  <a href="/calendar/special-events/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Special Event</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\special-events\accompong-maroon-festival.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\special-events\ash-wednesday.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Ash Wednesday | SelassieFest Calendar</title>
<meta name="description" content="The start of the Lenten season, marked by reflection and repentance across Jamaica's Christian communities.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/" class="active">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Special Event</span>
  <h1>Ash Wednesday</h1>
  <div class="date-line">Wednesday, February 10, 2027</div>
</div>
<div class="event-body">
  <p>The start of the Lenten season, marked by reflection and repentance across Jamaica's Christian communities.</p>
  <a href="/calendar/special-events/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Special Event</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\special-events\ash-wednesday.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\special-events\black-friday.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Black Friday | SelassieFest Calendar</title>
<meta name="description" content="A community shopping day spotlighting Caribbean- and Rastafari-owned vendors and small businesses, held the day after Thanksgiving.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/" class="active">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Special Event</span>
  <h1>Black Friday</h1>
  <div class="date-line">Friday, November 26, 2027</div>
</div>
<div class="event-body">
  <p>A community shopping day spotlighting Caribbean- and Rastafari-owned vendors and small businesses, held the day after Thanksgiving.</p>
  <a href="/calendar/special-events/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Special Event</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\special-events\black-friday.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\special-events\bob-marley-birthday.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Bob Marley's Birthday | SelassieFest Calendar</title>
<meta name="description" content="Honoring the life and legacy of reggae's most iconic voice, whose music carried messages of unity, resistance, and Rastafari faith around the world.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/" class="active">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Special Event</span>
  <h1>Bob Marley's Birthday</h1>
  <div class="date-line">Saturday, February 6, 2027</div>
</div>
<div class="event-body">
  <p>Honoring the life and legacy of reggae's most iconic voice, whose music carried messages of unity, resistance, and Rastafari faith around the world.</p>
  <a href="/calendar/special-events/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Special Event</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\special-events\bob-marley-birthday.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\special-events\christmas-day.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Christmas Day | SelassieFest Calendar</title>
<meta name="description" content="Celebrated with traditional Jamaican dishes like sorrel, fruit cake, and gungo peas, and time spent with family and community.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/" class="active">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Special Event</span>
  <h1>Christmas Day</h1>
  <div class="date-line">Saturday, December 25, 2027</div>
</div>
<div class="event-body">
  <p>Celebrated with traditional Jamaican dishes like sorrel, fruit cake, and gungo peas, and time spent with family and community.</p>
  <a href="/calendar/special-events/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Special Event</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\special-events\christmas-day.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\special-events\christmas-eve.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Christmas Eve Celebration | SelassieFest Calendar</title>
<meta name="description" content="A warm community gathering on the eve of Christmas, filled with music, food, and fellowship.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/" class="active">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Special Event</span>
  <h1>Christmas Eve Celebration</h1>
  <div class="date-line">Friday, December 24, 2027</div>
</div>
<div class="event-body">
  <p>A warm community gathering on the eve of Christmas, filled with music, food, and fellowship.</p>
  <a href="/calendar/special-events/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Special Event</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\special-events\christmas-eve.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\special-events\easter-monday.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Easter Monday | SelassieFest Calendar</title>
<meta name="description" content="A traditional Jamaican day of family gatherings, kite-flying, and outdoor celebration.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/" class="active">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Special Event</span>
  <h1>Easter Monday</h1>
  <div class="date-line">Monday, March 29, 2027</div>
</div>
<div class="event-body">
  <p>A traditional Jamaican day of family gatherings, kite-flying, and outdoor celebration.</p>
  <a href="/calendar/special-events/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Special Event</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\special-events\easter-monday.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\special-events\ethiopian-christmas.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Ethiopian Christmas (Ganna) | SelassieFest Calendar</title>
<meta name="description" content="Celebrated according to the Ethiopian Orthodox calendar, Ganna honors the birth of Christ with a liturgical tradition central to Rastafari spiritualit">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/" class="active">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Special Event</span>
  <h1>Ethiopian Christmas (Ganna)</h1>
  <div class="date-line">Thursday, January 7, 2027</div>
</div>
<div class="event-body">
  <p>Celebrated according to the Ethiopian Orthodox calendar, Ganna honors the birth of Christ with a liturgical tradition central to Rastafari spirituality.</p>
  <a href="/calendar/special-events/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Special Event</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\special-events\ethiopian-christmas.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\special-events\ethiopian-new-year.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Ethiopian New Year (Enkutatash) | SelassieFest Calendar</title>
<meta name="description" content="Marking the new year according to the Ethiopian calendar — a date of spiritual renewal significant to the Rastafari faith.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/" class="active">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Special Event</span>
  <h1>Ethiopian New Year (Enkutatash)</h1>
  <div class="date-line">Saturday, September 11, 2027</div>
</div>
<div class="event-body">
  <p>Marking the new year according to the Ethiopian calendar — a date of spiritual renewal significant to the Rastafari faith.</p>
  <a href="/calendar/special-events/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Special Event</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\special-events\ethiopian-new-year.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\special-events\good-friday.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Good Friday | SelassieFest Calendar</title>
<meta name="description" content="A solemn day of remembrance observed throughout Jamaica and the wider Caribbean.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/" class="active">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Special Event</span>
  <h1>Good Friday</h1>
  <div class="date-line">Friday, March 26, 2027</div>
</div>
<div class="event-body">
  <p>A solemn day of remembrance observed throughout Jamaica and the wider Caribbean.</p>
  <a href="/calendar/special-events/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Special Event</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\special-events\good-friday.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\special-events\groundation-day.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Groundation Day | SelassieFest Calendar</title>
<meta name="description" content="Commemorating His Imperial Majesty Haile Selassie I's historic 1966 visit to Jamaica — one of the most sacred dates on the Rastafari calendar, marked ">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/" class="active">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Special Event</span>
  <h1>Groundation Day</h1>
  <div class="date-line">Wednesday, April 21, 2027</div>
</div>
<div class="event-body">
  <p>Commemorating His Imperial Majesty Haile Selassie I's historic 1966 visit to Jamaica — one of the most sacred dates on the Rastafari calendar, marked by Nyabinghi gatherings.</p>
  <a href="/calendar/special-events/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Special Event</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\special-events\groundation-day.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\special-events\index.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>2027 Annual Special Events | SelassieFest Calendar</title>
<meta name="description" content="2027 Annual Special Events">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/" class="active">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="hub-hero">
  <h1>2027 Annual Special Events</h1>
  <p>Part of the SelassieFest annual calendar, organized by Ras Tafari Inc.</p>
</div>
<div class="container">
  <div class="event-grid">
  <div class="event-card">
    <span class="event-date-badge">Friday, January 1, 2027</span>
    <h3>New Year's Day</h3>
    <p>A day of reflection and fresh starts, marking the turn of the calendar year for the SelassieFest community.</p>
    <a href="/calendar/special-events/new-years-day.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Wednesday, January 6, 2027</span>
    <h3>Accompong Maroon Festival</h3>
    <p>Honoring the historic 1739 peace treaty between the Leeward Maroons and the British, this day celebrates Maroon heritage, resistance, and self-governance.</p>
    <a href="/calendar/special-events/accompong-maroon-festival.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Thursday, January 7, 2027</span>
    <h3>Ethiopian Christmas (Ganna)</h3>
    <p>Celebrated according to the Ethiopian Orthodox calendar, Ganna honors the birth of Christ with a liturgical tradition central to Rastafari spirituality.</p>
    <a href="/calendar/special-events/ethiopian-christmas.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Saturday, February 6, 2027</span>
    <h3>Bob Marley's Birthday</h3>
    <p>Honoring the life and legacy of reggae's most iconic voice, whose music carried messages of unity, resistance, and Rastafari faith around the world.</p>
    <a href="/calendar/special-events/bob-marley-birthday.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Wednesday, February 10, 2027</span>
    <h3>Ash Wednesday</h3>
    <p>The start of the Lenten season, marked by reflection and repentance across Jamaica's Christian communities.</p>
    <a href="/calendar/special-events/ash-wednesday.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Friday, March 26, 2027</span>
    <h3>Good Friday</h3>
    <p>A solemn day of remembrance observed throughout Jamaica and the wider Caribbean.</p>
    <a href="/calendar/special-events/good-friday.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Monday, March 29, 2027</span>
    <h3>Easter Monday</h3>
    <p>A traditional Jamaican day of family gatherings, kite-flying, and outdoor celebration.</p>
    <a href="/calendar/special-events/easter-monday.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Wednesday, April 21, 2027</span>
    <h3>Groundation Day</h3>
    <p>Commemorating His Imperial Majesty Haile Selassie I's historic 1966 visit to Jamaica — one of the most sacred dates on the Rastafari calendar, marked by Nyabinghi gatherings.</p>
    <a href="/calendar/special-events/groundation-day.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Sunday, May 23, 2027</span>
    <h3>Labour Day</h3>
    <p>Jamaica's national day of community service and volunteerism, when citizens come together to improve their neighborhoods.</p>
    <a href="/calendar/special-events/labour-day.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Tuesday, September 7, 2027</span>
    <h3>Miss Lou's Birthday</h3>
    <p>Honoring Louise Bennett-Coverley, Jamaica's beloved folklorist and poet who championed Jamaican Patois as a language of pride and identity.</p>
    <a href="/calendar/special-events/miss-lou-birthday.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Saturday, September 11, 2027</span>
    <h3>Ethiopian New Year (Enkutatash)</h3>
    <p>Marking the new year according to the Ethiopian calendar — a date of spiritual renewal significant to the Rastafari faith.</p>
    <a href="/calendar/special-events/ethiopian-new-year.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Monday, October 18, 2027</span>
    <h3>National Heroes Day</h3>
    <p>Honoring Jamaica's seven National Heroes, including Marcus Garvey and Nanny of the Maroons, who shaped the nation's fight for freedom and justice.</p>
    <a href="/calendar/special-events/national-heroes-day.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Wednesday, November 24, 2027</span>
    <h3>Irie Disguise: The Blackout Masquerade</h3>
    <p>A festive costume masquerade on the eve of Thanksgiving, blending Jonkonnu-inspired disguise traditions with a modern night of music, dancing, and community — held the Wednesday before Thanksgiving, historically the biggest night out of the year.</p>
    <a href="/calendar/special-events/irie-disguise-blackout-masquerade.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Friday, November 26, 2027</span>
    <h3>Black Friday</h3>
    <p>A community shopping day spotlighting Caribbean- and Rastafari-owned vendors and small businesses, held the day after Thanksgiving.</p>
    <a href="/calendar/special-events/black-friday.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Friday, December 24, 2027</span>
    <h3>Christmas Eve Celebration</h3>
    <p>A warm community gathering on the eve of Christmas, filled with music, food, and fellowship.</p>
    <a href="/calendar/special-events/christmas-eve.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Saturday, December 25, 2027</span>
    <h3>Christmas Day</h3>
    <p>Celebrated with traditional Jamaican dishes like sorrel, fruit cake, and gungo peas, and time spent with family and community.</p>
    <a href="/calendar/special-events/christmas-day.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Sunday, December 26, 2027</span>
    <h3>Jonkonnu</h3>
    <p>A centuries-old Jamaican masquerade tradition featuring costumed characters like Pitchy Patchy and Horse Head, marking the start of the Christmas street-festival season on Boxing Day.</p>
    <a href="/calendar/special-events/jonkonnu.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  </div>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\special-events\index.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\special-events\irie-disguise-blackout-masquerade.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Irie Disguise: The Blackout Masquerade | SelassieFest Calendar</title>
<meta name="description" content="A festive costume masquerade on the eve of Thanksgiving, blending Jonkonnu-inspired disguise traditions with a modern night of music, dancing, and com">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/" class="active">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Special Event</span>
  <h1>Irie Disguise: The Blackout Masquerade</h1>
  <div class="date-line">Wednesday, November 24, 2027</div>
</div>
<div class="event-body">
  <p>A festive costume masquerade on the eve of Thanksgiving, blending Jonkonnu-inspired disguise traditions with a modern night of music, dancing, and community — held the Wednesday before Thanksgiving, historically the biggest night out of the year.</p>
  <a href="/calendar/special-events/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Special Event</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\special-events\irie-disguise-blackout-masquerade.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\special-events\jonkonnu.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Jonkonnu | SelassieFest Calendar</title>
<meta name="description" content="A centuries-old Jamaican masquerade tradition featuring costumed characters like Pitchy Patchy and Horse Head, marking the start of the Christmas stre">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/" class="active">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Special Event</span>
  <h1>Jonkonnu</h1>
  <div class="date-line">Sunday, December 26, 2027</div>
</div>
<div class="event-body">
  <p>A centuries-old Jamaican masquerade tradition featuring costumed characters like Pitchy Patchy and Horse Head, marking the start of the Christmas street-festival season on Boxing Day.</p>
  <a href="/calendar/special-events/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Special Event</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\special-events\jonkonnu.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\special-events\labour-day.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Labour Day | SelassieFest Calendar</title>
<meta name="description" content="Jamaica's national day of community service and volunteerism, when citizens come together to improve their neighborhoods.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/" class="active">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Special Event</span>
  <h1>Labour Day</h1>
  <div class="date-line">Sunday, May 23, 2027</div>
</div>
<div class="event-body">
  <p>Jamaica's national day of community service and volunteerism, when citizens come together to improve their neighborhoods.</p>
  <a href="/calendar/special-events/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Special Event</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\special-events\labour-day.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\special-events\miss-lou-birthday.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Miss Lou's Birthday | SelassieFest Calendar</title>
<meta name="description" content="Honoring Louise Bennett-Coverley, Jamaica's beloved folklorist and poet who championed Jamaican Patois as a language of pride and identity.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/" class="active">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Special Event</span>
  <h1>Miss Lou's Birthday</h1>
  <div class="date-line">Tuesday, September 7, 2027</div>
</div>
<div class="event-body">
  <p>Honoring Louise Bennett-Coverley, Jamaica's beloved folklorist and poet who championed Jamaican Patois as a language of pride and identity.</p>
  <a href="/calendar/special-events/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Special Event</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\special-events\miss-lou-birthday.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\special-events\national-heroes-day.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>National Heroes Day | SelassieFest Calendar</title>
<meta name="description" content="Honoring Jamaica's seven National Heroes, including Marcus Garvey and Nanny of the Maroons, who shaped the nation's fight for freedom and justice.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/" class="active">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Special Event</span>
  <h1>National Heroes Day</h1>
  <div class="date-line">Monday, October 18, 2027</div>
</div>
<div class="event-body">
  <p>Honoring Jamaica's seven National Heroes, including Marcus Garvey and Nanny of the Maroons, who shaped the nation's fight for freedom and justice.</p>
  <a href="/calendar/special-events/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Special Event</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\special-events\national-heroes-day.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\special-events\new-years-day.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>New Year's Day | SelassieFest Calendar</title>
<meta name="description" content="A day of reflection and fresh starts, marking the turn of the calendar year for the SelassieFest community.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/" class="active">Special Events</a>
      <a href="/calendar/weekly/">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-calendar-check"></i> Special Event</span>
  <h1>New Year's Day</h1>
  <div class="date-line">Friday, January 1, 2027</div>
</div>
<div class="event-body">
  <p>A day of reflection and fresh starts, marking the turn of the calendar year for the SelassieFest community.</p>
  <a href="/calendar/special-events/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Special Event</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\special-events\new-years-day.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\weekly\ai-dj-night.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>AI DJ Night | SelassieFest Calendar</title>
<meta name="description" content="A tech-forward Tuesday evening blending AI-driven mixes with community sponsorship activations.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/">Special Events</a>
      <a href="/calendar/weekly/" class="active">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-sync-alt"></i> Weekly Recurring Event</span>
  <h1>AI DJ Night</h1>
  <div class="date-line">Every Tuesday &middot; Sponsorships</div>
</div>
<div class="event-body">
  <p>A tech-forward Tuesday evening blending AI-driven mixes with community sponsorship activations.</p>
  <a href="/calendar/weekly/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Weekly Events</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\weekly\ai-dj-night.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\weekly\astrological-birthday-parties.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Astrological Birthday Parties | SelassieFest Calendar</title>
<meta name="description" content="Private celebration bookings themed around astrological birthday months, hosted every Saturday.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/">Special Events</a>
      <a href="/calendar/weekly/" class="active">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-sync-alt"></i> Weekly Recurring Event</span>
  <h1>Astrological Birthday Parties</h1>
  <div class="date-line">Every Saturday &middot; $800–$1,200 rental</div>
</div>
<div class="event-body">
  <p>Private celebration bookings themed around astrological birthday months, hosted every Saturday.</p>
  <a href="/calendar/weekly/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Weekly Events</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\weekly\astrological-birthday-parties.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\weekly\dancehall-101.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dancehall 101 | SelassieFest Calendar</title>
<meta name="description" content="A beginner-friendly dance class followed by an open-floor party, teaching the fundamentals of dancehall movement.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/">Special Events</a>
      <a href="/calendar/weekly/" class="active">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-sync-alt"></i> Weekly Recurring Event</span>
  <h1>Dancehall 101</h1>
  <div class="date-line">Every Wednesday &middot; $10 class</div>
</div>
<div class="event-body">
  <p>A beginner-friendly dance class followed by an open-floor party, teaching the fundamentals of dancehall movement.</p>
  <a href="/calendar/weekly/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Weekly Events</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\weekly\dancehall-101.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\weekly\dub-poetry-open-mic.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dub Poetry & Open Mic | SelassieFest Calendar</title>
<meta name="description" content="A soulful Thursday evening of spoken word, dub poetry, and open-mic performances.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/">Special Events</a>
      <a href="/calendar/weekly/" class="active">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-sync-alt"></i> Weekly Recurring Event</span>
  <h1>Dub Poetry & Open Mic</h1>
  <div class="date-line">Every Thursday &middot; $10 entry</div>
</div>
<div class="event-body">
  <p>A soulful Thursday evening of spoken word, dub poetry, and open-mic performances.</p>
  <a href="/calendar/weekly/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Weekly Events</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\weekly\dub-poetry-open-mic.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\weekly\fish-fry-fridays.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Fish Fry Fridays | SelassieFest Calendar</title>
<meta name="description" content="A weekly island eatery night featuring fresh fried fish and classic Caribbean sides.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/">Special Events</a>
      <a href="/calendar/weekly/" class="active">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-sync-alt"></i> Weekly Recurring Event</span>
  <h1>Fish Fry Fridays</h1>
  <div class="date-line">Every Friday &middot; Island eatery</div>
</div>
<div class="event-body">
  <p>A weekly island eatery night featuring fresh fried fish and classic Caribbean sides.</p>
  <a href="/calendar/weekly/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Weekly Events</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\weekly\fish-fry-fridays.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\weekly\index.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Weekly Recurring Events | SelassieFest Calendar</title>
<meta name="description" content="Weekly Recurring Events">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/">Special Events</a>
      <a href="/calendar/weekly/" class="active">Weekly Events</a>
    </div>
  </div>
</div>

<div class="hub-hero">
  <h1>Weekly Recurring Events</h1>
  <p>Part of the SelassieFest annual calendar, organized by Ras Tafari Inc.</p>
</div>
<div class="container">
  <div class="event-grid">
  <div class="event-card">
    <span class="event-date-badge">Every Monday</span>
    <h3>New Music Live</h3>
    <p>An incubator stage spotlighting emerging artists and fresh sounds every Monday.</p>
    <a href="/calendar/weekly/new-music-live.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Every Tuesday</span>
    <h3>AI DJ Night</h3>
    <p>A tech-forward Tuesday evening blending AI-driven mixes with community sponsorship activations.</p>
    <a href="/calendar/weekly/ai-dj-night.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Every Wednesday</span>
    <h3>Dancehall 101</h3>
    <p>A beginner-friendly dance class followed by an open-floor party, teaching the fundamentals of dancehall movement.</p>
    <a href="/calendar/weekly/dancehall-101.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Every Thursday</span>
    <h3>Dub Poetry & Open Mic</h3>
    <p>A soulful Thursday evening of spoken word, dub poetry, and open-mic performances.</p>
    <a href="/calendar/weekly/dub-poetry-open-mic.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Every Friday</span>
    <h3>Fish Fry Fridays</h3>
    <p>A weekly island eatery night featuring fresh fried fish and classic Caribbean sides.</p>
    <a href="/calendar/weekly/fish-fry-fridays.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Every Saturday</span>
    <h3>Astrological Birthday Parties</h3>
    <p>Private celebration bookings themed around astrological birthday months, hosted every Saturday.</p>
    <a href="/calendar/weekly/astrological-birthday-parties.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="event-card">
    <span class="event-date-badge">Every Sunday</span>
    <h3>Soul Sundays (25+)</h3>
    <p>A mature lounge night of soul, R&B, and reggae for the 25-and-up crowd, closing out the week.</p>
    <a href="/calendar/weekly/soul-sundays.html" class="btn-sm">View Details <i class="fas fa-arrow-right"></i></a>
  </div>
  </div>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\weekly\index.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\weekly\new-music-live.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>New Music Live | SelassieFest Calendar</title>
<meta name="description" content="An incubator stage spotlighting emerging artists and fresh sounds every Monday.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/">Special Events</a>
      <a href="/calendar/weekly/" class="active">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-sync-alt"></i> Weekly Recurring Event</span>
  <h1>New Music Live</h1>
  <div class="date-line">Every Monday &middot; $5 entry</div>
</div>
<div class="event-body">
  <p>An incubator stage spotlighting emerging artists and fresh sounds every Monday.</p>
  <a href="/calendar/weekly/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Weekly Events</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\weekly\new-music-live.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\calendar\weekly\soul-sundays.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Soul Sundays (25+) | SelassieFest Calendar</title>
<meta name="description" content="A mature lounge night of soul, R&B, and reggae for the 25-and-up crowd, closing out the week.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@200;300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
    :root {
      --bg-black: #0D0D0D;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --text-white: #F5F5F5;
      --text-muted: #b0b0b0;
      --roots-green: #0E5E36;
      --gold-accent: #E5A93C;
      --red-accent: #C83737;
      --transition-default: all 0.25s ease;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      background-color: var(--bg-black);
      color: var(--text-white);
      font-family: 'Jost', sans-serif;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }
    a { text-decoration:none; transition: var(--transition-default); }

    /* Header */
    .site-header { padding: 28px 32px 16px; border-bottom: 1px solid var(--border-dim); background: rgba(13,13,13,0.96); }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:20px; }
    .brand-link { display:inline-block; text-align:center; transition:opacity .2s; }
    .brand-link:hover { opacity:.85; }
    .site-title { font-weight:200; font-size:2.4rem; letter-spacing:.12em; text-transform:uppercase; color:var(--text-white); line-height:1.2; }
    .tagline { font-weight:300; font-size:.85rem; letter-spacing:.3em; text-transform:uppercase; color:var(--gold-accent); margin-top:6px; border-top:1px solid var(--roots-green); display:inline-block; padding-top:8px; }
    .powered-by-wrapper { display:flex; align-items:center; gap:12px; background:rgba(255,255,255,0.05); padding:8px 16px 8px 20px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-weight:300; font-size:.8rem; text-transform:uppercase; letter-spacing:.1em; color:#aaa; }
    .powered-by-logo img { height:36px; width:auto; border-radius:4px; }
    .jvgh-badge-wrapper { display:flex; align-items:center; gap:8px; background:rgba(14,94,54,0.15); padding:6px 14px; border-radius:60px; border:1px solid rgba(14,94,54,0.4); }
    .jvgh-badge-text { font-weight:500; font-size:.75rem; color:#6dbe8f; }

    /* Local sub-nav */
    .fest-nav { background:rgba(5,8,5,0.96); border-bottom:1px solid var(--border-dim); position:sticky; top:0; z-index:100; }
    .nav-container { max-width:1300px; margin:0 auto; padding:.9rem 2rem; display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:1rem; }
    .logo-area { display:flex; align-items:center; gap:.6rem; font-weight:400; font-size:1.1rem; }
    .logo-area i { color:var(--gold-accent); }
    .nav-links { display:flex; gap:1.6rem; flex-wrap:wrap; }
    .nav-links a { color:#ddd; font-size:.9rem; text-transform:uppercase; letter-spacing:.05em; border-bottom:2px solid transparent; padding-bottom:4px; }
    .nav-links a:hover, .nav-links a.active { color:var(--gold-accent); border-bottom-color:var(--gold-accent); }

    .container { max-width:1200px; margin:0 auto; padding:3rem 2rem; }

    /* Hub hero */
    .hub-hero { text-align:center; padding: 3rem 2rem 2rem; }
    .hub-hero h1 { font-weight:300; font-size:2.6rem; letter-spacing:.04em; margin-bottom:1rem; }
    .hub-hero p { color:var(--text-muted); max-width:700px; margin:0 auto; font-size:1.05rem; }
    .category-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(280px,1fr)); gap:1.5rem; margin-top:2.5rem; }
    .category-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.2rem; padding:2rem; transition:var(--transition-default); }
    .category-card:hover { border-color:var(--gold-accent); transform:translateY(-4px); }
    .category-card i { font-size:2rem; color:var(--gold-accent); margin-bottom:1rem; display:block; }
    .category-card h2 { font-weight:500; font-size:1.3rem; margin-bottom:.6rem; }
    .category-card p { color:var(--text-muted); font-size:.92rem; margin-bottom:1.2rem; }
    .category-card a.btn { display:inline-block; background:var(--gold-accent); color:#0a0a0a; font-weight:600; padding:.5rem 1.2rem; border-radius:30px; font-size:.85rem; }

    /* Event list grid (category hub pages) */
    .event-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:1.4rem; margin-top:2rem; }
    .event-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1rem; padding:1.6rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .event-card:hover { border-color:var(--gold-accent); transform:translateY(-3px); }
    .event-date-badge { display:inline-block; background:rgba(229,169,60,0.12); color:var(--gold-accent); font-size:.75rem; font-weight:600; letter-spacing:.05em; text-transform:uppercase; padding:.3rem .8rem; border-radius:30px; margin-bottom:.9rem; align-self:flex-start; }
    .event-card h3 { font-weight:500; font-size:1.2rem; margin-bottom:.6rem; }
    .event-card p { color:var(--text-muted); font-size:.9rem; flex:1; margin-bottom:1rem; }
    .event-card a.btn-sm { color:var(--gold-accent); font-size:.85rem; font-weight:600; text-transform:uppercase; letter-spacing:.05em; }

    /* Single event page */
    .event-hero { text-align:center; padding:3rem 2rem; border-bottom:1px solid var(--border-dim); }
    .event-hero .badge { display:inline-block; background:rgba(14,94,54,0.15); border:1px solid rgba(14,94,54,0.4); color:#6dbe8f; font-size:.8rem; font-weight:600; text-transform:uppercase; letter-spacing:.08em; padding:.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .event-hero h1 { font-weight:300; font-size:2.6rem; margin-bottom:.8rem; }
    .event-hero .date-line { font-size:1.2rem; color:var(--gold-accent); font-weight:500; letter-spacing:.02em; }
    .event-body { max-width:760px; margin:0 auto; padding:3rem 2rem; }
    .event-body p { color:#ddd; font-size:1.05rem; margin-bottom:1.4rem; }
    .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--gold-accent); font-weight:600; margin-top:1rem; }

    footer.site-footer { text-align:center; padding:2.5rem 2rem; border-top:1px solid var(--border-dim); color:#777; font-size:.85rem; }

    @media (max-width:700px) {
      .header-flex { flex-direction:column; align-items:center; }
      .site-title { font-size:1.7rem; }
      .event-hero h1, .hub-hero h1 { font-size:1.8rem; }
    }
</style>
</head>
<body>
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
    <a href="/JamaicaVillageGH/" class="jvgh-badge-wrapper" aria-label="Visit Jamaica Village Ghana">
      <i class="fas fa-map-marker-alt" style="color:#6dbe8f; font-size:0.75rem;" aria-hidden="true"></i>
      <span class="jvgh-badge-text">Jamaica Village Ghana</span>
    </a>
  </div>
</header>
<div class="fest-nav">
  <div class="nav-container">
    <div class="logo-area"><i class="fas fa-calendar-alt"></i><span>SelassieFest Calendar</span></div>
    <div class="nav-links">
      <a href="/calendar/">Calendar Home</a>
      <a href="/calendar/festivals/">Festivals</a>
      <a href="/calendar/special-events/">Special Events</a>
      <a href="/calendar/weekly/" class="active">Weekly Events</a>
    </div>
  </div>
</div>

<div class="event-hero">
  <span class="badge"><i class="fas fa-sync-alt"></i> Weekly Recurring Event</span>
  <h1>Soul Sundays (25+)</h1>
  <div class="date-line">Every Sunday &middot; $15 cover</div>
</div>
<div class="event-body">
  <p>A mature lounge night of soul, R&B, and reggae for the 25-and-up crowd, closing out the week.</p>
  <a href="/calendar/weekly/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Weekly Events</a>
</div>

<footer class="site-footer">
  &copy; 2027 SelassieFest Collective &middot; Ras Tafari Inc. &middot; <a href="/calendar/" style="color:var(--gold-accent);">Full Calendar</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] calendar\weekly\soul-sundays.html" -ForegroundColor DarkGray

Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "  Done. $fileCount files written." -ForegroundColor Green
Write-Host "  Open GitHub Desktop to review changes," -ForegroundColor Green
Write-Host "  then commit and push." -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""