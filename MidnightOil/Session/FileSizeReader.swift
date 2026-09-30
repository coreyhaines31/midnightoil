import Foundation

enum FileSizeReader {
    /// Size in bytes, summing contents for packages like Safari's `.download`.
    /// Nil if nothing exists at the URL.
    static func size(of url: URL) -> Int64? {
        let keys: Set<URLResourceKey> = [.isDirectoryKey, .totalFileAllocatedSizeKey, .fileSizeKey]
        guard let values = try? url.resourceValues(forKeys: keys) else { return nil }
        guard values.isDirectory == true else {
            return Int64(values.totalFileAllocatedSize ?? values.fileSize ?? 0)
        }

        var total: Int64 = 0
        let contents = FileManager.default.enumerator(at: url, includingPropertiesForKeys: Array(keys))
        while let file = contents?.nextObject() as? URL {
            let fileValues = try? file.resourceValues(forKeys: keys)
            total += Int64(fileValues?.totalFileAllocatedSize ?? fileValues?.fileSize ?? 0)
        }
        return total
    }
}
