import IOKit.ps
import MidnightOilCore

enum PowerSourceReader {
    static func current() -> PowerState {
        guard let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue() else {
            return PowerState(batteryPercent: nil, isOnBattery: false)
        }
        let providingType = IOPSGetProvidingPowerSourceType(info)?.takeUnretainedValue() as String?
        let isOnBattery = providingType == kIOPSBatteryPowerValue

        let sources = IOPSCopyPowerSourcesList(info)?.takeRetainedValue() as? [CFTypeRef] ?? []
        for source in sources {
            guard let description = IOPSGetPowerSourceDescription(info, source)?
                    .takeUnretainedValue() as? [String: Any],
                  description[kIOPSTypeKey] as? String == kIOPSInternalBatteryType,
                  let current = description[kIOPSCurrentCapacityKey] as? Int,
                  let max = description[kIOPSMaxCapacityKey] as? Int,
                  max > 0
            else { continue }
            return PowerState(batteryPercent: current * 100 / max, isOnBattery: isOnBattery)
        }
        return PowerState(batteryPercent: nil, isOnBattery: isOnBattery)
    }
}
