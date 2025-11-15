import Foundation

enum SnapshotRecording {
    static var isEnabled: Bool {
        ProcessInfo.processInfo.environment["SNAPSHOT_RECORD"] == "1"
    }
}
