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
]
