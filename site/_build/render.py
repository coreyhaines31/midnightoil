#!/usr/bin/env python3
"""Renders site/alternatives/*.html and site/alternatives/index.html from pages.py.

    python3 site/_build/render.py
"""
import html
import json
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from pages import PAGES, HUB  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..")
DOWNLOAD = "https://github.com/coreyhaines31/midnightoil/releases/latest"
REPO = "https://github.com/coreyhaines31/midnightoil"

FLAME = ('<svg viewBox="0 0 24 30" fill="currentColor" aria-hidden="true"><path d="M12 0c6.8 0 10 4.7 10 10.6 0 6.3-4.6 '
         '9.4-7.5 18.4-.9-3.8-3.6-6.6-4.7-10.3-1 1.9-2.5 4-3.9 5.1C2.6 21.5 2 18.2 2 15.4 2 8.8 4.8 0 12 0z"/></svg>')

PAGE_CSS = """
    .sub-hero { padding: 72px 0 40px; }
    .sub-hero .eyebrow { font-size: 13px; font-weight: 600; letter-spacing: 0.06em; text-transform: uppercase; color: var(--flame); margin-bottom: 14px; }
    .sub-hero h1 { font-size: clamp(38px, 6vw, 64px); font-weight: 700; letter-spacing: -0.035em; line-height: 1.04; max-width: 900px; }
    .sub-hero h1 code { font: inherit; background: none; padding: 0; font-family: ui-monospace, SFMono-Regular, Menlo, monospace; font-size: 0.88em; font-weight: 600; letter-spacing: -0.02em; }
    .sub-hero .lede { font-size: clamp(18px, 2vw, 21px); color: var(--muted); max-width: 720px; margin: 20px 0 0; line-height: 1.45; }
    .sub-hero .actions { display: flex; align-items: center; gap: 22px; margin-top: 28px; flex-wrap: wrap; }
    .tldr { background: var(--gray); border-radius: var(--radius); padding: 26px 28px; margin: 44px 0 0; max-width: 900px; }
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
    .two > div { background: var(--gray); border-radius: 16px; padding: 22px; }
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
    .related a { display: block; background: #fff; border-radius: 14px; padding: 18px 20px; text-decoration: none; box-shadow: 0 0 0 0.5px rgba(0,0,0,0.08); }
    .related a:hover { box-shadow: 0 0 0 0.5px rgba(0,0,0,0.16), 0 8px 24px rgba(0,0,0,0.06); }
    .related b { display: block; margin-bottom: 4px; }
    .related span { color: var(--muted); font-size: 14px; }
    section.tight { padding: 64px 0; }
    @media (max-width: 720px) { .two { grid-template-columns: 1fr; } .sub-hero { padding-top: 48px; } }
"""


def esc(t):
    return html.escape(t, quote=True)


def nav():
    return f'''  <div class="nav">
    <div class="wrap">
      <a class="brand" href="/"><img src="/images/icon.png" alt=""> Midnight Oil</a>
      <nav>
        <a href="/#features">Features</a>
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
    return f'      <nav class="footer-alts" aria-label="Alternatives"><a class="label" href="/alternatives/">Alternatives</a>{links}</nav>\n'


def footer():
    return f'''  <footer>
    <div class="wrap">
{footer_alternatives()}      <span>© 2026 Corey Haines. <a href="{REPO}/blob/main/LICENSE">FSL-1.1-MIT License</a>.</span>
      <span><a href="{REPO}">GitHub</a> &nbsp;·&nbsp; <a href="{REPO}/releases">Releases</a> &nbsp;·&nbsp; <a href="{REPO}/issues">Issues</a></span>
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
        f.write(page[:i] + footer_alternatives() + "      " + page[j:])


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
  <meta property="og:image" content="https://midnightoil.app/images/icon.png">
  <meta property="og:url" content="https://midnightoil.app{path}">
  <link rel="icon" href="/images/icon.png">
  <link rel="apple-touch-icon" href="/images/icon.png">
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
        <h2>{text}</h2>
        <a class="pill big" href="{DOWNLOAD}">Download for macOS</a>
        <p class="fineprint">Free · Source on GitHub · macOS 14 or later · <code>brew install --cask coreyhaines31/tap/midnightoil</code></p>
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
        <a class="pill big" href="{DOWNLOAD}">Download Midnight Oil</a>
        <a class="link" href="#compare">See the comparison</a>
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


def render_hub():
    path = "/alternatives/"
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


if __name__ == "__main__":
    for p in PAGES:
        render_page(p)
    render_hub()
    render_homepage_footer()
    print(f"rendered {len(PAGES)} pages + hub + homepage footer")
