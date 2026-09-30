# Lungo — Competitor Profile

Researched 2026-09-30 via WebFetch/WebSearch. Facts marked "unverified" could not be confirmed.

## At a Glance

| | |
|---|---|
| Tagline | "Keeps your Mac awake" (App Store subtitle) / "Prevent your Mac from going to sleep" (site) |
| Maker | Sindre Sorhus (prolific open-source dev; Lungo is one of his paid closed-source Mac apps). Site: sindresorhus.com/lungo |
| Price | $4.00 one-time on the US Mac App Store (App Store id1263070803). Also in Setapp ($14.99/mo bundle). No IAP. |
| License | Proprietary / closed source. Not open source. |
| Current version | 2.8.3 ("Bug fixes"), released 15 Sep (2026 per App Store; year not printed on page) |
| Min macOS | macOS 26 (Tahoe) for current version. Older builds 1.6.0–2.7.2 offered free on the site for macOS 10.13–15 |
| Size | 6 MB |
| Apple Silicon | Native (unverified on-page, but Sindre's apps are Swift/Universal; no Rosetta complaints found) |
| Ratings | App Store US: 4.8/5, 200 ratings. Setapp: 99% positive, 1,840 ratings. Product Hunt: 278 upvotes, #1 of day (2017) |

## Positioning

Design-first minimalism from a developer with a large following. Sindre's own framing at launch: "a modern alternative to Caffeine, which hasn't been updated in years." The site states the philosophy explicitly: focused features and great defaults rather than Amphetamine-style feature sprawl. Chris Messina on PH: "I could never understand all the extra features in Amphetamine."

## Features

- Menu bar toggle; right-click to activate (opt-in "Activate on left-click")
- Duration presets (e.g. 10 min, 1 hour, indefinite) with configurable default duration
- Custom keyboard shortcuts to activate/deactivate
- "Allow display to sleep while keeping computer awake"
- "Pause while screen is locked"
- "Deactivate when switching to battery" (opt-in)
- Launch at login; charming menu bar animation; dark mode; VoiceOver and other accessibility support
- Automation: Shortcuts actions; URL scheme (`lungo:activate?minutes=10`, `lungo:deactivate`, `lungo:toggle`); lungo-cli command-line tool; Raycast commands; Node/Swift/AppleScript/Python examples

Explicit non-features (from Sindre's FAQ):
- Closed lid: "No, that's not allowed for apps on the App Store" (unless on charger with external display)
- System Settings sleep schedules override Lungo
- Cannot prevent restarts/forced logouts
- Does not keep Slack/Teams status active
- No triggers (app launch, schedule, power connect), no battery-threshold guard, no display-only-vs-system-only beyond the single "allow display to sleep" toggle

## Pricing

$4 one-time (US). Free older versions for unsupported macOS. Setapp inclusion. No free tier, no trial outside Setapp.

## Social proof / reviews

Praise themes:
- Does one thing well: "Does 1 thing and 1 thing well" (rm -rf --no-preserve-root /, Oct 2022); "just werks. Never fails" (DevinRhode2, Jul 2022) — https://apps.apple.com/us/app/lungo/id1263070803?see-all=reviews
- Polish/animation: "simple to use, works every time, and has a charming animation" (The instramentalist, Sep 2022) — same
- Better Caffeine: "Does the same as Caffeine, but nicer :)" (TK Running, Jul 2017) — same
- Consolidation: "I have been using it and have uninstalled all other messy applications" (Ahmad Awais) — https://www.producthunt.com/products/lungo
- Focus: "When an app focus on doing a thing right" (Jose, Sep 24 2026) — https://setapp.com/apps/lungo

Complaint themes:
- No clamshell: "WOULD BE GREAT WITH CLAMSHELL FUNCTION" (Anders-Meyer Eldøy, Sep 3 2026) — https://setapp.com/apps/lungo
- Display never sleeps: "Display won't sleep if lungo is active" (jfwilkus, Nov 2017; dev added a preference) — App Store reviews URL above
- Aggressive OS floor: latest build requires macOS 26; users on Sonoma/Sequoia are on frozen legacy builds — https://sindresorhus.com/lungo
- Paid for something `caffeinate` does free (recurring HN/AlternativeTo sentiment; e.g. https://news.ycombinator.com/item?id=45300616)
- No Reddit threads surfaced in searches.

## Strengths

- Highest polish and best ratings in the category; strong author brand
- Real automation surface (Shortcuts, URL scheme, CLI, Raycast)
- Sandboxed, App Store trust, no data collection

## Weaknesses

- Paid and closed source
- Hard no on closed-lid, by design (App Store sandbox)
- No triggers or scheduling; deliberately minimal
- Current version drops everything before macOS 26

## Implications for Midnight Oil

- "Lungo alternative" page: free + open source + closed-lid + triggers, and support for macOS 13/14/15, not just 26. Those four gaps are the whole pitch.
- Lungo's users value restraint; do not out-Amphetamine them. Keep the default UI as simple as Lungo, put power under a menu.
- Match its automation surface (CLI/URL scheme/Shortcuts) if the target is people running agents; Lungo's CLI is the nearest thing to an agent hook in this set.
- Cite the Setapp clamshell review as evidence of unmet demand.

## Sources

- https://sindresorhus.com/lungo
- https://apps.apple.com/us/app/lungo/id1263070803?mt=12 (and see-all=reviews)
- https://setapp.com/apps/lungo
- https://www.producthunt.com/products/lungo
- https://blog.apps.deals/amphetamine-alternatives-mac (Aug 2026 comparison)
