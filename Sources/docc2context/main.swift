import Foundation
import docc2contextCore

@main
struct docc2contextCLI {
    static func main() throws {
        let arguments = CommandLine.arguments.dropFirst()
        if arguments.contains("--help") || arguments.contains("-h") {
            print(HelpText.message)
            return
        }

        let version = VersionResolver.docc2contextVersion
        print("docc2context (bootstrap) – version \(version)")
        print("Run with --help for usage information.")
    }
}

private enum HelpText {
    static let message = """
    docc2context – DocC to Markdown Converter (bootstrap)

    This placeholder executable only verifies SwiftPM wiring.
    Future tasks will implement real conversion features.
    """
}
