# Keyword Demand — Midnight Oil

Source: Ahrefs Keywords Explorer (US, pulled 2026-09-30), plus WebSearch SERP checks. Volume = US monthly; GV = global; TP = traffic potential of the top-ranking page; KD = difficulty. "0" means Ahrefs has no recorded volume (typically <10/mo), not that no one searches it.

## Requested queries

| Query | Demand signal | Verdict | What page should target it |
|---|---|---|---|
| amphetamine alternative mac | 0 US / 10 GV. Parent "amphetamine mac" = **1,300/mo** (GV 3,800), "amphetamine app mac" 350/mo. "amphetamine alternative" alone is polluted by Adderall intent (parent topic "alternative to adderall"). | Real demand, but only via the head term | `/amphetamine-alternative` — title must include "Amphetamine app for Mac" so it can rank for the 1,300/mo head term, not just the long tail |
| amphetamine app alternative | 0 / 0 | No standalone demand | Same page as above; use as H2 variant |
| keepingyouawake alternative | Not in Ahrefs DB. "keepingyouawake" = 100/mo (GV 700), KD 1 | Small but clean | `/keepingyouawake-alternative` — light page; cheap to rank |
| caffeine mac alternative | 0 / 20 GV. Head terms: "caffeine mac" **1,000/mo**, "caffeine for mac" **700/mo** (TP 1,900), KD 0 for both | Real demand via head terms | `/caffeine-alternative` — target "Caffeine for Mac" (the abandoned Lighthead app); note "caffeine" search-suggest is 100% beverage intent, so keep "mac" in every title |
| caffeine app mac not working | 0 / 0 | No measurable demand | Fold into the Caffeine alternative page as an FAQ ("Caffeine stopped working on macOS X?") |
| lungo vs amphetamine | Not in DB. "lungo mac" 10/mo (GV 40) | Negligible | Skip a dedicated page; one row in a comparison table |
| keep mac awake app | 0 / 10 GV. Related: "keep mac awake" 100/mo (KD 57), "how to keep mac from sleeping" **1,000/mo** (TP 3,200, KD 0), parent "prevent mac from sleeping" | Real demand on the how-to phrasing | Homepage + `/how-to-keep-mac-from-sleeping` guide (highest-TP informational term in the set) |
| keep mac awake with lid closed | 10/mo (GV 20). Parent "prevent mac from sleeping when lid closed" TP 150; "keep macbook awake when closed" TP 150 | Small but high-intent; multiple 2026 blog posts target it for AI agents | `/keep-mac-awake-lid-closed` — the differentiator page; also the hook for caffeinate/jiggler comparisons |
| prevent mac from sleeping terminal | 0 / 10 GV; SERP is dominated by caffeinate tutorials (techradar, lidrun, ss64) | Low standalone; folds into caffeinate | `/caffeinate` page section "from the terminal" |
| caffeinate mac command | 100/mo; head "caffeinate mac" **900/mo** (GV 2,700, KD 0), "caffeinate command" 150/mo (KD 6). TP ~1,000 | **Real demand** | `/caffeinate` — full flag reference + "what caffeinate can't do" + CLI shim. Best dev-intent term in the set |
| mac keep awake for claude code | Not in DB. SERP shows 9+ dedicated posts since Apr 2026 (openreplay, andrewbaker.ninja, bleepingswift, kanaries, agentbarista, mindstudio, caffeinate-claude repo, ChuckReynolds X post) | Emerging; supply is growing faster than Ahrefs can measure | `/keep-mac-awake-claude-code` (+ Codex/Cursor variants). Core positioning page; also seed a Claude Code hook/skill |
| keep mac awake while running script | Not in DB | Negligible as phrased | Section in the how-to guide; ranks via "how to keep mac from sleeping" |
| mouse jiggler mac | 150/mo (TP 900, KD 4, transactional). Head "mouse jiggler" **18,000/mo** (GV 46,000, KD 0, TP 5,200) | **Largest adjacent demand by far** | `/vs/mouse-jiggler` + `/blog/mouse-jiggler-mac` interceptor ("you don't need a jiggler, you need to stop sleep") |

## Head terms worth owning (not in original list)

| Query | US vol | KD | Note |
|---|---|---|---|
| mouse jiggler | 18,000 | 0 | Adjacent intent; interceptor only |
| amphetamine mac | 1,300 | 0 | Navigational to the App Store app; alternative page |
| how to keep mac from sleeping | 1,000 | 0 | Best informational entry point (TP 3,200) |
| caffeine mac | 1,000 | 0 | Abandoned Lighthead app; alternative page |
| caffeinate mac | 900 | 0 | Developer intent; caffeinate page |
| caffeine for mac | 700 | 0 | Same page as caffeine mac |
| amphetamine app mac | 350 | 0 | Same page as amphetamine mac |
| keepingyouawake | 100 | 1 | Alternative page |
| keep mac awake | 100 | 57 | Hard for its size; skip as primary |

## Takeaways
1. The long-tail "X alternative" phrasings have near-zero measured volume; demand lives in the **head terms** (amphetamine mac, caffeine mac, caffeinate mac) at KD 0. Alternative pages must be titled to catch the head term.
2. Three pages carry most of the reachable volume: `/caffeinate`, `/amphetamine-alternative`, `/caffeine-alternative` (~4,000/mo combined US, all KD 0).
3. "how to keep mac from sleeping" (1,000/mo, TP 3,200) is the best generic guide target.
4. "keep mac awake for claude code" is not yet measurable but the SERP is filling with 2026 posts; own it early.
5. Mouse jiggler is 10x everything else combined, but the intent is presence-faking; treat as an interceptor, not a positioning target.
