# KeepingYouAwake — Competitor Profile

Researched 2026-09-30. Sources: GitHub repo, releases API, issues, CHANGELOG, keepingyouawake.app, third-party comparison articles. Reddit could not be scraped directly; community signal comes from GitHub issues.

## At a Glance

| Field | Value |
|---|---|
| Tagline | "Prevents your Mac from going to sleep." (site + repo description) |
| Maker | Marcel Dierkes (GitHub `newmarcel`), Germany; solo maintainer with community PRs, since 2014 |
| Price | Free |
| License | MIT, fully open source (asks forks not to reuse the name/icon) |
| Distribution | GitHub release zip; Homebrew `brew install --cask keepingyouawake`; Sparkle auto-updates. Not on the App Store |
| Min macOS | 10.13 for 1.6.8; unreleased 1.6.9 raises to macOS 12 (Apple toolchain requirement) |
| Download size | 4.5 MB zip (1.6.8); 1.7-2.2 MB for prior versions |
| Current version | 1.6.8, released 2025-09-12 (Tahoe icon). 1.6.7 on 2025-07-18, 1.6.6 on 2024-10-26 |
| Maintenance | Active: repo pushed 2026-08-15; 1.6.9 in CHANGELOG; PR to prep macOS 27 build opened 2026-09-27 |
| GitHub | 6,950 stars, 270 forks, 32 open issues. 1.6.8 zip: 231,790 downloads; 1.6.7: 58,344; 1.6.6: 131,165 |
| Website | https://keepingyouawake.app/ (privacy policy, download link, © 2014-2025) |

## Positioning

The minimalist. A thin, sandboxed, hardened-runtime GUI wrapper around Apple's own `caffeinate` command, explicitly built as a modern replacement for Lighthead's abandoned Caffeine. Sells safety ("based on an official command line tool by Apple") and simplicity ("stops your Mac from sleeping with a single click"). Third-party roundups position it as the default "free, open-source, one-click" Amphetamine alternative.

## Features

- One-click activate/deactivate from the menu bar (cup icon)
- Timed activation with preset and customizable durations; "activate for duration" menu
- Advanced settings: activate on launch, deactivate at low battery / Low Power Mode, allow display sleep, quit when duration ends, deactivate while another user account is active
- Auto-activate when an external display is connected (added 1.6.3, bug-fixed in 1.6.7)
- URL scheme `keepingyouawake:///activate` and `/deactivate` for scripting
- Notifications (macOS 11+), start at login, custom menu bar icons, ~20 community translations
- Sandboxed + hardened runtime, Developer ID signed and notarized
- **Not supported**: closed lid (by design; README: "will only prevent sleep on desktop Macs and portable Macs with an open lid"), triggers beyond external display, AppleScript, screen-saver-only prevention (requested in #260)

## Pricing

Free, MIT. Nothing to undercut.

## Social Proof / Reviews

No App Store presence, so no star rating. Proxies: 6,950 GitHub stars; ~230K downloads of 1.6.8 in about a year; Homebrew cask.

**Praise themes** (README, third-party roundups, issues):
1. Open source + Homebrew — "It is free, open source and installs with Homebrew." (slack.green)
2. Simple and trusted — "wrapper around Apple's caffeinate tool ... with preset durations and an option to stop when the battery runs low" (slack.green); "For most people who only click 'keep awake' and 'stop', that is all Amphetamine was doing anyway."
3. Longevity — the app has shipped continuously since 2014 with support back to old macOS versions
4. Good citizen — issue #262: "I've been using KYA for a while now and it's really helpful."
5. Contributor-friendly — CONTRIBUTING.md, translations accepted, community PRs land

**Complaint themes** (https://github.com/newmarcel/KeepingYouAwake/issues):
1. **No closed-lid mode** is the dominant ask — #258 "Optional keep awake while lid closed option" (Aug 2026): "Enabling this feature would help many users who run autonomous agents or even just long build tasks on their MacBooks." Five follow-up comments; commenter dawoodabdullah010: "I faced the same issue with Claude Code running out overnight, so I created a solution." #262 (Sep 28, 2026) offers a PR wrapping `pmset disablesleep`; reply the same week: "need this."
2. External display trigger unreliable — #235 "Activate when External Display Connected Still Not Working" (Aug 2025); #234 "External display not registering while in clamshell"
3. Missing conveniences — #260 prevent-screen-saver-only mode; #241 live remaining-time in menu; #240 allow-display-sleep in menubar; #237 activate via Spotlight launch; #255 turn off on lid open
4. Tahoe/menu-bar quirks — #259 icon not showing on 14.7.8; #244 display cycling on Tahoe 26.03 (closed)
5. Enterprise — #250 managed preference (MDM) support

## Strengths

- Actively maintained; releases in Jul and Sep 2025, main branch touched Aug 2026, 1.6.9 in progress
- Open source, MIT, notarized, sandboxed; trusted "does nothing weird" reputation
- Homebrew cask + Sparkle updates, no App Store friction
- Tiny (under 5 MB), fast, single-purpose
- Big install base (6.9K stars, hundreds of thousands of downloads)

## Weaknesses

- **No closed-lid keep-awake, and the maintainer has historically declined it** ("out of thermal considerations"). Multiple 2026 issues show users running AI agents/long builds asking for it and third-party devs advertising their own apps in the thread (HoldAwake Direct, Sleepless, an unnamed MIT tool).
- Almost no automation: one trigger (external display), no app/process trigger, no "until time," no AppleScript
- Cannot prevent screen saver without also preventing display sleep (#260)
- Slow cadence: roughly one meaningful feature release every 1-2 years; most releases are translations and icon updates
- Minimum macOS going to 12 with 1.6.9 drops High Sierra-Big Sur users
- Web presence is a one-page site; little content marketing, no "vs" pages

## Implications for Midnight Oil

- KYA's issue tracker is a **public demand signal for exactly Midnight Oil's pitch**: closed-lid + "autonomous agents" + "Claude Code running out overnight." Quote #258 and #262 on the alternative page (they are public, dated, and specific).
- Positioning line: "KeepingYouAwake for the lid-closed, agent-running era." Match its virtues (free, MIT, tiny, Homebrew, notarized, one click) and add the two things it refuses to do: closed-lid mode and process-aware sessions ("keep awake while `claude` is running").
- Address the thermal objection head-on: KYA's maintainer says closed-lid is unsafe. Midnight Oil should document the safeguards (stop at battery threshold, plugged-in-only default, display off, auto-revert `disablesleep` on quit/crash) so the comparison doesn't read as reckless.
- Be honest about the root/sudoers requirement: KYA users care about sandboxing. Explain what Midnight Oil touches and how it cleans up.
- Ship a Homebrew cask early; KYA users arrive via `brew`.
- Competing entrants are already circling this thread (HoldAwake, Sleepless, others); speed to a polished, documented closed-lid mode matters more than feature count.

## Sources

- https://github.com/newmarcel/KeepingYouAwake
- https://github.com/newmarcel/KeepingYouAwake/releases (dates verified via api.github.com)
- https://github.com/newmarcel/KeepingYouAwake/blob/main/CHANGELOG.md
- https://github.com/newmarcel/KeepingYouAwake/issues/258 (lid-closed request, agents/Claude Code)
- https://github.com/newmarcel/KeepingYouAwake/issues/262 (lid-closed PR offer, Sep 2026)
- https://github.com/newmarcel/KeepingYouAwake/issues/261 (1.6.9 / macOS 27 prep)
- https://github.com/newmarcel/KeepingYouAwake/issues/260, /235, /234, /250, /241, /240
- https://keepingyouawake.app/
- https://slack.green/en/blog/amphetamine-mac-alternative
- https://alternativeto.net/software/keepingyouawake
- https://www.idownloadblog.com/2016/02/17/amphetamine-keepingyouawake-for-mac/
- https://github.com/Aboudjem/Sleepless (competing open-source lid-closed tool mentioned in #258; not evaluated)
