#!/usr/bin/env python3
"""Renders site/alternatives/*.html and site/alternatives/index.html from pages.py.

    python3 site/_build/render.py
"""
import html
import json
import datetime
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(__file__))
from pages import PAGES, HUB  # noqa: E402
from guides import GUIDES, UPDATED  # noqa: E402
from teams import CHECKOUT, DOCS, LEGAL, SALES_OPEN, TEAMS  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..")
DOWNLOAD = "https://github.com/coreyhaines31/midnightoil/releases/latest"
REPO = "https://github.com/coreyhaines31/midnightoil"

DOWNLOAD_ICON = ('<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 4v11m-5-5 5 5 5-5M5 20h14" fill="none" '
                 'stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/></svg>')
GITHUB_ICON = ('<svg viewBox="0 0 16 16" fill="currentColor" aria-hidden="true"><path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 '
               '5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52'
               '-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59'
               '.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82'
               '.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 '
               '.21.15.46.55.38A8.01 8.01 0 0 0 16 8c0-4.42-3.58-8-8-8z"/></svg>')
# The two main calls to action, everywhere a page offers the download.
CTAS = (f'<a class="pill big" href="https://github.com/coreyhaines31/midnightoil/releases/latest">{DOWNLOAD_ICON}Download free</a>\n'
        f'        <a class="pill big glass" href="https://github.com/coreyhaines31/midnightoil">{GITHUB_ICON}View source code</a>')

FLAME = ('<svg viewBox="0 0 24 30" fill="currentColor" aria-hidden="true"><path d="M12 0c6.8 0 10 4.7 10 10.6 0 6.3-4.6 '
         '9.4-7.5 18.4-.9-3.8-3.6-6.6-4.7-10.3-1 1.9-2.5 4-3.9 5.1C2.6 21.5 2 18.2 2 15.4 2 8.8 4.8 0 12 0z"/></svg>')

PAGE_CSS = """
    .sub-hero { padding: 72px 22px 40px; }
    .sub-hero .eyebrow { font-size: 13px; font-weight: 600; letter-spacing: 0.06em; text-transform: uppercase; color: var(--flame); margin-bottom: 14px; }
    .sub-hero h1 { font-size: clamp(38px, 6vw, 64px); font-weight: 700; letter-spacing: -0.035em; line-height: 1.04; max-width: 900px; }
    .sub-hero h1 code { font: inherit; background: none; padding: 0; font-family: ui-monospace, SFMono-Regular, Menlo, monospace; font-size: 0.88em; font-weight: 600; letter-spacing: -0.02em; }
    .sub-hero .lede { font-size: clamp(18px, 2vw, 21px); color: var(--muted); max-width: 720px; margin: 20px 0 0; line-height: 1.45; }
    .sub-hero .actions { display: flex; align-items: center; gap: 14px; margin-top: 28px; flex-wrap: wrap; }
    .tldr { background: var(--glass); border-radius: 28px; padding: 26px 28px; margin: 44px 0 0; max-width: 900px; position: relative; box-shadow: var(--glass-shadow); -webkit-backdrop-filter: var(--glass-blur); backdrop-filter: var(--glass-blur); }
    .tldr h2 { font-size: 15px; letter-spacing: 0.04em; text-transform: uppercase; color: var(--muted); margin-bottom: 10px; }
    .tldr p { margin: 0; font-size: 18px; line-height: 1.5; }
    .prose { max-width: 760px; }
    .prose h2 { font-size: clamp(28px, 3.6vw, 40px); margin: 0 0 16px; }
    .prose h3 { font-size: 21px; font-weight: 600; letter-spacing: -0.015em; margin: 32px 0 8px; }
    .prose p, .prose li { color: var(--muted); font-size: 17px; line-height: 1.6; }
    .prose p strong { color: var(--text); font-weight: 600; }
    .prose ul { padding-left: 20px; margin: 0 0 8px; }
    .prose li { margin-bottom: 6px; }
    .prose code, .compare code { font: 15px ui-monospace, SFMono-Regular, Menlo, monospace; background: var(--gray); padding: 2px 6px; border-radius: 5px; }
    .prose pre { background: #14162a; color: #d9dbe9; border-radius: 12px; padding: 16px 18px; overflow-x: auto; font: 14px/1.6 ui-monospace, SFMono-Regular, Menlo, monospace; }
    .prose pre code { background: none; padding: 0; color: inherit; font-size: inherit; }
    .prose blockquote { margin: 18px 0; padding: 14px 20px; border-left: 3px solid var(--gold); background: var(--gray); border-radius: 0 12px 12px 0; }
    .prose blockquote p { margin: 0; font-size: 16px; }
    .prose blockquote cite { display: block; margin-top: 6px; font-size: 13px; color: var(--faint); font-style: normal; }
    .prose blockquote cite a { color: var(--faint); }
    .two { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-top: 8px; }
    .two > div { background: var(--glass); border-radius: 22px; padding: 22px; box-shadow: var(--glass-shadow); }
    .two h3 { margin: 0 0 10px; font-size: 18px; }
    .two ul { margin: 0; padding-left: 18px; }
    .two li { font-size: 15px; margin-bottom: 6px; }
    .steps { counter-reset: step; list-style: none; padding: 0; margin: 0; }
    .steps li { counter-increment: step; position: relative; padding-left: 46px; margin-bottom: 18px; }
    .steps li::before { content: counter(step); position: absolute; left: 0; top: -2px; width: 30px; height: 30px; border-radius: 50%; background: var(--text); color: #fff; font-weight: 600; font-size: 14px; display: grid; place-items: center; }
    .steps li b { color: var(--text); display: block; margin-bottom: 2px; }
    .glance { max-width: 760px; margin: 0 0 44px; }
    .glance .compare td:first-child { font-weight: 500; }
    .related { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 14px; }
    .related a { display: block; background: var(--glass); border-radius: 22px; padding: 18px 20px; text-decoration: none; box-shadow: var(--glass-shadow); transition: transform .2s ease, background .2s ease; }
    .related a:hover { background: var(--glass-strong); transform: translateY(-2px); }
    .related b { display: block; margin-bottom: 4px; }
    .related span { color: var(--muted); font-size: 14px; }
    section.tight { padding: 64px 0; }
    .tldr::after { content: ""; position: absolute; inset: 0; border-radius: inherit; padding: 1px; pointer-events: none; background: var(--rim);
      -webkit-mask: linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0); -webkit-mask-composite: xor; mask: linear-gradient(#000 0 0) content-box exclude, linear-gradient(#000 0 0); }
    @media (max-width: 720px) {
      .two { grid-template-columns: 1fr; } .sub-hero { padding-top: 48px; }
      .sub-hero .actions:has(.glass) { flex-direction: column; align-items: stretch; max-width: 340px; }
      .sub-hero .actions .pill { justify-content: center; }
    }
"""


def esc(t):
    return html.escape(t, quote=True)


def nav():
    return f'''  <div class="aurora" aria-hidden="true"><i></i><i></i><i></i><i></i></div>
  <div class="nav">
    <div class="wrap">
      <a class="brand" href="/"><img src="/images/icon-192.png" alt=""> Midnight Oil</a>
      <nav>
        <a href="/#features">Features</a>
        <a href="/guides">Guides</a>
        <a href="/teams">Teams</a>
        <a href="/#faq">FAQ</a>
        <a href="{REPO}">GitHub</a>
        <a class="pill" href="{DOWNLOAD}">Download</a>
      </nav>
    </div>
  </div>
'''


def footer_alternatives():
    """Every alternative page, linked from every footer for internal linking."""
    links = "".join(f'<a href="/alternatives/{p["slug"]}">{esc(p["competitor"])} alternative</a>' for p in PAGES)
    return f'      <nav class="footer-alts" aria-label="Alternatives"><a class="label" href="/alternatives">Alternatives</a>{links}</nav>\n'


def footer_guides():
    """Every guide, linked from every footer like the alternatives."""
    links = "".join(f'<a href="/guides/{g["slug"]}">{esc(g["card_title"])}</a>' for g in GUIDES)
    return f'      <nav class="footer-alts" aria-label="Guides"><a class="label" href="/guides">Guides</a>{links}</nav>\n'


def footer():
    return f'''  <footer>
    <div class="wrap">
{footer_guides()}{footer_alternatives()}      <span>© 2026 Corey Haines. <a href="{REPO}/blob/main/LICENSE">FSL-1.1-MIT License</a>.</span>
      <span><a href="{REPO}">GitHub</a> &nbsp;·&nbsp; <a href="{REPO}/releases">Releases</a> &nbsp;·&nbsp; <a href="{REPO}/issues">Issues</a> &nbsp;·&nbsp; <a href="/teams">Teams</a> &nbsp;·&nbsp; <a href="/privacy">Privacy</a> &nbsp;·&nbsp; <a href="/terms">Terms</a></span>
    </div>
  </footer>
'''


def render_homepage_footer():
    """The homepage is hand-written; keep its footer list in sync between the markers."""
    path = os.path.join(ROOT, "index.html")
    with open(path) as f:
        page = f.read()
    start, end = "<!-- alternatives -->\n", "<!-- /alternatives -->"
    i, j = page.index(start) + len(start), page.index(end)
    with open(path, "w") as f:
        f.write(page[:i] + footer_guides() + footer_alternatives() + "      " + page[j:])


def head(title, description, path):
    return f'''<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{esc(title)}</title>
  <meta name="description" content="{esc(description)}">
  <link rel="canonical" href="https://midnightoil.app{path}">
  <meta property="og:title" content="{esc(title)}">
  <meta property="og:description" content="{esc(description)}">
  <meta property="og:image" content="https://midnightoil.app/images/og.png">
  <meta property="og:image:width" content="1200">
  <meta property="og:image:height" content="630">
  <meta property="og:url" content="https://midnightoil.app{path}">
  <meta name="twitter:card" content="summary_large_image">
  <link rel="icon" href="/images/icon-192.png">
  <link rel="apple-touch-icon" href="/images/icon-512.png">
  <link rel="stylesheet" href="/site.css">
  <style>{PAGE_CSS}  </style>
  <script async src="https://tracerkit.com/t.js" data-key="tk__vMOLefQSrM_pLCt"></script>
</head>
<body>
'''


def table(rows, competitor):
    out = [f'        <div class="table-scroll"><table class="compare">',
           f'          <thead><tr><th></th><th class="us">Midnight Oil</th><th>{esc(competitor)}</th></tr></thead><tbody>']
    for label, us, them in rows:
        out.append(f'            <tr><td>{label}</td><td class="us y">{us}</td><td>{them}</td></tr>')
    out.append('          </tbody></table></div>')
    return "\n".join(out)


def faq_schema(faqs):
    data = {"@context": "https://schema.org", "@type": "FAQPage", "mainEntity": [
        {"@type": "Question", "name": q, "acceptedAnswer": {"@type": "Answer", "text": a}} for q, a in faqs]}
    return f'<script type="application/ld+json">{json.dumps(data)}</script>'


def cta(text):
    return f'''    <section class="cta">
      <div class="wrap">
        <div class="cta-card">
          <img src="/images/icon-192.png" alt="" width="96" height="96">
          <h2>{text}</h2>
          <p>Free. No account, no subscription.</p>
          <div class="actions">
            {CTAS}
          </div>
          <p class="fineprint">macOS 14 or later · Apple Silicon and Intel · <code>brew install --cask coreyhaines31/tap/midnightoil</code></p>
        </div>
      </div>
    </section>
'''


def render_page(p):
    path = f"/alternatives/{p['slug']}"
    parts = [head(p["title"], p["description"], path), nav(), "  <main>\n"]
    parts.append(f'''    <div class="wrap sub-hero">
      <div class="eyebrow">{esc(p["eyebrow"])}</div>
      <h1>{p["h1"]}</h1>
      <p class="lede">{p["lede"]}</p>
      <div class="actions">
        {CTAS}
      </div>
      <div class="tldr"><h2>The short version</h2><p>{p["tldr"]}</p></div>
    </div>
''')
    for sec in p["sections"]:
        cls = "tight" + (" gray" if sec.get("gray") else "")
        sid = f' id="{sec["id"]}"' if sec.get("id") else ""
        body = sec["html"]
        if sec.get("table"):
            body = body.replace("{{TABLE}}", table(sec["table"], p["competitor"]))
        parts.append(f'    <section class="{cls}"{sid}>\n      <div class="wrap"><div class="prose">\n{body}\n      </div></div>\n    </section>\n')
    # related pages
    others = [q for q in PAGES if q["slug"] != p["slug"]]
    rel = "".join(f'          <a href="/alternatives/{q["slug"]}"><b>{esc(q["card_title"])}</b><span>{esc(q["card_blurb"])}</span></a>\n' for q in others)
    parts.append(f'''    <section class="tight gray">
      <div class="wrap">
        <div class="section-head"><h2>Other ways people keep a Mac awake</h2></div>
        <div class="related">
{rel}        </div>
      </div>
    </section>
''')
    parts.append(cta(p["cta"]))
    parts.append("  </main>\n")
    parts.append(footer())
    parts.append(faq_schema(p["faqs"]) + "\n</body>\n</html>\n")
    os.makedirs(os.path.join(ROOT, "alternatives"), exist_ok=True)
    with open(os.path.join(ROOT, "alternatives", f"{p['slug']}.html"), "w") as f:
        f.write("".join(parts))


def article_schema(g, path):
    data = {"@context": "https://schema.org", "@type": "TechArticle", "headline": g["h1"],
            "description": g["description"], "url": f"https://midnightoil.app{path}",
            "dateModified": UPDATED, "image": "https://midnightoil.app/images/og.png",
            "author": {"@type": "Person", "name": "Corey Haines", "url": "https://corey.co"},
            "publisher": {"@type": "Organization", "name": "Midnight Oil", "url": "https://midnightoil.app/"}}
    return f'<script type="application/ld+json">{json.dumps(data)}</script>'


def render_guide(g):
    path = f"/guides/{g['slug']}"
    parts = [head(g["title"], g["description"], path), nav(), "  <main>\n"]
    parts.append(f'''    <div class="wrap sub-hero">
      <div class="eyebrow">{esc(g["eyebrow"])} · Updated {UPDATED[:7]}</div>
      <h1>{g["h1"]}</h1>
      <p class="lede">{g["lede"]}</p>
      <div class="tldr"><h2>The short answer</h2><p>{g["tldr"]}</p></div>
    </div>
''')
    for sec in g["sections"]:
        cls = "tight" + (" gray" if sec.get("gray") else "")
        parts.append(f'    <section class="{cls}" id="{sec["id"]}">\n      <div class="wrap"><div class="prose">\n{sec["html"]}\n      </div></div>\n    </section>\n')
    faq = "".join(f"        <h3>{esc(q)}</h3>\n        <p>{esc(a)}</p>\n" for q, a in g["faqs"])
    parts.append(f'    <section class="tight" id="faq">\n      <div class="wrap"><div class="prose">\n        <h2>Questions</h2>\n{faq}      </div></div>\n    </section>\n')
    others = [o for o in GUIDES if o["slug"] != g["slug"]]
    rel = "".join(f'          <a href="/guides/{o["slug"]}"><b>{esc(o["card_title"])}</b><span>{esc(o["card_blurb"])}</span></a>\n' for o in others)
    if rel:
        parts.append(f'''    <section class="tight gray">
      <div class="wrap">
        <div class="section-head"><h2>More guides</h2></div>
        <div class="related">
{rel}        </div>
      </div>
    </section>
''')
    parts.append(cta(g["cta"]))
    parts.append("  </main>\n")
    parts.append(footer())
    parts.append(article_schema(g, path) + "\n" + faq_schema(g["faqs"]) + "\n</body>\n</html>\n")
    write(path, "".join(parts))


def render_guides_hub():
    path = "/guides"
    cards = "".join(f'          <a href="/guides/{g["slug"]}"><b>{esc(g["card_title"])}</b><span>{esc(g["card_blurb"])}</span></a>\n' for g in GUIDES)
    write(path, f'''{head("Mac sleep guides: keep a Mac awake, or let it sleep", "How macOS sleep works and how to control it: stop a Mac from sleeping, clamshell mode, sleep settings, keeping the screen on, and running AI agents overnight.", path)}{nav()}  <main>
    <div class="wrap sub-hero">
      <div class="eyebrow">Guides</div>
      <h1>How Mac sleep works, and how to control it</h1>
      <p class="lede">Straight answers to the questions people ask about keeping a Mac awake, using what macOS already has, and where an app helps.</p>
    </div>
    <section class="tight">
      <div class="wrap">
        <div class="related">
{cards}        </div>
      </div>
    </section>
{cta("Keep your Mac awake in one click.")}  </main>
{footer()}</body>
</html>
''')


def render_hub():
    path = "/alternatives"
    cards = "".join(f'          <a href="/alternatives/{q["slug"]}"><b>{esc(q["card_title"])}</b><span>{esc(q["card_blurb"])}</span></a>\n' for q in PAGES)
    body = f'''{head(HUB["title"], HUB["description"], path)}{nav()}  <main>
    <div class="wrap sub-hero">
      <div class="eyebrow">Alternatives</div>
      <h1>{HUB["h1"]}</h1>
      <p class="lede">{HUB["lede"]}</p>
    </div>
    <section class="tight">
      <div class="wrap">
        <div class="glance"><table class="compare">
          <thead><tr><th>{esc(HUB["glance"][0][0])}</th><th class="us">{esc(HUB["glance"][0][1])}</th></tr></thead>
          <tbody>{"".join(f'<tr><td>{esc(a)}</td><td class="{"us y" if b == "Midnight Oil" else ""}">{esc(b)}</td></tr>' for a, b in HUB["glance"][1:])}</tbody>
        </table></div>
        <div class="related">
{cards}        </div>
      </div>
    </section>
    <section class="tight gray">
      <div class="wrap"><div class="prose">
{HUB["html"]}
      </div></div>
    </section>
{cta(HUB["cta"])}  </main>
{footer()}</body>
</html>
'''
    with open(os.path.join(ROOT, "alternatives", "index.html"), "w") as f:
        f.write(body)


def write(path, body):
    out = os.path.join(ROOT, path.strip("/") + ".html")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, "w") as f:
        f.write(body)


def render_teams():
    t = TEAMS
    features = "".join(f'''        <div class="teams-feature">
          <div><h2>{esc(title)}</h2><p>{esc(text)}</p></div>
          <div class="art">{art}</div>
        </div>
''' for title, text, art in t["features"])
    included = "".join(f"<li>{esc(item)}</li>" for item in t["included"])
    faqs = "".join(f'          <details><summary>{esc(q)}</summary><p>{a}</p></details>\n' for q, a in t["faqs"])
    body = f'''{head(t["title"], t["description"], "/teams")}{nav()}  <main>
    <div class="wrap sub-hero">
      <div class="eyebrow">{esc(t["eyebrow"])}</div>
      <h1>{esc(t["h1"])}</h1>
      <p class="lede">{esc(t["lede"])}</p>
      <div class="actions">
        <a class="pill big" href="#pricing">See pricing</a>
        <a href="/docs/teams/deploy">How deployment works →</a>
      </div>
    </div>
    <section class="tight">
      <div class="wrap">
{features}      </div>
    </section>
    <section class="tight gray" id="pricing">
      <div class="wrap">
        <div class="section-head center"><h2>One price per Mac.</h2></div>
        <div class="price-card">
          <div class="amount">$5 <small>per Mac per month, billed yearly</small></div>
          <p style="color:var(--muted);margin:6px 0 0">$60 per Mac per year. Five Macs minimum. Midnight Oil itself stays free for everyone.</p>
          <ul>{included}</ul>
          <form class="seat-row" action="{CHECKOUT if SALES_OPEN else "#pricing"}" method="get">
            <label>Macs <input id="seats" name="seats" type="number" min="5" max="1000" value="10"></label>
            <span class="total" id="total">$600/yr</span>
            {'<button class="pill" type="submit">Buy for your team</button>' if SALES_OPEN else '<span class="pill soon" aria-disabled="true">Coming soon</span>'}
          </form>
        </div>
      </div>
    </section>
    <section class="tight" id="faq">
      <div class="wrap">
        <div class="section-head center"><h2>Questions</h2></div>
        <div class="faq">
{faqs}        </div>
      </div>
    </section>
  </main>
{footer()}  <script>
    (() => {{
      const seats = document.getElementById("seats"), total = document.getElementById("total");
      const update = () => {{
        const n = Math.max(5, Math.min(1000, Math.floor(Number(seats.value) || 5)));
        total.textContent = "$" + (n * 60).toLocaleString("en-US") + "/yr";
      }};
      seats.addEventListener("input", update);
      update();
    }})();
  </script>
</body>
</html>
'''
    write("/teams", body)


def render_doc(d, eyebrow=None):
    body = f'''{head(d["title"], d["description"], d["path"])}{nav()}  <main>
    <div class="wrap sub-hero">
      {f'<div class="eyebrow">{esc(eyebrow)}</div>' if eyebrow else ""}
      <h1>{esc(d["h1"])}</h1>
      {f'<p class="lede">{esc(d["lede"])}</p>' if d.get("lede") else ""}
    </div>
    <section class="tight">
      <div class="wrap"><div class="prose">
{d["html"]}
      </div></div>
    </section>
  </main>
{footer()}</body>
</html>
'''
    write(d["path"], body)


def render_404():
    page = head("Page not found · Midnight Oil", "This page doesn't exist.", "/404").replace(
        "<head>\n", '<head>\n  <meta name="robots" content="noindex">\n', 1)
    write("/404", page + nav() + f'''  <main>
    <div class="wrap sub-hero">
      <div class="eyebrow">404</div>
      <h1>This page is asleep for good.</h1>
      <p class="lede">The page you asked for doesn't exist. Midnight Oil itself is right here, and it's free.</p>
      <div class="actions">
        {CTAS}
      </div>
      <p class="lede" style="font-size:17px"><a href="/">Home</a> · <a href="/alternatives">Alternatives</a> · <a href="/teams">Teams</a></p>
    </div>
  </main>
''' + footer() + "</body>\n</html>\n")


def render_sitemap():
    """Lists every page, with lastmod from the last commit that touched it."""
    root = os.path.normpath(ROOT)
    urls = []
    for folder, _, files in os.walk(root):
        if "_build" in os.path.relpath(folder, root).split(os.sep):
            continue
        for name in files:
            if not name.endswith(".html") or name == "404.html":
                continue
            file = os.path.normpath(os.path.join(folder, name))
            rel = os.path.relpath(file, root)[:-len(".html")]
            path = "/" + (rel[:-len("index")].rstrip("/") if rel.endswith("index") else rel)
            changed = subprocess.run(["git", "log", "-1", "--format=%cs", "--", file],
                                     capture_output=True, text=True).stdout.strip()
            urls.append((path, changed or datetime.date.today().isoformat()))
    urls.sort(key=lambda u: (u[0] != "/", u[0]))
    rows = "".join(f"  <url><loc>https://midnightoil.app{p}</loc><lastmod>{d}</lastmod></url>\n" for p, d in urls)
    with open(os.path.join(ROOT, "sitemap.xml"), "w") as f:
        f.write('<?xml version="1.0" encoding="UTF-8"?>\n'
                '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n' + rows + "</urlset>\n")
    return len(urls)


if __name__ == "__main__":
    for p in PAGES:
        render_page(p)
    render_hub()
    render_homepage_footer()
    render_teams()
    for d in DOCS:
        render_doc(d, d["eyebrow"])
    for d in LEGAL:
        render_doc(d)
    for g in GUIDES:
        render_guide(g)
    render_guides_hub()
    render_404()
    pages = render_sitemap()
    print(f"sitemap: {pages} pages")
    print(f"rendered {len(PAGES)} pages + hub + homepage footer + teams + {len(DOCS)} docs + {len(LEGAL)} legal")
