# Amphetamine — Competitor Profile

Researched 2026-09-30. Sources: Mac App Store (page + iTunes Lookup API), GitHub (x74353 repos + issues), press coverage, third-party comparison articles. Reddit could not be scraped directly; community signal comes from GitHub issues and App Store reviews.

## At a Glance

| Field | Value |
|---|---|
| Tagline | "Powerful keep-awake utility" (App Store subtitle); "the most awesome keep-awake app ever created for macOS" (description) |
| Maker | William Gustafson (solo dev, GitHub `x74353`, site iffy.co — site returned a TLS error on fetch, may be down) |
| Price | Free. "No catch... No ads, no IAP, no pro version, no tracking" |
| License | Proprietary / closed source. Only the helper add-ons (Enhancer, Power Protect) are MIT on GitHub |
| Distribution | Mac App Store only (sandboxed). No Homebrew cask, no DMG (issue #3 requests one, unanswered) |
| Min macOS | 10.13 High Sierra |
| Download size | 6.7 MB |
| Current version | 5.3.2, released 2023-11-10 (App Store API `currentVersionReleaseDate`) |
| First released | 2014-11-13 |
| App Store rating | 4.8 / 5, 3.2K ratings (US store, fetched 2026-09-30) |
| GitHub | x74353/Amphetamine (resources/issues) 133 stars; Amphetamine-Enhancer 1,139 stars, last push 2020-07-06; Amphetamine-Power-Protect 69 stars, last push 2023-12-07 |

## Positioning

The "everything" keep-awake app. Marketed on breadth: 15+ trigger types, closed-display mode, AppleScript, custom icons. Free is a core message ("It's a gift from me to you"). Famous mainly for its 2021 Apple naming dispute (Apple threatened removal over the drug name, then backed down — MacRumors, 9to5Mac, Engadget coverage), which cemented it as the default Caffeine replacement.

## Features

- Sessions: indefinite, for N minutes/hours, until a clock time, while a file downloads, while an app runs
- Per-session toggles: allow display sleep, allow screen saver, allow system sleep when lid closed, move mouse cursor, lock screen
- Triggers (auto-start sessions): external display connected, display mirrored, USB/Bluetooth device, app running / frontmost, battery charging or above threshold, power adapter state, IP address, Wi-Fi SSID, Cisco AnyConnect VPN, DNS server, audio output in use, drive mounted, CPU threshold, idle threshold
- Closed-Display Mode (lid closed keep-awake) — see gotchas
- Drive Alive (keeps external drives spinning), lock screen after inactivity, periodic cursor movement
- AppleScript support, custom menu bar icons, custom notification sounds, statistics, Debug Mode
- Add-ons (separate installs, outside App Store): **Amphetamine Enhancer** (closed-display fail-safe + full process list for triggers, blocked by sandbox) and **Power Protect** (sudoers drop-in so a closed-display script can toggle `pmset disablesleep` without a password prompt on Apple Silicon)

## Pricing

Free, no monetization at all. Nothing to compete on price; compete on maintenance, simplicity, open source, and purpose-fit.

## Social Proof / Reviews

Rating: 4.8 stars, 3.2K ratings — https://apps.apple.com/us/app/amphetamine/id937984704?mt=12&see-all=reviews&platform=mac

**Praise themes** (App Store reviews, same URL):
1. Unbelievably free / high quality — "It is unbelievable that an app of that high quality is written by a single person and provided for free." (_Joe256, 2022)
2. Was frequently updated — "gets updated far more frequently than a lot of paid apps." (occasional downloader, 2021). Note this is now dated; see weaknesses.
3. Triggers solve real workflows — "essential for keeping the laptop from sleeping and thus killing remote database connections." (Bowden Data, 2021)
4. Stability — "It's stable! It's customizable! This is the BEST app to keep your MacBook awake without fail." (BP0496, 2020)
5. Customization — custom icons and sounds (silverplasticware, 2017)

**Complaint themes** (GitHub issues at https://github.com/x74353/Amphetamine/issues; 19 of 20 open, zero maintainer replies since Dec 2023):
1. Closed-lid mode is fragile — "Closed-Display Mode silently dropped for timed sessions when no external display is attached (5.3.2 + Power Protect)" (#19, Aug 2026); "if enable it, my Mac just goes to sleep when the lid is closed" (#1, Dec 2023)
2. Power Protect side effects — "Power Protect (disablesleep toggling) may trigger black-screen-on-wake from deep sleep on macOS Tahoe 26" (#16, May 2026)
3. Doesn't work on newer macOS/hardware — "Amphetamine no effect on MacOS 15.3.x" on M4 Max (#11, Apr 2025)
4. Nagging permission prompts — "Keep getting message about Location Services access when app starts" (#5, 2024; users still reporting in 2025)
5. Distribution — "Request: Amphetamine .DMG file release" (#3), "Homebrew installation would be so dope" (Jun 2026 comment); "Certificate Expired" (#12, Apr 2025)
6. Reliability decay — "Drive Alive stops working after some days and requires full reboot" (#14, Feb 2026); "Screen lock silently fails on non-QWERTY keyboard layouts" (#18)

## Strengths

- Brand recognition: the name everyone searches for; 4.8 stars on 3.2K ratings; press history
- Deepest feature set in the category (triggers, AppleScript, closed-display mode)
- Genuinely free with no dark patterns
- Runs back to macOS 10.13, so works on old Macs

## Weaknesses

- **Effectively unmaintained**: last release 2023-11-10 (almost 3 years ago as of this scan). No developer activity on GitHub since Dec 2023; `x74353` has no public GitHub events. Issues from 2024-2026 sit unanswered. Some SEO articles (bundl.run) claim "updates into early 2026" — the App Store API contradicts this.
- **Closed-display mode is a three-part install** (App Store app + Enhancer or Power Protect script + sudoers file + a `defaults write` from Terminal) because of App Store sandboxing. Users report it silently failing on timed sessions and on battery.
- Closed source, App Store only; no Homebrew, no notarized DMG
- Complexity: 15 trigger types and a settings maze for a job most people want done with one click
- Sonoma/Sequoia/Tahoe friction: Location Services prompt for Wi-Fi triggers, Rosetta warning, Bluetooth privacy crash fix, Tahoe wake bug with Power Protect
- The name itself: some corporate/managed environments and users object to it (Apple's 2021 objection; slack.green lists "managed corporate devices" as a switch reason)

## Implications for Midnight Oil

- Lead with **"maintained"**: "Amphetamine hasn't shipped since November 2023" is verifiable and is the single strongest switch trigger. Link the App Store version history.
- Own **closed-lid** as a first-class, one-toggle feature. Amphetamine's Power Protect saga (separate download, sudoers file, Terminal command, silent failures, Tahoe black-screen reports) is the exact pain an overnight-agent user hits. Document how Midnight Oil does it and whether it needs a password.
- Own **the AI-agent use case** explicitly. Third-party guides (getmasset.com, Jun 2026) already recommend Amphetamine for "keep your Mac awake for AI agents" with the warning "Test it before you trust it on the walk to a meeting." Nobody owns that keyword with a purpose-built product.
- Ship via **Homebrew cask + notarized DMG** and say so; Amphetamine users have been asking for both since 2024.
- Don't try to match 15 trigger types. Position simplicity as the feature ("one job, done right"), but keep the two triggers that matter for agents: while a process/app is running, and until a time.
- Open source + MIT is a differentiator vs Amphetamine (proprietary), and a parity point vs KeepingYouAwake.
- Keep the comparison factual and respectful; Amphetamine has a loyal base and a sympathetic solo-dev story.

## Sources

- https://apps.apple.com/us/app/amphetamine/id937984704
- https://apps.apple.com/us/app/amphetamine/id937984704?mt=12&see-all=reviews&platform=mac
- https://itunes.apple.com/lookup?id=937984704&country=us (version 5.3.2, 2023-11-10, 6.7 MB, min 10.13, release notes)
- https://github.com/x74353/Amphetamine (resources + issue tracker)
- https://github.com/x74353/Amphetamine/issues/1, /11, /16, /19, /3, /5, /12
- https://github.com/x74353/Amphetamine-Enhancer
- https://github.com/x74353/Amphetamine-Power-Protect
- https://github.com/x74353/SaveAmphetamine
- https://www.macrumors.com/2021/01/02/amphetamine-app-store-removal-threat/
- https://9to5mac.com/2021/01/03/apple-macos-amphetamine/
- https://slack.green/en/blog/amphetamine-mac-alternative
- https://www.getmasset.com/resources/blog/keep-your-mac-awake-for-ai-agents
- https://alternativeto.net/software/amphetamine/
- https://koffret.com/learn/amphetamine-fuguai (Power Protect install steps)
- iffy.co/amphetamine — TLS error on fetch 2026-09-30, unverified
