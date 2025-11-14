import ArgumentParser
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
            let parsedArguments = try Docc2contextCLIOptions.parse(trimmedArguments)
            let options = try resolveOptions(from: parsedArguments)
            let forceLabel = options.forceOverwrite ? "enabled" : "disabled"
            let summary = "CLI not yet implemented. Input: \(options.inputPath!), output: \(options.outputPath!), " +
                "format: \(options.format), force: \(forceLabel)."
            return Docc2contextCommandResult(exitCode: 0, output: summary)
        } catch let error as CLIError {
            return Docc2contextCommandResult(exitCode: ExitCode.usageError, output: error.description)
        } catch let error as ValidationError {
            return Docc2contextCommandResult(exitCode: ExitCode.usageError, output: error.description)
        } catch {
            if let localizedError = error as? LocalizedError, let description = localizedError.errorDescription {
                return Docc2contextCommandResult(exitCode: ExitCode.usageError, output: description)
            }
            let fallbackDescription = String(describing: error)
            return Docc2contextCommandResult(exitCode: ExitCode.usageError, output: fallbackDescription)
        }
    }

    private func resolveOptions(from parsedArguments: Docc2contextCLIOptions) throws -> CLIOptions {
        var options = CLIOptions()
        guard let input = parsedArguments.inputPath?.trimmingCharacters(in: .whitespacesAndNewlines), !input.isEmpty else {
            throw CLIError.missingInput
        }
        guard let output = parsedArguments.outputPath?.trimmingCharacters(in: .whitespacesAndNewlines), !output.isEmpty else {
            throw CLIError.missingOutput
        }

        let normalizedFormat = parsedArguments.format.lowercased()
        guard normalizedFormat == "markdown" else {
            throw CLIError.unsupportedFormat(parsedArguments.format)
        }

        options.inputPath = input
        options.outputPath = output
        options.forceOverwrite = parsedArguments.force
        options.format = normalizedFormat
        return options
    }
}

struct Docc2contextCLIOptions: ParsableArguments {
    @Argument(help: "DocC bundle or archive to convert.")
    var inputPath: String?

    @Option(name: .customLong("output"), help: "Target directory that will contain Markdown + link graph outputs.")
    var outputPath: String?

    @Flag(name: .long, help: "Overwrite the output directory if it already exists.")
    var force: Bool = false

    @Option(name: .customLong("format"), help: "Output format. Supported values: markdown (default).")
    var format: String = "markdown"
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
