"""Content for /teams, the Teams docs, and the legal pages. Rendered by render.py."""

CHECKOUT = "https://app.midnightoil.app/checkout"
DASHBOARD = "https://app.midnightoil.app/dashboard"

FLAME = ('<svg viewBox="0 0 24 32" fill="#ff8c42" aria-hidden="true"><path d="M12 30c6.8 -0 10 -4.7 10 -10.6 0 -6.3 '
         '-4.6 -9.4 -7.5 -18.4 -0.9 3.8 -3.6 6.6 -4.7 10.3 -1 -1.9 -2.5 -4 -3.9 -5.1C2.6 8.5 2 11.8 2 14.6 2 21.2 4.8 30 12 30z"/></svg>')
BUILDING = ('<svg viewBox="0 0 24 24" fill="none" stroke="#ff8c42" stroke-width="1.7" stroke-linecap="round" '
            'stroke-linejoin="round" aria-hidden="true"><rect x="4" y="3" width="16" height="18" rx="2"/>'
            '<path d="M9 7h.01M15 7h.01M9 11h.01M15 11h.01M9 15h.01M15 15h.01M10 21v-3h4v3"/></svg>')


def web(url, nav_on, inner):
    tabs = "".join(f'<span class="{"on" if t == nav_on else ""}">{t}</span>' for t in ["Overview", "Fleet", "Deploy", "Members", "Billing"])
    return (f'<div class="mk-web" role="img" aria-label="The Midnight Oil for Teams dashboard, {nav_on} page">'
            f'<div class="bar"><i></i><i></i><i></i><span>{url}</span></div>'
            f'<div class="top"><b>Midnight Oil</b>{tabs}</div><div class="page">{inner}</div></div>')


FLEET_MOCK = web("app.midnightoil.app/dashboard/fleet", "Fleet", """
<h4>Fleet</h4><div class="sub">3 of 5 Macs awake now · 5 of 25 seats used</div>
<div class="card"><table>
<tr><th>Mac</th><th>Status</th><th>Battery</th><th>Last seen</th></tr>
<tr><td><b>Build Mac 1</b></td><td><span class="pill-on">Awake</span> <span class="muted">Schedule “Overnight agents”</span></td><td>plugged in</td><td class="muted">Just now</td></tr>
<tr><td><b>Build Mac 2</b></td><td><span class="pill-on">Awake</span> <span class="muted">Trigger “Docked at desk”</span></td><td>plugged in</td><td class="muted">2 min ago</td></tr>
<tr><td><b>Render Studio</b></td><td><span class="pill-on">Awake</span> <span class="muted">By hand · lid closed OK</span></td><td>71%</td><td class="muted">1 min ago</td></tr>
<tr><td><b>Design MacBook</b></td><td><span class="pill-off">Can sleep</span></td><td>88%</td><td class="muted">4 min ago</td></tr>
<tr><td><b>Marta’s MacBook</b></td><td><span class="pill-off">Offline</span></td><td class="muted">—</td><td class="muted">3 h ago</td></tr>
</table></div>""")

DEPLOY_MOCK = web("app.midnightoil.app/dashboard/deploy", "Deploy", """
<h4>Deploy</h4><div class="sub">Build a configuration profile for your MDM.</div>
<div class="card">
<div class="check"><i></i><span><b>Report to the fleet dashboard</b><br><span class="muted">Macs appear on the Fleet page.</span></span></div>
<div class="check"><i></i><span><b>Turn off closed-lid mode</b><br><span class="muted">Laptops sleep when the lid closes, as usual.</span></span></div>
<div style="display:flex;gap:12px;margin-top:6px"><div style="flex:1">Longest session (hours)<div class="field">8</div></div>
<div style="flex:1">Always end below (battery %)<div class="field">20</div></div></div>
<span class="btn">Download profile</span>
</div>""")

LOCK_MOCK = f"""<div class="mk-win short" role="img" aria-label="Midnight Oil's Sessions settings, managed by the organization: controls are locked.">
<div class="mk-pane">
<div class="mk-intro">{BUILDING}<div>Some settings here are managed by your organization and can’t be changed on this Mac.</div></div>
<div class="mk-h">Sessions</div>
<div class="mk-group">
<div class="mk-row" style="opacity:.5"><div class="mk-text"><div class="mk-title">Allow display sleep</div></div><div class="mk-switch"></div></div>
</div>
<div class="mk-h">Safety</div>
<div class="mk-group">
<div class="mk-row" style="opacity:.5"><div class="mk-text"><div class="mk-title">End sessions when the battery is low</div></div><div class="mk-switch"></div></div>
<div class="mk-row" style="opacity:.5"><div class="mk-text"><div class="mk-title">Below 20%</div></div></div>
</div>
</div>
<div class="mk-menu">{FLAME}<div><b>Keeping your Mac awake</b><span>Ends by 7:00 PM</span><small>Limit set by your organization</small></div></div>
</div>"""

WEBHOOK_MOCK = f"""<div role="img" aria-label="Session events from Midnight Oil posted to Slack, and the signed JSON body.">
<div class="mk-slack">
<div class="msg"><div class="avatar">{FLAME}</div><div><b>Midnight Oil</b><span class="t">11:00 PM</span><div>🔥 Build Mac 1 is staying awake on the “Overnight agents” schedule.</div></div></div>
<div class="msg"><div class="avatar">{FLAME}</div><div><b>Midnight Oil</b><span class="t">7:00 AM</span><div>Build Mac 1 can sleep again after 8h on the “Overnight agents” schedule.</div></div></div>
</div>
<div class="mk-json">{{
  <span class="k">"event"</span>: <span class="s">"session.ended"</span>,
  <span class="k">"device"</span>: {{ <span class="k">"label"</span>: <span class="s">"Build Mac 1"</span>, … }},
  <span class="k">"session"</span>: {{
    <span class="k">"source"</span>: <span class="s">"schedule"</span>, <span class="k">"sourceName"</span>: <span class="s">"Overnight agents"</span>,
    <span class="k">"endCause"</span>: <span class="s">"scheduleEnded"</span>, <span class="k">"awakeSeconds"</span>: 28800
  }}
}}</div>
</div>"""

TEAMS = {
    "title": "Midnight Oil for Teams: keep your Macs awake on purpose",
    "description": "Deploy Midnight Oil with your MDM, lock the rules that matter, and see which Macs are working right now. $5 per Mac per month, billed yearly.",
    "eyebrow": "Midnight Oil for Teams",
    "h1": "Every Mac in your fleet, awake on purpose.",
    "lede": "Deploy Midnight Oil with your MDM, lock the rules that matter, and see which Macs are working right now. For teams running agents, builds, and renders on Macs nobody is sitting at.",
    "features": [
        ("Deploy it with one profile.",
         "Build a configuration profile in the dashboard: your license key, the settings to lock, and the rules to follow. Upload it to Jamf, Kandji, Intune, Mosyle, or any MDM. Every Mac it reaches is set up, with nothing for anyone to paste.",
         DEPLOY_MOCK),
        ("Lock the rules that matter.",
         "Turn closed-lid mode off company-wide, cap how long a session someone starts can run, and set a battery floor no one can go under. Locked settings say so on the Mac, so nobody wonders why a switch won’t move.",
         LOCK_MOCK),
        ("See the whole fleet at a glance.",
         "Which Macs are awake right now, why (a schedule, a trigger, someone’s session), how long until they sleep, and their battery. Macs that haven’t checked in show as offline. Reporting is off until your profile turns it on.",
         FLEET_MOCK),
        ("Send sessions wherever you work.",
         "Every Mac posts when a session starts and ends to a URL you choose, signed so you know it’s yours. Point it at a Slack channel for a readable feed, or at your own systems for logging and alerts.",
         WEBHOOK_MOCK),
    ],
    "included": [
        "Managed settings and the license key in one configuration profile",
        "Policies: closed-lid off, session time limit, battery floor",
        "Fleet dashboard with seats, status, and battery",
        "Signed session webhook, with Slack formatting built in",
        "Admins for your team, and email support",
    ],
    "faqs": [
        ("Do the people at my company need Teams to use Midnight Oil?",
         "No. Midnight Oil is free for everyone, at home or at work. Teams is for organizations that want to deploy it, lock its settings, and see their fleet."),
        ("What does a Mac send, and to whom?",
         "Nothing, unless your profile turns on fleet reporting or a webhook. Then it sends session status (awake or not, why, until when) and battery, to the Teams dashboard or the URL you set. Never the computer’s name, user names, files, or what apps are doing. The full list is on the <a href=\"/docs/teams/privacy\">privacy page</a>."),
        ("Does the license key need an internet connection?",
         "No. Keys are signed and checked on the Mac itself. Macs that report to the dashboard pick up renewed keys on their own; others get them in your next profile."),
        ("What happens if the subscription lapses?",
         "Keys stay valid for 30 days past the paid period. After that, Teams features turn off and Midnight Oil keeps working as the free app. Nothing breaks."),
        ("Which MDMs does it work with?",
         "Any MDM that deploys configuration profiles: Jamf Pro, Kandji, Microsoft Intune, Mosyle, Addigy, JumpCloud, and others. You can also install the profile by hand for a few Macs. See the <a href=\"/docs/teams/deploy\">deployment guide</a>."),
        ("What if more Macs report than I paid for?",
         "Nothing stops working. The dashboard shows the overage so you can add seats when it suits you. Seats change anytime from Billing, prorated."),
    ],
}

DOCS = [
    {
        "path": "/docs/teams/deploy",
        "title": "Deploy Midnight Oil for Teams with your MDM",
        "description": "Build a configuration profile with your license key, settings, and policies, and deploy it with Jamf, Kandji, Intune, Mosyle, or by hand.",
        "eyebrow": "Teams docs",
        "h1": "Deploy with your MDM",
        "lede": "One configuration profile carries your license key, settings, and policies. Build it in the dashboard, upload it to your MDM, and scope it to the Macs running Midnight Oil.",
        "html": """
        <h2>1. Install Midnight Oil on your Macs</h2>
        <p>Deploy the app the way you deploy other apps: the DMG from <a href="https://github.com/coreyhaines31/midnightoil/releases/latest">GitHub Releases</a>, or <code>brew install --cask coreyhaines31/tap/midnightoil</code>. It's signed and notarized by Apple and updates itself. To push updates yourself instead, add <code>SUEnableAutomaticChecks</code> set to <code>false</code> to the profile (the standard key for apps that update with Sparkle).</p>
        <h2>2. Build the profile</h2>
        <p>Sign in to the <a href="https://app.midnightoil.app/dashboard/deploy">Teams dashboard</a> and open <strong>Deploy</strong>. Choose:</p>
        <ul>
          <li><strong>Fleet reporting</strong>, if you want Macs on the Fleet page, and a <strong>Mac name</strong> using your MDM's variable so each Mac reports its own name.</li>
          <li><strong>Policies</strong>: turn off closed-lid mode, cap the length of sessions people start, set a battery floor.</li>
          <li><strong>Settings</strong> to lock on or off, or leave to each person.</li>
          <li>An optional <strong>session webhook</strong> URL and signing secret.</li>
        </ul>
        <p>Download the profile. It's a standard <code>.mobileconfig</code> with your license key inside, so treat it like a credential and keep it in your MDM.</p>
        <h2>3. Upload it to your MDM</h2>
        <h3>Jamf Pro</h3>
        <p>Computers › Configuration Profiles › Upload. Scope it to the Macs (or a smart group of Macs with Midnight Oil installed). For the Mac name, use <code>$COMPUTERNAME</code>.</p>
        <h3>Kandji</h3>
        <p>Library › Add new › Custom Profile, upload the file, and assign it to a Blueprint. For the Mac name, use <code>$COMPUTER_NAME</code>.</p>
        <h3>Microsoft Intune</h3>
        <p>Devices › macOS › Configuration › Create › Templates › Custom, upload the file, and assign it. Use the Device channel. For the Mac name, use <code>{{devicename}}</code>.</p>
        <h3>Mosyle, Addigy, JumpCloud, and others</h3>
        <p>Add a custom configuration profile, upload the file, and assign it to the Macs. Use your MDM's device-name variable for the Mac name.</p>
        <h3>A few Macs, no MDM</h3>
        <p>Double-click the profile on each Mac, then approve it in System Settings › General › Device Management. Installing needs an administrator.</p>
        <h2>4. Check a Mac</h2>
        <p>In Midnight Oil, open Settings › General. The <strong>Midnight Oil for Teams</strong> section shows your organization, seats, and policies, and says the license was deployed by your organization. Locked settings are dimmed with a note at the top of their pane. If fleet reporting is on, the Mac appears on the Fleet page within a minute.</p>
        <h2>Updating the profile</h2>
        <p>Build a new profile and upload it in place of the old one. Profiles from your dashboard share an identifier, so the new one replaces the old on each Mac. Renewed keys reach reporting Macs automatically; redeploy the profile so the rest get them too.</p>
        <h2>Every managed key</h2>
        <p>For MDMs that prefer key-value settings over an uploaded profile, these are the preferences for the domain <code>app.midnightoil.MidnightOil</code>:</p>
        <ul>
          <li><code>teamsLicenseKey</code> (string): your license key.</li>
          <li><code>fleetReporting</code> (boolean): report to the fleet dashboard.</li>
          <li><code>deviceLabel</code> (string): the Mac's name on the Fleet page and in webhooks.</li>
          <li><code>webhookURL</code>, <code>webhookSecret</code> (string): the session webhook.</li>
          <li><code>policyDisallowClosedLid</code> (boolean), <code>policyMaxSessionHours</code> (integer, 1–168), <code>policyMinimumBatteryFloor</code> (integer, 1–99).</li>
          <li>Any setting, such as <code>allowsDisplaySleep</code>, <code>startsSessionAtLaunch</code>, <code>endsWhenUnplugged</code>, <code>staysAwakeWithLidClosed</code>, <code>batteryFloorEnabled</code>, <code>batteryFloorPercent</code>, <code>triggersEnabled</code>, <code>driveAliveEnabled</code>.</li>
        </ul>
""",
    },
    {
        "path": "/docs/teams/webhook",
        "title": "Midnight Oil session webhook: payload and signatures",
        "description": "Every Mac posts session.started and session.ended to your URL, signed with HMAC-SHA256. Payload reference and how to verify the signature.",
        "eyebrow": "Teams docs",
        "h1": "Session webhook",
        "lede": "Each Mac posts a JSON event to your URL when a session starts and when it ends. Requests are signed so you can tell they came from your Macs.",
        "html": """
        <h2>Events</h2>
        <p><code>session.started</code> and <code>session.ended</code>, sent as a <code>POST</code> with <code>Content-Type: application/json</code>.</p>
<pre><code>{
  "event": "session.ended",
  "id": "5e0b6b0e-1f0f-4c1a-9a63-2c0d7c4a1e55",
  "occurredAt": "2026-10-02T07:00:03Z",
  "device": { "id": "mac_0b4b5e2c-…", "label": "Build Mac 1", "appVersion": "1.4.0" },
  "session": {
    "startedAt": "2026-10-01T23:00:00Z",
    "endedAt": "2026-10-02T07:00:03Z",
    "source": "schedule",
    "sourceName": "Overnight agents",
    "allowsDisplaySleep": true,
    "staysAwakeWithLidClosed": false,
    "endCause": "scheduleEnded",
    "awakeSeconds": 28803,
    "awaySeconds": 27950
  }
}</code></pre>
        <ul>
          <li><code>id</code> is unique per delivery. Retries reuse it, so you can ignore one you've already handled.</li>
          <li><code>source</code> is <code>manual</code>, <code>schedule</code>, or <code>trigger</code>; <code>sourceName</code> is the schedule or trigger's name.</li>
          <li><code>endsAt</code> appears when the session has an end time. <code>endedAt</code>, <code>endCause</code>, <code>awakeSeconds</code>, and <code>awaySeconds</code> appear on <code>session.ended</code>.</li>
          <li><code>endCause</code> is one of <code>you</code>, <code>timeUp</code>, <code>appQuit</code>, <code>downloadFinished</code>, <code>lowBattery</code>, <code>unplugged</code>, <code>triggerEnded</code>, <code>scheduleEnded</code>, <code>schedulePaused</code>, <code>policyLimit</code>, <code>replaced</code>, <code>midnightOilQuit</code>.</li>
        </ul>
        <h2>Verifying the signature</h2>
        <p>With a signing secret in your profile, each request carries <code>X-MidnightOil-Signature: t=&lt;unix seconds&gt;,v1=&lt;hex&gt;</code>. <code>v1</code> is the HMAC-SHA256 of <code>&lt;t&gt;.&lt;raw body&gt;</code> using your secret, the same scheme as Stripe's. Compare in constant time, and reject timestamps more than five minutes old.</p>
<pre><code>// Node.js
import { createHmac, timingSafeEqual } from "node:crypto";

function verify(rawBody, header, secret) {
  const { t, v1 } = Object.fromEntries(header.split(",").map((part) =&gt; part.split("=")));
  if (Math.abs(Date.now() / 1000 - Number(t)) &gt; 300) return false;
  const expected = createHmac("sha256", secret).update(`${t}.${rawBody}`).digest("hex");
  return v1.length === expected.length &amp;&amp; timingSafeEqual(Buffer.from(v1), Buffer.from(expected));
}</code></pre>
<pre><code># Python
import hmac, hashlib, time

def verify(raw_body: bytes, header: str, secret: str) -&gt; bool:
    parts = dict(part.split("=", 1) for part in header.split(","))
    if abs(time.time() - int(parts["t"])) &gt; 300:
        return False
    expected = hmac.new(secret.encode(), f"{parts['t']}.".encode() + raw_body, hashlib.sha256).hexdigest()
    return hmac.compare_digest(expected, parts["v1"])</code></pre>
        <h2>Delivery</h2>
        <ul>
          <li>Your URL must use <code>https</code>. Redirects aren't followed.</li>
          <li>Answer with any 2xx. Network errors, 429, and 5xx are retried after 2 seconds, 10 seconds, and a minute; other responses aren't.</li>
          <li>When Midnight Oil quits mid-session, it waits up to three seconds to send <code>session.ended</code>.</li>
        </ul>
        <h2>Slack</h2>
        <p>Use a Slack incoming-webhook URL (<code>https://hooks.slack.com/…</code>) and Macs post readable messages instead, like “🔥 Build Mac 1 is staying awake on the “Overnight agents” schedule.” Slack messages aren't signed.</p>
""",
    },
    {
        "path": "/docs/teams/privacy",
        "title": "What Midnight Oil for Teams sends, and when",
        "description": "The free app sends nothing. With Teams, Macs report session status and battery only when your profile turns it on. The full list.",
        "eyebrow": "Teams docs",
        "h1": "What a Mac sends, and when",
        "lede": "The free app sends nothing beyond an update check you can turn off. With Teams, a Mac reports only what's listed here, and only when your organization's profile turns it on.",
        "html": """
        <h2>Fleet reporting</h2>
        <p>Off unless the profile sets <code>fleetReporting</code>. Then, every five minutes and when a session starts or ends, a Mac sends to <code>app.midnightoil.app</code>:</p>
        <ul>
          <li>A random device id the app made for itself, and the name your profile gives the Mac, if any.</li>
          <li>The Midnight Oil version.</li>
          <li>Whether it's being kept awake; if so, whether by hand, a schedule, or a trigger, that schedule or trigger's name, when it started and ends, and whether closed-lid mode is on.</li>
          <li>Battery level and whether it's plugged in.</li>
          <li>The session start or end event, with the fields in the <a href="/docs/teams/webhook">webhook payload</a>.</li>
          <li>Your license key, to say which organization the Mac belongs to.</li>
        </ul>
        <h2>The session webhook</h2>
        <p>Off unless the profile sets <code>webhookURL</code>. Then each session start and end goes to that URL, which you control, with the <a href="/docs/teams/webhook">payload described here</a>.</p>
        <h2>Never sent</h2>
        <p>The computer's own name, user names, IP or Wi-Fi details, which apps are running, files, keystrokes, or screen contents. Triggers that use those things are evaluated on the Mac; only their names are reported.</p>
        <h2>Kept for</h2>
        <p>Each Mac's latest status stays until you remove it or end your subscription. Session events are deleted after 30 days. The dashboard runs on Vercel with a Neon Postgres database in the US.</p>
        <h2>Turning it off</h2>
        <p>Deploy a profile without fleet reporting or the webhook, and Macs stop sending within a few seconds.</p>
""",
    },
]

LEGAL = []
