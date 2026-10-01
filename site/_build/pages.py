# Content for the alternative pages. Every factual claim here traces to
# competitor-profiles/*.md (researched 2026-09-30). Keep it honest.

PAGES = [
    # ------------------------------------------------------------------ Amphetamine
    {
        "slug": "amphetamine",
        "competitor": "Amphetamine",
        "title": "Amphetamine for Mac: what happened, and the alternative",
        "description": "Amphetamine, the Mac keep-awake app, hasn't shipped an update since November 2023. Midnight Oil is the free, source-available replacement: same sessions and triggers, one-toggle closed-lid mode, and built for overnight AI-agent runs.",
        "eyebrow": "Amphetamine alternative",
        "h1": "Amphetamine's last update was 2023.<br>Your agents run in 2026.",
        "lede": "Amphetamine was the best keep-awake app on the Mac, and it's still free. It's also been frozen at version 5.3.2 since November 10, 2023, with issues piling up unanswered. Midnight Oil is the maintained, source-available replacement built for the way people keep Macs awake now: overnight agent runs, long builds, the laptop closed in a bag.",
        "tldr": "Amphetamine still works and has more trigger types than anything else, but it's unmaintained, closed source, and its closed-lid mode is a three-part install. Midnight Oil does the same core job with a one-checkbox closed-lid mode, installs from Homebrew, and ships updates.",
        "card_title": "Amphetamine",
        "card_blurb": "Last update 2023. Closed-lid mode takes a script, a sudoers file, and a Terminal command.",
        "cta": "Switch in about a minute.",
        "faqs": [
            ("Is Amphetamine still being updated?", "No. The current Mac App Store version is 5.3.2, released November 10, 2023. Its GitHub issue tracker shows no maintainer replies since December 2023, with reports of it not working on newer Macs and macOS releases."),
            ("Is Midnight Oil free like Amphetamine?", "Yes. Midnight Oil is free to use, at home or at work, with the full source on GitHub. No account and no telemetry."),
            ("Does Midnight Oil have Amphetamine's closed-display mode?", "Yes. It's a checkbox called Stay Awake with Lid Closed. A small helper you approve once in System Settings handles it, and it restores normal sleep when the session ends, when the app quits, or if the app crashes. No script download, no sudoers file."),
            ("Can I install Midnight Oil with Homebrew?", "Yes: brew install --cask coreyhaines31/tap/midnightoil. Or download the notarized DMG from GitHub Releases."),
        ],
        "sections": [
            {"id": "why", "html": """
        <h2>Why people are leaving Amphetamine</h2>
        <p>Amphetamine earned its reputation. It's free with no catch, it has a 4.8-star rating from more than 3,000 reviews, and for years it shipped updates faster than most paid apps. The problem is what happened after November 2023.</p>
        <h3>It stopped shipping</h3>
        <p>The App Store lists <strong>version 5.3.2, released November 10, 2023</strong>, as current. On the project's GitHub issue tracker, 19 of the 20 open issues have no reply from the developer, going back to December 2023. Those issues include <em>“Amphetamine no effect on macOS 15.3.x”</em> on an M4 Max, a recurring Location Services prompt on launch, an expired certificate, and Drive Alive silently stopping after a few days.</p>
        <h3>Closed-lid mode is a project</h3>
        <p>Because Amphetamine lives in the sandboxed App Store, keeping a MacBook awake with the lid shut takes three extra pieces: the separate <strong>Power Protect</strong> script from GitHub, a <strong>sudoers</strong> file so it can run <code>pmset disablesleep</code> without a password, and a <code>defaults write</code> command in Terminal. Even then, a 2026 issue reports closed-display mode <em>“silently dropped for timed sessions when no external display is attached,”</em> and another reports a black screen on wake from deep sleep on macOS Tahoe.</p>
        <h3>App Store only</h3>
        <p>There's no DMG and no Homebrew cask. Users have been asking for both since 2024. If you manage Macs with a script, or your work Mac blocks the App Store, you're stuck.</p>
        <h3>The name</h3>
        <p>Apple tried to remove it over the name in 2021 and backed down. Some managed and corporate environments never did.</p>
            """},
            {"id": "compare", "gray": True, "html": """
        <h2>Midnight Oil vs Amphetamine</h2>
        <p>Where it matters, side by side. Amphetamine facts are from the App Store listing and the project's GitHub as of September 2026.</p>
        {{TABLE}}
        <h3>What Amphetamine still does better</h3>
        <p>Breadth. Amphetamine has around fifteen trigger types, including Cisco AnyConnect VPN, DNS server, audio output in use, mounted drives, and CPU load, plus AppleScript support and a periodic cursor-mover. If your workflow depends on one of those, Amphetamine is still the only app that has it, and it's still free.</p>
        <h3>What Midnight Oil does better</h3>
        <p>It's maintained, its source is on GitHub, and the closed-lid feature is a checkbox rather than an installation guide. It installs from Homebrew or a notarized DMG. And it was built around the job most people have now: an AI agent, a build, or a render that needs the Mac to stay up while you're somewhere else.</p>
            """, "table": [
                ("Price", "Free", "Free"),
                ("Source code public", "Yes (FSL, MIT after 2 years)", "No"),
                ("Last release", "October 2026", "November 10, 2023"),
                ("Install", "Homebrew cask or DMG", "Mac App Store only"),
                ("Sessions: minutes, hours, until a time, while an app runs, while a download finishes", "Yes", "Yes"),
                ("Closed-lid mode", "One checkbox; helper approved once", "Separate script + sudoers file + Terminal command"),
                ("Sleep restored if the app crashes", "Yes, within a second", "Not with Power Protect (manual reset)"),
                ("Triggers", "Wi-Fi, USB, Bluetooth, display, power, battery, app, IP, schedule, idle", "Those plus VPN, DNS, audio, drives, CPU"),
                ("Weekly schedules, like work hours", "Own tab, optional conditions, skip a day from the menu", "Via a schedule trigger"),
                ("AppleScript", "No", "Yes"),
                ("Battery floor and unplug rules", "Yes", "Yes"),
                ("Lid-close alarm on battery", "Yes", "No"),
                ("Drive Alive", "Yes", "Yes (reports of it stopping)"),
                ("Download size", "3 MB", "6.7 MB"),
                ("Minimum macOS", "14 Sonoma", "10.13 High Sierra"),
            ]},
            {"id": "switch", "html": """
        <h2>Switching takes about a minute</h2>
        <ol class="steps">
          <li><b>Install Midnight Oil.</b> <code>brew install --cask coreyhaines31/tap/midnightoil</code>, or download the DMG and drag it to Applications.</li>
          <li><b>Recreate your triggers.</b> Amphetamine's settings don't export. Most people have one or two: “docked to a display and on power” and “while Terminal is running” take about thirty seconds each in Settings › Triggers. A schedule-only trigger, like work hours, belongs in Settings › Schedules now.</li>
          <li><b>Set up closed-lid mode, if you use it.</b> Check “Stay awake with lid closed” in a session; the first time, Midnight Oil asks to install its helper and macOS asks you to approve it in Login Items. That's it.</li>
          <li><b>Undo Power Protect.</b> If you installed Amphetamine's Power Protect, remove its sudoers entry so nothing else can toggle sleep without a password. The Power Protect README has the uninstall steps.</li>
          <li><b>Quit Amphetamine.</b> Keep it installed if you rely on a trigger Midnight Oil doesn't have. Otherwise, drag it to the Trash.</li>
        </ol>
        <h3>Who should stay on Amphetamine</h3>
        <p>If you're on a Mac older than macOS 14, or you depend on AppleScript control or one of the exotic triggers, stay. It still works for plenty of people. Just know nothing is coming to fix it when it doesn't.</p>
            """},
        ],
    },
    # ------------------------------------------------------------------ Caffeine
    {
        "slug": "caffeine",
        "competitor": "Caffeine",
        "title": "Caffeine for Mac: the original keep-awake app, and a modern alternative",
        "description": "Caffeine is the one-click coffee cup that's kept Macs awake since 2006. It still works, but it has no timers you can see, no triggers, and no closed-lid mode. Midnight Oil is the free, source-available alternative for longer jobs.",
        "eyebrow": "Caffeine alternative",
        "h1": "Caffeine is a cup you click.<br>Midnight Oil is the rest of the night.",
        "lede": "Caffeine is the app that started this category: click the cup, your Mac stays awake. Two decades on it's still free and still tiny, and for a lot of people that's exactly enough. If you need it to run for a set time, react to what's happening, or keep a closed laptop working, you've outgrown it.",
        "tldr": "Keep Caffeine if all you ever do is click the cup. Get Midnight Oil for sessions that end on their own, triggers, closed-lid mode, and battery safety. Both are free, and both publish their source.",
        "card_title": "Caffeine",
        "card_blurb": "The 2006 original. One click, and that's the whole app: no timers, triggers, or lid mode.",
        "cta": "More than a cup.",
        "faqs": [
            ("Is Caffeine for Mac still maintained?", "Yes. IntelliScape Solutions continues the original Lighthead app; version 1.1.4 shipped in September 2025 with native Apple Silicon support and macOS Tahoe compatibility. Note there are at least three projects named Caffeine with the same coffee-cup icon, which causes confusion about which one you have."),
            ("Does Caffeine work with the lid closed?", "No. Caffeine has no closed-lid support. Closing the lid puts the MacBook to sleep. Midnight Oil's Stay Awake with Lid Closed option handles that through a helper you approve once."),
            ("Can Caffeine turn itself on when I open an app or plug in a display?", "No. Caffeine has no triggers. Midnight Oil can start a session when a display is connected, on power, on a Wi-Fi network, while a specific app is running, on a schedule, and more."),
            ("Is Midnight Oil free?", "Yes. Free to use, source on GitHub, no telemetry."),
        ],
        "sections": [
            {"id": "why", "html": """
        <h2>What Caffeine does, and where it stops</h2>
        <p>Caffeine has one control: a coffee cup in the menu bar. Full cup, your Mac won't sleep. Empty cup, it will. Right-click for a handful of preferences: activate at launch, start at login, a default duration. Under a megabyte, free, and after a 2025 handoff to IntelliScape it runs natively on Apple Silicon and macOS Tahoe.</p>
        <p>That simplicity is the product. It's also the ceiling.</p>
        <h3>No visible timer</h3>
        <p>You can set a default duration in preferences, but there's no countdown, no “until 7 AM,” and no way to extend a running session. You click the cup and hope you remember to click it again.</p>
        <h3>No triggers</h3>
        <p>Caffeine can't turn itself on when you plug in a display, join your office Wi-Fi, or launch Terminal, and it can't turn itself off when a build finishes or an app quits. It's manual, always.</p>
        <h3>No closed-lid mode</h3>
        <p>Close the MacBook and it sleeps, cup or no cup. For a download or a render at your desk that's fine. For an agent run you want to carry to the next room, it isn't.</p>
        <h3>Three apps, one name</h3>
        <p>At least three projects call themselves Caffeine for Mac and use the same cup icon: IntelliScape's, a fork at caffeine-app.net, and another on GitHub. Reviews and Homebrew point at different ones. It's not a dealbreaker, but it's confusing when something breaks.</p>
        <h3>The analytics ping</h3>
        <p>A 2023 MacUpdate reviewer asked why the app <em>“pings analytics.intelliscapesolutions.com every 2 minutes.”</em> Midnight Oil makes no network calls except to check for updates, and you can turn that off.</p>
            """},
            {"id": "compare", "gray": True, "html": """
        <h2>Midnight Oil vs Caffeine</h2>
        {{TABLE}}
        <h3>What Caffeine does better</h3>
        <p>It's smaller (under 1 MB), it runs back to macOS 11, and there's nothing to learn. If your whole use case is “don't sleep during this presentation,” Caffeine is the right amount of app.</p>
        <h3>What Midnight Oil does better</h3>
        <p>Everything that happens after the click. Sessions that end at a time or when an app quits, a countdown in the menu bar, triggers that start sessions on their own, closed-lid mode, and battery rules so a laptop never cooks in a bag.</p>
            """, "table": [
                ("Price", "Free", "Free (donations)"),
                ("Source code public", "Yes (FSL, MIT after 2 years)", "Yes, MIT"),
                ("One-click on and off", "Yes", "Yes"),
                ("Timed sessions with a visible countdown", "Yes", "Default duration only, no countdown"),
                ("Keep awake until a time", "Yes", "No"),
                ("While an app is running / while a file downloads", "Yes", "No"),
                ("Triggers (display, power, Wi-Fi, app, …)", "Yes", "No"),
                ("Weekly schedules, like work hours", "Yes", "No"),
                ("Closed-lid mode", "Yes", "No"),
                ("End on low battery or unplug", "Yes", "No"),
                ("Hot keys", "Yes", "No"),
                ("Network activity", "Update check only, can be disabled", "Analytics ping reported by users"),
                ("Download size", "3 MB", "Under 1 MB"),
                ("Minimum macOS", "14 Sonoma", "11.5 Big Sur"),
            ]},
            {"id": "switch", "html": """
        <h2>Switching</h2>
        <ol class="steps">
          <li><b>Install Midnight Oil.</b> <code>brew install --cask coreyhaines31/tap/midnightoil</code>, or the DMG from GitHub.</li>
          <li><b>Click the flame instead of the cup.</b> “Keep Awake Indefinitely” is the same thing Caffeine did. The menu also offers minutes, hours, a clock time, or while an app runs.</li>
          <li><b>Quit Caffeine.</b> Two keep-awake apps at once is harmless but pointless.</li>
        </ol>
        <h3>Who should stay on Caffeine</h3>
        <p>Anyone on macOS 11–13, and anyone who wants the smallest possible app with no options. There's no shame in a cup.</p>
            """},
        ],
    },
    # ------------------------------------------------------------------ caffeinate
    {
        "slug": "caffeinate",
        "competitor": "caffeinate",
        "title": "caffeinate on Mac: the command, its flags, and when you want an app instead",
        "description": "How the built-in macOS caffeinate command works (-d, -i, -s, -u, -t, -w), what it can't do, and why people running Claude Code or long jobs overnight end up wanting a menu bar app with closed-lid mode.",
        "eyebrow": "caffeinate vs an app",
        "h1": "<code>caffeinate</code> keeps your Mac awake until you close the lid.<br>Then it doesn't.",
        "lede": "Every Mac ships with <code>caffeinate</code>, a Terminal command that keeps the machine awake. It's free, it's already installed, and for a one-off job it's fine. This page covers the flags, the gotchas, and the point where a menu bar app is the better tool.",
        "tldr": "<code>caffeinate -i</code> holds your Mac awake until you press Ctrl-C, but not through a closed lid or a closed terminal, and with nothing in the menu bar to show it's running. Midnight Oil uses the same power assertion and adds the parts caffeinate can't: closed-lid mode, a countdown, triggers, and battery safety.",
        "card_title": "caffeinate command",
        "card_blurb": "Built in and free. Stops at a closed lid, and dies with the terminal.",
        "cta": "The same assertion, with a menu bar.",
        "faqs": [
            ("What does caffeinate do on a Mac?", "caffeinate creates a power-management assertion that stops macOS from sleeping. With no flags it prevents idle sleep until you stop it. You can scope it to a command (caffeinate -i make), a duration (caffeinate -t 3600), or a process (caffeinate -w PID)."),
            ("Does caffeinate keep a MacBook awake with the lid closed?", "No. Closing the lid is an explicit sleep request that a power assertion can't override. The workaround, sudo pmset -a disablesleep 1, needs an admin password and must be reverted by hand. Midnight Oil's closed-lid mode does this through a helper that restores sleep automatically."),
            ("How do I keep my Mac awake while Claude Code runs overnight?", "The command-line way is tmux new-session -d 'caffeinate -i claude', which keeps the assertion alive even if the terminal closes. The simpler way is Midnight Oil: start a session while Terminal is running, or until 7 AM, and check Stay Awake with Lid Closed if you're closing the laptop."),
            ("How do I stop caffeinate?", "Press Ctrl-C in the terminal that started it, or run killall caffeinate. Check what's holding your Mac awake with pmset -g assertions."),
        ],
        "sections": [
            {"id": "why", "html": """
        <h2>How caffeinate works</h2>
        <p><code>/usr/bin/caffeinate</code> has shipped with every Mac since 2012. It asks the power manager for an assertion, the same mechanism Xcode, Final Cut, and Midnight Oil use, and holds it until the command exits. The man page hasn't changed since it was written, which tells you how simple it is.</p>
        <h3>The flags</h3>
        <pre><code>caffeinate            # prevent idle sleep until Ctrl-C
caffeinate -d         # also keep the display on
caffeinate -i         # prevent idle system sleep (the default)
caffeinate -s         # prevent system sleep; only works on AC power
caffeinate -u -t 5    # declare the user active for 5 seconds
caffeinate -t 3600    # for one hour
caffeinate -w 12345   # until process 12345 exits
caffeinate -i make    # for as long as this command runs
caffeinate -dimsu     # everything</code></pre>
        <p>Check what's holding the Mac awake with <code>pmset -g assertions</code>. Stop a stray one with <code>killall caffeinate</code>.</p>
        <h2>Where it falls down</h2>
        <h3>A closed lid beats it</h3>
        <p>An assertion holds off <em>idle</em> sleep. Closing the lid isn't idle; it's an explicit request, and as one guide puts it, <em>“no assertion overrides it.”</em> The workaround is <code>sudo pmset -a disablesleep 1</code>, which needs an admin password, applies to the whole machine, and stays on until you remember to turn it off. A MacBook still running in a bag with sleep disabled has nowhere to put its heat.</p>
        <h3>It has no face</h3>
        <p>Nothing in the menu bar tells you caffeinate is running, or for how long. You find out it wasn't when the SSH session is gone in the morning.</p>
        <h3>It dies with the terminal</h3>
        <p>Close the window, quit Terminal, or have it crash, and the assertion goes with it. The community answer is to wrap it in tmux, which works, and is one more thing to remember at 11 PM.</p>
        <h3>Some flags silently do nothing</h3>
        <p><code>-s</code> is a no-op on battery. <code>-t</code> is ignored when you wrap a command. <code>-u</code> expires after five seconds unless you say otherwise. Each of these has a Stack Exchange thread from someone who thought it worked.</p>
        <h3>No triggers, no schedule</h3>
        <p>It can't start when you dock, stop when the battery gets low, say “until 7 AM and then let it sleep,” or hold your Mac awake every weekday from 9 to 5. You'd script all of that yourself, cron included.</p>
        <h2>The overnight agent problem, specifically</h2>
        <p>People running Claude Code, Codex, and Cursor agents overnight have converged on the same recipe: <code>tmux new-session -d -s agent 'caffeinate -i claude'</code>, sometimes wired into Claude Code's hooks so it starts automatically. It works, as long as the lid stays open and you never need to see whether it's still running. There are half a dozen wrapper projects on GitHub whose only job is to make caffeinate less annoying.</p>
        <p>Midnight Oil is what that recipe wants to be. Start a session <strong>while Terminal is running</strong> and it ends when the agent's app quits. Or <strong>until 7 AM</strong>. Check <strong>Stay awake with lid closed</strong> and you can shut the laptop. The flame in the menu bar shows time remaining, and normal sleep comes back on its own when the session ends, when the app quits, or if anything crashes.</p>
            """},
            {"id": "compare", "gray": True, "html": """
        <h2>Midnight Oil vs caffeinate</h2>
        {{TABLE}}
        <h3>When caffeinate is the right tool</h3>
        <p>Scripts and CI. If you're already in a shell and the job is <code>caffeinate -i ./build.sh</code>, there's no reason to open an app. It's also the only option on a Mac where you can't install anything.</p>
        <h3>When an app is</h3>
        <p>Anything you'd want to see, extend, or forget about: an overnight run, a download, a render, a presentation, or a laptop you're about to close.</p>
            """, "table": [
                ("Price", "Free", "Free, preinstalled"),
                ("Mechanism", "IOKit power assertion", "IOKit power assertion"),
                ("Shows it's running and time left", "Menu bar flame and countdown", "Nothing; check pmset"),
                ("Survives closing the terminal", "Yes", "No (unless wrapped in tmux)"),
                ("Keep awake until a clock time", "Yes", "No (seconds only, via -t)"),
                ("While an app is running", "Yes, pick from a list", "Yes, one process, via -w or wrapping"),
                ("Closed-lid mode", "Yes; sleep restored automatically", "No; sudo pmset workaround, manual reset"),
                ("Triggers", "Yes", "No"),
                ("Weekly schedules, like work hours", "Yes", "No (cron plus a script)"),
                ("End on low battery or unplug", "Yes", "No"),
                ("Works from a script", "Hot keys; CLI planned", "Yes"),
                ("Install", "Homebrew cask or DMG", "None needed"),
            ]},
            {"id": "switch", "html": """
        <h2>Replacing your caffeinate habit</h2>
        <ol class="steps">
          <li><b>Install Midnight Oil.</b> <code>brew install --cask coreyhaines31/tap/midnightoil</code></li>
          <li><b>Start the agent</b> in Terminal, Cursor, or wherever it lives.</li>
          <li><b>Click the flame › While App Is Running › Terminal.</b> Or Keep Awake Until › 7:00 AM. Check “Stay awake with lid closed” if you're closing the laptop.</li>
          <li><b>Leave.</b> When the app quits or the time arrives, your Mac goes back to its normal sleep schedule.</li>
        </ol>
        <p>Keep <code>caffeinate</code> in your scripts. Use Midnight Oil for everything you'd otherwise have to remember.</p>
            """},
        ],
    },
    # ------------------------------------------------------------------ KeepingYouAwake
    {
        "slug": "keepingyouawake",
        "competitor": "KeepingYouAwake",
        "title": "KeepingYouAwake alternative with closed-lid mode: Midnight Oil",
        "description": "KeepingYouAwake is a well-maintained, open-source keep-awake app for Mac. It deliberately doesn't support a closed lid or app-based triggers. Midnight Oil is the free, source-available alternative that does.",
        "eyebrow": "KeepingYouAwake alternative",
        "h1": "KeepingYouAwake stops at the lid.<br>Midnight Oil doesn't.",
        "lede": "KeepingYouAwake is the app most people recommend after Amphetamine: free, MIT-licensed, actively maintained, a Homebrew cask, one click. It also draws a line at closed-lid mode, on purpose, and its most-requested feature in 2026 is exactly that. Midnight Oil is the free, source-available alternative that crosses the line carefully.",
        "tldr": "Lid open and just need on/off with a timer? KeepingYouAwake is excellent; keep it. Running agents overnight with the lid closed, or want sessions tied to an app? Midnight Oil adds those, and it's free too.",
        "card_title": "KeepingYouAwake",
        "card_blurb": "Maintained, minimal, open source. Refuses closed-lid mode on principle.",
        "cta": "Same values. More coverage.",
        "faqs": [
            ("Does KeepingYouAwake work with the lid closed?", "No. Its README says it only prevents sleep on desktop Macs and portables with an open lid, out of thermal considerations. A 2026 issue requesting the feature notes it would help users who run autonomous agents or long build tasks."),
            ("Why does Midnight Oil allow closed-lid mode if KeepingYouAwake won't?", "Because the risk can be managed rather than avoided. Midnight Oil's helper restores normal sleep the moment a session ends, when the app quits, or if the app crashes; sessions can end below a battery level or when unplugged; and an alarm sounds if the lid closes on battery. The feature is off unless you check it."),
            ("Is Midnight Oil open source like KeepingYouAwake?", "Its full source is on GitHub under FSL-1.1-MIT: free to use and modify, but not to resell, and each release becomes MIT two years after it ships. KeepingYouAwake is MIT today. Both install with a Homebrew cask."),
            ("Can I run both?", "Yes, but there's no reason to. Two keep-awake apps hold two assertions and do the same thing."),
        ],
        "sections": [
            {"id": "why", "html": """
        <h2>What KeepingYouAwake gets right</h2>
        <p>Plenty. It's been shipping since 2014, the maintainer still pushes releases (1.6.8 in September 2025, with 1.6.9 in progress), it has nearly 7,000 GitHub stars and around 230,000 downloads of the current version. It's sandboxed, notarized, translated into twenty languages, and it wraps Apple's own <code>caffeinate</code> so the mechanism is beyond reproach. If you want a thin, trustworthy on/off switch with a timer, this is the one.</p>
        <h2>Where it stops</h2>
        <h3>No closed-lid mode, on purpose</h3>
        <p>The README is explicit: it <em>“will only prevent sleep on desktop Macs and portable Macs with an open lid,”</em> out of thermal considerations. That's a reasonable position. It's also the project's most-requested feature. An August 2026 issue asks for an optional lid-closed mode because it <em>“would help many users who run autonomous agents or even just long build tasks on their MacBooks.”</em> A commenter adds: <em>“I faced the same issue with Claude Code running out overnight.”</em> A pull request offering the feature followed in late September.</p>
        <h3>One trigger</h3>
        <p>It can activate when an external display connects, and several issues report even that as unreliable. There's no “while this app is running,” no schedule, no Wi-Fi or power trigger.</p>
        <h3>No “until”</h3>
        <p>Durations only. You can't say “until 7 AM,” and there's no live countdown in the menu (issue #241 asks for one).</p>
            """},
            {"id": "compare", "gray": True, "html": """
        <h2>Midnight Oil vs KeepingYouAwake</h2>
        {{TABLE}}
        <h3>What KeepingYouAwake does better</h3>
        <p>It's smaller, it runs on macOS 10.13 through Tahoe, it's translated into twenty languages, it's sandboxed, and it has a decade of track record. If those matter more to you than lid support, stay.</p>
        <h3>What Midnight Oil does better</h3>
        <p>Closed-lid mode with real safeguards, sessions tied to an app or a clock time, a live countdown, ten trigger types, battery rules, hot keys, and statistics. Same license, same price.</p>
            """, "table": [
                ("Price", "Free", "Free"),
                ("Source code public", "Yes (FSL, MIT after 2 years)", "Yes, MIT"),
                ("Actively maintained", "Yes", "Yes"),
                ("Install", "Homebrew cask or DMG", "Homebrew cask or zip"),
                ("One-click on and off", "Yes", "Yes"),
                ("Timed sessions", "Yes, with a live countdown", "Yes, no countdown"),
                ("Keep awake until a time", "Yes", "No"),
                ("While an app is running", "Yes", "No"),
                ("Closed-lid mode", "Yes, opt-in, with safeguards", "No, by design"),
                ("Triggers", "10 kinds", "External display only"),
                ("Weekly schedules, like work hours", "Yes", "No"),
                ("End on low battery / Low Power Mode", "Yes", "Yes"),
                ("Lid-close alarm on battery", "Yes", "No"),
                ("Sandboxed", "No (helper needs root for lid mode)", "Yes"),
                ("Languages", "English", "About 20"),
                ("Minimum macOS", "14 Sonoma", "10.13 (12 from 1.6.9)"),
            ]},
            {"id": "switch", "html": """
        <h2>Switching</h2>
        <ol class="steps">
          <li><b>Install Midnight Oil.</b> <code>brew install --cask coreyhaines31/tap/midnightoil</code></li>
          <li><b>Set your defaults.</b> Settings › Sessions has the same allow-display-sleep and low-battery options you're used to. Settings › General has launch at login.</li>
          <li><b>Add the trigger you wanted.</b> Settings › Triggers › Add Trigger › App Running › Terminal. For work hours, Settings › Schedules › Add “Work hours”.</li>
          <li><b>Turn on closed-lid mode when you need it.</b> It's a checkbox in a running session. Approve the helper once.</li>
          <li><b>Quit KeepingYouAwake.</b> <code>brew uninstall --cask keepingyouawake</code> if you're done with it.</li>
        </ol>
            """},
        ],
    },
    # ------------------------------------------------------------------ Mouse jiggler
    {
        "slug": "mouse-jiggler",
        "competitor": "Mouse jiggler",
        "title": "Mouse jiggler for Mac? You probably need a keep-awake app instead",
        "description": "Mouse jigglers fake input to look active. If your actual problem is a Mac that sleeps during a download, a build, or an AI-agent run, a keep-awake app does the job properly: no Accessibility permission, nothing for IT to detect, and it works with the lid closed.",
        "eyebrow": "Mouse jiggler alternative",
        "h1": "You don't need a mouse jiggler.<br>You need your Mac to stay awake.",
        "lede": "A mouse jiggler wiggles the cursor so the computer thinks you're there. That's the right tool for exactly one job: keeping a chat status green. If what you want is for your Mac to stay awake through a download, a render, a build, or an overnight agent run, a jiggler is the wrong tool, and a keep-awake app is the right one.",
        "tldr": "Jigglers fake input. Midnight Oil asks macOS for a power assertion, the same thing Xcode does: no moving cursor, no Accessibility permission, nothing on a compliance report, and it works with the lid closed, which no jiggler can.",
        "card_title": "Mouse jigglers",
        "card_blurb": "Fake input to look busy. Detectable, and no help once the lid closes.",
        "cta": "Keep it awake, honestly.",
        "faqs": [
            ("Is Midnight Oil a mouse jiggler?", "No. It never moves your cursor or sends fake input. It holds a macOS power-management assertion, which is what stops the Mac from sleeping. It won't keep Slack or Teams showing you as active, by design."),
            ("Will a mouse jiggler keep my MacBook awake with the lid closed?", "No. Closing the lid puts a MacBook to sleep regardless of cursor movement. Midnight Oil's closed-lid mode is built for that case."),
            ("Can IT detect a mouse jiggler?", "Usually. A USB jiggler enumerates as a mouse the computer keeps a record of; a software jiggler needs Accessibility access that device-management tools can report; and the movement is perfectly periodic. In 2024 Wells Fargo dismissed more than a dozen employees for simulated activity. A keep-awake app is a normal power assertion, the same one Xcode and Final Cut use."),
            ("Does Midnight Oil need Accessibility permission?", "No. It needs no special permissions for ordinary sessions. Closed-lid mode uses a helper you approve once in System Settings."),
        ],
        "sections": [
            {"id": "why", "html": """
        <h2>Two different problems</h2>
        <p>“Mouse jiggler” is one of the most-searched Mac utilities there is, and most of the people searching don't actually want a jiggler. They have one of two problems that look alike from the outside.</p>
        <h3>Problem one: your status goes yellow</h3>
        <p>Slack and Teams mark you away after a few minutes without input. A jiggler fixes that by pretending you're typing. If this is your problem, a keep-awake app won't help; it doesn't send input. You'll want to think about whether faking presence is worth the risk (see below), but that's a different page.</p>
        <h3>Problem two: your Mac goes to sleep</h3>
        <p>The download stalls, the SSH session drops, the render stops, the agent freezes mid-task. A jiggler sort of fixes this, by resetting the idle timer every thirty seconds with a fake mouse event. A keep-awake app fixes it properly, by telling macOS not to sleep. That's what Midnight Oil does.</p>
        <h2>Why a jiggler is the wrong fix for sleep</h2>
        <h3>It can't survive a closed lid</h3>
        <p>Close the MacBook and it sleeps, <em>“jiggler or not, unless it's plugged into power and an external display.”</em> Some Mac jiggler apps say so in their own descriptions. Midnight Oil's closed-lid mode keeps the laptop working in a bag.</p>
        <h3>It's detectable, and it looks like what it is</h3>
        <p>A USB jiggler works by telling the computer it's a mouse, and that's also how it's found. A software jiggler needs Accessibility access, which management tools can list. The movement arrives every 30 or 60 seconds on the dot. Endpoint tools flag all of this, and in 2024 Wells Fargo dismissed more than a dozen employees over <em>“simulation of keyboard activity.”</em> A keep-awake app holds an ordinary power assertion. There's nothing to detect because there's nothing being faked.</p>
        <h3>It interferes with the work</h3>
        <p>A cursor that moves on its own can steal focus or misclick during exactly the unattended run you set it up for.</p>
        <h3>Corporate Macs block it anyway</h3>
        <p>Management profiles can lock energy settings, block apps from outside the App Store, and pre-empty the Accessibility list. A jiggler needs one of those; Midnight Oil's basic sessions need none.</p>
            """},
            {"id": "compare", "gray": True, "html": """
        <h2>Midnight Oil vs a mouse jiggler</h2>
        {{TABLE}}
        <h3>When a jiggler is the right tool</h3>
        <p>When the only thing you need is a green status dot and you've made peace with the risk. Stick Software's Jiggler is free, open source, and has been around for years.</p>
        <h3>When Midnight Oil is</h3>
        <p>When the Mac itself needs to stay up: downloads, builds, renders, presentations, and especially AI agents working while you're away.</p>
            """, "table": [
                ("Keeps the Mac awake", "Yes, via a power assertion", "Indirectly, by faking input"),
                ("Keeps Slack or Teams green", "No, by design", "Yes"),
                ("Works with the lid closed", "Yes", "No"),
                ("Moves your cursor", "Never", "Every 30–60 seconds"),
                ("Needs Accessibility permission", "No", "Software jigglers: yes"),
                ("Visible to device management", "A normal power assertion", "Extra mouse device or Accessibility grant"),
                ("Timed and until-a-time sessions", "Yes", "Rarely"),
                ("Ends when an app quits", "Yes", "No"),
                ("Weekly schedules, like work hours", "Yes", "Rarely"),
                ("Battery safety", "Yes", "No"),
                ("Price", "Free, source on GitHub", "Free to $25"),
            ]},
            {"id": "switch", "html": """
        <h2>If sleep was your real problem</h2>
        <ol class="steps">
          <li><b>Install Midnight Oil.</b> <code>brew install --cask coreyhaines31/tap/midnightoil</code>, or the DMG from GitHub.</li>
          <li><b>Click the flame and pick how long.</b> Indefinitely, 8 hours, until 7 AM, or while Terminal is running.</li>
          <li><b>Closing the laptop?</b> Check “Stay awake with lid closed.”</li>
          <li><b>Unplug the jiggler.</b> Or quit it. Your cursor will stay where you left it.</li>
        </ol>
            """},
        ],
    },
]

HUB = {
    "title": "Alternatives to Amphetamine, Caffeine, caffeinate, and mouse jigglers for Mac",
    "description": "Honest comparisons of the ways people keep a Mac awake, and where Midnight Oil fits: the free, source-available keep-awake app built for overnight AI-agent runs and closed-lid work.",
    "h1": "Every way to keep a Mac awake,<br>compared honestly.",
    "lede": "Five ways people do this, what each does well, and where it stops. Sometimes the other tool is the right one; we say so.",
    "glance": [
        ("You want…", "Use"),
        ("One click, lid open, nothing else", "Caffeine or KeepingYouAwake"),
        ("A command in a script or CI job", "caffeinate"),
        ("Slack or Teams to show you as active", "A mouse jiggler (and maybe a rethink)"),
        ("Fifteen kinds of triggers and AppleScript, on an old macOS", "Amphetamine, as long as it still runs"),
        ("Awake 9 to 5 on weekdays, only while plugged in", "Midnight Oil"),
        ("An overnight agent run, the lid closed, sleep restored when it's done", "Midnight Oil"),
    ],
    "cta": "Give your agents the night shift.",
    "html": """
        <h2>How we compare</h2>
        <p>Every page here was researched from the competitor's own App Store listing, GitHub repository, release history, and user reviews as of September 2026, and each states plainly what the other tool does better. If you spot something out of date, <a href="https://github.com/coreyhaines31/midnightoil/issues">open an issue</a> and we'll fix it.</p>
        <p>The short version of the category: <strong>Amphetamine</strong> has the most features and hasn't shipped since 2023. <strong>KeepingYouAwake</strong> is maintained and minimal, and won't keep a closed lid awake on principle. <strong>Caffeine</strong> is the 2006 original, a cup you click. <strong>caffeinate</strong> is built in and lives in the terminal. <strong>Mouse jigglers</strong> solve a different problem than most people think. Midnight Oil is free, with its source on GitHub like the best of them, and built for the way Macs get kept awake now: overnight, unattended, sometimes closed.</p>
    """,
}
