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

    enum ExitCode {
        static let usageError = 64
    }

    enum CLIError: Error, CustomStringConvertible {
        case missingInput
        case missingOutput
        case missingValue(flag: String)
        case unsupportedFormat(String)
        case unknownFlag(String)
        case unexpectedArgument(String)

        var description: String {
            switch self {
            case .missingInput:
                return "Missing input path. Provide a DocC bundle or archive to convert."
            case .missingOutput:
                return "Missing required --output <directory> option."
            case .missingValue(let flag):
                return "Flag \(flag) requires a value."
            case .unsupportedFormat(let value):
                return "Unsupported format '\(value)'. Supported formats: markdown."
            case .unknownFlag(let flag):
                return "Unknown flag '\(flag)'. Pass --help to see supported options."
            case .unexpectedArgument(let value):
                return "Unexpected argument '\(value)'. Provide only one input path."
            }
        }
    }

    struct CLIOptions {
        var inputPath: String?
        var outputPath: String?
        var forceOverwrite: Bool = false
        var format: String = "markdown"
    }

    public func run(arguments: [String]) -> Docc2contextCommandResult {
        let trimmedArguments = Array(arguments.dropFirst())
        if trimmedArguments.contains("--help") || trimmedArguments.contains("-h") {
            return Docc2contextCommandResult(exitCode: 0, output: Docc2contextHelp().render())
        }

        do {
            let options = try parse(trimmedArguments)
            let summary = "CLI not yet implemented. Input: \(options.inputPath!), output: \(options.outputPath!), " +
                "format: \(options.format), force: \(options.forceOverwrite ? "enabled" : "disabled")."
            return Docc2contextCommandResult(exitCode: 0, output: summary)
        } catch let error as CLIError {
            return Docc2contextCommandResult(exitCode: ExitCode.usageError, output: error.description)
        } catch {
            return Docc2contextCommandResult(exitCode: ExitCode.usageError, output: "Unable to parse arguments.")
        }
    }

    private func parse(_ arguments: [String]) throws -> CLIOptions {
        var options = CLIOptions()
        var index = 0
        while index < arguments.count {
            let token = arguments[index]
            switch token {
            case "--output":
                index += 1
                guard index < arguments.count else { throw CLIError.missingValue(flag: "--output") }
                options.outputPath = arguments[index]
            case "--format":
                index += 1
                guard index < arguments.count else { throw CLIError.missingValue(flag: "--format") }
                let value = arguments[index]
                guard value.lowercased() == "markdown" else { throw CLIError.unsupportedFormat(value) }
                options.format = value.lowercased()
            case "--force":
                options.forceOverwrite = true
            case "--help", "-h":
                // already handled earlier, ignore
                break
            default:
                if token.hasPrefix("-") {
                    throw CLIError.unknownFlag(token)
                }
                if options.inputPath == nil {
                    options.inputPath = token
                } else {
                    throw CLIError.unexpectedArgument(token)
                }
            }
            index += 1
        }

        guard options.inputPath?.isEmpty == false else {
            throw CLIError.missingInput
        }
        guard options.outputPath?.isEmpty == false else {
            throw CLIError.missingOutput
        }

        return options
    }
}

public struct Docc2contextHelp {
    public init() {}

    public func render() -> String {
        """
        docc2context – DocC to Markdown converter (bootstrap)

        Usage:
          docc2context <input-path> --output <directory> [--format markdown] [--force]

        Options:
          -h, --help         Show this help message and exit.
          --output <dir>     Required. Target directory that will contain Markdown + link graph outputs.
          --force            Overwrite the output directory if it already exists.
          --format <value>   Output format. Supported values: markdown (default).
        """
    }
}
