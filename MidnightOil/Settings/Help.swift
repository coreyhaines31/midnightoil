// Every explanation the app shows in one place: pane intros, info popovers,
// hover tooltips, and menu item tooltips. Keep each one true to what the code
// does, short enough to read at a glance, and free of jargon.
// Copy reads best unwrapped, and one case per condition type is clearer than any split.
// swiftlint:disable line_length cyclomatic_complexity

enum Help {
    struct Intro {
        let symbol: String
        let text: String
    }

    // MARK: - Pane intros

    enum Pane {
        static let general = Intro(
            symbol: "gearshape",
            text: "How Midnight Oil starts up and stays up to date."
        )
        static let sessions = Intro(
            symbol: "timer",
            text: """
                Defaults for every session you start from the menu. You can still change these for a \
                single session from the menu while it runs.
                """
        )
        static let schedules = Intro(
            symbol: "calendar.badge.clock",
            text: """
                Keep your Mac awake at the same times every week, like work hours or overnight. A \
                schedule starts a session when its window opens and ends it when the window closes. A \
                session you start yourself always takes priority.
                """
        )
        static let triggers = Intro(
            symbol: "bolt",
            text: """
                Triggers keep your Mac awake on their own while their conditions hold, like “docked to a \
                display and on power”, and stop when they don't. A session you start yourself always \
                takes priority.
                """
        )
        static let closedLid = Intro(
            symbol: "laptopcomputer",
            text: """
                Normally a MacBook sleeps the moment you close the lid, even if an app is keeping it \
                awake. Closed-lid mode switches that off for the length of a session, so an agent or a \
                build keeps running in your bag.
                """
        )
        static let driveAlive = Intro(
            symbol: "externaldrive",
            text: """
                Some external hard drives spin down after a few idle minutes, which can pause a backup, \
                a render, or an agent writing to that drive. Drive Alive touches each drive you pick \
                every few seconds so it stays spun up.
                """
        )
        static let hotKeys = Intro(
            symbol: "keyboard",
            text: "Keyboard shortcuts that work from any app, so you can start or end a session without opening the menu."
        )
        static let notifications = Intro(
            symbol: "bell",
            text: "What Midnight Oil tells you, and what it sounds like. Your Mac's Focus settings still apply."
        )
        static let appearance = Intro(
            symbol: "paintbrush",
            text: "How Midnight Oil looks in your menu bar."
        )
        static let statistics = Intro(
            symbol: "chart.bar",
            text: "What your Mac did while Midnight Oil kept it awake. All of this stays on your Mac."
        )
    }

    // MARK: - General

    static let launchAtLogin = """
        Opens Midnight Oil in the menu bar when you log in. It doesn't start a session by itself; \
        turn on the next option for that.
        """
    static let startAtLaunch = """
        Starts a session every time Midnight Oil opens, and keeps it running until you end it. Combined \
        with Launch at login, your Mac stays awake from the moment you log in.
        """
    static let automaticUpdates = """
        Checks for a new version about once a day. Updates download in the background and install the \
        next time Midnight Oil quits. This is the only network request Midnight Oil makes.
        """
    static let checkNow = "Look for a new version right now."

    // MARK: - Sessions

    static let allowDisplaySleep = """
        Keeps the Mac running but lets the screen turn off on its usual schedule. Good for overnight \
        runs: the work continues without the screen lit all night. Turn it off for presentations or \
        anything you're watching.
        """
    static let endWhenUnplugged = """
        Ends a session the moment you disconnect power, so a laptop doesn't keep running on battery \
        after you pack it up.
        """
    static let endOnLowBattery = """
        Ends a session when the battery falls below this level while running on battery. A Mac that's \
        plugged in is never cut off.
        """
    static let batteryLevel = "The battery level that ends a session."

    // MARK: - Schedules

    static let scheduleSwitch = "Turn this schedule on or off."
    static let editSchedule = "Change this schedule's name, days, hours, or session options."
    static let removeSchedule = "Delete this schedule."
    static let addSchedule = "Create a schedule with its own days and hours."
    static let addWorkHours = """
        Keeps your Mac awake Monday to Friday, 9 AM to 5 PM. Change the days and hours anytime.
        """
    static let addOvernight = """
        Keeps your Mac awake every night from 11 PM to 7 AM, with the screen allowed to sleep. Good for \
        agents that run while you sleep.
        """
    static let scheduleWhen = """
        The days and hours this schedule keeps your Mac awake. If the end time is earlier than the start, \
        the window runs past midnight and ends the next morning.
        """
    static let scheduleSessionOptions = "How the session behaves while this schedule is running it."
    static let scheduleSkip = """
        Ending a schedule's session skips the rest of that window. The schedule starts again at its next \
        window, or when Midnight Oil next opens during one.
        """

    // MARK: - Triggers

    static let enableTriggers = "Pause every trigger at once without deleting any. Turn back on to resume."
    static let triggerSwitch = "Turn this trigger on or off."
    static let editTrigger = "Change this trigger's name, conditions, or session options."
    static let removeTrigger = "Delete this trigger."
    static let addTrigger = "Create a trigger from one or more conditions."
    static let addExampleTrigger = """
        Adds a trigger that keeps your Mac awake whenever it's plugged in and connected to an external \
        display. Edit or remove it anytime.
        """
    static let triggerConditions = """
        The trigger runs a session while every condition here is true, and ends it as soon as one isn't.
        """
    static let removeCondition = "Remove this condition."
    static let triggerSessionOptions = "How the session behaves while this trigger is running it."

    static func condition(_ kind: CriterionKind) -> String {
        switch kind {
        case .wifiNetwork:
            """
            True while connected to any of these Wi-Fi networks. Separate names with commas. macOS asks \
            for Location access the first time, because it treats the network name as location data.
            """
        case .usbDevice:
            "True while any of these USB devices is plugged in, matched by product name. Use + to pick one that's connected."
        case .bluetoothDevice:
            "True while any of these paired Bluetooth devices is connected. Use + to pick from your paired devices."
        case .externalDisplay:
            "True while a display other than the built-in screen is connected, or while none is."
        case .powerSource:
            "True while the Mac is running on the power adapter, or on battery."
        case .batteryLevel:
            "True while the battery is at least, or at most, this level. Never true on Macs without a battery."
        case .appRunning:
            """
            True while any of these apps is open. Apps are identified by bundle ID, like \
            com.apple.Terminal. Use + to pick one that's running.
            """
        case .appFrontmost:
            "True while one of these apps is the one in front. Use + to pick one that's running."
        case .ipAddress:
            """
            True while any of this Mac's network addresses starts with one of these, like 10.0. for an \
            office network. Use + to see this Mac's current addresses.
            """
        case .schedule:
            """
            True on the selected days between these two times. If the end time is earlier than the \
            start, the window runs past midnight.
            """
        case .idle:
            """
            “Active within” is true while you've used the keyboard or mouse recently. “Idle for at \
            least” becomes true once you've been away that long.
            """
        }
    }

    // MARK: - Closed lid

    static let helper = """
        A small helper that turns lid sleep off during a closed-lid session and back on afterward, using \
        Apple's own pmset tool. It only accepts requests from Midnight Oil, and restores normal sleep \
        if Midnight Oil quits or crashes. macOS asks you to approve it once in System Settings › Login Items.
        """
    static let installHelper = "Install the helper. macOS then asks you to approve it in System Settings."
    static let approveHelper = "Open System Settings › Login Items and switch on Midnight Oil."
    static let removeHelper = "Uninstall the helper. Closed-lid mode stops working until you install it again."
    static let lidDefault = """
        New sessions start with closed-lid mode on. You can still switch it for a single session from \
        the menu. Needs the helper.
        """
    static let lidAlarm = """
        Plays a sound when you close the lid on battery during a closed-lid session, so you know the \
        Mac is still running before it goes in a bag.
        """
    static let lidDisplayNote = """
        Plugged in with an external display, macOS already keeps a closed MacBook awake, so you don't \
        need the helper for that setup.
        """

    // MARK: - Drive Alive

    static let enableDriveAlive = "Turn Drive Alive on for the drives you pick below."
    static let driveInterval = """
        How often each chosen drive is touched. Drives usually spin down after several idle minutes, \
        so every 10 seconds is plenty.
        """
    static let driveWhen = """
        During sessions: only while Midnight Oil is keeping your Mac awake. Always: whenever Midnight \
        Oil is open, even with no session running.
        """
    static let drivePick = "Keep this drive spun up."
    static let internalDrive = "Internal drive. SSDs don't spin down, so this one doesn't need Drive Alive."
    static let refreshDrives = "Look again for connected drives."

    // MARK: - Hot keys

    static let toggleHotKey = "Starts a session that runs until you end it, or ends the one that's running."
    static let endHotKey = "Ends the running session. Does nothing if none is running."
    static let settingsHotKey = "Opens this window."
    static let hotKeysFooter = "Click a field, then press the keys you want. Click the × to clear a shortcut."

    // MARK: - Notifications

    static let notifyEnd = """
        When time runs out, the app a session was following quits, a download finishes, or a battery \
        rule ends it. Not when you end it yourself. If you were away, the notification includes a \
        short recap.
        """
    static let notifyTriggerStart = "A notice each time a trigger starts a session, so a Mac staying awake is never a surprise."
    static let notificationSound = "The sound that plays with Midnight Oil's notifications."
    static let lidAlarmSound = "The sound that plays when you close the lid on battery during a closed-lid session."
    static let playSound = "Play this sound."

    // MARK: - Appearance

    static let menuBarIcon = "The flame is an outline when your Mac can sleep, and filled in while a session keeps it awake."
    static let showRemaining = "Shows the time left next to the icon during timed sessions, like “1h 20m”."
    static let customImages = "Pick one image for when your Mac can sleep and one for while a session runs."
    static let templates = """
        Templates are recolored to match the menu bar in light and dark mode, so use black shapes on a \
        transparent background. Turn this off to keep full-color images as they are.
        """

    // MARK: - Statistics

    static let away = """
        You count as away after 5 minutes without touching the keyboard or mouse, and those 5 minutes \
        count too. Time your Mac spent asleep never counts.
        """
    static let chart = "Each day's awake time, split into time you were away and time you were at the Mac."
    static let tileSessions = "Sessions recorded on this Mac."
    static let tileAwayAllTime = "All the time your Mac kept working while you were away."
    static let tileLongest = "The longest single session."
    static let tileLidClosed = "Total time a session kept your Mac working with the lid shut."
    static let exportCSV = "Save every recorded session as a spreadsheet file."
    static let clearHistory = "Delete every recorded session from this Mac."
    static let clearHistoryConfirm = "Every recorded session on this Mac is deleted. This can't be undone. Export a CSV first to keep a copy."

    // MARK: - Menu tooltips

    enum Menu {
        static let indefinitely = "Stay awake until you end the session."
        static let forDuration = "Stay awake for a set time, then sleep normally."
        static let until = "Stay awake until a time of day, like 7 AM."
        static let otherTime = "Pick any date and time."
        static let whileApp = "Stay awake until the app you pick quits. Pick the one running your agent."
        static let whileDownloading = "Stay awake until a download finishes. You'll pick the file that's downloading."
        static let extend = "Add time without restarting the session."
        static let end = "Let your Mac sleep normally again."
        static let skipSchedule = "End this session and skip the rest of this window. The schedule starts again next time."
        static let nextSchedule = "The next time one of your schedules keeps your Mac awake."
        static let settings = "Triggers, closed-lid mode, Drive Alive, statistics, and more."
        static let checkForUpdates = "New versions download in the background and install when Midnight Oil quits."
        static let allowDisplaySleep = allowDisplaySleepShort
        static let staysAwakeWithLidClosed = "Keep working with the lid shut. Needs the closed-lid helper."
        static let allowDisplaySleepShort = "Let the screen turn off while your Mac keeps working."
    }
}

// swiftlint:enable line_length cyclomatic_complexity
