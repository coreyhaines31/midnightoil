# Mouse Jigglers (Jiggler app + hardware dongles)

## At a Glance
- **What:** Software or USB hardware that moves the cursor periodically so the machine looks "in use." Category leader on Mac is Stick Software's **Jiggler** (freeware, GPL, source on GitHub, v1.10 supports macOS 26 Tahoe). Hardware: dozens of $10-25 Amazon dongles (Giguid, Geyes, HONKID, Pukapro) plus "trackpad jiggler" mechanical devices that physically tap a MacBook trackpad.
- **Search demand (Ahrefs US):** "mouse jiggler" **18,000/mo** (global 46,000), "mouse jiggler mac" 150/mo (TP 900), "mouse jiggler software mac" 10/mo. Dwarfs every keep-awake query combined.
- **Price:** Jiggler free; hardware $10-25; App Store clones $0-10.
- **Position vs Midnight Oil:** Adjacent category with a different (and reputationally messier) job-to-be-done: faking presence rather than preventing sleep.

## What it does
- **Jiggler (sticksoftware.com):** "a little freeware app with one purpose: to keep your Mac awake." Menu bar toggle; can jiggle only when idle; conditional modes (when machine is busy, when iTunes is playing, when particular apps run); "Zen jiggle" mode moves the cursor invisibly. Needs Accessibility permission.
- **Hardware dongles:** Plug into USB-A/USB-C, enumerate as a HID mouse, wiggle the cursor on a fixed interval. "No software needed," "driver-free," marketed as "undetectable." Trackpad versions sit on the MacBook trackpad and physically tap it.
- **Why people buy them:** Keep Teams/Slack/Zoom green ("Teams shows you as Away after 5 minutes of inactivity"); corporate-locked Macs where energy settings and app installs are MDM-blocked; stepping away without the screen locking.

## Limitations
- **Do not stop a closed MacBook from sleeping.** "Close it and a MacBook sleeps, jiggler or not, unless it's plugged into power and an external display."
- **Wrong tool for actual keep-awake.** Cursor movement resets the idle timer but is a hack; on a headless/overnight run it does nothing useful that a power assertion doesn't do better.
- **Detectable.** Hardware: "A USB jiggler works because it tells the computer it is a mouse. That is also how it is found." Software: "an app that moves the cursor needs Accessibility access ... MDM tools can report that list." Behaviorally: "The movement comes every 30 or 60 seconds, on the dot."
- **Reputational risk.** Wells Fargo fired more than a dozen wealth-management employees in June 2024 for "simulation of keyboard activity"; widely covered by Forbes, TechRadar, Tom's Guide.
- **Corporate Macs block them anyway.** "MDM profiles can lock energy settings, block apps from certain sources, or pre-ban the Accessibility list entirely."
- **Hardware quality issues.** Amazon reviews cite on/off switches that fail and devices that won't work through USB hubs. Some Mac jiggler apps explicitly note they don't work with the lid closed.
- **Interferes with real work.** A moving cursor can steal focus or misclick during an unattended agent run.

## What people say
- "Jiggler is freeware (which means use it freely with no charge)" — https://www.sticksoftware.com/software/Jiggler.html
- "Slack and Teams go by input. Awake and Away is a completely normal, very annoying combination." — https://green-dotter.com/blog/mouse-jiggler-mac
- "a work from home game changer" (Amazon 5-star review of a USB jiggler) — https://www.amazon.com/Giguid-Jiggler-Undetectable-Cellphone-ROBYMICE/dp/B0BG84BH98
- "Tools like CrowdStrike and Carbon Black easily detect USB connected 'mouse jiggler' devices." — https://boards.straightdope.com/t/wells-fargo-fires-employees-for-using-mouse-jigglers/1003012
- Wells Fargo "fires over a dozen employees for faking mouse movements" — https://www.tomsguide.com/computing/wells-fargo-fires-over-a-dozen-employees-for-faking-mouse-movements
- "My manager caught me with a mouse jiggler" (viral Reddit post referenced in Forbes coverage) — https://www.forbes.com/sites/jackkelly/2024/06/18/wells-fargo-fires-mouse-jigglers-taking-aim-at-fake-work-and-other-trends/
- Category comparison pages exist because of confusion: alternativeto lists Jiggler, Mouse Mover, Mouse Shaker, Onliner as "Prevent Sleep Mode Apps" — https://alternativeto.net/software/jiggler-mouse

## How a keep-awake app differs
| | Mouse jiggler | Keep-awake app (Midnight Oil) |
|---|---|---|
| Mechanism | Fakes user input (HID events) | IOKit power assertion (same as Xcode/caffeinate) |
| Keeps Teams/Slack green | Yes | No (by design) |
| Closed-lid MacBook | No | Yes |
| Needs Accessibility permission | Yes | No |
| Shows up to IT as suspicious | Yes | No — it's a normal power assertion |
| Cursor interference | Yes | None |
| Triggers (app running, AC power, schedule) | Jiggler: partial | Yes |

## Implications for Midnight Oil
1. **Intercept the 18K/mo "mouse jiggler" traffic with an honest explainer**, not a clone: "You probably don't need a mouse jiggler — you need your Mac to stay awake." Capture the subset (devs, overnight jobs, downloads, renders, AI agents) whose real problem is sleep, and send presence-fakers elsewhere.
2. **Positioning line:** "Not a mouse jiggler. Nothing to detect, nothing to explain to IT."
3. **Closed-lid is again the wedge** — jigglers physically cannot do it.
4. **Do not add presence-faking.** It would attach the Wells Fargo stigma to an otherwise clean developer tool and trigger MDM/Accessibility flags.
5. **Page targets:** `/vs/mouse-jiggler` (comparison), `/blog/mouse-jiggler-mac` (SEO interceptor), and a FAQ entry "Does Midnight Oil keep me active on Teams/Slack? No — here's why."

## Sources
- https://www.sticksoftware.com/software/Jiggler.html
- https://green-dotter.com/blog/mouse-jiggler-mac
- https://slack.green/en/blog/can-mouse-jiggler-be-detected
- https://clickmimic.app/blog/keep-microsoft-teams-status-active-mac/
- https://www.forbes.com/sites/jackkelly/2024/06/18/wells-fargo-fires-mouse-jigglers-taking-aim-at-fake-work-and-other-trends/
- https://www.tomsguide.com/computing/wells-fargo-fires-over-a-dozen-employees-for-faking-mouse-movements
- https://www.amazon.com/Geyes-Undetectable-Multi-Track-Driver-Free-Black/dp/B0C8DGC4VT · https://www.amazon.com/MacBook-Trackpad-Jiggler-Undetectable-Mechanical/dp/B0D5L69Y78
- https://www.tomshardware.com/how-to/best-mouse-jiggler-methods
- Ahrefs Keywords Explorer (US), 2026-09-30
