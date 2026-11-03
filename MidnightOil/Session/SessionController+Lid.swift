import Foundation
import MidnightOilCore

extension SessionController {
    func handleLidChange(for session: Session) {
        guard session.staysAwakeWithLidClosed else {
            lastLidClosed = nil
            lastUnattended = nil
            return
        }
        let isClosed = LidState.isClosed() ?? false
        defer { lastLidClosed = isClosed }
        let isOnBattery = lastPower?.isOnBattery ?? false
        if Preferences.soundsLidAlarm,
           LidAlarm.shouldSound(wasClosed: lastLidClosed, isClosed: isClosed, isOnBattery: isOnBattery) {
            SystemSounds.play(Preferences.lidAlarmSound)
        }
        lockIfUnattended(isClosed: isClosed)
    }

    private func lockIfUnattended(isClosed: Bool) {
        guard Preferences.locksOnLidClose else {
            lastUnattended = nil
            return
        }
        // An open lid already rules it out, so skip the display lookup.
        let isUnattended = isClosed && LidLock.isUnattended(
            isClosed: isClosed,
            hasExternalDisplay: ScreenLocker.hasExternalDisplay()
        )
        defer { lastUnattended = isUnattended }
        if LidLock.shouldLock(wasUnattended: lastUnattended, isUnattended: isUnattended) {
            ScreenLocker.lock()
        }
    }

    func pauseLidModeIfHot(for session: Session) {
        let shouldPause = session.staysAwakeWithLidClosed
            && Preferences.pausesLidModeWhenHot
            && ThermalGuard.shouldPause(
                wasPaused: isLidModePausedForHeat,
                level: ThermalLevel(ProcessInfo.processInfo.thermalState),
                isLidClosed: LidState.isClosed() ?? false
            )
        guard shouldPause != isLidModePausedForHeat else { return }
        isLidModePausedForHeat = shouldPause
        syncLidClosedMode()
        if shouldPause { SessionNotifier.lidModePausedForHeat() }
    }
}

extension SessionController {
    /// Sleep left off is the failure that matters, so keep asking until it's back on. Stops as
    /// soon as closed-lid mode is wanted again, since that request takes the helper's hold anyway.
    func retryRestoringSleep() {
        Task {
            try? await Task.sleep(for: .seconds(5))
            guard !lidModeRequested else { return }
            if !(await helper.setSleepDisabled(false)), !lidModeRequested {
                retryRestoringSleep()
            }
        }
    }
}
