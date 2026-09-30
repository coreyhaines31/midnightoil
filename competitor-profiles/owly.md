# Owly — Competitor Profile

Researched 2026-09-30 via WebFetch/WebSearch. Facts marked "unverified" could not be confirmed.

## At a Glance

| | |
|---|---|
| Tagline | "Keep your display awake" (App Store subtitle); site: "A lightweight menu bar utility that prevents your Mac from sleeping. Pick a duration, set smart triggers, and never worry about your Mac dozing off mid-task again." |
| Maker | FIPLAB Ltd, London (est. 2009; makers of Memory Clean, Battery Monitor, etc.). Site: fiplab.com/apps/owly-for-mac |
| Price | Free on the Mac App Store (id882812218). No IAP or Pro tier listed. |
| License | Proprietary / closed source |
| Current version | 2.5, released 25 Feb (2026 per App Store; year not printed). "Rebuilt for macOS Tahoe with new interface" |
| Prior cadence | 2.4 (Jul 2021, M1 support), 2.3 (Oct 2020), 2.2 (Oct 2020), back to 1.0 (Jun 2014). Roughly a 4.5-year gap between 2.4 and 2.5. |
| Min macOS | 11.5 or later |
| Size | 6.6 MB |
| Apple Silicon | Native since 2.4 (Jul 2021) |
| Ratings | App Store US: 4.7/5, 382 ratings (largest review base of the four) |

## Positioning

The free, "smart triggers" option on the App Store from an established utility shop. Long-lived (2014) with a loyal user base; App Store reviews repeatedly call it a Caffeine replacement. The 2.5 rebuild positions it as modern (Tahoe UI, inline duration grid, icon colors) while remaining free.

## Features

- Duration grid: 5 minutes to 8 hours, or indefinite; live countdown in menu bar and dock badge
- Two modes: "Keep Awake" (display + system) or "Display Only"
- Smart Triggers: daily schedule; power connect/disconnect; auto-activate when specific apps launch
- Global hotkey (customizable)
- Battery threshold protection (auto-off below a set battery level)
- Notifications on activate/deactivate
- Launch screensaver action; 10 active icon colors incl. system accent
- Dark mode; start at login; dock icon toggle; right-click toggle on/off
- Help center at support.fiplab.com/owly (Duration Modes, Smart Triggers, Preferences pages)

Not present: no closed-lid/clamshell support (confirmed by a Nov 2025 review); no Shortcuts/URL scheme/CLI found on site or store page (unverified); no calendar integration.

## Pricing

Free, no IAP. FIPLAB monetizes elsewhere; privacy label notes the app collects email for marketing and crash data (not linked to identity).

## Social proof / reviews

Praise themes:
- Caffeine replacement: "Perfect Replacement for Caffeine ... Owly blows the rest of them out of the water" (COGirl33, Apr 2018) — https://apps.apple.com/us/app/owly-prevent-display-sleep/id882812218?see-all=reviews
- Lightweight: "does not slow down or otherwise interfere with computer speed" (Big.Pooh, Feb 2017) — same
- External display / TV use case: keeps HDMI smart TVs from sleeping "with NO ABILITY to disable this sleep mode" otherwise (Mannyar, Jun 2020) — same
- Timer flexibility: "Extremely useful!" for toggling between work and breaks (Bizarre Foodie, May 2017) — same
- Support responsiveness: "customer support I received a response in 4 minutes" (BoxerDoc, Oct 2020) — same
- Corporate lock-policy workaround: "It works perfectly!!!" (TravJohn, Dec 2020) — same

Complaint themes:
- No clamshell: "Owly doesn't have the ability to keep my MacBook awake in clamshell mode" without charger (Evan Hatfield, Nov 5 2025) — same URL
- Doesn't persist across reboot: "occasionally fails to remain enabled after rebooting, requiring manual reactivation" (RobE2760, Jul 2017) — same
- Idle-based wake request: wants "the wake time to start after the last detected activity" (VMGore, Aug 2018) — same
- Multi-year gaps with no updates (2021 to 2026) — App Store version history
- Marketing email collection in privacy label — App Store listing
- No Reddit threads surfaced in searches.

## Strengths

- Free with a genuinely competitive feature set (triggers, modes, battery guard, hotkey, countdown)
- Largest rating base (382) and highest-volume social proof among the four
- Established company; just re-invested (Tahoe rebuild)

## Weaknesses

- Closed source; email-for-marketing data collection
- No closed-lid support (App Store sandbox)
- History of long dormancy; App Store dependency
- No automation surface (Shortcuts/CLI) found
- Not framed for developers or long-running jobs at all

## Implications for Midnight Oil

- Owly is the toughest "free" comparison: it already has triggers, modes, hotkeys, and battery guard. An "Owly alternative" page cannot win on feature count alone; win on open source, no data collection, closed-lid, and agent/dev workflow (CLI hooks, process-aware sessions).
- Reuse Owly's proven feature vocabulary (duration grid, smart triggers, display-only mode) so users see parity at a glance.
- The reboot-persistence and idle-based-start complaints are small, concrete wins to ship and call out.
- Do not claim Owly is abandoned; 2.5 shipped in 2026.

## Sources

- https://fiplab.com/apps/owly-for-mac
- https://apps.apple.com/us/app/owly-display-sleep-prevention/id882812218?mt=12 (and see-all=reviews)
- https://support.fiplab.com/owly/getting-started
- https://www.fiplab.com/
