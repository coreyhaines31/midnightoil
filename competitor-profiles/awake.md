# Awake — Competitor Profile

Researched 2026-11-03 from the launch tweet (x.com/illyism/status/2117564207386574909) and the GitHub README. Launched the same day; numbers are day-one.

## At a Glance

| | |
|---|---|
| Tagline | "Close the lid. Keep running." |
| Maker | Ilias Ism (@illyism) |
| Repo / site | github.com/Illyism/awake · il.ly/awake |
| Price | Free |
| License | MIT, open source (Swift) |
| Current version | 1.0.2 (2026-11-03, repo created the same day) |
| Min macOS | App: macOS 26 Tahoe on Apple Silicon (cask `depends_on macos: :tahoe`, `arch: :arm64`; arm64-only DMG). CLI: the Homebrew formula only needs macOS, and the Nix flake builds for `x86_64-darwin` too |
| Traction | Launch tweet ~4.2K views / 56 likes a few hours in (via api.fxtwitter.com, 2026-11-03); 3 GitHub stars at research time |
| Distribution | curl install script, "tell your agent" prompt, Homebrew tap (cask + CLI formula), notarized DMG, Nix flake / nix-darwin module |

## Positioning

Built for one job: closing the lid while AI agents run (Claude Code, Codex, Cursor, OpenCode), sold through fear of what goes wrong. The pitch is a teardown of the alternatives: bare `caffeinate` doesn't stop Clamshell Sleep, `caffeinate` without `-d` lets Wi-Fi drop, and raw `sudo pmset -a disablesleep 1` leaves the screen unlocked and "cooks your MacBook to 50°C+ in a backpack" (launch tweet; the README says "past 45°C"). It is the closest competitor to Midnight Oil's own agent-focused positioning.

## Features

- Lid-closed keep-awake: `pmset -a disablesleep 1` + `caffeinate -dims` + IOKit `kPMSetClamshellSleepState`
- **Instant screen lock on lid close**: watches `AppleClamshellState` on `IOPMrootDomain`, calls private `SACLockScreenImmediate()`
- **Backpack circuit breaker**: every 30s checks battery %, `AppleSmartBattery` temperature, and thermal pressure. Pauses at ≤10% battery or a closed lid at ≥40°C / thermal pressure ≥ moderate, then **auto-resumes** (+4% battery / −2°C hysteresis) for timed and indefinite sessions. `awake -- <cmd>` stops instead of resuming. Thresholds set by env vars
- **Control Center toggle** (macOS 26 `ControlWidgetToggle`, sandboxed appex)
- Menu bar timer (30m/1h/2h/4h/indefinite) showing live battery % and temperature; the menu bar icon can be hidden
- CLI: `awake`, `awake 45m`, `awake -- <cmd>`, `awake status` (shows temp, lid state, last auto-stop reason), `asleep`
- `~/.config/awake/on-sleep` hook script (idle/sleep events, e.g. unmount encrypted volumes)
- No network calls or telemetry

## Privilege model

Installs `/etc/sudoers.d/awake` (validated with `visudo -cf`) allowing passwordless `pmset -a disablesleep 0|1` for every `%admin` user. Any process running as an admin user can toggle that setting, which is a wider grant than a team-signed helper, though limited to two exact commands. Setup uses Touch ID.

## Where Midnight Oil is ahead

- A signed `SMAppService` helper that accepts only the team-signed app, instead of a sudoers rule
- Normal sleep is restored if the app crashes
- Triggers (Wi-Fi, devices, displays, power, apps), Drive Alive, lid-close alarm on battery
- `run` passes through the command's exit status and shares one session across parallel runs; `--json`
- A universal app (Intel + Apple Silicon) on macOS 14+. Awake's app is Apple Silicon + Tahoe only; its CLI alone runs on Intel

## Where Awake is ahead (tracked)

- Screen lock on lid close → #142
- Thermal pause plus auto-resume → #143
- Control Center toggle + `awake 45m` shorthand → #144
- Nix packaging, the `on-sleep` hook (not tracked)

## Messaging to borrow

- The "backpack" fear: heat, a dead battery, an unlocked screen
- A "why bare caffeinate isn't enough" teardown section
- Candidate pages: `/vs/awake`, a guide on whether you can close a MacBook while Claude Code runs
