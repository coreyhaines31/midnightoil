import Foundation
import MidnightOilCore

/// Listens for the `midnightoil` command on a Unix socket in Application Support. Only
/// processes running as the signed-in user can connect, and each connection carries one
/// request and one response.
final class CLIServer: Sendable {
    private let handler: @MainActor @Sendable (CLIRequest) -> CLIResponse
    private let path = CLIProtocol.socketURL.path

    init(handler: @escaping @MainActor @Sendable (CLIRequest) -> CLIResponse) {
        self.handler = handler
    }

    func start() {
        try? FileManager.default.createDirectory(
            at: CLIProtocol.socketURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        // A socket left behind by a crash would block the bind.
        unlink(path)
        let listener = socket(AF_UNIX, SOCK_STREAM, 0)
        guard listener >= 0, var address = Self.address(path) else { return }
        let size = socklen_t(MemoryLayout<sockaddr_un>.size)
        let bound = withUnsafePointer(to: &address) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { bind(listener, $0, size) }
        }
        guard bound == 0, chmod(path, 0o600) == 0, listen(listener, 8) == 0 else {
            close(listener)
            return
        }
        let handler = handler
        Thread.detachNewThread {
            while true {
                let client = accept(listener, nil, nil)
                if client < 0 {
                    if errno == EINTR || errno == ECONNABORTED { continue }
                    return
                }
                DispatchQueue.global().async { Self.serve(client, handler: handler) }
            }
        }
    }

    func stop() {
        unlink(path)
    }

    static func address(_ path: String) -> sockaddr_un? {
        var address = sockaddr_un()
        address.sun_family = sa_family_t(AF_UNIX)
        let bytes = Array(path.utf8)
        guard bytes.count < MemoryLayout.size(ofValue: address.sun_path) else { return nil }
        withUnsafeMutableBytes(of: &address.sun_path) { $0.copyBytes(from: bytes) }
        return address
    }

    private static func serve(_ client: Int32, handler: @escaping @MainActor @Sendable (CLIRequest) -> CLIResponse) {
        var uid = uid_t()
        var gid = gid_t()
        guard getpeereid(client, &uid, &gid) == 0, uid == getuid() else {
            close(client)
            return
        }
        var timeout = timeval(tv_sec: 5, tv_usec: 0)
        setsockopt(client, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
        setsockopt(client, SOL_SOCKET, SO_NOSIGPIPE, [Int32(1)], socklen_t(MemoryLayout<Int32>.size))
        guard let data = readRequest(client),
              let request = try? CLIProtocol.decoder().decode(CLIRequest.self, from: data)
        else {
            reply(CLIResponse(error: "Midnight Oil didn't understand that request. Update the app and try again.",
                              status: .asleep), to: client)
            return
        }
        DispatchQueue.main.async {
            let response = MainActor.assumeIsolated { handler(request) }
            DispatchQueue.global().async { reply(response, to: client) }
        }
    }

    /// Reads until the command closes its side. Requests are tiny; anything over 64 KB is refused.
    private static func readRequest(_ client: Int32) -> Data? {
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 4_096)
        while data.count <= 65_536 {
            let received = read(client, &buffer, buffer.count)
            if received == 0 { return data }
            if received < 0 {
                if errno == EINTR { continue }
                return nil
            }
            data.append(buffer, count: received)
        }
        return nil
    }

    private static func reply(_ response: CLIResponse, to client: Int32) {
        if let data = try? CLIProtocol.encoder().encode(response) {
            data.withUnsafeBytes { raw in
                var offset = 0
                while offset < raw.count {
                    let written = write(client, raw.baseAddress! + offset, raw.count - offset)
                    if written <= 0 { break }
                    offset += written
                }
            }
        }
        close(client)
    }
}
