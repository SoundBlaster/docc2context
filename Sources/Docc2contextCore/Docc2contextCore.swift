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

/// Programmatic entry point for running the `docc2context` CLI.
///
/// This type is primarily used by the executable target, but is also convenient for tests and for embedding
/// `docc2context` behavior into other tooling (e.g. a custom release pipeline).
///
/// The command is intentionally deterministic and offline-friendly: it converts DocC bundle directories or
/// `.doccarchive` directories into Markdown outputs under `--output`.
///
/// ## Usage
/// ```swift
/// let result = Docc2contextCommand().run(arguments: [
///   "docc2context",
///   "/path/to/MyDocs.doccarchive",
///   "--output", "/tmp/out",
///   "--force",
///   "--symbol-layout", "single",
/// ])
/// print(result.exitCode)
/// print(result.output)
/// ```
public struct Docc2contextCommand {
    private let inputDetector: InputLocationDetector
    private let pipeline: MarkdownGenerationPipeline

    public init(
        inputDetector: InputLocationDetector = .init(),
        pipeline: MarkdownGenerationPipeline = .init()
    ) {
        self.inputDetector = inputDetector
        self.pipeline = pipeline
    }

    enum ExitCode {
        static let usageError = 64
    }

    enum CLIError: Error, CustomStringConvertible {
        case missingInput
        case missingOutput
        case missingValue(flag: String)
        case unsupportedFormat(String)
        case unsupportedSymbolLayout(String)
        case unsupportedTutorialLayout(String)
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
            case .unsupportedSymbolLayout(let value):
                return "Unsupported symbol layout '\(value)'. Supported values: tree, single."
            case .unsupportedTutorialLayout(let value):
                return "Unsupported tutorial layout '\(value)'. Supported values: chapter, single."
            case .unknownFlag(let flag):
                return "Unknown flag '\(flag)'. Pass --help to see supported options."
            case .unexpectedArgument(let value):
                return "Unexpected argument '\(value)'. Provide only one input path."
            }
        }
    }

    struct CLIOptions {
        let inputPath: String
        let outputPath: String
        let forceOverwrite: Bool
        let format: String
        let technologyFilter: [String]?
        let symbolLayout: MarkdownGenerationPipeline.SymbolLayout
        let tutorialLayout: MarkdownGenerationPipeline.TutorialLayout
    }

    public func run(arguments: [String]) -> Docc2contextCommandResult {
        let trimmedArguments = Array(arguments.dropFirst())
        if trimmedArguments.contains("--help") || trimmedArguments.contains("-h") {
            return Docc2contextCommandResult(exitCode: 0, output: Docc2contextHelp().render())
        }

        do {
            let parsedArguments = try Docc2contextCLIOptions.parse(trimmedArguments)
            let options = try resolveOptions(from: parsedArguments)
            let inputLocation = try inputDetector.detect(inputPath: options.inputPath)
            let inputURL = try inputDetector.resolvedBundleURL(from: inputLocation)
            let summary = try pipeline.generateMarkdown(
                from: inputURL.path,
                to: options.outputPath,
                forceOverwrite: options.forceOverwrite,
                technologyFilter: options.technologyFilter,
                symbolLayout: options.symbolLayout,
                tutorialLayout: options.tutorialLayout)
            let formattedSummary = "Generated \(summary.tutorialVolumeCount) tutorial volume(s), " +
                "\(summary.chapterCount) chapter(s), \(summary.referenceArticleCount) reference article(s), " +
                "and \(summary.symbolCount) symbol(s) into \(summary.outputDirectory.path)."
            return Docc2contextCommandResult(exitCode: 0, output: formattedSummary)
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

        let normalizedSymbolLayout = parsedArguments.symbolLayout.lowercased()
        guard let symbolLayout = MarkdownGenerationPipeline.SymbolLayout(rawValue: normalizedSymbolLayout) else {
            throw CLIError.unsupportedSymbolLayout(parsedArguments.symbolLayout)
        }

        let normalizedTutorialLayout = parsedArguments.tutorialLayout.lowercased()
        guard let tutorialLayout = MarkdownGenerationPipeline.TutorialLayout(rawValue: normalizedTutorialLayout) else {
            throw CLIError.unsupportedTutorialLayout(parsedArguments.tutorialLayout)
        }

        return CLIOptions(
            inputPath: input,
            outputPath: output,
            forceOverwrite: parsedArguments.force,
            format: normalizedFormat,
            technologyFilter: parsedArguments.technology,
            symbolLayout: symbolLayout,
            tutorialLayout: tutorialLayout)
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

    @Option(name: .customLong("technology"), help: "Filter symbols by technology/module name. Can be specified multiple times.")
    var technology: [String] = []

    @Option(
        name: .customLong("symbol-layout"),
        help: "Symbol page output layout. Supported values: tree (default), single."
    )
    var symbolLayout: String = "tree"

    @Option(
        name: .customLong("tutorial-layout"),
        help: "Tutorial output layout. Supported values: chapter (default), single."
    )
    var tutorialLayout: String = "chapter"
}

public struct Docc2contextHelp {
    public init() {}

    public func render() -> String {
        """
        docc2context – DocC to Markdown converter (bootstrap)

        Usage:
          docc2context <input-path> --output <directory> [--format markdown] [--force] [--technology <name>] [--symbol-layout tree|single] [--tutorial-layout chapter|single]

        Options:
          -h, --help                Show this help message and exit.
          --output <dir>            Required. Target directory that will contain Markdown + link graph outputs.
          --force                   Overwrite the output directory if it already exists.
          --format <value>          Output format. Supported values: markdown (default).
          --technology <name>       Filter symbols by technology/module name. Can be specified multiple times.
          --symbol-layout <value>   Symbol page output layout. Supported values: tree (default), single.
          --tutorial-layout <value> Tutorial output layout. Supported values: chapter (default), single.
        """
    }
}
