"""The /cli page: telling your agent to keep the Mac awake, through the `midnightoil` command."""

# Shown on the homepage too (paste it there when it changes). The command output matches the real tool.
TERMINAL = """<div class="cli-term" role="img" aria-label="Claude Code in a terminal. You ask it to keep the Mac awake until the migration is done because you're closing the lid. It runs midnightoil run with --lid-closed, and Midnight Oil reports it's keeping the Mac awake while the migration runs, with the lid closed.">
          <div class="bar"><span><i style="background:#ff5f57"></i><i style="background:#febc2e"></i><i style="background:#28c840"></i></span><span>claude — ~/code/app</span></div>
<pre><span class="p">›</span> Run the billing migration. Keep my Mac awake until it's done, I'm closing the lid.

<span class="ok">⏺</span> Bash(midnightoil run --lid-closed -- npm run migrate)
  <span class="c">⎿</span> Keeping your Mac awake: While “npm” runs
     Stays awake with the lid closed
     Migrating 1,284 invoices… <span class="c">(running)</span>

<span class="ok">⏺</span> Running. Your Mac stays awake until it's done,
  lid closed or not, then sleeps as usual.</pre>
        </div>"""

# Plain words you can say, and the command your agent runs for them.
ASKS = [
    ("Keep my Mac awake until 7am.", "midnightoil start --until 7am"),
    ("Run the tests and keep the Mac awake till they're done. I'm closing the lid.", "midnightoil run --lid-closed -- npm test"),
    ("Stay awake for two hours, but let the screen go dark.", "midnightoil start --for 2h --allow-display-sleep"),
    ("Is anything keeping my Mac awake?", "midnightoil status"),
    ("OK, let it sleep.", "midnightoil stop"),
]

AGENT_LINE = "For commands that take more than a few minutes, run them through `midnightoil run -- <command>` so the Mac stays awake until they finish."

CLI = {
    "path": "/cli",
    "title": "Tell your AI agent to keep your Mac awake · Midnight Oil",
    "description": "Ask Claude Code, Codex, or Cursor to keep your Mac awake in plain words. It runs the free midnightoil command: until a job ends, until 7am, or lid closed.",
    "eyebrow": "For AI agents",
    "h1": "Just tell your agent<br>to keep your Mac awake.",
    "lede": "Midnight Oil comes with a <code>midnightoil</code> command, so Claude Code, Codex, and Cursor can run it for you. Say what you want in plain words. Your agent turns it into a command, and your Mac stays awake for exactly as long as the work takes, even with the lid closed.",
    "faqs": [
        ("Can I ask Claude Code to keep my Mac awake?", "Yes. With Midnight Oil installed, ask in plain words, like “keep my Mac awake until the migration is done, I'm closing the lid.” Claude Code runs the midnightoil command, and the Mac stays awake until the job finishes, lid closed included."),
        ("Do I have to teach my agent the commands?", "No. Agents read midnightoil --help like any other command. To make it automatic, add one line to CLAUDE.md or AGENTS.md telling them to run long commands through midnightoil run."),
        ("Which agents work with it?", "Any agent that can run terminal commands: Claude Code, Codex, Cursor, Gemini CLI, and the rest. You can also use the command yourself or in scripts."),
        ("How is midnightoil different from caffeinate?", "Both hold the same macOS power assertion. midnightoil adds closed-lid mode, your battery safety settings, clock times like --until 6am, a countdown in the menu bar, and one shared session for agents running in parallel."),
        ("What happens if two agents keep the Mac awake at once?", "They share one session, which lasts until the last command finishes. One agent finishing never lets the Mac sleep under the other."),
        ("How do I get the midnightoil command?", "Install Midnight Oil with Homebrew (brew install --cask coreyhaines31/tap/midnightoil) and it's on your PATH. If you installed the app from the DMG, link it once with sudo ln -sf \"/Applications/Midnight Oil.app/Contents/MacOS/midnightoil\" /usr/local/bin/midnightoil."),
    ],
}

COMMANDS = [
    ("midnightoil run -- &lt;command&gt;", "Runs the command and keeps the Mac awake until it finishes. Exits with the command's own status, and prints its messages to stderr so the command's output still pipes cleanly."),
    ("midnightoil start", "Keeps the Mac awake until you stop it. Add <code>--for 90m</code>, <code>--until 6:30pm</code>, or <code>--while-pid 4242</code> to end it on its own."),
    ("midnightoil status", "Says whether the Mac is being kept awake, by what, and until when. Add <code>--json</code> for scripts."),
    ("midnightoil stop", "Ends the current session, the same as End Session in the menu."),
]

OPTIONS = [
    ("--lid-closed", "Keep running with the lid shut. Needs the one-time helper approval in Settings › Closed Lid."),
    ("--allow-display-sleep", "Let the screen turn off while the Mac keeps working. Best for overnight runs."),
    ("--json", "Print the session as JSON."),
]

COMPARE = [
    ("Your agent can run it", "Yes", "Yes"),
    ("Keeps working with the lid closed", "Yes, and sleep comes back on its own", "No"),
    ("Ends on low battery or unplug", "Yes, using your settings", "No"),
    ("Clock times", "<code>--until 6am</code>", "Seconds only, with <code>-t</code>"),
    ("Agents running in parallel", "One shared session until the last finishes", "One assertion per process"),
    ("Shows it's running", "Flame and countdown in the menu bar", "Nothing; check <code>pmset -g assertions</code>"),
    ("Also a menu bar app", "Yes, with schedules and triggers", "No"),
    ("Install", "Comes with Midnight Oil", "Built in"),
]
