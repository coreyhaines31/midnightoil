"""How-to guides: answers to the questions people search before they find Midnight Oil.

Rendered to /guides/<slug> by render.py. Each guide answers its question fully with what
macOS already offers, then shows where an app helps. Facts checked against Apple's
"Set sleep and wake settings for your Mac" (macOS Ventura through Golden Gate), October 2026.
"""

UPDATED = "2026-10-06"

GUIDES = [
    # ------------------------------------------------------------------ Stop sleeping
    {
        "slug": "stop-mac-from-sleeping",
        "title": "How to stop your Mac from sleeping: 4 ways that work",
        "description": "Stop a Mac or MacBook from sleeping with System Settings, the caffeinate command, pmset, or a free app. Steps for macOS Ventura through Golden Gate.",
        "eyebrow": "Guide",
        "h1": "How to stop your Mac from sleeping",
        "lede": "Four ways, from a switch in System Settings to a command in Terminal. Which one you want depends on how long the Mac needs to stay awake, whether it's plugged in, and whether the lid will be closed.",
        "tldr": "<strong>Plugged-in MacBook:</strong> System Settings › Battery › Options › turn on <em>Prevent automatic sleeping on power adapter when the display is off</em>. <strong>Mac mini, iMac, Mac Studio, Mac Pro:</strong> System Settings › Energy › turn on <em>Prevent automatic sleeping when the display is off</em>. <strong>Just for one job:</strong> run <code>caffeinate -i</code> in Terminal. <strong>On battery, with the lid closed, or until a set time:</strong> System Settings can't do it; use <code>pmset</code> or an app.",
        "card_title": "Stop your Mac from sleeping",
        "card_blurb": "System Settings, caffeinate, pmset, or an app: which to use when.",
        "cta": "Keep your Mac awake in one click.",
        "faqs": [
            ("How do I stop my Mac from going to sleep?", "On a MacBook, open System Settings › Battery › Options and turn on Prevent automatic sleeping on power adapter when the display is off. On a desktop Mac, open System Settings › Energy and turn on Prevent automatic sleeping when the display is off. For a one-off job, run caffeinate -i in Terminal and press Ctrl-C when you're done."),
            ("How do I keep my MacBook from sleeping on battery?", "System Settings only offers the prevent-sleep switch on the power adapter. On battery, run caffeinate -i in Terminal, or use a keep-awake app such as Midnight Oil, which can also end the session when the battery drops below a level you choose."),
            ("How do I turn off sleep mode on a Mac completely?", "sudo pmset -a disablesleep 1 in Terminal turns off all sleep, including when the lid closes. It stays that way until you run sudo pmset -a disablesleep 0, so use it with care on a laptop: a MacBook that never sleeps can drain its battery or overheat in a bag."),
            ("Why does my Mac still go to sleep?", "Check three things. The prevent-sleep switch only works on the power adapter, so a MacBook on battery still sleeps. Closing the lid always sleeps the Mac unless an external display, power, and keyboard are connected, or sleep is disabled with pmset. And a scheduled sleep can override everything: run pmset -g sched to see one."),
            ("Does keeping a Mac awake damage it?", "No. Macs are built to run for days. Keep it ventilated, and let the display sleep when you don't need it, which saves power and the screen. Midnight Oil's Allow display sleep option does exactly that while the Mac keeps working."),
        ],
        "sections": [
            {"id": "pick", "html": """
        <h2>Which method to use</h2>
        <div class="table-scroll"><table class="compare">
          <thead><tr><th>Your situation</th><th>Use</th></tr></thead>
          <tbody>
            <tr><td>MacBook, plugged in, every day</td><td>System Settings › Battery › Options</td></tr>
            <tr><td>Mac mini, iMac, Mac Studio, Mac Pro</td><td>System Settings › Energy</td></tr>
            <tr><td>One download, build, or command</td><td><code>caffeinate</code> in Terminal</td></tr>
            <tr><td>MacBook on battery</td><td><code>caffeinate</code>, or an app with a battery floor</td></tr>
            <tr><td>Lid closed</td><td>An external display (<a href="/guides/clamshell-mode">clamshell mode</a>), <code>pmset</code>, or an app with closed-lid mode</td></tr>
            <tr><td>Until 7 AM, while an app runs, or every weekday 9 to 5</td><td>An app</td></tr>
          </tbody>
        </table></div>
            """},
            {"id": "settings", "html": """
        <h2>1. System Settings</h2>
        <p>Since macOS Ventura, sleep settings live in System Settings. The names below are the same in Ventura, Sonoma, Sequoia, Tahoe, and Golden Gate.</p>
        <h3>On a MacBook</h3>
        <ol class="steps">
          <li><b>Open System Settings › Battery.</b></li>
          <li><b>Click Options…</b> at the bottom of the pane.</li>
          <li><b>Turn on “Prevent automatic sleeping on power adapter when the display is off.”</b> The Mac now stays awake whenever it's plugged in, even after the screen goes dark.</li>
        </ol>
        <p>The screen still turns off on its own schedule. That's set separately in System Settings › Lock Screen › <em>Turn display off on power adapter when inactive</em>. Leaving the display free to sleep is usually what you want: the Mac keeps working and saves power. To keep the screen on too, see <a href="/guides/keep-mac-screen-on">how to keep your Mac screen on</a>.</p>
        <h3>On a Mac mini, iMac, Mac Studio, or Mac Pro</h3>
        <ol class="steps">
          <li><b>Open System Settings › Energy.</b></li>
          <li><b>Turn on “Prevent automatic sleeping when the display is off.”</b></li>
        </ol>
        <h3>What this can't do</h3>
        <p>The switch only works on the power adapter, so a MacBook on battery still sleeps. Closing the lid still sleeps it. And it's all or nothing: there's no “until the download finishes” or “until 7 AM,” so you have to remember to turn it back off.</p>
            """},
            {"id": "caffeinate", "gray": True, "html": """
        <h2>2. The caffeinate command</h2>
        <p>Every Mac includes <code>caffeinate</code>, a Terminal command that holds the Mac awake until you stop it. It works on battery and needs no admin password.</p>
        <pre><code>caffeinate -i              # stay awake until you press Ctrl-C
caffeinate -i -t 7200      # for two hours
caffeinate -d              # keep the display on too
caffeinate -i ./build.sh   # for as long as this command runs</code></pre>
        <p>It stops when you press Ctrl-C or close the Terminal window, and it doesn't keep a closed lid awake. There's more on the flags and the catches in <a href="/alternatives/caffeinate">the caffeinate guide</a>.</p>
            """},
            {"id": "pmset", "html": """
        <h2>3. pmset, for full control</h2>
        <p><code>pmset</code> changes the power settings directly. It needs an admin password, and its changes stay until you change them back.</p>
        <pre><code>pmset -g                          # see the current settings
sudo pmset -c sleep 0             # never sleep on the charger
sudo pmset -b sleep 0             # never sleep on battery
sudo pmset -a disablesleep 1      # never sleep at all, even with the lid closed
sudo pmset -a disablesleep 0      # undo that</code></pre>
        <p><code>-c</code> means on the charger, <code>-b</code> on battery, and <code>-a</code> both. Before changing <code>sleep</code>, note the value <code>pmset -g</code> shows so you can put it back.</p>
        <p><strong>Be careful with <code>disablesleep 1</code> on a laptop.</strong> It applies to the whole Mac and doesn't turn itself off. Forget about it and a MacBook in a bag keeps running, with nowhere for its heat to go.</p>
            """},
            {"id": "app", "gray": True, "html": """
        <h2>4. A keep-awake app</h2>
        <p>An app makes sense when you want the Mac awake for a reason and then back to normal, without remembering to undo anything. <a href="/">Midnight Oil</a> is free and lives in the menu bar:</p>
        <ul>
          <li><strong>Keep Awake For</strong> a set time, or <strong>Keep Awake Until</strong> a clock time like 7:00 AM.</li>
          <li><strong>While App Is Running</strong>: stays awake until Terminal, Cursor, or Final Cut quits.</li>
          <li><strong>While File Is Downloading</strong>: stops when the download finishes.</li>
          <li><strong>Stay awake with lid closed</strong>, with sleep restored automatically when the session ends, the app quits, or anything crashes.</li>
          <li><strong>Schedules</strong> like weekdays 9 to 5, and <strong>battery safety</strong> that ends sessions when you unplug or drop below a level you choose.</li>
        </ul>
        <p>Other options: <a href="/alternatives/keepingyouawake">KeepingYouAwake</a> is a good minimal on/off switch, and <a href="/alternatives/amphetamine">Amphetamine</a> still works but hasn't been updated since 2023.</p>
            """},
            {"id": "models", "html": """
        <h2>By Mac model</h2>
        <h3>MacBook Air</h3>
        <p>Use Battery › Options when plugged in. The Air has no fan, so if you keep it awake with the lid closed, leave it somewhere open rather than in a sleeve.</p>
        <h3>MacBook Pro</h3>
        <p>Same settings as the Air. For long jobs on battery, set a battery floor so a session ends before the battery runs out.</p>
        <h3>Mac mini, Mac Studio, iMac</h3>
        <p>System Settings › Energy is usually all you need, since there's no battery or lid. A Mac mini used as a home server is the classic case for leaving <em>Prevent automatic sleeping when the display is off</em> on permanently.</p>
            """},
            {"id": "still", "gray": True, "html": """
        <h2>If your Mac still falls asleep</h2>
        <ul>
          <li><strong>It's on battery.</strong> The System Settings switch only applies on the power adapter.</li>
          <li><strong>The lid closed.</strong> A closed lid sleeps a MacBook unless it's in <a href="/guides/clamshell-mode">clamshell mode</a> or sleep is disabled.</li>
          <li><strong>A scheduled sleep.</strong> Run <code>pmset -g sched</code>. Cancel a repeating one with <code>sudo pmset repeat cancel</code>.</li>
          <li><strong>Something else is fighting it.</strong> <code>pmset -g assertions</code> lists every app holding the Mac awake, or not.</li>
          <li><strong>It's the external drive that's sleeping.</strong> Turn off <em>Put hard disks to sleep when possible</em> in Battery › Options or Energy, or use Midnight Oil's Drive Alive to keep just the drives you pick awake.</li>
        </ul>
            """},
        ],
    },
    # ------------------------------------------------------------------ Clamshell mode
    {
        "slug": "clamshell-mode",
        "title": "MacBook clamshell mode, with or without a monitor",
        "description": "How to use a MacBook with the lid closed: what Apple's clamshell mode needs, how to set it up, and how to keep a closed MacBook running with no monitor.",
        "eyebrow": "Guide",
        "h1": "MacBook clamshell mode, with or without a monitor",
        "lede": "Clamshell mode is Apple's name for using a MacBook with the lid closed. Apple supports it with a monitor attached. Running closed with no monitor, for an overnight job or a laptop in a bag, takes one more step.",
        "tldr": "<strong>With a monitor:</strong> plug in power, an external display, and a keyboard and mouse or trackpad, then close the lid. The MacBook keeps running on the external display. <strong>Without a monitor:</strong> macOS sleeps the moment the lid closes. To keep it running, either disable sleep with <code>sudo pmset -a disablesleep 1</code> (and undo it later), or use an app with a closed-lid mode that restores sleep for you.",
        "card_title": "Clamshell mode",
        "card_blurb": "Use a MacBook closed, with a monitor or without one.",
        "cta": "Close the lid. Keep working.",
        "faqs": [
            ("What is clamshell mode on a MacBook?", "Clamshell mode, also called closed-display mode, is using a MacBook with its lid closed while it drives an external display. Apple supports it when the Mac is connected to power, an external display, and an external keyboard and mouse or trackpad."),
            ("Can I use clamshell mode without an external monitor?", "Not with Apple's settings alone: without a display attached, closing the lid puts the Mac to sleep. You can keep it running with sudo pmset -a disablesleep 1, or with an app like Midnight Oil whose closed-lid mode keeps the Mac awake for a session and restores normal sleep afterwards."),
            ("Does clamshell mode work on battery?", "Apple's clamshell mode expects the power adapter. With sleep disabled or Midnight Oil's closed-lid mode, a closed MacBook can keep running on battery, but plan for the drain: Midnight Oil can end the session below a battery level you choose, and sounds an alarm if the lid closes on battery."),
            ("Is it bad to run a MacBook with the lid closed?", "No, Apple supports it. Heat is the thing to watch. On a desk with the vents clear it's fine. In a bag or sleeve under heavy load, airflow is limited, so keep long, heavy jobs to an open space or a lighter workload."),
            ("Why does my external display go black when I close the lid?", "Usually the Mac isn't on power, or no external keyboard or mouse is connected, so it sleeps instead of switching to clamshell mode. Connect power, press a key on the external keyboard to wake it, and reconnect the display if it stays dark."),
        ],
        "sections": [
            {"id": "what", "html": """
        <h2>What clamshell mode is</h2>
        <p>When you close a MacBook's lid, macOS treats it as a request to sleep. Clamshell mode is the exception Apple builds in: if the Mac has power, an external display, and an external keyboard and pointer, closing the lid moves everything to the external display and the Mac keeps running.</p>
        <p>It's how many people use a MacBook at a desk: one big monitor, the laptop closed off to the side. Some models depend on it. A MacBook Air with M3, for example, can only drive a second external display with its lid closed.</p>
            """},
            {"id": "setup", "gray": True, "html": """
        <h2>Set up clamshell mode with a monitor</h2>
        <ol class="steps">
          <li><b>Connect power.</b> Use the MacBook's power adapter, or a dock or monitor that charges over USB-C or Thunderbolt.</li>
          <li><b>Connect a keyboard and a mouse or trackpad.</b> Wired, or Bluetooth paired while the lid is still open.</li>
          <li><b>Connect the external display</b> and wait for the desktop to appear on it.</li>
          <li><b>Close the lid.</b> The built-in screen turns off and the external display becomes the only one.</li>
        </ol>
        <p>To leave clamshell mode, open the lid. To set which display is the main one, use System Settings › Displays.</p>
            """},
            {"id": "without", "html": """
        <h2>Running closed without a monitor</h2>
        <p>This is the case Apple doesn't cover, and the one most people searching for clamshell mode actually want: start a long job, close the laptop, and leave. An AI agent working through the night. A large download or upload. A build or a render on the train.</p>
        <p>With no display attached, closing the lid always sleeps the Mac. A keep-awake setting or <code>caffeinate</code> doesn't help, because they prevent <em>idle</em> sleep, and closing the lid is an explicit request. There are two ways around it.</p>
        <h3>Option 1: pmset</h3>
        <pre><code>sudo pmset -a disablesleep 1   # stop all sleep, lid included
sudo pmset -a disablesleep 0   # put it back</code></pre>
        <p>It works, but it applies to the whole Mac and stays on until you turn it off. Forget, and the MacBook never sleeps again: in a bag, on battery, until it runs flat or gets hot.</p>
        <h3>Option 2: a closed-lid mode that undoes itself</h3>
        <p><a href="/">Midnight Oil</a> has a <strong>Stay awake with lid closed</strong> checkbox. It uses the same <code>pmset</code> setting through a small helper you approve once in System Settings, and turns sleep back on automatically when the session ends, when the app quits, and even if the app crashes. On battery, an alarm sounds when the lid closes, and you can end sessions below a battery level you choose.</p>
            """},
            {"id": "heat", "gray": True, "html": """
        <h2>Heat and battery</h2>
        <ul>
          <li><strong>On a desk:</strong> closed is fine. Apple supports it, and Apple silicon MacBooks run cool under most loads.</li>
          <li><strong>In a bag:</strong> airflow is limited. Fine for a download or a light agent run; avoid hours of heavy compiling or rendering.</li>
          <li><strong>MacBook Air:</strong> it has no fan, so it slows itself down when warm instead of getting louder. A long job will take longer closed in a bag.</li>
          <li><strong>On battery:</strong> set a floor so the Mac stops working before the battery empties.</li>
        </ul>
            """},
            {"id": "trouble", "html": """
        <h2>Troubleshooting</h2>
        <h3>The external display goes black when I close the lid</h3>
        <p>Check that the Mac is on power and that an external keyboard or mouse is connected. Press a key to wake it. If it stays dark, unplug and reconnect the display.</p>
        <h3>The Mac sleeps when I close the lid, even with a monitor</h3>
        <p>Same checks: power first, then an external keyboard or pointer. Without both, macOS sleeps instead of entering clamshell mode.</p>
        <h3>I used pmset and now the Mac never sleeps</h3>
        <p>Run <code>sudo pmset -a disablesleep 0</code>. Check with <code>pmset -g</code>: <code>SleepDisabled</code> should be <code>0</code>.</p>
            """},
        ],
    },
    # ------------------------------------------------------------------ Sleep settings
    {
        "slug": "mac-sleep-settings",
        "title": "Mac sleep settings explained, Ventura to Golden Gate",
        "description": "Every Mac sleep setting in System Settings and what it does, plus how to set a sleep timer and a sleep schedule from Terminal.",
        "eyebrow": "Guide",
        "h1": "Mac sleep settings, explained",
        "lede": "Apple split the old Energy Saver pane across Lock Screen, Battery, and Energy when System Settings arrived in macOS Ventura. Here's where every sleep setting lives now, what each one actually does, and the two things you can only do from Terminal.",
        "tldr": "<strong>When the screen turns off:</strong> System Settings › Lock Screen. <strong>Whether the Mac sleeps after that:</strong> Battery › Options on a MacBook, Energy on a desktop. <strong>A sleep timer:</strong> <code>sudo shutdown -s +30</code> sleeps the Mac in 30 minutes. <strong>A sleep and wake schedule:</strong> <code>sudo pmset repeat</code>, since the Schedule button is gone.",
        "card_title": "Mac sleep settings",
        "card_blurb": "Where every sleep setting lives now, and what each one does.",
        "cta": "Sleep on your terms.",
        "faqs": [
            ("Where are the sleep settings on a Mac?", "In System Settings. Lock Screen sets when the display turns off. On a MacBook, Battery › Options holds the switch that stops the Mac sleeping on the power adapter; on a desktop Mac, the same switch is in Energy."),
            ("How do I set a sleep timer on a Mac?", "Open Terminal and run sudo shutdown -s +30 to put the Mac to sleep in 30 minutes. Use any number of minutes, or a clock time such as sudo shutdown -s 2330. Cancel it with sudo killall shutdown."),
            ("How do I schedule my Mac to sleep and wake?", "Use pmset: sudo pmset repeat sleep MTWRFSU 23:00:00 wakeorpoweron MTWRF 07:30:00 sleeps every night at 11 PM and wakes on weekdays at 7:30. See the schedule with pmset -g sched, and remove it with sudo pmset repeat cancel."),
            ("What's the difference between display sleep and sleep?", "Display sleep turns off the screen while the Mac keeps running: downloads continue, agents keep working. Sleep suspends the whole Mac, so apps and network connections pause until it wakes."),
            ("What does Wake for network access do?", "It lets the Mac wake briefly when another device asks for something it shares, such as a file share, a printer, or remote access, then go back to sleep."),
        ],
        "sections": [
            {"id": "map", "html": """
        <h2>Where each setting lives</h2>
        <div class="table-scroll"><table class="compare">
          <thead><tr><th>Setting</th><th>Where</th><th>What it does</th></tr></thead>
          <tbody>
            <tr><td>Turn display off on battery when inactive</td><td>Lock Screen</td><td>Screen timeout on battery</td></tr>
            <tr><td>Turn display off on power adapter when inactive</td><td>Lock Screen</td><td>Screen timeout when plugged in</td></tr>
            <tr><td>Start Screen Saver when inactive</td><td>Lock Screen</td><td>Shows the screen saver before the display turns off</td></tr>
            <tr><td>Require password after screen saver begins or display is turned off</td><td>Lock Screen</td><td>How quickly the Mac locks</td></tr>
            <tr><td>Prevent automatic sleeping on power adapter when the display is off</td><td>Battery › Options (MacBook)</td><td>Keeps a plugged-in MacBook awake after the screen turns off</td></tr>
            <tr><td>Prevent automatic sleeping when the display is off</td><td>Energy (desktop Macs)</td><td>The same, for Mac mini, iMac, Mac Studio, Mac Pro</td></tr>
            <tr><td>Put hard disks to sleep when possible</td><td>Battery › Options or Energy</td><td>Spins down idle disks, including external drives</td></tr>
            <tr><td>Wake for network access</td><td>Battery › Options or Energy</td><td>Wakes the Mac for file sharing and remote access</td></tr>
            <tr><td>Low Power Mode</td><td>Battery (MacBook)</td><td>Trades speed for battery life</td></tr>
          </tbody>
        </table></div>
            """},
            {"id": "how", "gray": True, "html": """
        <h2>How the pieces fit together</h2>
        <p>macOS sleeps in two stages. First, after the Lock Screen timeout, the <strong>display</strong> turns off. Then, unless something stops it, the <strong>Mac</strong> sleeps too. The prevent-sleep switch in Battery › Options or Energy stops that second stage, but on a MacBook only while it's plugged in.</p>
        <p>Apps can also hold the Mac awake with a power assertion. That's how a video call, a Time Machine backup, <code>caffeinate</code>, or <a href="/">Midnight Oil</a> keeps it up for as long as they need. To see who's holding it awake right now:</p>
        <pre><code>pmset -g assertions</code></pre>
        <p>A closed lid is different. It's an explicit sleep request, and assertions don't override it. See <a href="/guides/clamshell-mode">clamshell mode</a> for the ways around that.</p>
            """},
            {"id": "timer", "html": """
        <h2>A sleep timer</h2>
        <p>macOS has no sleep-timer setting, but Terminal has one:</p>
        <pre><code>sudo shutdown -s +30      # sleep in 30 minutes
sudo shutdown -s 2330     # sleep at 11:30 PM
sudo killall shutdown     # cancel it
pmset sleepnow            # sleep right now</code></pre>
        <p>Despite the name, <code>shutdown -s</code> puts the Mac to sleep rather than shutting it down. More ways, including a Shortcut and sleeping when a job finishes, in <a href="/guides/mac-sleep-timer">how to set a sleep timer on a Mac</a>.</p>
            """},
            {"id": "schedule", "gray": True, "html": """
        <h2>A sleep and wake schedule</h2>
        <p>The old Energy Saver pane had a Schedule button; System Settings doesn't. <code>pmset</code> still does it:</p>
        <pre><code># Sleep every night at 11 PM, wake weekdays at 7:30 AM
sudo pmset repeat sleep MTWRFSU 23:00:00 wakeorpoweron MTWRF 07:30:00

pmset -g sched             # show the schedule
sudo pmset repeat cancel   # remove it</code></pre>
        <p>Days are written M T W R F S U, where R is Thursday and U is Sunday.</p>
        <p>The opposite, keeping the Mac <em>awake</em> on a schedule such as weekdays 9 to 5, isn't something macOS offers at all. Midnight Oil's Schedules do it, with conditions like “only while plugged in.”</p>
            """},
            {"id": "defaults", "html": """
        <h2>See every setting at once</h2>
        <p><code>pmset -g</code> prints the current values, including some System Settings doesn't show. A few worth knowing:</p>
        <ul>
          <li><code>displaysleep</code>: minutes before the display turns off.</li>
          <li><code>sleep</code>: minutes before the Mac sleeps; <code>0</code> means never.</li>
          <li><code>disksleep</code>: minutes before idle disks spin down.</li>
          <li><code>SleepDisabled</code>: <code>1</code> if someone ran <code>pmset -a disablesleep 1</code>. If your MacBook never sleeps, check this first.</li>
        </ul>
            """},
        ],
    },
    # ------------------------------------------------------------------ Screen on
    {
        "slug": "keep-mac-screen-on",
        "title": "How to keep your Mac screen on, and when not to",
        "description": "Keep a Mac or MacBook display from turning off with Lock Screen settings, caffeinate -d, or an app, and why an overnight job is better off with the screen dark.",
        "eyebrow": "Guide",
        "h1": "How to keep your Mac screen on",
        "lede": "Keeping the screen on and keeping the Mac awake are two different settings. Here's how to do the first, and why you often want only the second.",
        "tldr": "<strong>Always:</strong> System Settings › Lock Screen › set <em>Turn display off on power adapter when inactive</em> (and on battery, on a MacBook) to Never, and <em>Start Screen Saver when inactive</em> to Never. <strong>Just for now:</strong> run <code>caffeinate -d</code> in Terminal. <strong>For an overnight job:</strong> let the screen sleep and keep only the Mac awake.",
        "card_title": "Keep your Mac screen on",
        "card_blurb": "Stop the display turning off, and when to let it.",
        "cta": "Screen off, Mac still working.",
        "faqs": [
            ("How do I stop my Mac screen from turning off?", "Open System Settings › Lock Screen. Set Turn display off on power adapter when inactive to Never, and on a MacBook do the same for the battery setting. Set Start Screen Saver when inactive to Never so the screen saver doesn't take over instead."),
            ("How do I keep my MacBook screen on without changing settings?", "Run caffeinate -d in Terminal. The display stays on until you press Ctrl-C. A keep-awake app does the same from the menu bar: in Midnight Oil, start a session with Allow display sleep turned off."),
            ("Does keeping the screen on keep the Mac awake?", "Yes. While the display is on, the Mac doesn't idle-sleep. The reverse isn't true: the Mac can stay awake with the screen off, which is the better setup for long jobs."),
            ("Why does my Mac screen keep turning off?", "The Lock Screen timeout is probably short, or the screen saver starts and then the display turns off. On battery, MacBooks also use their own, usually shorter, timeout."),
        ],
        "sections": [
            {"id": "settings", "html": """
        <h2>Keep the screen on in System Settings</h2>
        <ol class="steps">
          <li><b>Open System Settings › Lock Screen.</b></li>
          <li><b>Set “Turn display off on power adapter when inactive” to Never.</b> On a MacBook, set the battery option too if you want the screen on when unplugged.</li>
          <li><b>Set “Start Screen Saver when inactive” to Never</b>, or the screen saver takes over instead.</li>
        </ol>
        <p>This stays in place until you change it back, for everything you do.</p>
            """},
            {"id": "temporary", "gray": True, "html": """
        <h2>Keep it on just for now</h2>
        <p>For a presentation, a recipe, a dashboard on a wall, or watching a long job, use something you can switch off afterwards:</p>
        <pre><code>caffeinate -d            # display on until Ctrl-C
caffeinate -d -t 3600    # for an hour</code></pre>
        <p>Or from the menu bar: start a <a href="/">Midnight Oil</a> session with <strong>Allow display sleep</strong> turned off. The screen stays on for that session only, then your normal timeout comes back.</p>
            """},
            {"id": "when-not", "html": """
        <h2>When to let the screen sleep</h2>
        <p>Most people searching for this actually need the <em>Mac</em> awake, not the screen. A download, a render, an AI agent working overnight: none of them need the display on. Letting it turn off saves power, keeps a laptop cooler, and avoids lighting up a room all night.</p>
        <p>The settings for that are different: keep the Lock Screen timeout short and stop the Mac itself from sleeping. That's covered in <a href="/guides/stop-mac-from-sleeping">how to stop your Mac from sleeping</a>. In Midnight Oil, it's one checkbox: <strong>Allow display sleep</strong> on, and the screen goes dark while the session keeps the Mac working.</p>
            """},
        ],
    },
    # ------------------------------------------------------------------ AI agents overnight
    {
        "slug": "run-ai-agents-overnight",
        "updated": "2026-10-13",
        "title": "Run Claude Code, Codex, or Cursor agents overnight",
        "description": "Why AI coding agents stop when your Mac sleeps, and a setup checklist for running Claude Code, Codex, or Cursor overnight or with the lid closed.",
        "eyebrow": "Guide",
        "h1": "Run Claude Code, Codex, or Cursor agents overnight",
        "lede": "You start a long task at 11 PM, go to bed, and wake up to a Mac that fell asleep at 11:15 with the agent frozen mid-step. Here's why that happens and how to set things up so the run finishes.",
        "tldr": "Plug in, keep the Mac awake for the length of the run, let the display sleep, and make sure the agent won't stop to ask for permission. The quickest version: <code>caffeinate -i</code> in a tmux session with the lid open, <code>midnightoil run --lid-closed -- claude</code>, or a <a href=\"/\">Midnight Oil</a> session <em>while Terminal is running</em> or <em>until 7 AM</em>, with the lid closed if you like.",
        "card_title": "Run AI agents overnight",
        "card_blurb": "Keep Claude Code, Codex, and Cursor working while you sleep.",
        "cta": "Give your agents the night shift.",
        "faqs": [
            ("Why does Claude Code stop when my Mac goes to sleep?", "Sleep suspends every process and drops network connections. The agent's connection to its model breaks mid-step, and nothing happens until the Mac wakes. Some tools retry when it does; many don't, and you come back to an error or a half-finished change."),
            ("How do I keep my Mac awake while Claude Code runs?", "In Terminal, run the agent inside tmux with caffeinate, for example tmux new-session -d -s agent 'caffeinate -i claude'. Or use Midnight Oil: start a session While App Is Running › Terminal, so the Mac stays awake until the terminal quits, or Keep Awake Until 7:00 AM. From the terminal, midnightoil run -- claude keeps the Mac awake until the agent exits, even with the lid closed if you add --lid-closed."),
            ("Can I close my MacBook while an AI agent runs?", "Not by default: closing the lid sleeps the Mac, even with caffeinate running. Use an external display (clamshell mode), sudo pmset -a disablesleep 1 (and undo it after), or Midnight Oil's Stay awake with lid closed, which restores sleep on its own when the session ends."),
            ("Does an overnight agent run need the screen on?", "No. The display can turn off while the Mac keeps working. It saves power and keeps a laptop cooler, which matters on long runs."),
            ("Will my agent wait for me to approve things overnight?", "If it's set to ask before running commands or editing files, yes: it pauses at the first prompt and waits until morning. Before you leave, give the agent the permissions the task needs, in a project or branch where that's safe."),
        ],
        "sections": [
            {"id": "why", "html": """
        <h2>Why agents stop overnight</h2>
        <p>macOS puts a Mac to sleep after a few idle minutes. An agent working in a terminal doesn't count as activity: there's no keyboard or mouse input, so the idle timer runs out on schedule. When the Mac sleeps, it suspends every process and drops network connections. The agent's request to its model breaks mid-step, an SSH session disconnects, and the run sits frozen until morning.</p>
        <p>This catches people because the agent was clearly busy. To macOS, busy isn't the same as active.</p>
            """},
            {"id": "checklist", "gray": True, "html": """
        <h2>Before you leave it running</h2>
        <ol class="steps">
          <li><b>Plug in.</b> A long run on battery can drain a laptop before morning. If you can't, set a battery floor.</li>
          <li><b>Keep the Mac awake for the length of the run.</b> Not forever: a setting you forget to undo means a MacBook that never sleeps again. The options are below.</li>
          <li><b>Let the display sleep.</b> The screen doesn't need to be on for the agent to work.</li>
          <li><b>Decide about the lid.</b> Open is simplest. Closed needs <a href="/guides/clamshell-mode">clamshell mode or a closed-lid mode</a>.</li>
          <li><b>Remove the approval prompts the task will hit.</b> An agent that stops to ask at 1 AM waits until you're up. Grant what the task needs before you go, on a branch or in a sandbox where that's safe.</li>
          <li><b>Give it a clear finish line.</b> “Run the tests after each step and open a pull request when they pass” gives you something to review in the morning.</li>
        </ol>
            """},
            {"id": "terminal", "html": """
        <h2>The Terminal way: tmux and caffeinate</h2>
        <pre><code>tmux new-session -d -s agent 'caffeinate -i claude'
tmux attach -t agent       # check on it later</code></pre>
        <p><code>caffeinate -i</code> holds off idle sleep for as long as the agent runs, and tmux keeps both alive if you close the Terminal window. Swap <code>claude</code> for <code>codex</code> or whatever starts your agent. It doesn't survive a closed lid, and nothing shows it's still running. More in <a href="/alternatives/caffeinate">the caffeinate guide</a>.</p>
        <p>Midnight Oil's <code>midnightoil</code> command works the same way and covers the lid. It ends the session when the agent exits, and the menu bar shows it's still going:</p>
        <pre><code>tmux new-session -d -s agent 'midnightoil run --lid-closed -- claude'</code></pre>
        <p>Agents can use it too. Add a line to your <code>CLAUDE.md</code> or <code>AGENTS.md</code>: “Run commands that take more than a few minutes through <code>midnightoil run -- &lt;command&gt;</code>.”</p>
            """},
            {"id": "app", "gray": True, "html": """
        <h2>The menu bar way: Midnight Oil</h2>
        <p><a href="/">Midnight Oil</a> is free and was built for this:</p>
        <ul>
          <li><strong>While App Is Running › Terminal</strong> (or Cursor, iTerm, Ghostty): the Mac stays awake until that app quits.</li>
          <li><strong>Keep Awake Until › 7:00 AM</strong>: awake through the night, then back to normal.</li>
          <li><strong>Stay awake with lid closed</strong>: close the laptop. Sleep comes back automatically when the session ends.</li>
          <li><strong>Allow display sleep</strong>: the screen goes dark, the Mac keeps working.</li>
          <li><strong>End sessions when the battery is low</strong>, and an alarm if the lid closes on battery.</li>
          <li><strong>Schedules</strong>: an “Overnight agents” schedule from 11 PM to 7 AM, only while plugged in, so you don't have to remember at all.</li>
        </ul>
            """},
            {"id": "remote", "html": """
        <h2>Agents on a Mac you don't sit at</h2>
        <p>If the agent runs on a Mac mini or a desk Mac you reach over SSH or screen sharing, the simplest fix is permanent: System Settings › Energy › <em>Prevent automatic sleeping when the display is off</em>. See <a href="/guides/stop-mac-from-sleeping">how to stop your Mac from sleeping</a>.</p>
        <p>Running agents across several Macs for a team? <a href="/teams">Midnight Oil for Teams</a> deploys the app and its rules with your MDM, and shows which Macs are awake and working.</p>
            """},
        ],
    },
    # ------------------------------------------------------------------ Won't sleep
    {
        "slug": "mac-wont-sleep",
        "updated": "2026-10-13",
        "title": "Mac won't sleep? Find what's keeping it awake",
        "description": "Find exactly what's stopping your Mac from sleeping with pmset -g assertions, fix the usual culprits, and stop it waking right back up. macOS 13 and later.",
        "eyebrow": "Guide",
        "h1": "Mac won't sleep? Here's how to find out why",
        "lede": "Something is holding your Mac awake, and macOS will tell you what if you ask. One Terminal command names the app, then the fix is usually a click.",
        "tldr": "Run <code>pmset -g assertions</code> in Terminal. Any line with <code>PreventUserIdleSystemSleep</code> or <code>PreventSystemSleep</code> names the process keeping the Mac up: quit that app. Nothing listed? Check <code>pmset -g</code> for <code>SleepDisabled 1</code> (undo it with <code>sudo pmset -a disablesleep 0</code>) and for a <code>sleep 0</code> value. If the Mac sleeps but wakes again, <code>pmset -g log | grep \"due to\"</code> shows why.",
        "card_title": "Mac won't sleep",
        "card_blurb": "Find the app keeping it awake, and stop it waking back up.",
        "cta": "Stay awake on purpose, not by accident.",
        "faqs": [
            ("Why won't my Mac go to sleep?", "Usually an app is holding a power assertion: music or video playing, a download, a backup, a screen share, or a keep-awake tool. Run pmset -g assertions in Terminal to see which, then quit it. If none is listed, check pmset -g for SleepDisabled 1 or sleep 0."),
            ("What is coreaudiod and why is it keeping my Mac awake?", "coreaudiod is macOS's audio service. It holds the Mac awake while any app plays sound, including a muted browser tab or a paused stream that never released audio. Close the tab or quit the app that was playing."),
            ("How do I see what woke my Mac?", "Run pmset -g log | grep \"due to\" in Terminal. Each wake lists a reason, such as the lid opening, a USB device, the network, or a scheduled wake."),
            ("Can a keep-awake app stop my Mac from sleeping after I quit it?", "Not one that uses power assertions: macOS releases them when the app quits. The exception is anything that ran sudo pmset -a disablesleep 1, which stays on until it's turned off. Midnight Oil turns closed-lid mode off again when a session ends or the app quits."),
            ("My MacBook doesn't sleep when I close the lid. Why?", "Either an external display, power, and keyboard are connected, which is Apple's clamshell mode, or sleep was disabled with pmset. Run pmset -g and look for SleepDisabled 1."),
        ],
        "sections": [
            {"id": "assertions", "html": """
        <h2>1. Ask macOS who's holding it awake</h2>
        <p>Apps keep a Mac awake by holding a <em>power assertion</em>. List them:</p>
        <pre><code>pmset -g assertions</code></pre>
        <p>The top half counts each type. Any non-zero <code>PreventUserIdleSystemSleep</code> or <code>PreventSystemSleep</code> means something is stopping sleep. The bottom half, under “Listed by owning process,” names who:</p>
        <pre><code>pid 63687(caffeinate): [0x...] 00:03:42 PreventUserIdleSystemSleep named: "caffeinate command-line tool"</code></pre>
        <p>A <code>PreventUserIdleDisplaySleep</code> line keeps only the screen on, which also stops idle sleep while it lasts. Quick version, just the names:</p>
        <pre><code>pmset -g | grep "prevented by"
 sleep        1 (sleep prevented by coreaudiod, caffeinate)</code></pre>
            """},
            {"id": "culprits", "gray": True, "html": """
        <h2>2. The usual suspects</h2>
        <div class="table-scroll"><table class="compare">
          <thead><tr><th>You see</th><th>What it means</th><th>Fix</th></tr></thead>
          <tbody>
            <tr><td><code>coreaudiod</code></td><td>Something is playing sound, even silently</td><td>Close the browser tab or app that played audio</td></tr>
            <tr><td>A browser</td><td>A video, a call, or a page that asked to stay awake</td><td>Close the tab</td></tr>
            <tr><td><code>caffeinate</code></td><td>A Terminal command or script is holding it</td><td><code>killall caffeinate</code></td></tr>
            <tr><td><code>backupd</code></td><td>Time Machine is backing up</td><td>Let it finish</td></tr>
            <tr><td><code>sharingd</code>, <code>screensharingd</code></td><td>AirDrop, file sharing, or a screen share</td><td>End the share, or turn sharing off in General › Sharing</td></tr>
            <tr><td>A keep-awake app</td><td>Amphetamine, KeepingYouAwake, Midnight Oil, and so on</td><td>End its session from the menu bar</td></tr>
          </tbody>
        </table></div>
        <p>With Midnight Oil, the flame in the menu bar shows when a session is running and what started it, and <code>midnightoil status</code> says the same in Terminal.</p>
            """},
            {"id": "settings", "html": """
        <h2>3. Nothing listed? Check the settings</h2>
        <pre><code>pmset -g</code></pre>
        <ul>
          <li><code>SleepDisabled 1</code>: someone ran <code>sudo pmset -a disablesleep 1</code>, and the Mac won't sleep at all, lid included. Undo it with <code>sudo pmset -a disablesleep 0</code>.</li>
          <li><code>sleep 0</code>: system sleep is set to never. Restore a value, for example <code>sudo pmset -c sleep 10</code> on the charger.</li>
          <li>On a MacBook, check System Settings › Battery › Options for <em>Prevent automatic sleeping on power adapter when the display is off</em>. On a desktop Mac it's in Energy.</li>
        </ul>
        <p>Every setting is explained in <a href="/guides/mac-sleep-settings">Mac sleep settings</a>.</p>
            """},
            {"id": "wakes", "gray": True, "html": """
        <h2>4. It sleeps, then wakes right back up</h2>
        <p>That's a different problem. Ask the power log what woke it:</p>
        <pre><code>pmset -g log | grep "due to"</code></pre>
        <p>Common reasons and what to do:</p>
        <ul>
          <li><strong>Network or a sharing service:</strong> turn off <em>Wake for network access</em> in Battery › Options or Energy.</li>
          <li><strong>USB or Bluetooth:</strong> a mouse, keyboard, or dock nudged it. Unplug the device to confirm.</li>
          <li><strong>A scheduled wake:</strong> <code>pmset -g sched</code> lists them; <code>sudo pmset repeat cancel</code> removes a repeating one.</li>
          <li><strong>DarkWake</strong> lines are Power Nap and maintenance wakes. They're brief and normal.</li>
        </ul>
            """},
            {"id": "flip", "html": """
        <h2>The flip side: awake only when you mean it</h2>
        <p>A Mac that stays awake by accident drains the battery and runs warm. One that stays awake on purpose is how downloads, builds, and AI agents finish overnight. The difference is ending it: a session that stops by itself when the job is done, at a set time, or when the battery gets low. That's what <a href="/">Midnight Oil</a> does, and when it ends, your Mac sleeps on its normal schedule again.</p>
            """},
        ],
    },
    # ------------------------------------------------------------------ Sleep timer
    {
        "slug": "mac-sleep-timer",
        "updated": "2026-10-13",
        "title": "How to set a sleep timer on a Mac or MacBook",
        "description": "macOS has no sleep timer button, but you can sleep a Mac in 30 minutes or at a set time with one Terminal command or a Shortcut, even with music playing.",
        "eyebrow": "Guide",
        "h1": "How to set a sleep timer on your Mac",
        "lede": "Falling asleep to a podcast, a movie, or a long render? macOS doesn't have a sleep timer in System Settings, but it has two ways to build one, and neither needs an app.",
        "tldr": "Open Terminal and run <code>sleep 1800; pmset sleepnow</code> to sleep the Mac in 30 minutes; leave the window open. For a clock time, <code>sudo shutdown -s 2330</code> sleeps it at 11:30 PM. Both work even while music or video is playing, which is exactly when the normal idle sleep doesn't.",
        "card_title": "Mac sleep timer",
        "card_blurb": "Sleep the Mac in 30 minutes, or at a set time.",
        "cta": "Awake exactly as long as you need.",
        "faqs": [
            ("Does a Mac have a sleep timer?", "Not in System Settings. Use Terminal: sleep 1800; pmset sleepnow sleeps the Mac in 30 minutes, and sudo shutdown -s 2330 sleeps it at 11:30 PM. A Shortcut with a Wait action and a Run Shell Script action does the same with a click."),
            ("Why doesn't my Mac sleep while music is playing?", "Audio playback holds the Mac awake on purpose, so the normal idle timer never fires. pmset sleepnow is a direct sleep request, so a timer that ends with it works even with music or video playing."),
            ("How do I cancel a sleep timer?", "For sleep 1800; pmset sleepnow, press Ctrl-C in that Terminal window. For sudo shutdown -s, run sudo killall shutdown."),
            ("Does shutdown -s turn my Mac off?", "No. On macOS, shutdown -s means sleep. shutdown -h is the one that shuts down."),
            ("Can I make the Mac sleep after a download or render finishes?", "Yes: put the command first and pmset sleepnow after it, like ./render.sh; pmset sleepnow. The Mac sleeps the moment the job ends."),
        ],
        "sections": [
            {"id": "terminal", "html": """
        <h2>1. In Terminal, in one line</h2>
        <pre><code>sleep 1800; pmset sleepnow     # sleep in 30 minutes (1800 seconds)
sleep 5400; pmset sleepnow     # in 90 minutes</code></pre>
        <p>No admin password needed. Keep the Terminal window open until it fires; press Ctrl-C to cancel.</p>
        <p>For a clock time, use <code>shutdown</code>, which on a Mac can sleep instead of shut down:</p>
        <pre><code>sudo shutdown -s 2330          # sleep at 11:30 PM
sudo shutdown -s +45           # sleep in 45 minutes
sudo killall shutdown          # cancel</code></pre>
        <p>This one runs in the background, so you can close Terminal.</p>
            """},
            {"id": "shortcut", "gray": True, "html": """
        <h2>2. As a Shortcut you can click</h2>
        <ol class="steps">
          <li><b>Open Shortcuts and create a new shortcut.</b> Name it “Sleep timer.”</li>
          <li><b>Add Ask for Input</b>, set to Number, with the prompt “Minutes?”</li>
          <li><b>Add Calculate</b> to multiply the answer by 60, then <b>Wait</b> for that many seconds.</li>
          <li><b>Add Run Shell Script</b> with <code>pmset sleepnow</code>. The first time, Shortcuts asks you to allow running scripts in Settings › Advanced.</li>
          <li><b>Pin it to the menu bar</b> from the shortcut's details, or give it a keyboard shortcut.</li>
        </ol>
            """},
            {"id": "after-job", "html": """
        <h2>3. Sleep when a job finishes, not after a guess</h2>
        <p>If you're waiting on a download, an export, or a script, don't guess at minutes. Chain the sleep after it:</p>
        <pre><code>./export.sh; pmset sleepnow
curl -O https://example.com/big.iso; pmset sleepnow</code></pre>
        <p>The Mac stays awake for the job and sleeps the moment it's done. If the job might outlast your idle timer, keep the Mac up for it too: <code>caffeinate -i ./export.sh; pmset sleepnow</code>, or with <a href="/cli">Midnight Oil's command</a>, <code>midnightoil run -- ./export.sh; pmset sleepnow</code>.</p>
            """},
            {"id": "why", "gray": True, "html": """
        <h2>Why the normal sleep setting doesn't help</h2>
        <p>System Settings' timers count <em>idle</em> time. Playing audio or video holds the Mac awake on purpose, so the idle timer never runs out while your podcast plays. A sleep timer works because <code>pmset sleepnow</code> is a direct request, like choosing Apple menu › Sleep. Where the regular settings live, and what each does, is in <a href="/guides/mac-sleep-settings">Mac sleep settings</a>.</p>
            """},
        ],
    },
]
