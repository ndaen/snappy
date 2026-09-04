# Snappy Landing Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publier une landing page GitHub Pages pour Snappy (EN + FR) avec une démo interactive du flux de capture, dans la famille visuelle de la landing Cubby.

**Architecture:** Deux fichiers HTML autonomes dans `docs/` (`index.html`, `fr/index.html`) servis par GitHub Pages en mode `main /docs`. CSS et JS inline, aucune étape de build. La démo est un faux bureau macOS en DOM pur, dessiné à une taille fixe de 1000×625 et mis à l'échelle par `transform: scale()` ; la miniature de capture est un clone DOM du bureau décalé et masqué par `overflow: hidden`.

**Tech Stack:** HTML5, CSS3, JavaScript vanilla (pointer events, ResizeObserver), Google Fonts (Instrument Sans). Vérification avec `python3 -m http.server` et Playwright (MCP).

**Spec:** `docs/superpowers/specs/2026-09-04-landing-page-design.md`

## Global Constraints

- Repo : `ndaen/snappy`, branche `main`. URL cible : `https://ndaen.github.io/snappy/` et `/fr/`.
- Contenu de `docs/` servi publiquement : uniquement `index.html`, `fr/index.html`, `icon.png`. `docs/superpowers/` reste dans le repo mais n'est pas lié depuis le site.
- Palette : fond `#08080A`, encre `#F4F3F1`, gris `#9A9793` et `#6F6C68`, accent bleu `#5CA8FF` (clair) → `#1B62D0` (profond). Aucun miel.
- Police : Instrument Sans via Google Fonts, repli `ui-sans-serif, system-ui, -apple-system, sans-serif`.
- Seule requête réseau autorisée : `fonts.googleapis.com` / `fonts.gstatic.com`.
- JS vanilla, aucune bibliothèque, rien n'est envoyé hors de la page.
- Commits : `<type>: <description en anglais>`, une ligne, minuscules, sans `Co-Authored-By`. Toujours passer le pathspec explicite à `git commit` (le repo peut avoir des fichiers indexés par ailleurs).
- Aucune modification du code Swift, des scripts ni des releases.
- Captures Playwright dans `.claude/screenshots/playwright/` du repo Snappy ; ne garder que les preuves finales.
- Les opérations GitHub qui créent ou publient (activation de Pages, description du repo) sont faites par Noah via `!`, jamais par l'agent.

## File Structure

| Fichier | Rôle |
|---|---|
| `docs/icon.png` | Icône 512 px exportée de `Logo/icon-1024.png`, utilisée par la nav, le closing, le footer, l'OG image et le favicon. |
| `docs/index.html` | Page anglaise complète : `<head>`, CSS, markup des huit blocs, script de la démo. |
| `docs/fr/index.html` | Copie française : même CSS et même script, textes et objet de chaînes `T` traduits, chemins relatifs préfixés `../`. |
| `README.md` | Réécrit en anglais avec lien vers le site. |
| `LICENSE` | MIT, absente aujourd'hui alors que le site l'annonce. |

Le fichier `docs/index.html` est construit en couches par les tâches 1 à 6. Chaque tâche insère du CSS avant le commentaire `/* @@css-end */`, du markup à la place du commentaire `<!-- @@demo -->`, et du JS avant `/* @@js-end */`. Ces trois ancres sont posées à la tâche 1 et retirées à la tâche 7.

---

### Task 1: Page statique EN (sans démo)

**Files:**
- Create: `docs/icon.png`
- Create: `docs/index.html`

**Interfaces:**
- Produces: les ancres `/* @@css-end */`, `<!-- @@demo -->`, `/* @@js-end */` et les variables CSS `--blue`, `--blue-deep`, `--bg`, `--ink`, `--muted`, `--faint`, `--line`.

- [ ] **Step 1: Exporter l'icône**

```bash
cd ~/app-idea/snappy && mkdir -p docs && sips -z 512 512 Logo/icon-1024.png --out docs/icon.png && sips -g pixelWidth docs/icon.png
```
Attendu : `pixelWidth: 512`.

- [ ] **Step 2: Écrire `docs/index.html`**

```html
<!doctype html>
<html lang="en" class="no-js">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Snappy — capture it, then decide</title>
<meta name="description" content="Snappy is a free, open-source screenshot tool for macOS. Grab an area, a window or the screen, then copy, save, annotate or pin it from a floating overlay. OCR included.">
<meta property="og:title" content="Snappy — capture it, then decide">
<meta property="og:description" content="A free, open-source screenshot tool for macOS, with a floating overlay, annotations and OCR.">
<meta property="og:type" content="website">
<meta property="og:image" content="https://ndaen.github.io/snappy/icon.png">
<link rel="alternate" hreflang="en" href="https://ndaen.github.io/snappy/">
<link rel="alternate" hreflang="fr" href="https://ndaen.github.io/snappy/fr/">
<link rel="alternate" hreflang="x-default" href="https://ndaen.github.io/snappy/">
<link rel="icon" href="icon.png">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Instrument+Sans:wght@400;500;600&display=swap">
<script>document.documentElement.classList.replace('no-js', 'js');</script>
<style>
  :root {
    --bg: #08080A; --ink: #F4F3F1; --muted: #9A9793; --faint: #6F6C68;
    --line: rgba(255, 255, 255, 0.08);
    --blue: #5CA8FF; --blue-deep: #1B62D0;
    --blue-a: 92, 168, 255;
    --pad: 64px;
  }
  * { box-sizing: border-box; }
  html { scroll-behavior: smooth; }
  body {
    margin: 0; background: var(--bg); color: var(--ink);
    font-family: "Instrument Sans", ui-sans-serif, system-ui, -apple-system, sans-serif;
    -webkit-font-smoothing: antialiased; overflow-x: hidden;
  }
  h1, h2, h3 { margin: 0; font-weight: 600; letter-spacing: -0.035em; }
  p { margin: 0; }
  a { color: var(--blue); text-decoration: none; }
  a:hover { color: #9CC9FF; }
  img { max-width: 100%; display: block; }
  code { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; font-size: 0.92em; }

  .wrap { max-width: 1280px; margin: 0 auto; padding-inline: var(--pad); }
  .eyebrow { font-size: 12.5px; font-weight: 600; letter-spacing: 0.08em; text-transform: uppercase; color: var(--blue); }
  .lead { font-size: 17px; line-height: 1.55; color: var(--muted); text-wrap: pretty; }

  .glow {
    position: absolute; top: -280px; left: 50%; transform: translateX(-50%);
    width: min(1100px, 130vw); height: 700px; pointer-events: none; z-index: 0;
    background: radial-gradient(closest-side, rgba(var(--blue-a), 0.16), rgba(var(--blue-a), 0) 70%);
  }
  .hairline {
    position: absolute; inset: 0 0 auto; height: 1px;
    background: linear-gradient(90deg, rgba(var(--blue-a), 0) 0%, rgba(var(--blue-a), 0.5) 50%, rgba(var(--blue-a), 0) 100%);
  }
  main { position: relative; z-index: 1; }

  /* nav */
  .nav { display: flex; align-items: center; justify-content: space-between; padding-block: 20px; border-bottom: 1px solid rgba(255,255,255,0.06); }
  .brand { display: flex; align-items: center; gap: 10px; }
  .brand img { width: 26px; height: 26px; border-radius: 7px; }
  .brand span { font-size: 15px; font-weight: 600; letter-spacing: -0.02em; }
  .tag { font-size: 11px; font-weight: 500; color: #8E8B86; border: 1px solid rgba(255,255,255,0.1); border-radius: 5px; padding: 2px 6px; }
  .nav-links { display: flex; align-items: center; gap: 28px; }
  .nav-links a { font-size: 14px; color: var(--muted); }
  .nav-links a:hover { color: var(--ink); }
  .lang-switch { display: inline-flex; align-items: center; gap: 5px; padding: 5px 8px; border-radius: 7px; }
  .lang-switch:hover { color: var(--ink) !important; background: rgba(255,255,255,0.06); }
  .nav-gh { display: flex; align-items: center; gap: 7px; color: var(--ink) !important; border: 1px solid rgba(255,255,255,0.12); background: rgba(255,255,255,0.04); border-radius: 8px; padding: 7px 12px; }
  .nav-gh:hover { background: rgba(255,255,255,0.08); }

  /* buttons */
  .btn { display: inline-flex; align-items: center; justify-content: center; gap: 9px; font-size: 15px; font-weight: 600; letter-spacing: -0.01em; border-radius: 10px; padding: 13px 20px; transition: transform 0.15s ease, filter 0.15s ease; }
  .btn:hover { transform: translateY(-1px); }
  .btn-primary { background: linear-gradient(180deg, #5CA8FF 0%, #2B74E0 100%); color: #06111F !important; box-shadow: 0 6px 24px rgba(var(--blue-a), 0.25), inset 0 1px 0 rgba(255,255,255,0.35); }
  .btn-primary:hover { filter: brightness(1.06); }
  .btn-ghost { color: var(--ink) !important; font-weight: 500; border: 1px solid rgba(255,255,255,0.14); background: rgba(255,255,255,0.035); }
  .btn-ghost:hover { background: rgba(255,255,255,0.07); }

  /* hero */
  .hero { display: flex; flex-direction: column; align-items: center; text-align: center; padding-top: 96px; }
  .badge { display: inline-flex; align-items: center; gap: 8px; border: 1px solid rgba(var(--blue-a), 0.25); background: rgba(var(--blue-a), 0.07); border-radius: 999px; padding: 5px 12px 5px 9px; font-size: 12.5px; color: #9CC9FF; }
  .hero h1 { margin-top: 26px; font-size: clamp(40px, 6vw, 76px); line-height: 1.02; letter-spacing: -0.04em; max-width: 880px; text-wrap: balance; }
  .hero h1 em { font-style: normal; background: linear-gradient(180deg, #7DBBFF 0%, #2B74E0 100%); -webkit-background-clip: text; background-clip: text; color: transparent; }
  .hero .lead { margin-top: 24px; font-size: clamp(16px, 1.6vw, 19px); max-width: 640px; }
  .cta-row { display: flex; flex-wrap: wrap; justify-content: center; gap: 12px; margin-top: 36px; }
  .fine { margin-top: 16px; font-size: 13px; color: var(--faint); }

  /* viewfinder corners, the Snappy motif */
  .vf { position: relative; }
  .vf::before, .vf::after, .vf > .vf-b::before, .vf > .vf-b::after {
    content: ""; position: absolute; width: 14px; height: 14px; border: 2px solid var(--blue);
    opacity: 0; transition: opacity 0.2s ease;
  }
  .vf::before { top: 10px; left: 10px; border-right: 0; border-bottom: 0; border-radius: 4px 0 0 0; }
  .vf::after { top: 10px; right: 10px; border-left: 0; border-bottom: 0; border-radius: 0 4px 0 0; }
  .vf > .vf-b::before { bottom: 10px; left: 10px; border-right: 0; border-top: 0; border-radius: 0 0 0 4px; }
  .vf > .vf-b::after { bottom: 10px; right: 10px; border-left: 0; border-top: 0; border-radius: 0 0 4px 0; }
  .vf:hover::before, .vf:hover::after, .vf:hover > .vf-b::before, .vf:hover > .vf-b::after { opacity: 1; }

  /* sections */
  .section { padding-top: 112px; }
  .section h2 { margin-top: 14px; font-size: clamp(30px, 3.6vw, 42px); line-height: 1.08; }
  .section .lead { margin-top: 16px; }
  .intro { max-width: 640px; }
  .cards { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 20px; margin-top: 48px; }
  .card { border: 1px solid var(--line); border-radius: 16px; padding: 26px; background: linear-gradient(180deg, rgba(255,255,255,0.035), rgba(255,255,255,0.012)); display: flex; flex-direction: column; gap: 14px; }
  .card-ico { width: 38px; height: 38px; border-radius: 10px; color: var(--blue); border: 1px solid rgba(var(--blue-a), 0.25); background: rgba(var(--blue-a), 0.1); display: flex; align-items: center; justify-content: center; }
  .card h3 { font-size: 19px; letter-spacing: -0.025em; }
  .card p { font-size: 15px; line-height: 1.55; color: var(--muted); text-wrap: pretty; }

  .split { display: grid; grid-template-columns: minmax(0, 0.85fr) minmax(0, 1fr); gap: 56px; align-items: start; }
  .steps { display: flex; flex-direction: column; gap: 12px; }
  .step { display: flex; gap: 16px; align-items: flex-start; padding: 20px 22px; border: 1px solid var(--line); border-radius: 14px; background: linear-gradient(180deg, rgba(255,255,255,0.035), rgba(255,255,255,0.012)); }
  .step b { flex-shrink: 0; width: 26px; height: 26px; border-radius: 8px; background: rgba(var(--blue-a), 0.12); border: 1px solid rgba(var(--blue-a), 0.25); color: var(--blue); font-size: 13px; font-weight: 600; display: flex; align-items: center; justify-content: center; }
  .step h3 { font-size: 16px; letter-spacing: -0.02em; }
  .step p { margin-top: 5px; font-size: 14.5px; line-height: 1.5; color: var(--muted); }
  .step strong { color: var(--ink); font-weight: 400; }
  .aside { margin-top: 22px; font-size: 15px; line-height: 1.55; color: #7A7772; }
  pre.sh { margin: 22px 0 0; padding: 16px 18px; border: 1px solid var(--line); border-radius: 12px; background: #0D0D10; font-size: 13.5px; line-height: 1.6; color: #C8C4BE; overflow-x: auto; }
  pre.sh i { font-style: normal; color: var(--faint); }

  .keys { margin-top: 40px; border: 1px solid var(--line); border-radius: 14px; overflow: hidden; }
  .keys table { width: 100%; border-collapse: collapse; }
  .keys td { padding: 18px 22px; font-size: 15px; border-top: 1px solid var(--line); }
  .keys tr:first-child td { border-top: 0; }
  .keys td:last-child { text-align: right; white-space: nowrap; }
  kbd { display: inline-block; min-width: 30px; padding: 4px 8px; margin-left: 4px; border-radius: 7px; border: 1px solid rgba(255,255,255,0.14); background: rgba(255,255,255,0.05); box-shadow: inset 0 -1px 0 rgba(0,0,0,0.5); font: 500 13px/1 ui-sans-serif, system-ui; text-align: center; }
  .note { display: flex; align-items: center; gap: 20px; margin-top: 24px; padding: 20px 24px; border: 1px solid var(--line); border-radius: 14px; background: rgba(255,255,255,0.02); }
  .note p { font-size: 15px; line-height: 1.5; color: var(--muted); }
  .note strong { color: var(--ink); font-weight: 400; }

  .closing { margin-top: 112px; padding: 64px 40px; text-align: center; overflow: hidden; border: 1px solid rgba(var(--blue-a), 0.2); border-radius: 20px; background: radial-gradient(100% 140% at 50% 0%, rgba(var(--blue-a), 0.14), rgba(var(--blue-a), 0) 70%), #0B0A0C; }
  .closing img { width: 56px; height: 56px; border-radius: 14px; margin: 0 auto; }
  .closing h2 { margin-top: 22px; font-size: clamp(28px, 3.4vw, 40px); line-height: 1.1; }
  .closing p { margin-top: 14px; font-size: 17px; color: var(--muted); }

  .foot { display: flex; align-items: center; justify-content: space-between; gap: 20px; margin-top: 88px; padding-block: 28px 40px; border-top: 1px solid rgba(255,255,255,0.06); font-size: 13.5px; }
  .foot-brand { display: flex; align-items: center; gap: 10px; color: var(--faint); }
  .foot-brand img { width: 20px; height: 20px; border-radius: 6px; }
  .foot-links { display: flex; align-items: center; gap: 24px; }
  .foot-links a { color: var(--muted); }
  .foot-links a:hover { color: var(--ink); }

  @media (max-width: 900px) {
    :root { --pad: 28px; }
    .cards { grid-template-columns: 1fr; }
    .split { grid-template-columns: 1fr; gap: 40px; }
    .nav-links a:not(.nav-gh):not(.lang-switch) { display: none; }
  }
  @media (max-width: 620px) {
    .hero { padding-top: 64px; }
    .foot { flex-direction: column; align-items: flex-start; }
  }
  @media (prefers-reduced-motion: reduce) {
    html { scroll-behavior: auto; }
    .btn, .vf::before, .vf::after { transition: none; }
  }
  /* @@css-end */
</style>
</head>
<body>

<div class="glow"></div>
<div class="hairline"></div>

<main>
  <div class="wrap">
    <nav class="nav">
      <div class="brand">
        <img src="icon.png" alt="Snappy">
        <span>Snappy</span>
        <span class="tag">macOS</span>
      </div>
      <div class="nav-links">
        <a href="#features">Features</a>
        <a href="#install">Install</a>
        <a href="#shortcuts">Shortcuts</a>
        <a class="lang-switch" href="fr/" hreflang="fr"><svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a15 15 0 0 1 0 18a15 15 0 0 1 0-18"/></svg>FR</a>
        <a class="nav-gh" href="https://github.com/ndaen/snappy">
          <svg width="15" height="15" viewBox="0 0 16 16" fill="currentColor" aria-hidden="true"><path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82a7.4 7.4 0 0 1 2-.27c.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.01 8.01 0 0 0 16 8c0-4.42-3.58-8-8-8Z"/></svg>
          GitHub
        </a>
      </div>
    </nav>
  </div>

  <div class="wrap">
    <section class="hero">
      <span class="badge">
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 3l2.6 5.6 6.1.8-4.5 4.2 1.2 6-5.4-3-5.4 3 1.2-6L3.3 9.4l6.1-.8z"/></svg>
        Free and open source — MIT
      </span>
      <h1>Capture it.<br><em>Then decide.</em></h1>
      <p class="lead">Snappy is a lightweight screenshot tool for your Mac. Grab an area, a window or the whole screen, then copy, save, annotate or pin it from a floating overlay, without cluttering your desktop.</p>
      <div class="cta-row">
        <a class="btn btn-primary" href="https://github.com/ndaen/snappy/releases/latest">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M16.4 12.7c0-2.2 1.8-3.2 1.9-3.3-1-1.5-2.6-1.7-3.2-1.7-1.4-.1-2.7.8-3.3.8-.7 0-1.7-.8-2.8-.8-1.5 0-2.8.9-3.6 2.2-1.5 2.6-.4 6.5 1.1 8.6.7 1 1.6 2.2 2.7 2.2 1.1 0 1.5-.7 2.8-.7s1.7.7 2.8.7c1.2 0 1.9-1 2.6-2.1.8-1.2 1.2-2.4 1.2-2.4s-2.2-.9-2.2-3.5Zm-2.3-6.4c.6-.7 1-1.7.9-2.7-.9 0-2 .6-2.6 1.3-.6.6-1.1 1.7-.9 2.6 1 .1 2-.5 2.6-1.2Z"/></svg>
          Download for macOS
        </a>
        <a class="btn btn-ghost" href="https://github.com/ndaen/snappy">
          See it on GitHub
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h13M13 6l6 6-6 6"/></svg>
        </a>
      </div>
      <p class="fine">macOS 14 or later · Apple silicon · unsigned build, see <a href="#install">install</a></p>
    </section>
  </div>

  <!-- @@demo -->

  <div class="wrap">
    <section class="section" id="features">
      <div class="intro">
        <span class="eyebrow">Features</span>
        <h2>Three things, no ceremony.</h2>
        <p class="lead">Every shot lands in an overlay first. Nothing hits your desktop until you say so.</p>
      </div>
      <div class="cards">
        <article class="card vf"><span class="vf-b"></span>
          <div class="card-ico"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M4 9V6a2 2 0 0 1 2-2h3M15 4h3a2 2 0 0 1 2 2v3M20 15v3a2 2 0 0 1-2 2h-3M9 20H6a2 2 0 0 1-2-2v-3"/></svg></div>
          <h3>Capture, then choose</h3>
          <p>Area, window or full screen, with global shortcuts and the native macOS selection. The overlay lets you copy without saving, save to the desktop, pin it on top, or drag it straight into Finder or any app.</p>
        </article>
        <article class="card vf"><span class="vf-b"></span>
          <div class="card-ico"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M4 7V5h16v2M12 5v14M9 19h6"/></svg></div>
          <h3>Text from anywhere</h3>
          <p>Select a region and the text inside it lands in your clipboard. French and English, powered by Apple's Vision framework, fully offline.</p>
        </article>
        <article class="card vf"><span class="vf-b"></span>
          <div class="card-ico"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 20l4-1 11-11-3-3L5 16z"/><path d="M13 7l3 3"/></svg></div>
          <h3>Annotate and export</h3>
          <p>Arrow, rectangle, highlight, text and pixelated blur. Exported at the original resolution, every time.</p>
        </article>
      </div>
    </section>
  </div>

  <div class="wrap">
    <section class="section split" id="install">
      <div>
        <span class="eyebrow">Install</span>
        <h2>Two minutes, one permission.</h2>
        <p class="lead">The build is not notarized, so macOS asks twice. Once you're through, it just works.</p>
        <p class="aside">Or build it yourself. Swift Package Manager, no Xcode project.</p>
        <pre class="sh"><i># installs Snappy.app into /Applications</i>
bash scripts/build-app.sh</pre>
      </div>
      <div class="steps">
        <div class="step"><b>1</b><div><h3>Download the DMG</h3><p>Grab the <a href="https://github.com/ndaen/snappy/releases/latest">latest release</a> and drag <strong>Snappy.app</strong> into <strong>/Applications</strong>.</p></div></div>
        <div class="step"><b>2</b><div><h3>Open it once, the hard way</h3><p>On first launch macOS refuses it. Go to <strong>System Settings › Privacy &amp; Security</strong> and click <strong>Open Anyway</strong>. Right-click › Open no longer works on macOS 15.</p></div></div>
        <div class="step"><b>3</b><div><h3>Allow screen recording</h3><p>Accept the <strong>Screen Recording</strong> prompt, then quit and relaunch Snappy. It can't capture anything before that.</p></div></div>
      </div>
    </section>
  </div>

  <div class="wrap">
    <section class="section" id="shortcuts">
      <div class="intro">
        <span class="eyebrow">Shortcuts</span>
        <h2>Three shortcuts to remember.</h2>
        <p class="lead">All of them are yours to change in Settings.</p>
      </div>
      <div class="keys"><table>
        <tr><td>Capture an area or a window</td><td><kbd>⌘</kbd><kbd>⇧</kbd><kbd>1</kbd></td></tr>
        <tr><td>Capture the whole screen</td><td><kbd>⌘</kbd><kbd>⇧</kbd><kbd>2</kbd></td></tr>
        <tr><td>Copy text from a region (OCR)</td><td><kbd>⌘</kbd><kbd>⇧</kbd><kbd>0</kbd></td></tr>
      </table></div>
      <div class="note"><p><strong>Use as default</strong>, in Settings, swaps macOS's own ⌘⇧3 and ⌘⇧4 for Snappy.</p></div>
    </section>
  </div>

  <div class="wrap">
    <section class="closing">
      <img src="icon.png" alt="">
      <h2>Take the shot. Keep your desktop.</h2>
      <p>Free, open source, and lighter than the app it replaces.</p>
      <div class="cta-row">
        <a class="btn btn-primary" href="https://github.com/ndaen/snappy/releases/latest">Download for macOS</a>
        <a class="btn btn-ghost" href="https://github.com/ndaen/snappy">See it on GitHub</a>
      </div>
    </section>
  </div>

  <div class="wrap">
    <footer class="foot">
      <div class="foot-brand">
        <img src="icon.png" alt="">
        <span>Snappy — free and open source, under the MIT licence.</span>
      </div>
      <div class="foot-links">
        <a href="https://github.com/ndaen/snappy">GitHub</a>
        <a href="https://github.com/ndaen/snappy/releases">Releases</a>
        <a href="https://github.com/ndaen/snappy/issues">Issues</a>
        <a href="https://ndaen.github.io/cubby-mac/">Cubby, from the same shelf</a>
      </div>
    </footer>
  </div>
</main>

<script>
/* @@js-end */
</script>
</body>
</html>
```

- [ ] **Step 3: Servir et vérifier**

```bash
cd ~/app-idea/snappy/docs && (python3 -m http.server 8765 >/dev/null 2>&1 &) && sleep 1 && curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8765/ && curl -s http://localhost:8765/ | grep -c '@@'
```
Attendu : `200` puis `3` (les trois ancres présentes).

Avec Playwright (MCP) : ouvrir `http://localhost:8765/`, viewport 1280×900, capture dans `.claude/screenshots/playwright/task1-en-desktop.png`, puis viewport 390×844, capture `task1-en-mobile.png`. Vérifier qu'aucun message console n'est une erreur et que `document.body.scrollWidth <= window.innerWidth` sur les deux viewports.

- [ ] **Step 4: Commit**

```bash
cd ~/app-idea/snappy && git add docs/icon.png docs/index.html && git commit -m "feat: static landing page (en)" -- docs/icon.png docs/index.html
```

---

### Task 2: Faux bureau statique (repli sans JS)

**Files:**
- Modify: `docs/index.html` (remplacer `<!-- @@demo -->`, ajouter du CSS avant `/* @@css-end */`)

**Interfaces:**
- Produces: la structure DOM `#stage > .desk > .scene` (1000×625 px) avec `.sel`, `.dim`, `.overlay`, `.toast`, `.pin`, `#note-text` composé de `<span class="ln">`. Le `.desk` est mis à l'échelle via la variable CSS `--k`.

- [ ] **Step 1: Ajouter le CSS de la démo avant `/* @@css-end */`**

```css
  /* demo: fake desktop */
  .stage { position: relative; margin-top: 64px; border: 1px solid var(--line); border-radius: 20px; background: #0D0C0E; overflow: hidden; }
  .stage-tools { display: flex; align-items: center; justify-content: space-between; gap: 16px; padding: 14px 20px; border-top: 1px solid var(--line); font-size: 13.5px; color: #7A7772; }
  .stage-tools button { font: inherit; font-size: 13px; font-weight: 500; color: var(--ink); background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.14); border-radius: 8px; padding: 7px 12px; cursor: pointer; }
  .stage-tools button:hover { background: rgba(255,255,255,0.1); }
  .stage-tools button[aria-pressed="true"] { background: rgba(var(--blue-a), 0.16); border-color: rgba(var(--blue-a), 0.4); color: #9CC9FF; }
  .desk-wrap { position: relative; width: 100%; aspect-ratio: 1000 / 625; overflow: hidden; }
  .desk { --k: 1; position: absolute; top: 0; left: 0; width: 1000px; height: 625px; transform: scale(var(--k)); transform-origin: top left; user-select: none; -webkit-user-select: none; touch-action: none; }
  .desk.mode-capture, .desk.mode-ocr { cursor: crosshair; }
  .scene { position: absolute; inset: 0; background: radial-gradient(120% 90% at 20% 0%, #1D2A44 0%, #101521 45%, #0B0D14 100%); }
  .mb { position: absolute; top: 0; left: 0; right: 0; height: 28px; display: flex; align-items: center; justify-content: space-between; padding-inline: 16px; font-size: 12px; color: rgba(244,243,241,0.7); background: rgba(255,255,255,0.06); backdrop-filter: blur(10px); }
  .mb div { display: flex; gap: 14px; }
  .mb b { font-weight: 600; }
  .win { position: absolute; top: 76px; left: 110px; width: 560px; height: 420px; border-radius: 12px; background: #1B1B1F; border: 1px solid rgba(255,255,255,0.1); box-shadow: 0 30px 60px rgba(0,0,0,0.5); overflow: hidden; }
  .win-bar { height: 38px; display: flex; align-items: center; gap: 8px; padding-inline: 14px; background: #232327; border-bottom: 1px solid rgba(255,255,255,0.06); font-size: 12px; color: rgba(244,243,241,0.5); }
  .win-bar i { width: 12px; height: 12px; border-radius: 50%; display: inline-block; }
  .win-bar i:nth-child(1) { background: #FF5F57; } .win-bar i:nth-child(2) { background: #FEBC2E; } .win-bar i:nth-child(3) { background: #28C840; }
  .win-bar span { margin-left: 10px; }
  .win-body { padding: 22px 26px; }
  .win-body h4 { margin: 0 0 12px; font-size: 20px; font-weight: 600; letter-spacing: -0.03em; }
  #note-text { font-size: 14.5px; line-height: 1.6; color: rgba(244,243,241,0.78); }
  #note-text .ln { display: block; }
  .chart { position: absolute; top: 120px; left: 700px; width: 190px; height: 240px; border-radius: 12px; background: #1B1B1F; border: 1px solid rgba(255,255,255,0.1); box-shadow: 0 30px 60px rgba(0,0,0,0.5); padding: 16px; display: flex; flex-direction: column; gap: 10px; }
  .chart span { font-size: 12px; color: rgba(244,243,241,0.5); }
  .bars { flex: 1; display: flex; align-items: flex-end; gap: 8px; }
  .bars i { flex: 1; border-radius: 4px 4px 0 0; background: linear-gradient(180deg, #5CA8FF, #1B62D0); }
  .dock { position: absolute; bottom: 10px; left: 50%; transform: translateX(-50%); display: flex; gap: 10px; padding: 8px 12px; border-radius: 18px; background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.1); backdrop-filter: blur(14px); }
  .dock i { width: 40px; height: 40px; border-radius: 11px; background: linear-gradient(160deg, rgba(255,255,255,0.35), rgba(255,255,255,0.08)); }
  .dock i.snappy { background: url(icon.png) center / cover; }
  .hint { position: absolute; top: 40px; right: 26px; font-size: 12.5px; color: rgba(244,243,241,0.55); background: rgba(0,0,0,0.35); border: 1px solid rgba(255,255,255,0.1); border-radius: 999px; padding: 6px 12px; pointer-events: none; transition: opacity 0.2s; }
  .desk.is-busy .hint { opacity: 0; }

  /* selection */
  .sel { position: absolute; display: none; border: 1px solid rgba(255,255,255,0.9); outline: 1px dashed rgba(0,0,0,0.6); outline-offset: -1px; box-shadow: 0 0 0 4000px rgba(0,0,0,0.45); pointer-events: none; }
  .sel.on { display: block; }
  .sel.ocr { border-color: var(--blue); box-shadow: 0 0 0 4000px rgba(var(--blue-a), 0.12); }
  .dim { position: absolute; display: none; font: 500 11px/1 ui-monospace, Menlo, monospace; color: #fff; background: rgba(0,0,0,0.75); border-radius: 5px; padding: 4px 6px; pointer-events: none; white-space: nowrap; }
  .dim.on { display: block; }
  .flash { position: absolute; inset: 0; background: #fff; opacity: 0; pointer-events: none; }
  .flash.go { animation: flash 0.18s ease-out; }
  @keyframes flash { from { opacity: 0.85; } to { opacity: 0; } }
  .ocr-hl { position: absolute; background: rgba(var(--blue-a), 0.35); border-radius: 3px; pointer-events: none; }

  /* floating overlay */
  .overlay { position: absolute; right: 22px; bottom: 74px; width: 240px; display: none; flex-direction: column; gap: 10px; padding: 10px; border-radius: 16px; background: rgba(28,28,32,0.72); border: 1px solid rgba(255,255,255,0.14); backdrop-filter: blur(24px) saturate(160%); box-shadow: 0 24px 60px rgba(0,0,0,0.55), inset 0 1px 0 rgba(255,255,255,0.12); transform-origin: bottom right; }
  .overlay.on { display: flex; animation: pop 0.22s cubic-bezier(0.2, 0.9, 0.3, 1.2); }
  @keyframes pop { from { opacity: 0; transform: scale(0.85) translateY(10px); } to { opacity: 1; transform: none; } }
  .thumb { position: relative; width: 100%; aspect-ratio: 16 / 10; border-radius: 10px; overflow: hidden; background: #000; box-shadow: 0 0 0 1px rgba(255,255,255,0.12); }
  .thumb .shot { position: absolute; top: 0; left: 0; width: 1000px; height: 625px; transform-origin: top left; pointer-events: none; }
  .thumb .vfc { position: absolute; width: 12px; height: 12px; border: 2px solid var(--blue); }
  .thumb .vfc:nth-child(1) { top: 6px; left: 6px; border-right: 0; border-bottom: 0; }
  .thumb .vfc:nth-child(2) { top: 6px; right: 6px; border-left: 0; border-bottom: 0; }
  .thumb .vfc:nth-child(3) { bottom: 6px; left: 6px; border-right: 0; border-top: 0; }
  .thumb .vfc:nth-child(4) { bottom: 6px; right: 6px; border-left: 0; border-top: 0; }
  .acts { display: grid; grid-template-columns: repeat(4, 1fr); gap: 6px; }
  .acts button { display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 8px 4px; border: 0; border-radius: 10px; background: rgba(255,255,255,0.06); color: rgba(244,243,241,0.85); font: inherit; font-size: 10.5px; cursor: pointer; }
  .acts button:hover { background: rgba(255,255,255,0.14); color: #fff; }
  .acts svg { width: 16px; height: 16px; }

  .toast { position: absolute; left: 50%; bottom: 84px; transform: translateX(-50%) translateY(8px); max-width: 70%; padding: 9px 14px; border-radius: 10px; background: rgba(28,28,32,0.85); border: 1px solid rgba(255,255,255,0.14); backdrop-filter: blur(16px); font-size: 12.5px; color: #fff; opacity: 0; pointer-events: none; transition: opacity 0.18s, transform 0.18s; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
  .toast.on { opacity: 1; transform: translateX(-50%); }
  .pin { position: absolute; top: 40px; left: 26px; display: none; border-radius: 10px; overflow: hidden; box-shadow: 0 16px 40px rgba(0,0,0,0.6), 0 0 0 1px rgba(255,255,255,0.18); }
  .pin.on { display: block; }
  .pin .shot { position: absolute; top: 0; left: 0; width: 1000px; height: 625px; transform-origin: top left; }

  /* no-JS: frozen mid-capture, overlay open */
  .no-js .sel, .no-js .dim, .no-js .overlay { display: block; }
  .no-js .overlay { display: flex; }
  .no-js .stage-tools button, .no-js .hint { display: none; }
  .stage .caption { padding: 0 20px 20px; text-align: center; font-size: 13.5px; color: #7A7772; }
  @media (max-width: 640px) { .stage-tools { flex-direction: column; align-items: flex-start; } }
  @media (prefers-reduced-motion: reduce) { .flash.go, .overlay.on { animation: none; } .toast, .hint { transition: none; } }
```

- [ ] **Step 2: Remplacer `<!-- @@demo -->` par le markup**

```html
  <div class="wrap">
    <section class="stage" id="stage" aria-label="Interactive demo of a Snappy capture">
      <div class="desk-wrap">
        <div class="desk mode-capture" id="desk">
          <div class="scene" id="scene">
            <div class="mb"><div><b></b><b>Notes</b><span>File</span><span>Edit</span><span>View</span></div><div><span>Thu 14:32</span></div></div>
            <div class="win">
              <div class="win-bar"><i></i><i></i><i></i><span>Release notes.md</span></div>
              <div class="win-body">
                <h4>Snappy 0.2 — what's new</h4>
                <p id="note-text">
                  <span class="ln">Capture an area and copy it without saving a file.</span>
                  <span class="ln">Select any text on screen and it lands in your clipboard.</span>
                  <span class="ln">Annotate with arrows, boxes and pixelated blur, then export</span>
                  <span class="ln">at the original resolution. Pinned shots stay on top of</span>
                  <span class="ln">everything until you dismiss them.</span>
                </p>
              </div>
            </div>
            <div class="chart"><span>Shots this week</span><div class="bars"><i style="height:35%"></i><i style="height:60%"></i><i style="height:45%"></i><i style="height:80%"></i><i style="height:55%"></i><i style="height:95%"></i><i style="height:70%"></i></div></div>
            <div class="dock"><i></i><i></i><i class="snappy"></i><i></i><i></i></div>
          </div>
          <div class="hint" id="hint">Drag anywhere to capture</div>
          <div class="sel" id="sel" style="left:140px;top:110px;width:500px;height:210px"></div>
          <div class="dim" id="dim" style="left:140px;top:326px">500 × 210</div>
          <div class="flash" id="flash"></div>
          <div class="pin" id="pin"></div>
          <div class="overlay" id="overlay">
            <div class="thumb" id="thumb"><span class="vfc"></span><span class="vfc"></span><span class="vfc"></span><span class="vfc"></span></div>
            <div class="acts">
              <button type="button" data-act="copy"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="9" y="9" width="11" height="11" rx="2"/><path d="M5 15V5a1 1 0 0 1 1-1h10"/></svg>Copy</button>
              <button type="button" data-act="save"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 4v11M7 10l5 5 5-5M5 20h14"/></svg>Save</button>
              <button type="button" data-act="annotate"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 20l4-1 11-11-3-3L5 16z"/></svg>Annotate</button>
              <button type="button" data-act="pin"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 17v5M8 3h8l-1 6 3 3H6l3-3z"/></svg>Pin</button>
            </div>
          </div>
          <div class="toast" id="toast"></div>
        </div>
      </div>
      <div class="stage-tools">
        <span id="stage-msg">Drag on the desktop to capture. Nothing leaves this page.</span>
        <button type="button" id="ocr-btn" aria-pressed="false">Try OCR <kbd>⌘</kbd><kbd>⇧</kbd><kbd>0</kbd></button>
      </div>
    </section>
  </div>
```

- [ ] **Step 3: Vérifier le rendu sans JS**

Playwright : ouvrir `http://localhost:8765/` avec JavaScript désactivé (via `browser_run_code_unsafe` : `context.route` non nécessaire, utiliser `page.addInitScript` impossible ; à la place, ouvrir la page puis exécuter `document.documentElement.className='no-js'` avec `browser_evaluate`). Vérifier que `.sel`, `.dim` et `.overlay` sont visibles (`getComputedStyle(el).display !== 'none'`). Capture `task2-nojs.png` à 1280 px. Vérifier `document.body.scrollWidth <= window.innerWidth` à 390 px.

- [ ] **Step 4: Commit**

```bash
cd ~/app-idea/snappy && git commit -m "feat: static fake desktop for the demo" -- docs/index.html
```

---

### Task 3: Sélection, overlay, Copy / Save / Pin

**Files:**
- Modify: `docs/index.html` (JS avant `/* @@js-end */`)

**Interfaces:**
- Produces: dans le script, les fonctions `setSel(x, y, w, h)`, `finishSel()`, `showToast(msg, ms)`, `closeOverlay()`, `toDesk(ev)` et l'objet de chaînes `T`. La variable `mode` vaut `'capture'` ou `'ocr'`. `rect` = `{x, y, w, h}` de la dernière sélection en coordonnées bureau.

- [ ] **Step 1: Écrire le script de base avant `/* @@js-end */`**

```js
(() => {
  const T = {
    copied: 'Copied to clipboard',
    saved: 'Saved to Desktop',
    pinned: 'Pinned on top',
    exported: 'Exported at original resolution',
    ocrHint: 'Select some text to copy it',
    captureHint: 'Drag anywhere to capture',
    ocrMsg: 'OCR mode: drag over the note to copy its text.',
    captureMsg: 'Drag on the desktop to capture. Nothing leaves this page.',
    ocrEmpty: 'No text in that area',
    ocrDone: 'Copied: '
  };
  const $ = (id) => document.getElementById(id);
  const desk = $('desk'), scene = $('scene'), sel = $('sel'), dim = $('dim'), flash = $('flash');
  const overlay = $('overlay'), thumb = $('thumb'), toast = $('toast'), pin = $('pin');
  const hint = $('hint'), msg = $('stage-msg'), ocrBtn = $('ocr-btn');
  const W = 1000, H = 625, MIN = 24;
  let mode = 'capture', dragging = false, start = null, rect = null, toastTimer = 0;

  // scale the 1000×625 desk to its container
  const wrap = desk.parentElement;
  const fit = () => desk.style.setProperty('--k', wrap.clientWidth / W);
  new ResizeObserver(fit).observe(wrap);
  fit();

  const k = () => wrap.clientWidth / W;
  const toDesk = (ev) => {
    const b = wrap.getBoundingClientRect();
    return { x: Math.max(0, Math.min(W, (ev.clientX - b.left) / k())), y: Math.max(0, Math.min(H, (ev.clientY - b.top) / k())) };
  };

  function setSel(x, y, w, h) {
    rect = { x, y, w, h };
    sel.style.cssText = `left:${x}px;top:${y}px;width:${w}px;height:${h}px`;
    sel.classList.add('on');
    sel.classList.toggle('ocr', mode === 'ocr');
    dim.textContent = `${Math.round(w)} × ${Math.round(h)}`;
    dim.style.cssText = `left:${x}px;top:${Math.min(H - 22, y + h + 6)}px`;
    dim.classList.add('on');
  }
  function clearSel() { sel.classList.remove('on'); dim.classList.remove('on'); }

  function showToast(text, ms = 1400) {
    toast.textContent = text; toast.classList.add('on');
    clearTimeout(toastTimer); toastTimer = setTimeout(() => toast.classList.remove('on'), ms);
  }

  // clone the scene, offset so only `rect` shows, scaled to fit `box`
  function makeShot(box) {
    const r = rect, s = Math.min(box.clientWidth / r.w, box.clientHeight / r.h);
    const shot = scene.cloneNode(true);
    shot.removeAttribute('id'); shot.className = 'shot';
    shot.style.transform = `scale(${s}) translate(${-r.x}px, ${-r.y}px)`;
    return shot;
  }
  function openOverlay() {
    thumb.querySelectorAll('.shot, svg, .blur').forEach((n) => n.remove());
    overlay.classList.add('on');
    overlay.classList.remove('is-editing');
    thumb.style.aspectRatio = `${rect.w} / ${rect.h}`;
    thumb.prepend(makeShot(thumb));
  }
  function closeOverlay() { overlay.classList.remove('on'); clearSel(); desk.classList.remove('is-busy'); }

  function finishSel() {
    if (!rect || rect.w < MIN || rect.h < MIN) { clearSel(); desk.classList.remove('is-busy'); return; }
    if (mode === 'ocr') return finishOcr();
    flash.classList.remove('go'); void flash.offsetWidth; flash.classList.add('go');
    setTimeout(openOverlay, 160);
  }
  let finishOcr = () => {}; // replaced in the OCR task

  // pointer handling
  desk.addEventListener('pointerdown', (ev) => {
    if (ev.button !== 0 || overlay.contains(ev.target) || overlay.classList.contains('is-editing')) return;
    overlay.classList.remove('on'); pin.classList.remove('on');
    desk.querySelectorAll('.ocr-hl').forEach((n) => n.remove());
    dragging = true; start = toDesk(ev); desk.classList.add('is-busy');
    desk.setPointerCapture(ev.pointerId); setSel(start.x, start.y, 0, 0);
  });
  desk.addEventListener('pointermove', (ev) => {
    if (!dragging) return;
    const p = toDesk(ev);
    setSel(Math.min(start.x, p.x), Math.min(start.y, p.y), Math.abs(p.x - start.x), Math.abs(p.y - start.y));
  });
  const up = (ev) => { if (!dragging) return; dragging = false; desk.releasePointerCapture?.(ev.pointerId); finishSel(); };
  desk.addEventListener('pointerup', up);
  desk.addEventListener('pointercancel', up);

  // overlay actions
  overlay.addEventListener('click', (ev) => {
    const b = ev.target.closest('[data-act]'); if (!b) return;
    const act = b.dataset.act;
    if (act === 'copy') { showToast(T.copied); setTimeout(closeOverlay, 700); }
    if (act === 'save') { showToast(T.saved); setTimeout(closeOverlay, 700); }
    if (act === 'pin') {
      pin.innerHTML = ''; pin.style.width = `${Math.min(220, rect.w * 0.45)}px`; pin.style.aspectRatio = `${rect.w} / ${rect.h}`;
      pin.classList.add('on'); pin.append(makeShot(pin)); showToast(T.pinned); setTimeout(closeOverlay, 500);
    }
    if (act === 'annotate') startAnnotate();
  });
  let startAnnotate = () => {}; // replaced in the annotate task

  // expose for later tasks and for tests
  window.__snappy = { setSel, finishSel, closeOverlay, showToast, get rect() { return rect; }, get mode() { return mode; },
    setMode(m) { mode = m; }, T, refs: { desk, scene, sel, dim, overlay, thumb, toast, pin, hint, msg, ocrBtn },
    setFinishOcr(f) { finishOcr = f; }, setStartAnnotate(f) { startAnnotate = f; }, makeShot };
})();
```

- [ ] **Step 2: Retirer les styles inline de repli au chargement**

Le markup de la tâche 2 porte `style="left:140px;…"` sur `#sel` et `#dim` pour le rendu sans JS. Ajouter juste après `const W = 1000…` :

```js
  sel.removeAttribute('style'); dim.removeAttribute('style');
```

- [ ] **Step 3: Vérifier avec Playwright**

Sur `http://localhost:8765/` à 1280×900 :
1. `browser_evaluate` : `!!window.__snappy && getComputedStyle(document.getElementById('sel')).display === 'none'` → `true`.
2. Glisser à la souris du point (300, 200) au point (700, 420) du `.desk-wrap` (coordonnées page = rect du `.desk-wrap` + offset) via `browser_drag` ou `page.mouse` dans `browser_run_code_unsafe`.
3. `browser_evaluate` : `document.getElementById('overlay').classList.contains('on') && document.querySelector('#thumb .shot') !== null` → `true`.
4. `browser_evaluate` : `document.getElementById('dim').textContent` → forme `NNN × NNN`, les deux nombres > 24.
5. Cliquer le bouton `Copy` → `browser_evaluate` : `document.getElementById('toast').textContent` → `Copied to clipboard`. Après 900 ms, `overlay.classList.contains('on')` → `false`.
6. Refaire un glisser puis cliquer `Pin` → `document.getElementById('pin').classList.contains('on')` → `true`.
7. Glisser de (300, 200) à (305, 205) → l'overlay ne s'ouvre pas (`on` absent).
Capture finale `task3-overlay.png` juste après l'étape 3.

- [ ] **Step 4: Commit**

```bash
cd ~/app-idea/snappy && git commit -m "feat: interactive capture, overlay and copy/save/pin" -- docs/index.html
```

---

### Task 4: Mini éditeur d'annotation

**Files:**
- Modify: `docs/index.html` (CSS avant `/* @@css-end */`, JS avant `/* @@js-end */`)

**Interfaces:**
- Consumes: `window.__snappy.setStartAnnotate`, `.refs.overlay`, `.refs.thumb`, `.showToast`, `.closeOverlay`, `.T`.
- Produces: la classe `is-editing` sur `.overlay`, la barre `.tools` avec `data-tool="arrow|rect|blur"` et `data-done`.

- [ ] **Step 1: CSS**

```css
  /* annotate */
  .overlay.is-editing { width: 420px; }
  .overlay.is-editing .acts { display: none; }
  .tools { display: none; align-items: center; gap: 6px; }
  .overlay.is-editing .tools { display: flex; }
  .tools button { flex: 1; padding: 7px 6px; border: 0; border-radius: 9px; background: rgba(255,255,255,0.06); color: rgba(244,243,241,0.85); font: inherit; font-size: 11.5px; cursor: pointer; }
  .tools button[aria-pressed="true"] { background: rgba(var(--blue-a), 0.22); color: #fff; box-shadow: inset 0 0 0 1px rgba(var(--blue-a), 0.4); }
  .tools button[data-done] { flex: 0 0 auto; background: var(--blue); color: #06111F; font-weight: 600; padding-inline: 12px; }
  .thumb.can-draw { cursor: crosshair; }
  .thumb svg.ink { position: absolute; inset: 0; width: 100%; height: 100%; pointer-events: none; overflow: visible; }
  .thumb .blur { position: absolute; backdrop-filter: blur(6px); background: rgba(120,120,130,0.25); pointer-events: none; }
  .thumb .blur::before { content: ""; position: absolute; inset: 0; background-image: linear-gradient(rgba(0,0,0,0.25) 1px, transparent 1px), linear-gradient(90deg, rgba(0,0,0,0.25) 1px, transparent 1px); background-size: 6px 6px; }
```

- [ ] **Step 2: Markup**

Dans `#overlay`, juste après `</div>` de `.acts`, ajouter :

```html
            <div class="tools">
              <button type="button" data-tool="arrow" aria-pressed="true">Arrow</button>
              <button type="button" data-tool="rect" aria-pressed="false">Box</button>
              <button type="button" data-tool="blur" aria-pressed="false">Blur</button>
              <button type="button" data-done>Done</button>
            </div>
```

- [ ] **Step 3: JS, avant `/* @@js-end */`**

```js
(() => {
  const S = window.__snappy, { overlay, thumb } = S.refs;
  const NS = 'http://www.w3.org/2000/svg';
  let tool = 'arrow', drawing = false, from = null, node = null;

  const local = (ev) => { const b = thumb.getBoundingClientRect(); return { x: ev.clientX - b.left, y: ev.clientY - b.top }; };
  const ink = () => {
    let svg = thumb.querySelector('svg.ink');
    if (!svg) {
      svg = document.createElementNS(NS, 'svg'); svg.classList.add('ink');
      svg.innerHTML = '<defs><marker id="ah" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M0 0L10 5L0 10z" fill="#FF453A"/></marker></defs>';
      thumb.append(svg);
    }
    return svg;
  };

  S.setStartAnnotate(() => {
    overlay.classList.add('is-editing'); thumb.classList.add('can-draw');
    thumb.querySelectorAll('.shot').forEach((n) => n.remove());
    thumb.prepend(S.makeShot(thumb));
  });

  overlay.querySelector('.tools').addEventListener('click', (ev) => {
    const b = ev.target.closest('button'); if (!b) return;
    if (b.hasAttribute('data-done')) { S.showToast(S.T.exported); setTimeout(S.closeOverlay, 800); overlay.classList.remove('is-editing'); thumb.classList.remove('can-draw'); return; }
    tool = b.dataset.tool;
    overlay.querySelectorAll('[data-tool]').forEach((x) => x.setAttribute('aria-pressed', String(x === b)));
  });

  thumb.addEventListener('pointerdown', (ev) => {
    if (!thumb.classList.contains('can-draw')) return;
    ev.stopPropagation(); drawing = true; from = local(ev); thumb.setPointerCapture(ev.pointerId);
    if (tool === 'arrow') { node = document.createElementNS(NS, 'line'); node.setAttribute('stroke', '#FF453A'); node.setAttribute('stroke-width', '3'); node.setAttribute('stroke-linecap', 'round'); node.setAttribute('marker-end', 'url(#ah)'); ink().append(node); }
    else if (tool === 'rect') { node = document.createElementNS(NS, 'rect'); node.setAttribute('fill', 'none'); node.setAttribute('stroke', '#FF453A'); node.setAttribute('stroke-width', '3'); node.setAttribute('rx', '3'); ink().append(node); }
    else { node = document.createElement('div'); node.className = 'blur'; thumb.append(node); }
  });
  thumb.addEventListener('pointermove', (ev) => {
    if (!drawing) return; ev.stopPropagation();
    const p = local(ev), x = Math.min(from.x, p.x), y = Math.min(from.y, p.y), w = Math.abs(p.x - from.x), h = Math.abs(p.y - from.y);
    if (tool === 'arrow') { node.setAttribute('x1', from.x); node.setAttribute('y1', from.y); node.setAttribute('x2', p.x); node.setAttribute('y2', p.y); }
    else if (tool === 'rect') { node.setAttribute('x', x); node.setAttribute('y', y); node.setAttribute('width', w); node.setAttribute('height', h); }
    else node.style.cssText = `left:${x}px;top:${y}px;width:${w}px;height:${h}px`;
  });
  const stop = (ev) => { if (!drawing) return; ev.stopPropagation(); drawing = false; thumb.releasePointerCapture?.(ev.pointerId); };
  thumb.addEventListener('pointerup', stop); thumb.addEventListener('pointercancel', stop);
})();
```

Note : `pointerdown` sur la miniature appelle `stopPropagation()` mais le gestionnaire du bureau (tâche 3) écoute aussi sur `desk` ; l'ordre de propagation fait que `thumb` reçoit l'événement d'abord, donc le bureau ne redémarre pas une sélection. Le garde `overlay.contains(ev.target)` de la tâche 3 couvre aussi ce cas.

- [ ] **Step 4: Vérifier avec Playwright**

1. Glisser une sélection (300,200)→(700,420), cliquer `Annotate`.
2. `browser_evaluate` : `document.getElementById('overlay').classList.contains('is-editing')` → `true`.
3. Glisser à l'intérieur de `#thumb` de (20,20) à (120,80) en coordonnées de la miniature → `document.querySelector('#thumb svg.ink line')` non nul avec `x2 > x1`.
4. Cliquer `Blur`, glisser (40,40)→(90,70) → `document.querySelector('#thumb .blur')` non nul.
5. Cliquer `Done` → toast `Exported at original resolution`, puis overlay fermé après 1 s.
Capture `task4-annotate.png` après l'étape 4.

- [ ] **Step 5: Commit**

```bash
cd ~/app-idea/snappy && git commit -m "feat: annotation mini editor in the demo overlay" -- docs/index.html
```

---

### Task 5: Mode OCR

**Files:**
- Modify: `docs/index.html` (JS avant `/* @@js-end */`)

**Interfaces:**
- Consumes: `window.__snappy.setFinishOcr`, `.setMode`, `.rect`, `.refs`, `.showToast`, `.T`.
- Produces: le bouton `#ocr-btn` bascule `mode`, la classe `mode-ocr` sur `.desk`, les surlignages `.ocr-hl`.

- [ ] **Step 1: JS, avant `/* @@js-end */`**

```js
(() => {
  const S = window.__snappy, { desk, sel, dim, hint, msg, ocrBtn } = S.refs;
  const lines = [...document.querySelectorAll('#note-text .ln')];

  function setMode(m) {
    S.setMode(m);
    desk.classList.toggle('mode-ocr', m === 'ocr'); desk.classList.toggle('mode-capture', m === 'capture');
    ocrBtn.setAttribute('aria-pressed', String(m === 'ocr'));
    hint.textContent = m === 'ocr' ? S.T.ocrHint : S.T.captureHint;
    msg.textContent = m === 'ocr' ? S.T.ocrMsg : S.T.captureMsg;
    S.closeOverlay();
  }
  ocrBtn.addEventListener('click', () => setMode(S.mode === 'ocr' ? 'capture' : 'ocr'));

  // desk-space rect of an element (undo the CSS scale)
  const deskRect = (el) => {
    const b = el.getBoundingClientRect(), d = desk.parentElement.getBoundingClientRect(), k = d.width / 1000;
    return { x: (b.left - d.left) / k, y: (b.top - d.top) / k, w: b.width / k, h: b.height / k };
  };
  const hits = (a, b) => a.x < b.x + b.w && a.x + a.w > b.x && a.y < b.y + b.h && a.y + a.h > b.y;

  S.setFinishOcr(() => {
    const r = S.rect, found = [];
    lines.forEach((ln) => {
      const lr = deskRect(ln);
      if (!hits(r, lr)) return;
      found.push(ln.textContent.trim());
      const hl = document.createElement('div'); hl.className = 'ocr-hl';
      hl.style.cssText = `left:${lr.x}px;top:${lr.y}px;width:${lr.w}px;height:${lr.h}px`;
      desk.append(hl);
    });
    sel.classList.remove('on'); dim.classList.remove('on'); desk.classList.remove('is-busy');
    S.showToast(found.length ? S.T.ocrDone + found.join(' ') : S.T.ocrEmpty, found.length ? 2600 : 1400);
    setTimeout(() => desk.querySelectorAll('.ocr-hl').forEach((n) => n.remove()), 2600);
  });
})();
```

- [ ] **Step 2: Vérifier avec Playwright**

1. Cliquer `#ocr-btn` → `document.getElementById('desk').classList.contains('mode-ocr')` → `true`, `aria-pressed="true"`.
2. Glisser sur la fenêtre Notes de (150, 150) à (600, 260) en coordonnées bureau (convertir avec le facteur `k`).
3. `browser_evaluate` : `document.querySelectorAll('.ocr-hl').length >= 1` et `document.getElementById('toast').textContent.startsWith('Copied: Capture an area')`.
4. Glisser sur une zone vide (800, 400)→(900, 500) → toast `No text in that area`.
5. Re-cliquer `#ocr-btn` → retour en `mode-capture`.
Capture `task5-ocr.png` après l'étape 3.

- [ ] **Step 3: Commit**

```bash
cd ~/app-idea/snappy && git commit -m "feat: ocr mode in the demo" -- docs/index.html
```

---

### Task 6: Boucle automatique mobile

**Files:**
- Modify: `docs/index.html` (JS avant `/* @@js-end */`)

**Interfaces:**
- Consumes: `window.__snappy.setSel`, `.finishSel`, `.closeOverlay`, `.refs.desk`, `.refs.ocrBtn`.

- [ ] **Step 1: JS, avant `/* @@js-end */`**

```js
(() => {
  const S = window.__snappy, { desk, ocrBtn } = S.refs;
  const small = matchMedia('(max-width: 640px)'), still = matchMedia('(prefers-reduced-motion: reduce)');
  let timer = 0, running = false;

  const wait = (ms) => new Promise((r) => { timer = setTimeout(r, ms); });
  async function loop() {
    while (running) {
      const steps = still.matches ? 1 : 18, x0 = 150, y0 = 110, w = 480, h = 220;
      desk.classList.add('is-busy');
      for (let i = 1; i <= steps && running; i++) { S.setSel(x0, y0, (w * i) / steps, (h * i) / steps); await wait(28); }
      if (!running) break;
      S.finishSel(); await wait(2400);
      S.closeOverlay(); await wait(1600);
    }
  }
  function apply() {
    const want = small.matches;
    if (want === running) return;
    running = want; clearTimeout(timer); S.closeOverlay();
    desk.style.pointerEvents = want ? 'none' : ''; ocrBtn.hidden = want;
    if (want) loop();
  }
  small.addEventListener('change', apply); apply();
})();
```

- [ ] **Step 2: Vérifier avec Playwright**

1. Viewport 390×844, recharger. Après 1200 ms : `document.getElementById('overlay').classList.contains('on')` → `true`, `document.getElementById('ocr-btn').hidden` → `true`, `getComputedStyle(document.getElementById('desk')).pointerEvents` → `none`.
2. Viewport 1280×900 sans recharger. Après 200 ms : overlay fermé, `ocr-btn.hidden` → `false`, `pointerEvents` → `auto`.
3. Reprendre l'étape 2 de la tâche 3 (glisser → overlay) pour prouver que l'interaction est revenue.
Capture `task6-mobile-loop.png` à 390 px pendant que l'overlay est ouvert.

- [ ] **Step 3: Commit**

```bash
cd ~/app-idea/snappy && git commit -m "feat: auto-playing demo on small screens" -- docs/index.html
```

---

### Task 7: Page française

**Files:**
- Create: `docs/fr/index.html`
- Modify: `docs/index.html` (retirer les trois ancres)

- [ ] **Step 1: Retirer les ancres de la page EN**

```bash
cd ~/app-idea/snappy && sed -i '' -e '/\/\* @@css-end \*\//d' -e '/\/\* @@js-end \*\//d' docs/index.html && grep -c '@@' docs/index.html
```
Attendu : `0`.

- [ ] **Step 2: Créer la copie**

```bash
mkdir -p docs/fr && cp docs/index.html docs/fr/index.html
```

- [ ] **Step 3: Adapter le `<head>` et les chemins**

Dans `docs/fr/index.html`, remplacer exactement :
- `<html lang="en"` → `<html lang="fr"`
- `<title>Snappy — capture it, then decide</title>` → `<title>Snappy — capture d'abord, décide ensuite</title>`
- `content="Snappy is a free, open-source screenshot tool for macOS. Grab an area, a window or the screen, then copy, save, annotate or pin it from a floating overlay. OCR included."` → `content="Snappy est un outil de capture d'écran gratuit et open source pour macOS. Capture une zone, une fenêtre ou l'écran, puis copie, sauve, annote ou épingle depuis un overlay flottant. OCR inclus."`
- `og:title` → `Snappy — capture d'abord, décide ensuite` ; `og:description` → `Un outil de capture d'écran gratuit et open source pour macOS, avec overlay flottant, annotations et OCR.`
- `href="icon.png"` (favicon) → `href="../icon.png"` ; les quatre `src="icon.png"` → `src="../icon.png"` ; dans le CSS `.dock i.snappy { background: url(icon.png)` → `url(../icon.png)`.
- Lien de langue : `<a class="lang-switch" href="fr/" hreflang="fr">…FR</a>` → `<a class="lang-switch" href="../" hreflang="en">…EN</a>` (garder le SVG).

- [ ] **Step 4: Traduire les textes**

| EN | FR |
|---|---|
| Features / Install / Shortcuts (nav) | Fonctions / Installer / Raccourcis |
| Free and open source — MIT | Gratuit et open source — MIT |
| Capture it.<br><em>Then decide.</em> | Capture d'abord.<br><em>Décide ensuite.</em> |
| Snappy is a lightweight screenshot tool for your Mac. Grab an area, a window or the whole screen, then copy, save, annotate or pin it from a floating overlay, without cluttering your desktop. | Snappy est un outil de capture d'écran léger pour ton Mac. Capture une zone, une fenêtre ou tout l'écran, puis copie, sauve, annote ou épingle depuis un overlay flottant, sans encombrer ton bureau. |
| Download for macOS (×2) | Télécharger pour macOS |
| See it on GitHub (×2) | Voir sur GitHub |
| macOS 14 or later · Apple silicon · unsigned build, see install | macOS 14 ou plus · Apple silicon · build non signé, voir installation |
| Drag anywhere to capture | Glisse n'importe où pour capturer |
| Drag on the desktop to capture. Nothing leaves this page. | Glisse sur le bureau pour capturer. Rien ne quitte cette page. |
| Try OCR | Essayer l'OCR |
| Copy / Save / Annotate / Pin | Copier / Sauver / Annoter / Épingler |
| Arrow / Box / Blur / Done | Flèche / Cadre / Flou / Terminé |
| Snappy 0.2 — what's new + les 5 lignes | Snappy 0.2 — nouveautés ; « Capture une zone et copie-la sans enregistrer de fichier. » / « Sélectionne un texte à l'écran, il arrive dans ton presse-papier. » / « Annote avec flèches, cadres et flou pixelisé, puis exporte » / « à la résolution d'origine. Les captures épinglées restent au-dessus » / « de tout jusqu'à ce que tu les fermes. » |
| Release notes.md / Shots this week / Thu 14:32 | Notes de version.md / Captures cette semaine / jeu. 14:32 |
| Three things, no ceremony. | Trois choses, sans cérémonie. |
| Every shot lands in an overlay first. Nothing hits your desktop until you say so. | Chaque capture arrive d'abord dans un overlay. Rien ne touche ton bureau sans ton accord. |
| Capture, then choose | Capturer, puis choisir |
| Area, window or full screen, with global shortcuts and the native macOS selection. The overlay lets you copy without saving, save to the desktop, pin it on top, or drag it straight into Finder or any app. | Zone, fenêtre ou écran entier, avec des raccourcis globaux et la sélection native de macOS. L'overlay permet de copier sans enregistrer, sauver sur le bureau, épingler au-dessus, ou glisser directement dans le Finder ou n'importe quelle app. |
| Text from anywhere | Du texte depuis n'importe où |
| Select a region and the text inside it lands in your clipboard. French and English, powered by Apple's Vision framework, fully offline. | Sélectionne une zone et le texte qu'elle contient arrive dans ton presse-papier. Français et anglais, propulsé par Vision d'Apple, entièrement hors ligne. |
| Annotate and export | Annoter et exporter |
| Arrow, rectangle, highlight, text and pixelated blur. Exported at the original resolution, every time. | Flèche, rectangle, surlignage, texte et flou pixelisé. Exporté à la résolution d'origine, à chaque fois. |
| Two minutes, one permission. | Deux minutes, une permission. |
| The build is not notarized, so macOS asks twice. Once you're through, it just works. | Le build n'est pas notarisé, macOS demande donc deux fois. Une fois passé, ça marche tout seul. |
| Or build it yourself. Swift Package Manager, no Xcode project. | Ou compile-le toi-même. Swift Package Manager, pas de projet Xcode. |
| # installs Snappy.app into /Applications | # installe Snappy.app dans /Applications |
| Download the DMG / Grab the latest release and drag Snappy.app into /Applications. | Télécharger le DMG / Récupère la dernière release et glisse Snappy.app dans /Applications. |
| Open it once, the hard way / On first launch macOS refuses it. Go to System Settings › Privacy & Security and click Open Anyway. Right-click › Open no longer works on macOS 15. | L'ouvrir une fois, à la dure / Au premier lancement, macOS refuse. Va dans Réglages Système › Confidentialité et sécurité et clique Ouvrir quand même. Clic droit › Ouvrir ne marche plus sur macOS 15. |
| Allow screen recording / Accept the Screen Recording prompt, then quit and relaunch Snappy. It can't capture anything before that. | Autoriser l'enregistrement de l'écran / Accepte la demande Enregistrement de l'écran, puis quitte et relance Snappy. Il ne peut rien capturer avant. |
| Three shortcuts to remember. / All of them are yours to change in Settings. | Trois raccourcis à retenir. / Tous modifiables dans les Réglages. |
| Capture an area or a window / Capture the whole screen / Copy text from a region (OCR) | Capturer une zone ou une fenêtre / Capturer tout l'écran / Copier le texte d'une zone (OCR) |
| Use as default, in Settings, swaps macOS's own ⌘⇧3 and ⌘⇧4 for Snappy. | Par défaut, dans les Réglages, remplace les ⌘⇧3 et ⌘⇧4 de macOS par Snappy. |
| Take the shot. Keep your desktop. / Free, open source, and lighter than the app it replaces. | Prends la capture. Garde ton bureau. / Gratuit, open source, et plus léger que l'app qu'il remplace. |
| Snappy — free and open source, under the MIT licence. | Snappy — gratuit et open source, sous licence MIT. |
| GitHub / Releases / Issues / Cubby, from the same shelf | GitHub / Releases / Issues / Cubby, de la même étagère |
| `aria-label="Interactive demo of a Snappy capture"` | `aria-label="Démo interactive d'une capture Snappy"` |

Objet `T` du script :

```js
  const T = {
    copied: 'Copié dans le presse-papier',
    saved: 'Enregistré sur le Bureau',
    pinned: 'Épinglé au-dessus',
    exported: 'Exporté à la résolution d\'origine',
    ocrHint: 'Sélectionne du texte pour le copier',
    captureHint: 'Glisse n\'importe où pour capturer',
    ocrMsg: 'Mode OCR : glisse sur la note pour copier son texte.',
    captureMsg: 'Glisse sur le bureau pour capturer. Rien ne quitte cette page.',
    ocrEmpty: 'Pas de texte dans cette zone',
    ocrDone: 'Copié : '
  };
```

- [ ] **Step 5: Vérifier**

```bash
cd ~/app-idea/snappy && grep -c 'icon.png' docs/fr/index.html && grep -c '\.\./icon.png' docs/fr/index.html && grep -n 'lang="fr"\|hreflang="en"' docs/fr/index.html | wc -l
```
Attendu : les deux premiers nombres égaux (toutes les références sont préfixées), le troisième `2`.

Playwright sur `http://localhost:8765/fr/` : l'icône se charge (`document.querySelector('.brand img').naturalWidth === 512`), glisser (300,200)→(700,420) puis `Copier` → toast `Copié dans le presse-papier`. OCR : cliquer `Essayer l'OCR`, glisser sur la note → toast commence par `Copié : Capture une zone`. Captures `final-fr-desktop.png` (1280) et `final-fr-mobile.png` (390).

- [ ] **Step 6: Commit**

```bash
cd ~/app-idea/snappy && git add docs/fr/index.html && git commit -m "feat: french landing page" -- docs/index.html docs/fr/index.html
```

---

### Task 8: README anglais et licence MIT

**Files:**
- Modify: `README.md`
- Create: `LICENSE`

- [ ] **Step 1: Écrire `LICENSE`**

```text
MIT License

Copyright (c) 2026 Noah

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 2: Réécrire `README.md`**

Lire d'abord le README actuel en entier (`cat README.md`) pour reprendre toute section absente de la liste ci-dessous (par exemple des notes de développement) et la traduire au même endroit. Contenu cible :

```markdown
<p align="center">
  <img src="Logo/icon-1024.png" width="160" alt="Snappy">
</p>

<h1 align="center">Snappy</h1>

<p align="center">A lightweight, CleanShot-style screenshot tool for macOS. Free and open source.</p>

<p align="center"><a href="https://ndaen.github.io/snappy/">Website</a> · <a href="https://ndaen.github.io/snappy/fr/">Site en français</a> · <a href="../../releases/latest">Download</a></p>

## Features

- **Capture** an area, a window or the whole screen (global shortcuts, native macOS selection)
- **Floating overlay** after every shot: copy **without saving**, save to the desktop, annotate, pin on top, drag straight into Finder or any app
- **OCR**: select a region, its text lands in your clipboard (Apple Vision, French and English, offline)
- **Annotation editor**: arrow, rectangle, highlight, text, pixelated blur, export at the original resolution
- **Settings**: custom shortcuts, plus a "Use as default" button that replaces macOS's own capture shortcuts (⌘⇧3 / ⌘⇧4)

## Default shortcuts

| Action | Shortcut |
|---|---|
| Capture an area or a window | ⌘⇧1 |
| Capture the screen | ⌘⇧2 |
| Copy text (OCR) | ⌘⇧0 |

## Install

1. Download the DMG from the [latest release](../../releases/latest)
2. Drag `Snappy.app` into `/Applications`
3. First launch: macOS refuses the unsigned build. Open **System Settings › Privacy & Security** and click **Open Anyway**
4. Allow **Screen Recording** when macOS asks, then **relaunch the app**

## Build from source

```bash
bash scripts/build-app.sh          # build + install into /Applications
bash scripts/package.sh 0.2.0     # .app + DMG in dist/ (no install)
```

macOS 14+, Apple Silicon. The app is unsigned: after every local rebuild, re-enable Snappy in System Settings › Privacy & Security › Screen Recording.

## Licence

MIT. See [LICENSE](LICENSE).
```

- [ ] **Step 3: Vérifier**

```bash
cd ~/app-idea/snappy && grep -c 'ndaen.github.io/snappy' README.md && test -f LICENSE && echo ok
```
Attendu : `2` puis `ok`.

- [ ] **Step 4: Commit**

```bash
cd ~/app-idea/snappy && git add LICENSE README.md && git commit -m "docs: english readme, website link and mit licence" -- LICENSE README.md
```

---

### Task 9: Vérification finale, push, activation de Pages

**Files:**
- Aucun nouveau fichier. Nettoyage de `.claude/screenshots/playwright/`.

- [ ] **Step 1: Contrôle réseau et console**

Playwright sur `http://localhost:8765/` et `/fr/` : via `browser_network_requests`, vérifier que tous les hôtes sont `localhost`, `fonts.googleapis.com` ou `fonts.gstatic.com`. Via `browser_console_messages`, aucune erreur.

- [ ] **Step 2: Parcours complet EN sur un seul chargement**

Enchaîner : glisser → overlay → `Copy` → glisser → `Annotate` → flèche → `Done` → `Try OCR` → glisser sur la note → toast `Copied: …` → `Try OCR` (retour capture) → glisser → `Pin` → `#pin.on`. Chaque assertion comme dans les tâches 3 à 5. Captures finales : `final-en-desktop.png` (1280, overlay ouvert) et `final-en-mobile.png` (390, boucle en cours).

- [ ] **Step 3: Nettoyer les captures**

```bash
cd ~/app-idea/snappy/.claude/screenshots/playwright && ls && rm -f task*.png && ls
```
Ne garder que `final-en-desktop.png`, `final-en-mobile.png`, `final-fr-desktop.png`, `final-fr-mobile.png`. Vérifier que `.claude/` est ignoré ou non par git : `git check-ignore .claude || echo "non ignoré"`. S'il n'est pas ignoré, ajouter `.claude/` à `.gitignore` et le commiter (`chore: ignore local claude folder`).

- [ ] **Step 4: Arrêter le serveur local et pousser**

```bash
pkill -f "http.server 8765"; cd ~/app-idea/snappy && git status --short && git push origin main
```
Attendu : arbre propre avant le push, push accepté.

- [ ] **Step 5: Activation par Noah**

Demander à Noah de lancer, via `!` :

```bash
gh api -X POST repos/ndaen/snappy/pages -f 'source[branch]=main' -f 'source[path]=/docs'
gh repo edit ndaen/snappy --homepage https://ndaen.github.io/snappy/ --description "Lightweight, CleanShot-style screenshot tool for macOS. Overlay, annotations, OCR. Free and open source."
```

- [ ] **Step 6: Contrôle public**

Après deux à trois minutes :

```bash
curl -s -o /dev/null -w "%{http_code}\n" https://ndaen.github.io/snappy/ && curl -s -o /dev/null -w "%{http_code}\n" https://ndaen.github.io/snappy/fr/ && curl -s -o /dev/null -w "%{http_code}\n" https://ndaen.github.io/snappy/icon.png
```
Attendu : trois fois `200`. Ouvrir les deux URL dans Playwright et refaire le glisser → overlay une fois sur chacune.

- [ ] **Step 7: Mémoire et leçons**

Mettre à jour la mémoire projet Snappy (`~/.claude/projects/-Users-ndaen-app-idea/memory/snappy-project.md`) : site en ligne, structure `docs/`, les deux pages à modifier en double. Si une correction de Noah est survenue pendant l'exécution, la consigner dans `docs/LESSONS.md` du repo Snappy (le créer s'il n'existe pas).
