import Foundation
import MidnightOilCore

let usage = """
midnightoil: keep your Mac awake from the terminal, with Midnight Oil's closed-lid mode and battery safety.

Usage:
  midnightoil start [--for 2h | --until 6am | --while-pid PID] [options]
  midnightoil run [options] [--] <command> [arguments...]
  midnightoil stop
  midnightoil status [--json]

Commands:
  start     Keep the Mac awake until you stop it, or for a time with --for or --until.
  run       Run a command and keep the Mac awake until it finishes. Runs started
            in parallel share one session that lasts until the last one finishes.
  stop      End the current session.
  status    Show whether the Mac is being kept awake, and until when.

Options:
  --for DURATION         Like 90m, 2h, or 1h30m.
  --until TIME           Like 6am, 6:30pm, or 18:30.
  --while-pid PID        Stay awake while another process runs.
  --lid-closed           Keep running with the lid closed (set up once in Settings › Closed Lid).
  --allow-display-sleep  Let the screen turn off while the Mac keeps working.
  --json                 Print the session as JSON.

Options you leave out follow your defaults in Midnight Oil's Settings.

Examples:
  midnightoil start --for 8h --lid-closed
  midnightoil run --lid-closed -- claude -p "fix the failing tests"
"""

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data("midnightoil: \(message)\n".utf8))
    exit(1)
}

func note(_ message: String) {
    FileHandle.standardError.write(Data("\(message)\n".utf8))
}

/// Sends one request and reads the reply. Nil if the app isn't listening.
func send(_ request: CLIRequest) -> CLIResponse? {
    let socket = Darwin.socket(AF_UNIX, SOCK_STREAM, 0)
    guard socket >= 0 else { return nil }
    defer { close(socket) }
    setsockopt(socket, SOL_SOCKET, SO_NOSIGPIPE, [Int32(1)], socklen_t(MemoryLayout<Int32>.size))
    // Never let a stuck app hold up the command, or a run that's already started.
    var timeout = timeval(tv_sec: 10, tv_usec: 0)
    setsockopt(socket, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
    setsockopt(socket, SOL_SOCKET, SO_SNDTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
    guard var address = socketAddress() else { fail("The path to Midnight Oil's socket is too long.") }
    let size = socklen_t(MemoryLayout<sockaddr_un>.size)
    let connected = withUnsafePointer(to: &address) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { connect(socket, $0, size) }
    }
    guard connected == 0, let body = try? CLIProtocol.encoder().encode(request) else { return nil }
    let sent = body.withUnsafeBytes { write(socket, $0.baseAddress, $0.count) }
    guard sent == body.count else { return nil }
    shutdown(socket, SHUT_WR)
    var reply = Data()
    var buffer = [UInt8](repeating: 0, count: 4_096)
    while true {
        let received = read(socket, &buffer, buffer.count)
        if received < 0, errno == EINTR { continue }
        if received <= 0 { break }
        reply.append(buffer, count: received)
    }
    return try? CLIProtocol.decoder().decode(CLIResponse.self, from: reply)
}

func socketAddress() -> sockaddr_un? {
    var address = sockaddr_un()
    address.sun_family = sa_family_t(AF_UNIX)
    let bytes = Array(CLIProtocol.socketURL.path.utf8)
    guard bytes.count < MemoryLayout.size(ofValue: address.sun_path) else { return nil }
    withUnsafeMutableBytes(of: &address.sun_path) { $0.copyBytes(from: bytes) }
    return address
}

/// The app this command ships inside, or nil when it was built on its own.
func enclosingApp() -> URL? {
    // argv[0] is just "midnightoil" when found on the PATH, so ask for the real path.
    guard let executable = Bundle.main.executableURL?.resolvingSymlinksInPath() else { return nil }
    let app = executable.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    return app.pathExtension == "app" ? app : nil
}

/// Opens Midnight Oil in the background if needed, then sends the request.
func sendLaunchingApp(_ request: CLIRequest) -> CLIResponse {
    if let response = send(request) { return response }
    let open = Process()
    open.executableURL = URL(filePath: "/usr/bin/open")
    open.arguments = enclosingApp().map { ["-g", $0.path] } ?? ["-g", "-b", CLIProtocol.bundleIdentifier]
    open.standardError = FileHandle.nullDevice
    do {
        try open.run()
        open.waitUntilExit()
    } catch {
        fail("Couldn't open Midnight Oil: \(error.localizedDescription)")
    }
    guard open.terminationStatus == 0 else {
        fail("Couldn't find Midnight Oil. Install it with: brew install --cask coreyhaines31/tap/midnightoil")
    }
    for _ in 0..<50 {
        Thread.sleep(forTimeInterval: 0.2)
        if let response = send(request) { return response }
    }
    fail("Midnight Oil opened but didn't answer. Check that it's running in the menu bar.")
}

func describe(_ status: CLIStatus) -> String {
    guard status.awake else { return "Not keeping your Mac awake." }
    var lines = ["Keeping your Mac awake: \(status.detail ?? "until you end it")"]
    if let startedBy = status.startedBy, startedBy != "you" { lines.append("Started by \(startedBy)") }
    var options: [String] = []
    if status.staysAwakeWithLidClosed { options.append("stays awake with the lid closed") }
    if status.allowsDisplaySleep { options.append("the screen can turn off") }
    if !options.isEmpty { lines.append(options.joined(separator: ", ").prefixUppercased) }
    return lines.joined(separator: "\n")
}

extension String {
    var prefixUppercased: String { prefix(1).uppercased() + dropFirst() }
}

func json(_ status: CLIStatus) -> String {
    let encoder = CLIProtocol.encoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return (try? encoder.encode(status)).map { String(decoding: $0, as: UTF8.self) } ?? "{}"
}

/// Prints the outcome. Returns false for an error. `run` reports on stderr, so the
/// command's own output can still be piped.
@discardableResult
func report(_ response: CLIResponse, json asJSON: Bool, action: CLIRequest.Action, toStderr: Bool = false) -> Bool {
    func output(_ text: String) {
        if toStderr { note(text) } else { print(text) }
    }
    if let error = response.error {
        FileHandle.standardError.write(Data("midnightoil: \(error)\n".utf8))
        return false
    }
    response.notes.forEach(note)
    if asJSON {
        output(json(response.status))
    } else if action == .stop {
        if !response.status.awake, response.notes.isEmpty { output("Stopped. Your Mac can sleep normally again.") }
    } else {
        output(describe(response.status))
    }
    return true
}

/// Runs the command with the terminal's input and output, and exits with its status.
func run(_ command: [String], request: CLIRequest, json: Bool) -> Never {
    // Make sure the app is up before the work starts, so the session covers all of it.
    let ready = sendLaunchingApp(CLIRequest(action: .status))
    if let error = ready.error { fail(error) }

    var pid = pid_t()
    let arguments = command.map { strdup($0) } + [nil]
    defer { arguments.forEach { free($0) } }
    let spawned = posix_spawnp(&pid, command[0], nil, nil, arguments, environ)
    guard spawned == 0 else { fail("Couldn't run \(command[0]): \(String(cString: strerror(spawned)))") }

    // Ctrl-C reaches the command directly; stay alive to report how it ended.
    signal(SIGINT, SIG_IGN)
    signal(SIGQUIT, SIG_IGN)
    var forwarders: [DispatchSourceSignal] = []
    for forwarded in [SIGTERM, SIGHUP] {
        signal(forwarded, SIG_IGN)
        let source = DispatchSource.makeSignalSource(signal: forwarded, queue: .global())
        source.setEventHandler { kill(pid, forwarded) }
        source.resume()
        forwarders.append(source)
    }

    var started = request
    started.pid = pid
    started.processName = URL(filePath: command[0]).lastPathComponent
    if let response = send(started) {
        if !report(response, json: json, action: .start, toStderr: true) {
            note("Running anyway, without keeping your Mac awake.")
        }
    } else {
        note("midnightoil: Couldn't reach Midnight Oil. Running anyway, without keeping your Mac awake.")
    }

    var status: Int32 = 0
    while waitpid(pid, &status, 0) < 0 {
        if errno != EINTR { exit(1) }
    }
    let signalNumber = status & 0x7f
    exit(signalNumber == 0 ? (status >> 8) & 0xff : 128 + signalNumber)
}

let command: CLICommand
do {
    command = try CLIArguments.parse(Array(CommandLine.arguments.dropFirst()))
} catch {
    fail("\(error.message)\nRun midnightoil --help for usage.")
}

switch command {
case .help:
    print(usage)
case .version:
    print(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown")
case .run(let request, let arguments, let json):
    run(arguments, request: request, json: json)
case .send(let request, let json):
    let response: CLIResponse
    if request.action == .start {
        response = sendLaunchingApp(request)
    } else if let answer = send(request) {
        response = answer
    } else {
        // The app isn't running, so nothing is keeping the Mac awake.
        response = CLIResponse(
            notes: request.action == .stop ? ["Nothing to stop: Midnight Oil isn't running."] : [],
            status: .asleep
        )
    }
    if !report(response, json: json, action: request.action) { exit(1) }
}
