# ======================================================================
# add-pickney-games.ps1
#
# Adds the /pickney-time/games/ subfolder — 33 individual game pages
# plus the games archive hub index.html — to your local selassiefest repo.
#
# Run from inside the repo folder:
#   cd C:\Users\mkepr\Documents\GitHub\selassiefest
#   powershell -ExecutionPolicy Bypass -File ".\add-pickney-games.ps1"
#
# This script ONLY writes files to disk. It does NOT run git
# add/commit/push. Review with `git status` / GitHub Desktop after.
# ======================================================================

$ErrorActionPreference = "Stop"
$repo = Get-Location

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Adding Pickney Time Games Archive" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

New-Item -ItemType Directory -Force -Path "$repo\pickney-time\games" | Out-Null

$fileCount = 0

Set-Content -LiteralPath "$repo\pickney-time\games\anansi-stories.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Anansi Stories | Pickney Time Games Archive</title>
<meta name="description" content="Tales of the trickster spider Anansi, passed down through generations.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-spider"></i> Nature & Story Play</span>
  <h1>Anansi Stories</h1>
  <p class="tagline-desc">Tales of the trickster spider Anansi, passed down through generations.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/anansi-stories.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">Any number, in a listening circle</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">Just a storyteller and an audience</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Gather in a circle with an elder or storyteller in the center.</span></li>
<li><span class="step-num">2</span><span>Listen as they share a tale of Anansi the trickster spider outsmarting bigger, stronger characters.</span></li>
<li><span class="step-num">3</span><span>Join in on repeated phrases or songs woven into the story.</span></li>
<li><span class="step-num">4</span><span>Discuss the lesson or moral at the end together.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">Anansi stories trace back to West African (Akan) folklore and remain central to Caribbean storytelling tradition.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\anansi-stories.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\bearing-skate.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Bearing Skate | Pickney Time Games Archive</title>
<meta name="description" content="A skateboard made from a wooden plank and old bearings.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-skating"></i> Homemade Toys</span>
  <h1>Bearing Skate</h1>
  <p class="tagline-desc">A skateboard made from a wooden plank and old bearings.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/bearing-skate.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">Solo, or in a group taking turns</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">A wooden plank, old wheel bearings, nails</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Attach bearings to the underside of a wooden plank to act as wheels.</span></li>
<li><span class="step-num">2</span><span>Find a hill or slope with a supervised, safe runout area.</span></li>
<li><span class="step-num">3</span><span>Ride the bearing skate down the hill, balancing with arms out.</span></li>
<li><span class="step-num">4</span><span>Take turns and time your runs — bragging rights go to the smoothest ride.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">A cornerstone of the Bearing Skate Hill Challenge at Pickney Time — always supervised by elders for safety.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\bearing-skate.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\brown-girl-in-the-ring.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Brown Girl in the Ring | Pickney Time Games Archive</title>
<meta name="description" content="A singing game where children dance in a circle.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-circle"></i> Ring Games</span>
  <h1>Brown Girl in the Ring</h1>
  <p class="tagline-desc">A singing game where children dance in a circle.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/brown-girl-in-the-ring.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">5 or more players</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">None — just voices and a circle of friends</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Form a circle with one player standing in the middle.</span></li>
<li><span class="step-num">2</span><span>Everyone sings the traditional song while circling around the center player.</span></li>
<li><span class="step-num">3</span><span>The center player dances and, at the song's cue, picks the next person to take their place.</span></li>
<li><span class="step-num">4</span><span>Repeat with a new center player each round.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">One of the most iconic Caribbean ring games, later made globally famous by Boney M's recording.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\brown-girl-in-the-ring.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\bull-inna-pen.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Bull Inna Pen | Pickney Time Games Archive</title>
<meta name="description" content="A classic Caribbean game of tag and strategy.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-running"></i> Yard Games</span>
  <h1>Bull Inna Pen</h1>
  <p class="tagline-desc">A classic Caribbean game of tag and strategy.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/bull-inna-pen.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">5 or more players</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">An open space marked as "the pen"</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>One player is the "bull" and stands inside the marked pen.</span></li>
<li><span class="step-num">2</span><span>Everyone else tries to run through the pen without getting tagged.</span></li>
<li><span class="step-num">3</span><span>If tagged, you join the bull inside the pen.</span></li>
<li><span class="step-num">4</span><span>The last player not caught wins.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">A game of nerve — timing your run past the bull takes courage and quick feet.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\bull-inna-pen.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\catch-a-base.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Catch-a-Base | Pickney Time Games Archive</title>
<meta name="description" content="A game of running, tagging, and teamwork.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-baseball"></i> Yard Games</span>
  <h1>Catch-a-Base</h1>
  <p class="tagline-desc">A game of running, tagging, and teamwork.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/catch-a-base.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">6 or more players</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">Two or more marked "bases"</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Designate two or more safe bases across the yard.</span></li>
<li><span class="step-num">2</span><span>One or more players are "it" and try to tag runners moving between bases.</span></li>
<li><span class="step-num">3</span><span>Runners are safe only while standing on a base.</span></li>
<li><span class="step-num">4</span><span>Tagged players become "it," and the game continues.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">A cousin of tag played all over the Caribbean — pure running, pure joy.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\catch-a-base.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\checkers.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Checkers | Pickney Time Games Archive</title>
<meta name="description" content="A strategic board game played in yards across the Caribbean.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-chess"></i> Yard Games</span>
  <h1>Checkers</h1>
  <p class="tagline-desc">A strategic board game played in yards across the Caribbean.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/checkers.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">2 players</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">A checkered board, 12 pieces per player (bottle caps work in a pinch!)</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Set up pieces on opposite ends of the board, moving diagonally only.</span></li>
<li><span class="step-num">2</span><span>Capture an opponent's piece by jumping over it into an empty square.</span></li>
<li><span class="step-num">3</span><span>Reach the far row to "king" a piece, letting it move both forward and backward.</span></li>
<li><span class="step-num">4</span><span>Win by capturing all opponent pieces or leaving them with no legal moves.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">Known locally as "Draft," this game has been played on hand-drawn boards using bottle caps and stones for generations.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\checkers.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\dandy-shandy.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dandy Shandy | Pickney Time Games Archive</title>
<meta name="description" content="A fast-paced chase game that builds speed and agility.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-running"></i> Yard Games</span>
  <h1>Dandy Shandy</h1>
  <p class="tagline-desc">A fast-paced chase game that builds speed and agility.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/dandy-shandy.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">6 or more players</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">A soft ball, open yard space</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Two "throwers" stand at opposite ends of a marked lane.</span></li>
<li><span class="step-num">2</span><span>Runners try to cross from one end to the other without being hit by the ball.</span></li>
<li><span class="step-num">3</span><span>If you're hit, you're out (or join the throwers, depending on house rules).</span></li>
<li><span class="step-num">4</span><span>Last runner standing wins.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">One of the highest-energy yard games — builds speed, reflexes, and a healthy respect for a well-aimed throw.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\dandy-shandy.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\dominoes.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dominoes | Pickney Time Games Archive</title>
<meta name="description" content="The beloved Caribbean pastime — clash with friends and family.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-dice"></i> Yard Games</span>
  <h1>Dominoes</h1>
  <p class="tagline-desc">The beloved Caribbean pastime — clash with friends and family.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/dominoes.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">2–4 players (often played in partnerships of 2v2)</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">A double-six (or double-nine) domino set, a hard table</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Shuffle the tiles face-down and draw your hand.</span></li>
<li><span class="step-num">2</span><span>Take turns matching a tile's number to an open end on the table.</span></li>
<li><span class="step-num">3</span><span>If you can't play, you knock and pass.</span></li>
<li><span class="step-num">4</span><span>First to play all their tiles — or the player with the lowest pip count when play is blocked — wins the round.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">In Jamaica, dominoes is a serious sport of its own — expect table slams, loud calls, and fierce partnership pride.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\dominoes.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\drink-box-truck.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Drink Box Truck | Pickney Time Games Archive</title>
<meta name="description" content="A toy truck made from a milk carton and bottle caps.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-truck"></i> Homemade Toys</span>
  <h1>Drink Box Truck</h1>
  <p class="tagline-desc">A toy truck made from a milk carton and bottle caps.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/drink-box-truck.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">Solo play or small group races</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">An empty juice/milk carton, bottle caps, a stick or wire axle, string</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Clean out an empty carton and attach bottle-cap wheels using a wire or stick axle.</span></li>
<li><span class="step-num">2</span><span>Attach a string to pull it along the ground like a toy truck.</span></li>
<li><span class="step-num">3</span><span>Decorate it however you like — many children personalized theirs with paint or markers.</span></li>
<li><span class="step-num">4</span><span>Race your truck against friends' creations!</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">A perfect example of Caribbean resourcefulness — turning packaging trash into treasured toys.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\drink-box-truck.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\eeh-yow.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Eeh Yow | Pickney Time Games Archive</title>
<meta name="description" content="A fast-paced ring game with clapping and laughter.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-circle"></i> Ring Games</span>
  <h1>Eeh Yow</h1>
  <p class="tagline-desc">A fast-paced ring game with clapping and laughter.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/eeh-yow.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">4 or more players</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">None — just voices and hands for clapping</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Form a circle or pair up facing a partner.</span></li>
<li><span class="step-num">2</span><span>Clap along to the rhythm of the traditional chant.</span></li>
<li><span class="step-num">3</span><span>Keep pace as the chant speeds up, testing everyone's reflexes.</span></li>
<li><span class="step-num">4</span><span>Miss a clap or the beat, and you're out (or simply laugh it off and rejoin).</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">A high-energy clapping game that rewards quick hands and quicker laughter.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\eeh-yow.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\elder-storytelling.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Elder Storytelling | Pickney Time Games Archive</title>
<meta name="description" content="Elders share stories of childhood, community, and tradition.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-users"></i> Nature & Story Play</span>
  <h1>Elder Storytelling</h1>
  <p class="tagline-desc">Elders share stories of childhood, community, and tradition.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/elder-storytelling.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">Any number, in a listening circle</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">Just an elder and an audience</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Gather in a circle around an elder storyteller.</span></li>
<li><span class="step-num">2</span><span>Listen to personal memories of their own childhood games, community, and traditions.</span></li>
<li><span class="step-num">3</span><span>Ask questions and share your own family's stories too.</span></li>
<li><span class="step-num">4</span><span>Reflect together on how much — and how little — has changed.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">This is the heart of Pickney Time: direct, living transmission of memory from one generation to the next.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\elder-storytelling.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\gig-building.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Gig Building | Pickney Time Games Archive</title>
<meta name="description" content="A simple instrument made from a tin can and string.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-music"></i> Homemade Toys</span>
  <h1>Gig Building</h1>
  <p class="tagline-desc">A simple instrument made from a tin can and string.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/gig-building.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">Solo or group</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">A tin can, string, a stick</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Punch small holes in a clean, empty tin can.</span></li>
<li><span class="step-num">2</span><span>Thread string through the holes and attach it to a stick handle.</span></li>
<li><span class="step-num">3</span><span>Spin, twirl, or strum it to create rhythm and sound.</span></li>
<li><span class="step-num">4</span><span>Join other children to create a homemade percussion band.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">A reminder that music can come from anything — resourcefulness turned trash into rhythm.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\gig-building.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\hose-hoop-wheel.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Hose Hoop Wheel | Pickney Time Games Archive</title>
<meta name="description" content="A rolling wheel made from an old hose and a stick.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-circle"></i> Homemade Toys</span>
  <h1>Hose Hoop Wheel</h1>
  <p class="tagline-desc">A rolling wheel made from an old hose and a stick.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/hose-hoop-wheel.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">Solo, or races with friends</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">An old bicycle tire, hose ring, or hoop, a guide stick</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Take an old tire, hose ring, or bent wire hoop.</span></li>
<li><span class="step-num">2</span><span>Use a stick to keep the hoop rolling and guide its direction as you run alongside it.</span></li>
<li><span class="step-num">3</span><span>Try to keep it upright and rolling for as long as possible.</span></li>
<li><span class="step-num">4</span><span>Race a friend's hoop down the street or around the yard.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">One of the simplest and oldest yard toys — just a hoop, a stick, and momentum.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\hose-hoop-wheel.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\index.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Games Archive | Pickney Time Games Archive</title>
<meta name="description" content="33 traditional Caribbean childhood games explained in detail">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="active">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="hub-hero">
  <h1>Pickney Time Games Archive</h1>
  <p>33 traditional Caribbean childhood games, toys, and stories — each with its own page explaining how to play, what you need, and the story behind it.</p>
</div>
<div class="container">
  <div class="archive-controls" id="filterGroup">
    <button class="filter-btn active" data-filter="all">All</button>
    <button class="filter-btn" data-filter="yard">Yard Games</button>
    <button class="filter-btn" data-filter="homemade">Homemade Toys</button>
    <button class="filter-btn" data-filter="ring">Ring Games</button>
    <button class="filter-btn" data-filter="nature">Nature & Story Play</button>
    <button class="filter-btn" data-filter="rainy">Rainy Day Play</button>
    <button class="filter-btn" data-filter="night">Night Games</button>
  </div>
  <div class="game-grid" id="gameGrid">
  <div class="game-card" data-category="nature">
    <div class="cat-tag">Nature & Story Play</div>
    <div class="icon"><i class="fas fa-spider"></i></div>
    <h3>Anansi Stories</h3>
    <p>Tales of the trickster spider Anansi, passed down through generations.</p>
    <a href="/pickney-time/games/anansi-stories.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="homemade">
    <div class="cat-tag">Homemade Toys</div>
    <div class="icon"><i class="fas fa-skating"></i></div>
    <h3>Bearing Skate</h3>
    <p>A skateboard made from a wooden plank and old bearings.</p>
    <a href="/pickney-time/games/bearing-skate.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="ring">
    <div class="cat-tag">Ring Games</div>
    <div class="icon"><i class="fas fa-circle"></i></div>
    <h3>Brown Girl in the Ring</h3>
    <p>A singing game where children dance in a circle.</p>
    <a href="/pickney-time/games/brown-girl-in-the-ring.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="yard">
    <div class="cat-tag">Yard Games</div>
    <div class="icon"><i class="fas fa-running"></i></div>
    <h3>Bull Inna Pen</h3>
    <p>A classic Caribbean game of tag and strategy.</p>
    <a href="/pickney-time/games/bull-inna-pen.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="yard">
    <div class="cat-tag">Yard Games</div>
    <div class="icon"><i class="fas fa-baseball"></i></div>
    <h3>Catch-a-Base</h3>
    <p>A game of running, tagging, and teamwork.</p>
    <a href="/pickney-time/games/catch-a-base.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="yard">
    <div class="cat-tag">Yard Games</div>
    <div class="icon"><i class="fas fa-chess"></i></div>
    <h3>Checkers</h3>
    <p>A strategic board game played in yards across the Caribbean.</p>
    <a href="/pickney-time/games/checkers.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="yard">
    <div class="cat-tag">Yard Games</div>
    <div class="icon"><i class="fas fa-running"></i></div>
    <h3>Dandy Shandy</h3>
    <p>A fast-paced chase game that builds speed and agility.</p>
    <a href="/pickney-time/games/dandy-shandy.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="yard">
    <div class="cat-tag">Yard Games</div>
    <div class="icon"><i class="fas fa-dice"></i></div>
    <h3>Dominoes</h3>
    <p>The beloved Caribbean pastime — clash with friends and family.</p>
    <a href="/pickney-time/games/dominoes.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="homemade">
    <div class="cat-tag">Homemade Toys</div>
    <div class="icon"><i class="fas fa-truck"></i></div>
    <h3>Drink Box Truck</h3>
    <p>A toy truck made from a milk carton and bottle caps.</p>
    <a href="/pickney-time/games/drink-box-truck.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="ring">
    <div class="cat-tag">Ring Games</div>
    <div class="icon"><i class="fas fa-circle"></i></div>
    <h3>Eeh Yow</h3>
    <p>A fast-paced ring game with clapping and laughter.</p>
    <a href="/pickney-time/games/eeh-yow.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="nature">
    <div class="cat-tag">Nature & Story Play</div>
    <div class="icon"><i class="fas fa-users"></i></div>
    <h3>Elder Storytelling</h3>
    <p>Elders share stories of childhood, community, and tradition.</p>
    <a href="/pickney-time/games/elder-storytelling.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="homemade">
    <div class="cat-tag">Homemade Toys</div>
    <div class="icon"><i class="fas fa-music"></i></div>
    <h3>Gig Building</h3>
    <p>A simple instrument made from a tin can and string.</p>
    <a href="/pickney-time/games/gig-building.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="homemade">
    <div class="cat-tag">Homemade Toys</div>
    <div class="icon"><i class="fas fa-circle"></i></div>
    <h3>Hose Hoop Wheel</h3>
    <p>A rolling wheel made from an old hose and a stick.</p>
    <a href="/pickney-time/games/hose-hoop-wheel.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="yard">
    <div class="cat-tag">Yard Games</div>
    <div class="icon"><i class="fas fa-hand-peace"></i></div>
    <h3>Jacks</h3>
    <p>A classic hand-eye coordination game played with small metal pieces.</p>
    <a href="/pickney-time/games/jacks.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="nature">
    <div class="cat-tag">Nature & Story Play</div>
    <div class="icon"><i class="fas fa-comment-dots"></i></div>
    <h3>Jamaican Sayings</h3>
    <p>Everyday sayings that reflect Caribbean culture and humor.</p>
    <a href="/pickney-time/games/jamaican-sayings.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="homemade">
    <div class="cat-tag">Homemade Toys</div>
    <div class="icon"><i class="fas fa-wind"></i></div>
    <h3>Kite Making</h3>
    <p>Build and fly kites from paper, sticks, and string.</p>
    <a href="/pickney-time/games/kite-making.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="ring">
    <div class="cat-tag">Ring Games</div>
    <div class="icon"><i class="fas fa-circle"></i></div>
    <h3>Little Miss Nancy</h3>
    <p>A ring game with songs and playful movement.</p>
    <a href="/pickney-time/games/little-miss-nancy.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="yard">
    <div class="cat-tag">Yard Games</div>
    <div class="icon"><i class="fas fa-dice"></i></div>
    <h3>Ludi</h3>
    <p>A classic Caribbean board game of strategy and luck.</p>
    <a href="/pickney-time/games/ludi.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="yard">
    <div class="cat-tag">Yard Games</div>
    <div class="icon"><i class="fas fa-circle"></i></div>
    <h3>Marbles</h3>
    <p>Knuckle down and aim true — marbles is a game of precision.</p>
    <a href="/pickney-time/games/marbles.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="yard">
    <div class="cat-tag">Yard Games</div>
    <div class="icon"><i class="fas fa-people-arrows"></i></div>
    <h3>Mother May I</h3>
    <p>A game of asking permission and taking steps forward.</p>
    <a href="/pickney-time/games/mother-may-i.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="night">
    <div class="cat-tag">Night Games</div>
    <div class="icon"><i class="fas fa-moon"></i></div>
    <h3>Night Games</h3>
    <p>Games that come alive under the stars — flashlight tag, shadows, and more.</p>
    <a href="/pickney-time/games/night-games.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="homemade">
    <div class="cat-tag">Homemade Toys</div>
    <div class="icon"><i class="fas fa-paper-plane"></i></div>
    <h3>Paper Plane</h3>
    <p>The art of folding and launching paper aircraft.</p>
    <a href="/pickney-time/games/paper-plane.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="homemade">
    <div class="cat-tag">Homemade Toys</div>
    <div class="icon"><i class="fas fa-water-gun"></i></div>
    <h3>Pear Gun</h3>
    <p>A playful toy gun made from a pear-shaped gourd.</p>
    <a href="/pickney-time/games/pear-gun.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="homemade">
    <div class="cat-tag">Homemade Toys</div>
    <div class="icon"><i class="fas fa-bullseye"></i></div>
    <h3>Pop Shot</h3>
    <p>A shooting game using a homemade launcher and targets.</p>
    <a href="/pickney-time/games/pop-shot.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="nature">
    <div class="cat-tag">Nature & Story Play</div>
    <div class="icon"><i class="fas fa-quote-left"></i></div>
    <h3>Proverbs</h3>
    <p>Jamaican proverbs that carry wisdom and life lessons.</p>
    <a href="/pickney-time/games/proverbs.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="ring">
    <div class="cat-tag">Ring Games</div>
    <div class="icon"><i class="fas fa-circle"></i></div>
    <h3>Puncienella Likkle Fella</h3>
    <p>A joyous ring game with call-and-response singing.</p>
    <a href="/pickney-time/games/puncienella-likkle-fella.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="homemade">
    <div class="cat-tag">Homemade Toys</div>
    <div class="icon"><i class="fas fa-cart-shopping"></i></div>
    <h3>Push Cart</h3>
    <p>A wooden cart built from scraps, perfect for hauling treasures.</p>
    <a href="/pickney-time/games/push-cart.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="rainy">
    <div class="cat-tag">Rainy Day Play</div>
    <div class="icon"><i class="fas fa-cloud-rain"></i></div>
    <h3>Rainy Day Play</h3>
    <p>Indoor games and activities for rainy afternoons.</p>
    <a href="/pickney-time/games/rainy-day-play.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="yard">
    <div class="cat-tag">Yard Games</div>
    <div class="icon"><i class="fas fa-traffic-light"></i></div>
    <h3>Red Light Green Light</h3>
    <p>A universal game of movement and control.</p>
    <a href="/pickney-time/games/red-light-green-light.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="yard">
    <div class="cat-tag">Yard Games</div>
    <div class="icon"><i class="fas fa-brain"></i></div>
    <h3>Riddles</h3>
    <p>Test your wit with Caribbean riddles and proverbs.</p>
    <a href="/pickney-time/games/riddles.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="homemade">
    <div class="cat-tag">Homemade Toys</div>
    <div class="icon"><i class="fas fa-person-walking"></i></div>
    <h3>Stilts</h3>
    <p>Wooden stilts for walking tall and balancing.</p>
    <a href="/pickney-time/games/stilts.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="yard">
    <div class="cat-tag">Yard Games</div>
    <div class="icon"><i class="fas fa-snowflake"></i></div>
    <h3>Stucky Freezy</h3>
    <p>Freeze and unfreeze — a game of quick reactions.</p>
    <a href="/pickney-time/games/stucky-freezy.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  <div class="game-card" data-category="homemade">
    <div class="cat-tag">Homemade Toys</div>
    <div class="icon"><i class="fas fa-car"></i></div>
    <h3>Wire Car</h3>
    <p>A handmade car crafted from wire and imagination.</p>
    <a href="/pickney-time/games/wire-car.html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
  </div>
  </div>
</div>
<script>
document.querySelectorAll('.filter-btn').forEach(btn => {
  btn.addEventListener('click', function() {
    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
    this.classList.add('active');
    const filter = this.dataset.filter;
    document.querySelectorAll('.game-card').forEach(card => {
      card.style.display = (filter === 'all' || card.dataset.category === filter) ? 'flex' : 'none';
    });
  });
});
</script>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\index.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\jacks.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Jacks | Pickney Time Games Archive</title>
<meta name="description" content="A classic hand-eye coordination game played with small metal pieces.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-hand-peace"></i> Yard Games</span>
  <h1>Jacks</h1>
  <p class="tagline-desc">A classic hand-eye coordination game played with small metal pieces.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/jacks.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">1 or more (takes turns)</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">A small ball, a set of jacks (or small stones — known as "stings")</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Scatter the jacks on a flat surface.</span></li>
<li><span class="step-num">2</span><span>Toss the ball up, and before it bounces (or after one bounce), pick up one jack and catch the ball.</span></li>
<li><span class="step-num">3</span><span>Repeat, picking up two jacks at a time, then three, increasing each round.</span></li>
<li><span class="step-num">4</span><span>Miss a catch or fumble the jacks, and it's the next player's turn.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">Also known as "Stings" in parts of Jamaica, using small stones when metal jacks weren't on hand.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\jacks.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\jamaican-sayings.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Jamaican Sayings | Pickney Time Games Archive</title>
<meta name="description" content="Everyday sayings that reflect Caribbean culture and humor.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-comment-dots"></i> Nature & Story Play</span>
  <h1>Jamaican Sayings</h1>
  <p class="tagline-desc">Everyday sayings that reflect Caribbean culture and humor.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/jamaican-sayings.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">Any number, in a group</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">Just conversation</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>An elder or leader shares a common Jamaican saying or phrase.</span></li>
<li><span class="step-num">2</span><span>The group guesses the meaning or context it's used in.</span></li>
<li><span class="step-num">3</span><span>Stories and examples are shared of when the saying applies.</span></li>
<li><span class="step-num">4</span><span>Children practice using the saying themselves.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">A playful way to keep Jamaican Patois expressions alive and understood by younger generations.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\jamaican-sayings.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\kite-making.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Kite Making | Pickney Time Games Archive</title>
<meta name="description" content="Build and fly kites from paper, sticks, and string.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-wind"></i> Homemade Toys</span>
  <h1>Kite Making</h1>
  <p class="tagline-desc">Build and fly kites from paper, sticks, and string.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/kite-making.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">Solo or family activity</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">Paper or plastic, bamboo sticks or dowels, string, tape or glue</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Build a simple frame from two crossed sticks.</span></li>
<li><span class="step-num">2</span><span>Stretch paper or plastic over the frame and secure it.</span></li>
<li><span class="step-num">3</span><span>Attach a tail for stability and a long string to fly it.</span></li>
<li><span class="step-num">4</span><span>Find open, windy space and launch — running to catch the wind if needed.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">Kite season is a highlight of Caribbean childhood — Easter especially is famous for kites filling the sky.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\kite-making.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\little-miss-nancy.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Little Miss Nancy | Pickney Time Games Archive</title>
<meta name="description" content="A ring game with songs and playful movement.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-circle"></i> Ring Games</span>
  <h1>Little Miss Nancy</h1>
  <p class="tagline-desc">A ring game with songs and playful movement.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/little-miss-nancy.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">5 or more players</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">None — just voices and a circle of friends</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Form a circle and choose a player to start in the middle.</span></li>
<li><span class="step-num">2</span><span>Sing the traditional call-and-response verses together.</span></li>
<li><span class="step-num">3</span><span>Follow the actions the song calls for, taking turns in the center.</span></li>
<li><span class="step-num">4</span><span>Keep going, rotating who stands in the middle.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">Like many ring games, the verses and actions can vary slightly from community to community — elders often know the version passed down in their family.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\little-miss-nancy.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\ludi.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Ludi | Pickney Time Games Archive</title>
<meta name="description" content="A classic Caribbean board game of strategy and luck.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-dice"></i> Yard Games</span>
  <h1>Ludi</h1>
  <p class="tagline-desc">A classic Caribbean board game of strategy and luck.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/ludi.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">2–4 players</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">Ludi board (or drawn cross-shaped board), dice, 4 tokens per player</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Each player picks a color and places their 4 tokens in their starting yard.</span></li>
<li><span class="step-num">2</span><span>Roll the dice to move a token out and around the board, aiming for your home column.</span></li>
<li><span class="step-num">3</span><span>Land on an opponent's token to send it back to their start — but watch your own back too.</span></li>
<li><span class="step-num">4</span><span>First player to get all 4 tokens home wins.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">Ludi is a beloved yard-and-verandah pastime across the Caribbean, often played late into the evening with plenty of good-natured trash talk.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\ludi.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\marbles.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Marbles | Pickney Time Games Archive</title>
<meta name="description" content="Knuckle down and aim true — marbles is a game of precision.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-circle"></i> Yard Games</span>
  <h1>Marbles</h1>
  <p class="tagline-desc">Knuckle down and aim true — marbles is a game of precision.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/marbles.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">2 or more players</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">A set of marbles, flat dirt or pavement</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Draw a circle in the dirt and each player places a few marbles inside.</span></li>
<li><span class="step-num">2</span><span>Take turns "knuckling down" and shooting your shooter marble at the ones in the circle.</span></li>
<li><span class="step-num">3</span><span>Any marble you knock outside the circle, you keep.</span></li>
<li><span class="step-num">4</span><span>Play continues until all marbles are claimed.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">A game of steady hands and sharp eyes — champions were made and reputations built on the marble circle.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\marbles.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\mother-may-i.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Mother May I | Pickney Time Games Archive</title>
<meta name="description" content="A game of asking permission and taking steps forward.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-people-arrows"></i> Yard Games</span>
  <h1>Mother May I</h1>
  <p class="tagline-desc">A game of asking permission and taking steps forward.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/mother-may-i.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">3 or more players</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">None — just open space</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>One player is "Mother" and stands facing the group from a distance.</span></li>
<li><span class="step-num">2</span><span>Players ask, "Mother, may I take [number] [type] of steps?"</span></li>
<li><span class="step-num">3</span><span>Mother grants or denies the request — forget to ask properly and you go back to start.</span></li>
<li><span class="step-num">4</span><span>First player to reach Mother wins and becomes the next Mother.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">A gentle game of patience, manners, and a little bit of strategy in how you phrase your ask.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\mother-may-i.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\night-games.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Night Games | Pickney Time Games Archive</title>
<meta name="description" content="Games that come alive under the stars — flashlight tag, shadows, and more.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-moon"></i> Night Games</span>
  <h1>Night Games</h1>
  <p class="tagline-desc">Games that come alive under the stars — flashlight tag, shadows, and more.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/night-games.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">4 or more players</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">A flashlight (optional), open outdoor space, supervision</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Gather outside once the sun sets and streetlights come on.</span></li>
<li><span class="step-num">2</span><span>Play flashlight tag, shadow games, or classic hide-and-seek in the dark.</span></li>
<li><span class="step-num">3</span><span>Set clear boundaries for how far players can go.</span></li>
<li><span class="step-num">4</span><span>Keep playing until it's time to head home for the night.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">Night games mark the golden hour of childhood — playing until the streetlights called everyone home.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\night-games.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\paper-plane.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Paper Plane | Pickney Time Games Archive</title>
<meta name="description" content="The art of folding and launching paper aircraft.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-paper-plane"></i> Homemade Toys</span>
  <h1>Paper Plane</h1>
  <p class="tagline-desc">The art of folding and launching paper aircraft.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/paper-plane.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">Any number</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">A sheet of paper</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Fold a sheet of paper into your favorite paper airplane design.</span></li>
<li><span class="step-num">2</span><span>Adjust the wings and nose for the flight style you want.</span></li>
<li><span class="step-num">3</span><span>Compete for distance, hang time, or trick landings.</span></li>
<li><span class="step-num">4</span><span>Try different folding techniques to see which flies best.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">Simple, free, and endlessly replayable — paper planes remain a universal Caribbean childhood pastime.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\paper-plane.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\pear-gun.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Pear Gun | Pickney Time Games Archive</title>
<meta name="description" content="A playful toy gun made from a pear-shaped gourd.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-water-gun"></i> Homemade Toys</span>
  <h1>Pear Gun</h1>
  <p class="tagline-desc">A playful toy gun made from a pear-shaped gourd.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/pear-gun.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">Solo or group play</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">A hollowed gourd or bamboo tube, small seeds or berries as "ammo"</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Hollow out a small section of gourd or bamboo to create a simple tube.</span></li>
<li><span class="step-num">2</span><span>Load it with small seeds or soft berries.</span></li>
<li><span class="step-num">3</span><span>Use a plunger stick to pop the "ammo" out with a satisfying pop.</span></li>
<li><span class="step-num">4</span><span>Play friendly target games with friends — always aim away from faces.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">An inventive homemade toy that turned natural materials into hours of playful fun.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\pear-gun.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\pop-shot.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Pop Shot | Pickney Time Games Archive</title>
<meta name="description" content="A shooting game using a homemade launcher and targets.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-bullseye"></i> Homemade Toys</span>
  <h1>Pop Shot</h1>
  <p class="tagline-desc">A shooting game using a homemade launcher and targets.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/pop-shot.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">Any number</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">Bamboo tube, a plunger stick, soft projectiles, cans or targets</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Build a simple bamboo pop-shot launcher (similar to the Pear Gun).</span></li>
<li><span class="step-num">2</span><span>Set up cans or soft targets at a safe distance.</span></li>
<li><span class="step-num">3</span><span>Take turns popping projectiles at the targets.</span></li>
<li><span class="step-num">4</span><span>Keep score of hits — most hits after a set number of rounds wins.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">A game that rewards steady aim and a bit of homemade engineering.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\pop-shot.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\proverbs.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Proverbs | Pickney Time Games Archive</title>
<meta name="description" content="Jamaican proverbs that carry wisdom and life lessons.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-quote-left"></i> Nature & Story Play</span>
  <h1>Proverbs</h1>
  <p class="tagline-desc">Jamaican proverbs that carry wisdom and life lessons.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/proverbs.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">Any number, in a group</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">Just conversation</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>An elder shares a traditional proverb, such as "Wat sweet nanny goat a go run him belly."</span></li>
<li><span class="step-num">2</span><span>The group discusses what they think it means.</span></li>
<li><span class="step-num">3</span><span>The elder shares the deeper life lesson behind it.</span></li>
<li><span class="step-num">4</span><span>Children are encouraged to remember and reuse the proverb in daily life.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">Proverbs pack generations of wisdom into a single memorable line — a living oral tradition.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\proverbs.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\puncienella-likkle-fella.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Puncienella Likkle Fella | Pickney Time Games Archive</title>
<meta name="description" content="A joyous ring game with call-and-response singing.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-circle"></i> Ring Games</span>
  <h1>Puncienella Likkle Fella</h1>
  <p class="tagline-desc">A joyous ring game with call-and-response singing.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/puncienella-likkle-fella.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">5 or more players</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">None — just voices and a circle of friends</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Form a circle with one player in the center as "Puncienella."</span></li>
<li><span class="step-num">2</span><span>The group sings the call, and Puncienella responds with actions or dance moves.</span></li>
<li><span class="step-num">3</span><span>Other players imitate the actions Puncienella performs.</span></li>
<li><span class="step-num">4</span><span>A new Puncienella is chosen and the song repeats.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">A game built on imitation and joy — the sillier the actions, the better.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\puncienella-likkle-fella.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\push-cart.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Push Cart | Pickney Time Games Archive</title>
<meta name="description" content="A wooden cart built from scraps, perfect for hauling treasures.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-cart-shopping"></i> Homemade Toys</span>
  <h1>Push Cart</h1>
  <p class="tagline-desc">A wooden cart built from scraps, perfect for hauling treasures.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/push-cart.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">2+ (one pushes, one rides, or take turns)</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">Scrap wood or a crate, four wheels, nails, rope for steering</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Build a simple wooden platform on four wheels.</span></li>
<li><span class="step-num">2</span><span>Add a rope or wire for steering.</span></li>
<li><span class="step-num">3</span><span>One child pushes while another rides, or use it to haul things around the yard.</span></li>
<li><span class="step-num">4</span><span>Take turns and see who can build the fastest or sturdiest cart.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">A hands-on carpentry project as much as a toy — often built with an older sibling or elder's help.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\push-cart.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\rainy-day-play.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Rainy Day Play | Pickney Time Games Archive</title>
<meta name="description" content="Indoor games and activities for rainy afternoons.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-cloud-rain"></i> Rainy Day Play</span>
  <h1>Rainy Day Play</h1>
  <p class="tagline-desc">Indoor games and activities for rainy afternoons.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/rainy-day-play.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">Any number</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">Whatever's on hand indoors — cards, dominoes, storytelling</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>When rain keeps everyone inside, gather in a common space.</span></li>
<li><span class="step-num">2</span><span>Choose from indoor-friendly games like dominoes, cards, or riddles.</span></li>
<li><span class="step-num">3</span><span>Take turns telling stories or singing while waiting out the rain.</span></li>
<li><span class="step-num">4</span><span>Keep the energy up with games that don't need much room.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">A reminder that the fun never really stopped for rain — it just moved indoors.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\rainy-day-play.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\red-light-green-light.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Red Light Green Light | Pickney Time Games Archive</title>
<meta name="description" content="A universal game of movement and control.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-traffic-light"></i> Yard Games</span>
  <h1>Red Light Green Light</h1>
  <p class="tagline-desc">A universal game of movement and control.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/red-light-green-light.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">4 or more players</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">None — just open space</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>One player calls out "Green light!" and everyone moves toward them.</span></li>
<li><span class="step-num">2</span><span>When they call "Red light!", everyone must freeze instantly.</span></li>
<li><span class="step-num">3</span><span>Caught moving on red light sends you back to the start.</span></li>
<li><span class="step-num">4</span><span>First to reach the caller wins and becomes the next caller.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">A game about self-control as much as speed — the sneakiest movers usually win.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\red-light-green-light.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\riddles.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Riddles | Pickney Time Games Archive</title>
<meta name="description" content="Test your wit with Caribbean riddles and proverbs.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-brain"></i> Yard Games</span>
  <h1>Riddles</h1>
  <p class="tagline-desc">Test your wit with Caribbean riddles and proverbs.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/riddles.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">Any number, in a group</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">Just your imagination</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>One person opens with "Riddle me this, riddle me that."</span></li>
<li><span class="step-num">2</span><span>They pose a riddle — often a clever wordplay rooted in everyday Caribbean life.</span></li>
<li><span class="step-num">3</span><span>Everyone else tries to guess the answer.</span></li>
<li><span class="step-num">4</span><span>Whoever guesses right gets to pose the next riddle.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">A game of wit passed down through generations, often bridging into proverbs and Anansi story time.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\riddles.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\stilts.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Stilts | Pickney Time Games Archive</title>
<meta name="description" content="Wooden stilts for walking tall and balancing.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-person-walking"></i> Homemade Toys</span>
  <h1>Stilts</h1>
  <p class="tagline-desc">Wooden stilts for walking tall and balancing.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/stilts.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">Solo, or race with friends</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">Two long wooden poles, foot blocks, rope or nails</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Attach foot blocks to two long poles at an even height.</span></li>
<li><span class="step-num">2</span><span>Practice standing and balancing with support nearby at first.</span></li>
<li><span class="step-num">3</span><span>Once steady, try walking short distances.</span></li>
<li><span class="step-num">4</span><span>Challenge friends to short stilt races once everyone's confident.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">Walking tall (literally) was a rite of passage — patience and practice were key.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\stilts.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\stucky-freezy.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Stucky Freezy | Pickney Time Games Archive</title>
<meta name="description" content="Freeze and unfreeze — a game of quick reactions.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-snowflake"></i> Yard Games</span>
  <h1>Stucky Freezy</h1>
  <p class="tagline-desc">Freeze and unfreeze — a game of quick reactions.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/stucky-freezy.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">4 or more players</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">None — just open space</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>One or two players are chosen as taggers.</span></li>
<li><span class="step-num">2</span><span>When tagged, a player must freeze in place ("stuck").</span></li>
<li><span class="step-num">3</span><span>Frozen players can be unfrozen by a teammate tagging them.</span></li>
<li><span class="step-num">4</span><span>The round ends when everyone is frozen, or after a set time limit.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">Jamaica's answer to freeze tag — teamwork matters as much as speed.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\stucky-freezy.html" -ForegroundColor DarkGray

Set-Content -LiteralPath "$repo\pickney-time\games\wire-car.html" -Encoding UTF8 -Value @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Wire Car | Pickney Time Games Archive</title>
<meta name="description" content="A handmade car crafted from wire and imagination.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
    :root {
      --black: #090909;
      --roots-green: #0F6A3A;
      --gold: #F3C13A;
      --heritage-red: #C92828;
      --cream: #F8F4EA;
      --text-white: #F5F5F5;
      --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08);
      --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif;
      --font-accent: 'Bebas Neue', sans-serif;
      --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }

    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .powered-by-wrapper { display:flex; align-items:center; gap:10px; background:rgba(255,255,255,0.05); padding:6px 14px; border-radius:60px; border:1px solid var(--border-dim); }
    .powered-by-text { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; color:#aaa; }
    .powered-by-logo img { height:30px; width:auto; border-radius:4px; }

    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }

    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }

    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .photo-placeholder .ph-filename { font-family:monospace; font-size:0.72rem; color:rgba(243,193,58,0.6); }

    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }

    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .how-to-list { list-style:none; display:flex; flex-direction:column; gap:12px; }
    .how-to-list li { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:14px; padding:14px 18px; display:flex; gap:14px; align-items:flex-start; font-weight:300; }
    .how-to-list .step-num { flex-shrink:0; width:28px; height:28px; border-radius:50%; background:var(--roots-green); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:600; font-size:0.85rem; }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }

    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:1.5rem; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .game-card .icon { font-size:1.6rem; color:var(--gold); margin-bottom:0.8rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }

    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }

    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
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
  </div>
</header>
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/pickney-time/games/" class="">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge"><i class="fas fa-car"></i> Homemade Toys</span>
  <h1>Wire Car</h1>
  <p class="tagline-desc">A handmade car crafted from wire and imagination.</p>
</div>
<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo / Illustration Coming Soon</span>
    <span class="ph-filename">/assets/images/games/wire-car.jpg</span>
  </div>

  <div class="info-strip">
    <div class="info-chip"><div class="label">Players</div><div class="value">Solo play, often in groups</div></div>
    <div class="info-chip"><div class="label">Materials</div><div class="value">Wire (coat hangers work well), pliers</div></div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-list-ol"></i> How to Play</h2>
  <ul class="how-to-list">
<li><span class="step-num">1</span><span>Bend wire into a car frame with a long steering handle.</span></li>
<li><span class="step-num">2</span><span>Add wire or bottle-cap wheels that actually roll.</span></li>
<li><span class="step-num">3</span><span>Hold the handle and run alongside your car, steering it as you go.</span></li>
<li><span class="step-num">4</span><span>Race against friends through the yard or down the street.</span></li>
  </ul>

  <h2 class="game-section-title"><i class="fas fa-hand-holding-heart"></i> Cultural Note</h2>
  <div class="cultural-note">Building the car is half the fun — every wire car was a little different, a reflection of its builder.</div>

  <a href="/pickney-time/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>

'@
$fileCount++; Write-Host "  [OK] pickney-time\games\wire-car.html" -ForegroundColor DarkGray

Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "  Done. $fileCount files written." -ForegroundColor Green
Write-Host "  Open GitHub Desktop to review changes," -ForegroundColor Green
Write-Host "  then commit and push." -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""