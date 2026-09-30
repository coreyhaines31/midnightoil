# caffeinate (built-in macOS command)

## At a Glance
- **What:** `/usr/bin/caffeinate` — Apple's CLI to "prevent the system from sleeping on behalf of a utility." Ships with every Mac since OS X 10.8 (2012); man page dated Nov 9, 2012 and unchanged since.
- **Price:** Free, preinstalled, no admin rights needed.
- **Interface:** Terminal only. No menu bar, no GUI, no preferences.
- **Search demand (Ahrefs US):** "caffeinate mac" 900/mo, "caffeinate command" 150/mo, "caffeinate mac command" 100/mo. Parent topic "caffeinate mac" TP ~1,000. KD 0-6.
- **Position vs Midnight Oil:** The zero-cost default every developer already knows. Midnight Oil wraps the same IOKit power assertion in a GUI with triggers and closed-lid support.

## What it does
Creates IOKit power-management assertions (the same mechanism Xcode uses). With no flags it prevents idle sleep. If a utility is passed, the assertion lives for that process; otherwise it lives until caffeinate exits (Ctrl-C or terminal closes).

| Flag | Effect |
|---|---|
| `-d` | Prevent the **display** from sleeping |
| `-i` | Prevent the system from **idle** sleeping (default behavior) |
| `-m` | Prevent the **disk** from idle sleeping |
| `-s` | Prevent **system** sleep — "valid only when system is running on AC power" |
| `-u` | Declare **user active**; wakes the display; defaults to a 5-second timeout without `-t` |
| `-t N` | Timeout in seconds; "not used when an utility is invoked" |
| `-w PID` | Hold assertion until the given process exits; "ignored when used with utility option" |

Common recipes: `caffeinate` (until Ctrl-C), `caffeinate -disu` (everything), `caffeinate -t 3600`, `caffeinate -i make`, `caffeinate -w <pid>`, `killall caffeinate`.

## Limitations
- **No closed-lid support.** "a lid close is an explicit sleep request, and no assertion overrides it." The workaround is `sudo pmset -a disablesleep 1` (needs sudo, and must be manually reverted).
- **No GUI, no status.** Nothing in the menu bar tells you it is running. Check with `ps aux | grep caffeinate` or `pmset -g assertions`.
- **Forgetting to kill it.** A bare `caffeinate` will "run until you kill it." Zombie processes survive force-quit of the parent (CaffeineKit exists specifically to fix "zombie caffeinate processes").
- **Dies with the terminal.** "closing or crashing the Terminal window terminates that process and drops the assertion" — the community answer is tmux, which is more setup.
- **No triggers.** Cannot activate on app launch, on AC power, at a schedule, or when a specific process is busy.
- **Silent no-ops.** `-s` does nothing on battery; `-t` is ignored when wrapping a command; `-u` expires after 5s. Users regularly think it worked when it didn't.
- **No sleep-again scheduling.** Cannot say "keep awake until 6am then let it sleep."

## What people say
- "caffeinate creates a power assertion, which holds off idle sleep ... a lid close is an explicit sleep request, and no assertion overrides it." — https://www.machinefriendly.com/blog/keep-macbook-awake-lid-closed-awaketoggle
- "A Mac still running inside a closed bag has nowhere to dump heat and will drain flat" (on the pmset workaround). — same
- "`caffeinate` alone will not keep a MacBook awake with the lid shut. Closing the lid triggers clamshell sleep, and a software power assertion cannot override it on battery power — full stop." — https://blog.openreplay.com/mac-awake-overnight-agent-runs-caffeinate/
- Recommended overnight-agent recipe: `tmux new-session -d -s agent 'caffeinate -i claude'` — same
- "So I figured out you can keep your mac awake while Claude Code is working (like overnight) ... It uses caffeinate (built into macOS) + Claude Code hooks in ~/.claude/settings.json" — https://x.com/ChuckReynolds/status/2065316099886117004
- Community wrappers exist because raw caffeinate is clunky: caffeinate-claude (https://github.com/bmoeskau/caffeinate-claude), CaffeineKit (https://github.com/jrr6/CaffeineKit), alfred-caffeinate (https://github.com/shawnrice/alfred-2-caffeinate-workflow), anti-sleep Claude skill (https://vibehackers.io/claude-code/skills/anti-sleep-sickn33).

Common how-to searches: "caffeinate mac", "how to keep mac from sleeping" (1,000/mo), "prevent mac from sleeping terminal", "caffeinate lid closed", "caffeinate not working", "killall caffeinate", "caffeinate -t hours", "caffeinate claude code".

## Implications for Midnight Oil
1. **Do not fight caffeinate; absorb it.** Ship a `/caffeinate` comparison page that teaches every flag honestly, then shows the four gaps (closed lid, visible status, triggers, auto-off). Developers will trust a page that explains `-disu` correctly.
2. **The AI-agent overnight use case is already being solved with caffeinate + tmux + hooks.** Multiple 2026 posts (openreplay, andrewbaker.ninja, bleepingswift, kanaries, agentbarista, caffeinate-claude) show demand; all of them end at "use tmux" or "use pmset disablesleep." Midnight Oil's pitch: same result, one click, plus lid-closed and sleep-again-at-6am.
3. **Forgetting to kill it is the emotional hook.** Menu-bar visibility + "wake until X / until process exits" triggers directly answer the top complaints.
4. **Offer a CLI shim** (`midnightoil -i claude`) so terminal users lose nothing.
5. **Closed-lid is the headline differentiator** — caffeinate categorically cannot do it, and the pmset workaround requires sudo and carries an overheating warning.

## Sources
- `man caffeinate` (local, macOS 26 / Darwin 25.6)
- https://ss64.com/mac/caffeinate.html
- https://www.machinefriendly.com/blog/keep-macbook-awake-lid-closed-awaketoggle
- https://blog.openreplay.com/mac-awake-overnight-agent-runs-caffeinate/
- https://www.techradar.com/how-to/computing/apple/terminal-101-prevent-your-mac-from-sleeping-1305716
- https://github.com/jrr6/CaffeineKit · https://github.com/bmoeskau/caffeinate-claude
- Ahrefs Keywords Explorer (US), 2026-09-30
