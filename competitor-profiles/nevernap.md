# NeverNap / NeverNap Pro — Competitor Profile

Researched 2026-09-30 via WebFetch/WebSearch. Facts marked "unverified" could not be confirmed.

## At a Glance

| | NeverNap (free) | NeverNap Pro |
|---|---|---|
| Tagline | "Stay awake, keep focused!" | "Keep your Mac awake" / "NeverNap Pro keeps your Mac awake when you need it most." |
| Maker | Lucas Raggers (indie, Netherlands; lucas.io; PH handle @van_laren) | same |
| App Store | id6739217844 | id6754521162 |
| Price | Free, no IAP | $2.99 / €2.99 one-time; Family Sharing (6); no IAP |
| License | Proprietary / closed source | same |
| Current version | 1.4, 28 Nov 2025 ("Finetuning") | 1.3, 8 Sep 2026 ("Bug fixes for reliability") |
| First release | 1.0, 15 Dec 2024 | 1.0, 29 Oct 2025 (Product Hunt launch 30 Oct 2025, 130 upvotes, #9 of day) |
| Min macOS | 13 Ventura or later | macOS 26 Tahoe or later (onmymenubar.app claims 14+; App Store says 26 — trust App Store) |
| Size | 854.9 KB (v1.2.2 notes: "Optimized to 177 KB") | 4.1 MB |
| Ratings | 5.0/5, 3 ratings (US) | "not enough ratings" (US and NL) |
| Apple Silicon | Native (unverified; new SwiftUI-era app, no Rosetta reports) | same |

## Positioning

A solo-dev "modern Caffeine" that launched free in Dec 2024 and added a $2.99 Pro sibling in Oct 2025. Maker's PH framing: "NeverNap Pro has more features and customization than Caffeine app." Pro sells on presets, three prevention modes, scheduling, app triggers, and calendar integration. Very small footprint and a privacy label of "collects no data" for both. Product Hunt lists Lungo, Caffeinated, and Amphetamine as its comparables.

## Features

Free NeverNap:
- Menu bar toggle with preset durations (5 min up to indefinite; 5-second preset removed in 1.2.1)
- Countdown timer with notification on expiry and "extend" option (1.1); notification toggle (1.2)
- Visible active indicator in menu bar

NeverNap Pro adds:
- Quick presets 5 min / 15 / 30 / 1 h / 4 h / infinite, plus custom exact-duration presets
- Three prevention modes: Full, Display only, System only
- Schedule a preset until a specific time or between time ranges
- Auto-activate presets when specific apps launch (improved in 1.2 "smarter app automation")
- Calendar integration: auto-activate during events, auto-deactivate after (1.1, refined 1.2)
- Global keyboard shortcuts per preset
- Show preset name and/or timer in menu bar
- Battery protection: minimum battery level for MacBooks

Not present (per store pages, lucas.io, onmymenubar): closed-lid/clamshell, Shortcuts/URL scheme/CLI, process- or agent-aware sessions, Homebrew.

## Pricing

Free tier is a real (limited) product; Pro is $2.99 one-time, no subscription, no IAP. Cheapest paid option among the four (Lungo $4).

## Social proof / reviews

Praise themes:
- Countdown + quick presets + visible indicator: "Amazing App" (kyle mcghost, 5/5, Jun 17 2025) praising "a countdown, quick time options, and a menu bar indicator" — https://apps.apple.com/us/app/nevernap/id6739217844?see-all=reviews
- Simplicity: "no complicated options or confusing interface elements" — https://onmymenubar.app/nevernap/
- Calendar integration called out as the standout Pro feature — same
- Head-to-head win in a blog test: "I Tested 2 Mac Sleep Prevention Apps (Spoiler: NeverNap Won My Heart)" — https://medium.com/@PowerUpSkills/i-tested-2-mac-sleep-prevention-apps-spoiler-nevernap-won-my-heart-5a273b7e1113 (fetch returned 403; title only)
- Third-party promo: X post by @okuwaki_m — https://x.com/okuwaki_m/status/1984077354931835251

Complaint themes:
- Almost no review volume: 3 ratings on free, none on Pro; no Reddit threads found. Absence of complaints reflects absence of audience, not a flawless product.
- Feature requests in the one review: custom icons and active-indicator color options — App Store review above
- Pro requires macOS 26, cutting off Sonoma/Sequoia users while the free app supports 13+
- Free app has not shipped since Nov 2025 (10 months); Pro is where updates go
- Review-site filler (funblocks, chatgate) suggests "more explicit onboarding" — https://www.funblocks.net/aitools/reviews/nevernap-pro (low-signal)

## Strengths

- Cheap, modern, no data collection, Family Sharing
- Calendar-event trigger is unique among the four
- Three prevention modes and per-preset hotkeys match or beat Owly

## Weaknesses

- Tiny footprint in search and social proof; unknown brand
- Solo dev; two SKUs to maintain; free tier already going stale
- Pro locked to macOS 26
- No closed-lid, no CLI/automation, no dev/agent framing

## Implications for Midnight Oil

- Low-priority alternative page (little search demand to capture), but a useful comparison row: NeverNap Pro is the "$2.99 with triggers" benchmark, so Midnight Oil's free/open-source feature set should be at least a superset (modes, hotkeys, schedule, app triggers, battery guard).
- Calendar-event trigger is a cheap idea to borrow if it fits the agent-overnight story (e.g. "keep awake until my 8am event").
- Emphasize macOS 13/14/15 support and open source against Pro's macOS 26 floor.
- Do not overstate: NeverNap is actively maintained (Pro 1.3 shipped Sep 2026).

## Sources

- https://apps.apple.com/us/app/nevernap/id6739217844 (and see-all=reviews)
- https://apps.apple.com/us/app/nevernap-pro/id6754521162?mt=12
- https://apps.apple.com/nl/app/nevernap-pro/id6754521162
- https://lucas.io/nevernappro and https://lucas.io/nevernap/
- https://www.producthunt.com/products/nevernap-pro
- https://onmymenubar.app/nevernap/
