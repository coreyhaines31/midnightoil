import Foundation

let sleepController = SleepController()
sleepController.restoreIfLeftDisabled()

let service = HelperService(sleep: sleepController)
let listener = NSXPCListener(machServiceName: HelperConstants.machServiceName)
listener.delegate = service
listener.resume()

dispatchMain()
