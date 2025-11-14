import Foundation

enum TestSupportPaths {
    private static let repoRootURL: URL = {
        var url = URL(fileURLWithPath: #filePath)
        while url.lastPathComponent != "Tests" {
            let parent = url.deletingLastPathComponent()
            if parent == url {
                fatalError("Unable to locate Tests directory from \(#filePath)")
            }
            url = parent
        }
        return url.deletingLastPathComponent()
    }()

    static let fixturesDirectory: URL = repoRootURL.appendingPathComponent("Fixtures", isDirectory: true)
    static let snapshotsDirectory: URL = repoRootURL
        .appendingPathComponent("Tests", isDirectory: true)
        .appendingPathComponent("__Snapshots__", isDirectory: true)
}
