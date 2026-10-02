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

DOCS = []

LEGAL = []
