# Caffeine — Competitor Profile

Researched 2026-09-30 via WebFetch/WebSearch. Facts marked "unverified" could not be confirmed.

## At a Glance

| | |
|---|---|
| Tagline | "Don't let your Mac fall asleep." |
| Maker | IntelliScape Solutions (Michael Jones), continuing Tomas Franzén's 2006 Lighthead Software app with his blessing. Site: intelliscapesolutions.com/apps/caffeine |
| Price | Free; donations via Donorbox |
| License | Open source, MIT (github.com/IntelliScape/caffeine, forked from tomasf/caffeine; Objective-C; 231 stars / 31 forks at time of fetch) |
| Current version | 1.1.4, released 21 Sep 2025 |
| Min macOS | macOS 11.5 Big Sur or later; "Compatible with macOS Tahoe 26!" |
| Size | ~827 KB (MacUpdate listing); site does not list size |
| Apple Silicon | Native as of 1.1.4 (universal binary; "Rosetta no longer required") |
| Distribution | Direct download or `brew install --cask caffeine`; not on the Mac App Store |
| Ratings | No App Store listing. MacUpdate: 4.4/5 from 68 ratings, 340,241 downloads |

## Positioning

The original 2006 keep-awake app and the name everyone remembers. One-click coffee-cup toggle in the menu bar: full cup = awake, empty cup = normal sleep. Right-click (or Cmd-click) for preferences. Trades on nostalgia and simplicity; the site's pitch is essentially the 2006 pitch plus "now works on Tahoe."

Fork confusion is real: at least three "Caffeine for Mac" projects share the name and coffee-cup icon — IntelliScape (intelliscapesolutions.com, v1.1.4), domzilla/Caffeine by Dominic Rodemer (caffeine-app.net, v1.6.4, MIT, 739 GitHub stars, adds localization), and Caffeine-Mac-Software/Caffeine-Mac on GitHub. A MacUpdate reviewer (oklair1, May 2025) even points users to caffeine-app.net as "newer development." Unverified which fork Homebrew's `caffeine` cask currently points to.

## Features

- Menu bar toggle (left-click on/off; right-click or Cmd-click for menu)
- Prevents idle sleep, display dimming, and screen saver
- Default duration presets in Preferences (indefinitely or fixed timeouts; exact preset list not confirmed on the current site)
- "Activate at launch" and "Start at login" options
- 1.1.4: changed keep-awake logic for macOS Tahoe breaking changes; fixed menu bar icon sometimes invisible; Apple Silicon native

Not present (per site/README): no triggers (app launch, power, schedule), no global hotkey, no closed-lid/clamshell support, no display-only vs system-only modes, no Shortcuts/URL scheme/CLI, no battery threshold, no notifications, no countdown display.

## Pricing

Free. Donation link only. No Pro tier, no IAP.

## Social proof / reviews

Praise themes:
- Simplicity and reliability: "This app does exactly what it says" style sentiment is the norm; MacUpdate reviewers wtfcar (Oct 2021) and iAziz (Sep 2021) gave 5/5 with no caveats — https://caffeine.macupdate.com/
- Legacy/name recognition: Lungo's own launch describes itself as "a modern alternative to Caffeine, which hasn't been updated in years" — https://www.producthunt.com/products/lungo
- Homebrew availability and tiny footprint (sub-1 MB)

Complaint themes:
- Privacy: "Why does this app ping analytics.intelliscapesolutions.com every 2 minutes?" — urbanaut, 0/5, Apr 2023, https://caffeine.macupdate.com/
- Dark mode / icon visibility: "does not support dark mode, rendering the menu bar icon invisible in that case" — paul-109, 3/5, Apr 2023, same URL (1.1.4 notes claim an icon-visibility fix)
- Breakage on new macOS: "didn't work for me on os 12" — marvin.effe, Nov 2021, same URL; HN thread "macOS Tahoe breaks Caffeine and other keep-awake apps" — https://news.ycombinator.com/item?id=45300616 (though commenter latexr reported it "worked fine" on a test Tahoe machine)
- Perceived abandonment: multi-year gaps between releases; AlternativeTo commenters steer to KeepingYouAwake: "Has all the features of Caffeine but includes auto-update and is open-source!" (Oct 2019) — https://www.alternativeto.net/software/caffeine/
- No Reddit-specific threads surfaced in searches.

## Strengths

- Brand recognition: "caffeine mac" is the generic term for the category
- Free, MIT, Homebrew cask, tiny
- Finally Apple Silicon native and Tahoe-compatible (Sep 2025)

## Weaknesses

- Feature-frozen at 2006 scope: no triggers, hotkeys, clamshell, modes, automation
- Slow cadence; each new macOS has broken it at least briefly
- Three forks with the same name and icon confuse users and split trust
- Analytics-ping complaint undermines the "tiny harmless utility" story
- Not sandboxed / not on App Store (fine for devs, a friction point for others)

## Implications for Midnight Oil

- "Caffeine alternative" page should lead with: modern, maintained, native, and explicit about the Tahoe breakage history. Name-check the fork confusion as a reason to want one canonical, actively maintained app.
- Match the one-click toggle and Homebrew cask (table stakes), then differentiate on closed-lid, triggers, and the overnight-agent use case Caffeine never contemplated.
- Zero telemetry is a stated selling point given the analytics complaint.
- Do not claim Caffeine is Intel-only or dead; as of 1.1.4 it is neither.

## Sources

- https://www.intelliscapesolutions.com/apps/caffeine
- https://intelliscapesolutions.com/apps/caffeine/releasenotes (returned HTTP 500 on fetch; version facts via search snippets)
- https://github.com/IntelliScape/caffeine
- https://caffeine.macupdate.com/
- https://www.caffeine-app.net/en/ and https://github.com/domzilla/Caffeine (competing fork)
- https://news.ycombinator.com/item?id=45300616
- https://www.alternativeto.net/software/caffeine/
- https://roaringapps.com/app/caffeine (stale; lists old 32-bit Lighthead build as discontinued)
