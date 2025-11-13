import Foundation

public struct Docc2contextCommandResult {
    public let exitCode: Int
    public let output: String

    public init(exitCode: Int, output: String) {
        self.exitCode = exitCode
        self.output = output
    }
}

public struct Docc2contextCommand {
    public init() {}

    public func run(arguments: [String]) -> Docc2contextCommandResult {
        let trimmedArguments = Array(arguments.dropFirst())
        let shouldShowHelp = trimmedArguments.contains("--help") || trimmedArguments.contains("-h")

        if shouldShowHelp {
            return Docc2contextCommandResult(exitCode: 0, output: Docc2contextHelp().render())
        }

        return Docc2contextCommandResult(
            exitCode: 0,
            output: "docc2context CLI bootstrap is ready. Pass --help to view available options."
        )
    }
}

public struct Docc2contextHelp {
    public init() {}

    public func render() -> String {
        """
        docc2context – DocC to Markdown converter (bootstrap)

        Usage:
          docc2context [--help]

        Options:
          -h, --help    Show this help message and exit.
        """
    }
}
