import Foundation

public enum VersionResolver {
    public static var docc2contextVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0-dev"
    }
}
