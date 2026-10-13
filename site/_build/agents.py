"""Per-agent pages: keeping the Mac awake while a specific AI agent works.

Rendered to /agents/<slug> by render.py, with /cli as the hub. Each page carries facts
specific to that agent: how it runs unattended, where its instructions file lives, and
whether a cloud version makes the question moot. Checked against each agent's own docs,
October 2026.
"""

UPDATED = "2026-10-13"

AGENTS = [
    # ------------------------------------------------------------------ Claude Code
    {
        "slug": "claude-code",
        "name": "Claude Code",
        "maker": "Anthropic",
        "blurb": "Terminal agent. Wrap the session, or add a line to CLAUDE.md.",
        "description": "Claude Code stops when your Mac sleeps. Keep it awake for the whole session, lid closed included, by asking Claude or with one line in CLAUDE.md.",
        "lede": "Claude Code runs on your Mac, so when the Mac sleeps, Claude stops mid-task. Midnight Oil keeps the Mac awake for exactly as long as Claude is working, even with the lid closed, then lets it sleep.",
        "tldr": "Start Claude through Midnight Oil with <code>midnightoil run --lid-closed -- claude</code> and the Mac stays awake until you quit the session. Or just tell Claude “keep my Mac awake until you're done,” or add one line to <code>CLAUDE.md</code> so it does that for every long job.",
        "glance": [
            ("Runs where", "In your terminal, on your Mac"),
            ("Interactive", "<code>claude</code>"),
            ("Unattended", "<code>claude -p \"…\"</code> prints the result and exits"),
            ("Instructions file", "<code>CLAUDE.md</code> in the repo, or <code>~/.claude/CLAUDE.md</code> for every project"),
            ("Needs your Mac awake?", "Yes. Claude Code on the web runs in Anthropic's cloud and doesn't."),
        ],
        "launch": "midnightoil run --lid-closed -- claude",
        "headless": 'midnightoil run --lid-closed -- claude -p "fix the failing tests and commit"',
        "file": "CLAUDE.md",
        "asks": [
            ("Keep my Mac awake until you're finished. I'm closing the lid.", "midnightoil start --lid-closed"),
            ("Run the full test suite and keep the Mac awake till it's done.", "midnightoil run -- npm test"),
            ("Stay awake until 7am, then let it sleep.", "midnightoil start --until 7am"),
        ],
        "sleep_html": """
        <p>A sleeping Mac freezes every process, Claude Code included. The request Claude was streaming from Anthropic's API is cut off, the shell commands it started stop where they were, and nothing moves until you open the lid. You come back to the step it was on at midnight, not a finished task.</p>
        <p>Claude Code doesn't hold the Mac awake on its own. It's a terminal program; macOS sees an idle machine and sleeps on its usual schedule, or the moment the lid closes.</p>
        """,
        "unattended_html": """
        <p>For long jobs, <code>claude -p</code> runs a single prompt and exits, which makes it easy to wrap: the session lasts exactly as long as Claude does, and <code>midnightoil</code> exits with Claude's exit code, so scripts can tell whether it worked.</p>
        <p>For an interactive session you'll walk away from, start <code>claude</code> through <code>midnightoil run</code>. The terminal works as usual; when you quit Claude, the Mac goes back to sleeping normally.</p>
        """,
        "faqs": [
            ("Does Claude Code keep running when my Mac sleeps?", "No. Sleep pauses every process, so Claude stops mid-request and picks nothing back up until you wake the Mac. Keep the Mac awake for the session with midnightoil run -- claude, or ask Claude to run midnightoil start."),
            ("Can I close my MacBook while Claude Code works?", "Yes, with Midnight Oil's closed-lid mode: run midnightoil run --lid-closed -- claude. Closed-lid mode needs a one-time approval in Settings › Closed Lid, and sessions can end on their own below a battery level you choose."),
            ("What do I put in CLAUDE.md?", "One line: For commands that take more than a few minutes, run them through `midnightoil run -- <command>` so the Mac stays awake until they finish. Put it in ~/.claude/CLAUDE.md to cover every project."),
            ("Do I need this for Claude Code on the web?", "No. Claude Code on the web runs in Anthropic's cloud, so your Mac can sleep. You only need it when Claude Code runs on your own Mac."),
        ],
    },
    # ------------------------------------------------------------------ Codex
    {
        "slug": "codex",
        "name": "Codex CLI",
        "maker": "OpenAI",
        "blurb": "Terminal agent. Wrap codex exec, or add a line to AGENTS.md.",
        "description": "Codex CLI stops when your Mac sleeps. Keep the Mac awake for a codex exec run or a whole session, lid closed included, with one line in AGENTS.md.",
        "lede": "OpenAI's Codex CLI runs on your Mac, so it stops when the Mac sleeps. Midnight Oil keeps the Mac awake while Codex works, lid open or closed, and lets it sleep the moment Codex is done.",
        "tldr": "Wrap the run: <code>midnightoil run --lid-closed -- codex exec \"…\"</code>. For an interactive session, <code>midnightoil run -- codex</code>. Or add one line to <code>AGENTS.md</code> and Codex keeps the Mac awake for every long command on its own.",
        "glance": [
            ("Runs where", "In your terminal, on your Mac"),
            ("Interactive", "<code>codex</code>"),
            ("Unattended", "<code>codex exec \"…\"</code> runs one task and exits"),
            ("Instructions file", "<code>AGENTS.md</code> in the repo, or <code>~/.codex/AGENTS.md</code> for every project"),
            ("Needs your Mac awake?", "Yes for the CLI and IDE extension. Codex cloud tasks run on OpenAI's servers and don't."),
        ],
        "launch": "midnightoil run --lid-closed -- codex",
        "headless": 'midnightoil run --lid-closed -- codex exec "migrate the API client to v2"',
        "file": "AGENTS.md",
        "asks": [
            ("Keep the Mac awake while you work through this. I'm heading to bed.", "midnightoil start --allow-display-sleep"),
            ("Build the release and keep my Mac awake until it finishes.", "midnightoil run -- make release"),
            ("I'm closing the lid. Keep going.", "midnightoil start --lid-closed"),
        ],
        "sleep_html": """
        <p>When the Mac sleeps, Codex freezes with it: the model request in flight drops, the command it was running stops, and the task waits for you to come back. <code>codex exec</code> in a script or cron job is hit hardest, because nobody is watching when it stalls.</p>
        <p>Codex doesn't ask macOS to stay awake. Idle sleep and a closed lid stop it like any other terminal program.</p>
        """,
        "unattended_html": """
        <p><code>codex exec</code> runs one task without the interactive UI, which is the cleanest thing to wrap: Midnight Oil holds the Mac awake from the first token to the last, exits with Codex's exit code, and prints its own messages on stderr, so Codex's output still pipes cleanly.</p>
        <p>Several Codex runs at once share one session that lasts until the last one finishes, so one agent finishing never lets the Mac sleep under another.</p>
        """,
        "faqs": [
            ("Does Codex keep working when my Mac sleeps?", "Not the CLI or the IDE extension: sleep pauses them mid-task. Codex cloud tasks keep going because they run on OpenAI's servers. For local runs, wrap them with midnightoil run -- codex exec \"…\"."),
            ("What goes in AGENTS.md?", "One line: For commands that take more than a few minutes, run them through `midnightoil run -- <command>` so the Mac stays awake until they finish. ~/.codex/AGENTS.md applies it to every project."),
            ("Can I run several Codex jobs overnight?", "Yes. Parallel midnightoil run sessions join one session that lasts until the last job finishes."),
            ("Will it drain my battery?", "Only as long as Codex runs, and you can set sessions to end when you unplug or when the battery drops below a level you pick."),
        ],
    },
    # ------------------------------------------------------------------ Cursor
    {
        "slug": "cursor",
        "name": "Cursor",
        "maker": "Anysphere",
        "blurb": "Editor agent and CLI. A trigger, a rule, or agent -p.",
        "description": "Cursor's agent stops when your Mac sleeps. Keep the Mac awake while Cursor is open or for one agent run, lid closed included, with a trigger or a rule.",
        "lede": "Cursor's agent works inside the editor on your Mac, so it stops when the Mac sleeps. Midnight Oil can stay awake whenever Cursor is open, or just for one long agent run, even with the lid closed.",
        "tldr": "Easiest: add an App Running trigger for Cursor in Midnight Oil's settings, and the Mac stays awake whenever Cursor is open. For a single run, tell the agent “keep my Mac awake until you're done,” or use the CLI: <code>midnightoil run -- agent -p \"…\"</code>.",
        "glance": [
            ("Runs where", "In the Cursor editor, or the Cursor CLI in your terminal"),
            ("Interactive", "The Agent panel in the editor, or <code>agent</code> in a terminal"),
            ("Unattended", "<code>agent -p \"…\"</code> (print mode) runs one prompt and exits"),
            ("Instructions file", "<code>.cursor/rules/</code>; the CLI also reads <code>AGENTS.md</code> and <code>CLAUDE.md</code>"),
            ("Needs your Mac awake?", "Yes for the editor and CLI. Cursor's background agents run in the cloud and don't."),
        ],
        "launch": "midnightoil run -- agent",
        "headless": 'midnightoil run --lid-closed -- agent -p --force "upgrade the project to React 19"',
        "file": "AGENTS.md or a Cursor rule",
        "asks": [
            ("Keep my Mac awake while you finish this refactor.", "midnightoil start"),
            ("Run the e2e tests and keep the Mac awake until they're done.", "midnightoil run -- npx playwright test"),
            ("Keep it awake for two hours, screen off.", "midnightoil start --for 2h --allow-display-sleep"),
        ],
        "sleep_html": """
        <p>Cursor's agent lives in the editor, and the editor sleeps with the Mac. The agent's model request is cut off, the terminal command it started freezes, and the chat sits at the step it was on until you wake the Mac.</p>
        <p>An open editor doesn't hold the Mac awake. macOS goes to sleep on its idle timer, and always when the lid closes.</p>
        """,
        "unattended_html": """
        <p><strong>In the editor:</strong> open Midnight Oil's Settings › Triggers › Add Trigger › App Running › Cursor. The Mac stays awake whenever Cursor is open and sleeps normally once you quit it. Turn on “Stay awake with the lid closed” in the trigger to cover a closed laptop.</p>
        <p><strong>From the CLI:</strong> <code>agent -p</code> runs one prompt and exits (add <code>--force</code> to let it change files without asking). Wrap it in <code>midnightoil run</code> and the session ends with the run.</p>
        """,
        "faqs": [
            ("Does Cursor's agent keep running when my Mac sleeps?", "No. The editor and the agent pause with the Mac. Cursor's background agents run in the cloud and are unaffected; everything in the editor and the Cursor CLI needs the Mac awake."),
            ("How do I keep my Mac awake whenever Cursor is open?", "Add an App Running trigger for Cursor in Midnight Oil's Settings › Triggers. The Mac stays awake while Cursor runs and sleeps normally after you quit it."),
            ("Where does the instruction go?", "In a rule under .cursor/rules, or in AGENTS.md at the project root, which Cursor's CLI also reads. The line: For commands that take more than a few minutes, run them through `midnightoil run -- <command>` so the Mac stays awake until they finish."),
        ],
    },
    # ------------------------------------------------------------------ Gemini CLI
    {
        "slug": "gemini-cli",
        "name": "Gemini CLI",
        "maker": "Google",
        "blurb": "Terminal agent. Wrap gemini -p, or add a line to GEMINI.md.",
        "description": "Gemini CLI stops when your Mac sleeps. Keep the Mac awake for a gemini -p run or a full session, lid closed included, with one line in GEMINI.md.",
        "lede": "Google's Gemini CLI runs in your terminal, so the Mac sleeping stops it cold. Midnight Oil keeps the Mac awake for as long as Gemini works, lid closed if you like, then gets out of the way.",
        "tldr": "Run <code>midnightoil run --lid-closed -- gemini</code> for a session you'll walk away from, or wrap a single prompt: <code>midnightoil run -- gemini -p \"…\"</code>. Add one line to <code>GEMINI.md</code> and Gemini keeps the Mac awake for long commands without being asked.",
        "glance": [
            ("Runs where", "In your terminal, on your Mac"),
            ("Interactive", "<code>gemini</code>"),
            ("Unattended", "<code>gemini -p \"…\"</code> runs one prompt and exits"),
            ("Instructions file", "<code>GEMINI.md</code> in the repo, or <code>~/.gemini/GEMINI.md</code> for every project"),
            ("Needs your Mac awake?", "Yes"),
        ],
        "launch": "midnightoil run --lid-closed -- gemini",
        "headless": 'midnightoil run --lid-closed -- gemini -p "write tests for every module in src/"',
        "file": "GEMINI.md",
        "asks": [
            ("Keep my Mac awake until you've finished. Closing the lid now.", "midnightoil start --lid-closed"),
            ("Run the benchmarks and keep the Mac awake for them.", "midnightoil run -- npm run bench"),
            ("Is anything keeping my Mac awake?", "midnightoil status"),
        ],
        "sleep_html": """
        <p>Gemini CLI is an ordinary process to macOS. When the Mac sleeps it freezes, the request to Gemini drops, and any shell command it started pauses until you wake the Mac again.</p>
        <p>It doesn't hold the Mac awake by itself, so idle sleep and a closed lid both stop it.</p>
        """,
        "unattended_html": """
        <p><code>gemini -p</code> runs a single prompt non-interactively, so the session lasts exactly as long as the run. Pair it with <code>--yolo</code> only in a repo where you're happy for Gemini to run commands without asking.</p>
        <p><code>midnightoil run</code> exits with Gemini's exit code and reports on stderr, so it drops into scripts and cron jobs without changing their output.</p>
        """,
        "faqs": [
            ("Does Gemini CLI keep running while my Mac sleeps?", "No. Sleep pauses it mid-task. Wrap the run with midnightoil run -- gemini, or ask Gemini to keep the Mac awake and it runs midnightoil start for you."),
            ("What should I add to GEMINI.md?", "One line: For commands that take more than a few minutes, run them through `midnightoil run -- <command>` so the Mac stays awake until they finish. ~/.gemini/GEMINI.md covers every project."),
            ("Can I close the lid?", "Yes, with --lid-closed after the one-time approval in Midnight Oil's Settings › Closed Lid. Sleep comes back on its own when the session ends."),
        ],
    },
    # ------------------------------------------------------------------ Aider
    {
        "slug": "aider",
        "name": "Aider",
        "maker": "open source",
        "blurb": "Terminal pair programmer. Wrap the session or a --message run.",
        "description": "Aider stops when your Mac sleeps. Keep the Mac awake for an Aider session or a scripted --message run, lid closed included, with the midnightoil command.",
        "lede": "Aider pair-programs from your terminal, so a sleeping Mac stops it mid-edit. Midnight Oil keeps the Mac awake for exactly as long as Aider runs, including scripted runs with the lid closed.",
        "tldr": "Start Aider through Midnight Oil: <code>midnightoil run -- aider</code>. For scripts, wrap a one-shot run: <code>midnightoil run --lid-closed -- aider --message \"…\" --yes-always</code>.",
        "glance": [
            ("Runs where", "In your terminal, on your Mac"),
            ("Interactive", "<code>aider</code>"),
            ("Unattended", "<code>aider --message \"…\"</code> applies one request and exits"),
            ("Instructions file", "A conventions file loaded with <code>--read CONVENTIONS.md</code>, or <code>read:</code> in <code>.aider.conf.yml</code>"),
            ("Needs your Mac awake?", "Yes. With a local model, the model server does too."),
        ],
        "launch": "midnightoil run -- aider",
        "headless": 'midnightoil run --lid-closed -- aider --message "add type hints to utils.py" --yes-always utils.py',
        "file": "CONVENTIONS.md",
        "asks": [],
        "sleep_html": """
        <p>Aider waits on the model and edits files as replies stream in. If the Mac sleeps mid-reply, the stream is cut and the edit stops where it was; you come back to a half-finished change and a failed request.</p>
        <p>Aider doesn't keep the Mac awake itself, and long multi-file requests are exactly the ones that outlast the idle timer.</p>
        """,
        "unattended_html": """
        <p>Aider mostly edits rather than running long commands itself, so the instruction-file trick matters less here than wrapping the whole run. <code>aider --message</code> applies one request and exits; <code>--yes-always</code> accepts its prompts. Loop over files in a script, wrap the script with <code>midnightoil run</code>, and the Mac stays awake until the last one is done.</p>
        <p>Running Aider against a local model? The model server has to stay awake as well, which this covers too: see <a href="/agents/ollama">Ollama</a>.</p>
        """,
        "faqs": [
            ("Does Aider keep running when the Mac sleeps?", "No. The model request drops and the edit stops partway. Start Aider with midnightoil run -- aider so the Mac stays awake for the session."),
            ("How do I run Aider unattended overnight?", "Script it with aider --message \"…\" --yes-always, and wrap the script: midnightoil run --lid-closed -- ./refactor.sh. The Mac sleeps normally once the script ends."),
            ("Can I tell Aider to keep the Mac awake?", "Aider is a pair programmer more than a command runner, so it's more reliable to start it through midnightoil run than to ask it mid-chat."),
        ],
    },
    # ------------------------------------------------------------------ GitHub Copilot
    {
        "slug": "copilot",
        "name": "GitHub Copilot",
        "maker": "GitHub",
        "blurb": "VS Code agent mode and Copilot CLI. A trigger or an instruction.",
        "description": "Copilot's agent mode and Copilot CLI stop when your Mac sleeps. Keep the Mac awake while VS Code is open or for one copilot -p run, lid closed included.",
        "lede": "Copilot's agent mode works inside VS Code, and Copilot CLI in your terminal. Both run on your Mac and stop when it sleeps. Midnight Oil keeps the Mac awake while they work, even with the lid closed.",
        "tldr": "In VS Code, add an App Running trigger for Visual Studio Code in Midnight Oil. With Copilot CLI, wrap the run: <code>midnightoil run -- copilot -p \"…\"</code>. Or add one line to <code>.github/copilot-instructions.md</code>.",
        "glance": [
            ("Runs where", "VS Code agent mode, or Copilot CLI in your terminal"),
            ("Interactive", "The Chat view in agent mode, or <code>copilot</code>"),
            ("Unattended", "<code>copilot -p \"…\"</code> runs one prompt and exits"),
            ("Instructions file", "<code>.github/copilot-instructions.md</code> or <code>AGENTS.md</code>; <code>~/.copilot/copilot-instructions.md</code> for the CLI everywhere"),
            ("Needs your Mac awake?", "Yes for agent mode and the CLI. Copilot's coding agent on GitHub runs in the cloud and doesn't."),
        ],
        "launch": "midnightoil run -- copilot",
        "headless": 'midnightoil run --lid-closed -- copilot -p "fix the flaky checkout test"',
        "file": ".github/copilot-instructions.md",
        "asks": [
            ("Keep my Mac awake until you're done with this.", "midnightoil start"),
            ("Run the build and keep the Mac awake for it.", "midnightoil run -- npm run build"),
            ("Let my Mac sleep now.", "midnightoil stop"),
        ],
        "sleep_html": """
        <p>Agent mode runs in VS Code, and Copilot CLI in your terminal. When the Mac sleeps, both freeze: the model request is cut off, terminal commands pause, and the task waits for you.</p>
        <p>An open VS Code window doesn't stop macOS from sleeping, and nothing does once the lid closes.</p>
        """,
        "unattended_html": """
        <p><strong>In VS Code:</strong> Midnight Oil's Settings › Triggers › Add Trigger › App Running › Visual Studio Code keeps the Mac awake whenever VS Code is open. Agent mode can also run <code>midnightoil</code> in its terminal when you ask.</p>
        <p><strong>Copilot CLI:</strong> <code>copilot -p</code> runs one prompt without the interactive UI. Wrap it in <code>midnightoil run</code> and the Mac stays awake until it exits, with Copilot's exit code passed through.</p>
        <p><strong>The coding agent on GitHub</strong>, the one you assign issues to, runs in GitHub Actions, so it doesn't need your Mac at all.</p>
        """,
        "faqs": [
            ("Does Copilot agent mode keep working while my Mac sleeps?", "No. VS Code and the agent pause with the Mac. Copilot's coding agent on GitHub is different: it runs in the cloud."),
            ("Where does the instruction go?", "In .github/copilot-instructions.md or AGENTS.md at the repo root. The line: For commands that take more than a few minutes, run them through `midnightoil run -- <command>` so the Mac stays awake until they finish."),
            ("Can I keep the Mac awake only while VS Code is open?", "Yes. Add an App Running trigger for Visual Studio Code in Midnight Oil's Settings › Triggers."),
        ],
    },
    # ------------------------------------------------------------------ Cline
    {
        "slug": "cline",
        "name": "Cline",
        "maker": "open source",
        "blurb": "VS Code extension. A trigger for VS Code, or a .clinerules line.",
        "description": "Cline stops when your Mac sleeps. Keep the Mac awake while VS Code is open or until Cline finishes a task, lid closed included, with a trigger or .clinerules.",
        "lede": "Cline runs inside VS Code on your Mac, so its long tasks stop when the Mac sleeps. Midnight Oil keeps the Mac awake while Cline works, and lets it sleep once the task is done.",
        "tldr": "Add an App Running trigger for Visual Studio Code in Midnight Oil, so the Mac stays awake whenever the editor is open. Or ask Cline “keep my Mac awake until you're done,” or put one line in <code>.clinerules</code>.",
        "glance": [
            ("Runs where", "Inside VS Code, on your Mac"),
            ("Interactive", "The Cline panel in VS Code"),
            ("Unattended", "Auto-approve settings let it run commands without asking"),
            ("Instructions file", "<code>.clinerules</code> at the project root, a file or a folder of rules"),
            ("Needs your Mac awake?", "Yes, and so does a local model server if you use one"),
        ],
        "launch": None,
        "headless": None,
        "file": ".clinerules",
        "asks": [
            ("Keep my Mac awake until this task is finished.", "midnightoil start"),
            ("Run the migrations and keep the Mac awake for them.", "midnightoil run -- npm run migrate"),
            ("Keep it awake till 6am, lid closed.", "midnightoil start --until 6am --lid-closed"),
        ],
        "sleep_html": """
        <p>Cline lives in VS Code, which sleeps with the Mac. Its request to the model drops, the command it ran in the terminal freezes, and the task waits at that step until you wake the Mac.</p>
        <p>With auto-approve turned on, Cline can work for a long time without you, which is when the idle timer and a closed lid catch it.</p>
        """,
        "unattended_html": """
        <p>Cline runs commands through VS Code's terminal, so it can run <code>midnightoil</code> like anything else. Ask it, or add the line to <code>.clinerules</code> and it wraps its own long commands.</p>
        <p>To cover the whole task, not just one command, use a trigger: Midnight Oil's Settings › Triggers › Add Trigger › App Running › Visual Studio Code. Turn on closed-lid mode in the trigger if the laptop will be shut.</p>
        """,
        "faqs": [
            ("Does Cline keep working while my Mac sleeps?", "No. VS Code and Cline pause with the Mac, so a long auto-approved task stops at the step it was on."),
            ("What goes in .clinerules?", "One line: For commands that take more than a few minutes, run them through `midnightoil run -- <command>` so the Mac stays awake until they finish."),
            ("Can I use Cline with the lid closed?", "Yes, with Midnight Oil's closed-lid mode, approved once in Settings › Closed Lid. Sessions can end on their own when you unplug or the battery gets low."),
        ],
    },
    # ------------------------------------------------------------------ Ollama
    {
        "slug": "ollama",
        "name": "Ollama",
        "maker": "open source",
        "blurb": "Local model server. Keep it serving while your agents call it.",
        "description": "Ollama stops serving when your Mac sleeps, and agents using it fail. Keep the Mac awake while Ollama runs or for a big model pull, lid closed included.",
        "lede": "Ollama serves models from your own Mac, so when the Mac sleeps, every agent and app calling it gets an error. Midnight Oil keeps the Mac awake while Ollama is running, or just for a long download.",
        "tldr": "Add an App Running trigger for Ollama in Midnight Oil and the Mac stays awake whenever Ollama is running. Running the server by hand? <code>midnightoil run -- ollama serve</code>. Pulling a big model? <code>midnightoil run -- ollama pull &lt;model&gt;</code>.",
        "glance": [
            ("Runs where", "On your Mac, as the Ollama app or <code>ollama serve</code>"),
            ("Serves", "A local API on port 11434 that agents and apps call"),
            ("Long jobs", "Model downloads, batch generation, agents using a local model"),
            ("Instructions file", "None; the agents that call it have their own"),
            ("Needs your Mac awake?", "Yes, for as long as anything is calling it"),
        ],
        "launch": "midnightoil run -- ollama serve",
        "headless": "midnightoil run -- ollama pull llama3.3",
        "file": None,
        "asks": [],
        "sleep_html": """
        <p>When the Mac sleeps, the Ollama server freezes. Requests in progress fail, and agents calling it, like Aider or Cline pointed at a local model, see connection errors and stop. A model download pauses partway too.</p>
        <p><code>OLLAMA_KEEP_ALIVE</code> doesn't help here: it controls how long a model stays loaded in memory, not whether the Mac stays awake.</p>
        """,
        "unattended_html": """
        <p><strong>Using the Ollama app:</strong> Midnight Oil's Settings › Triggers › Add Trigger › App Running › Ollama keeps the Mac awake whenever Ollama is running and lets it sleep once you quit it.</p>
        <p><strong>Running the server yourself:</strong> <code>midnightoil run -- ollama serve</code> keeps the Mac awake for exactly as long as the server runs.</p>
        <p><strong>Big downloads:</strong> wrap <code>ollama pull</code> and the session ends the moment the model is on disk. Turn on <code>--allow-display-sleep</code> so the screen goes dark while the Mac keeps working.</p>
        """,
        "faqs": [
            ("Does Ollama keep running when my Mac sleeps?", "No. The server pauses with the Mac, so requests fail and agents using a local model stop. Keep the Mac awake while Ollama runs with an App Running trigger in Midnight Oil."),
            ("Does OLLAMA_KEEP_ALIVE keep my Mac awake?", "No. It sets how long Ollama keeps a model loaded in memory after a request. It has no effect on Mac sleep."),
            ("Can I use my Mac as an always-on Ollama server?", "Yes, for as long as you want. Run midnightoil run -- ollama serve, or a trigger for the Ollama app, and set sessions to end on battery if it's a laptop."),
        ],
    },
]
