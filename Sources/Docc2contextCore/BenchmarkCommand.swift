import ArgumentParser
import Foundation

public struct BenchmarkCommandResult {
    public let exitCode: Int
    public let output: String

    public init(exitCode: Int, output: String) {
        self.exitCode = exitCode
        self.output = output
    }
}

public protocol BenchmarkRunning {
    func run(configuration: PerformanceBenchmarkHarness.Configuration) throws -> PerformanceBenchmarkHarness.Result
}

extension PerformanceBenchmarkHarness: BenchmarkRunning {}

public struct BenchmarkCommand {
    private let harness: BenchmarkRunning
    private let fixtureBuilder: BenchmarkFixtureBuilder
    private let comparator: BenchmarkComparator
    private let fileManager: FileManager

    public init(
        harness: BenchmarkRunning = PerformanceBenchmarkHarness(),
        fixtureBuilder: BenchmarkFixtureBuilder = .init(),
        comparator: BenchmarkComparator = .init(),
        fileManager: FileManager = .default
    ) {
        self.harness = harness
        self.fixtureBuilder = fixtureBuilder
        self.comparator = comparator
        self.fileManager = fileManager
    }

    enum CLIError: Error, CustomStringConvertible {
        case missingFixture
        case iterationsMustBePositive
        case thresholdMustBePositive
        case baselineMissing(String)
        case invalidBaseline(String)
        case toleranceMustBePositive

        var description: String {
            switch self {
            case .missingFixture:
                return "Fixture not found. Provide --fixture <path> or run from the repository root where Fixtures/ArticleReference.doccarchive exists."
            case .iterationsMustBePositive:
                return "Iterations must be greater than zero."
            case .thresholdMustBePositive:
                return "Threshold seconds must be greater than zero."
            case .baselineMissing(let path):
                return "Baseline file not found at \(path)."
            case .invalidBaseline(let reason):
                return "Baseline file is invalid: \(reason)"
            case .toleranceMustBePositive:
                return "Tolerance multipliers must be greater than zero."
            }
        }
    }

    struct CLIOptions: ParsableArguments {
        @Option(name: .customLong("fixture"), help: "DocC bundle or archive to benchmark. Defaults to Fixtures/ArticleReference.doccarchive when present.")
        var fixturePath: String?

        @Option(name: .customLong("synthesize-megabytes"), help: "Optional size target for synthesizing a benchmark bundle from the base fixture.")
        var synthesizeMegabytes: Double?

        @Option(name: .customLong("iterations"), help: "Number of benchmark iterations to run.")
        var iterations: Int = 3

        @Option(name: .customLong("threshold-seconds"), help: "Fail when the slowest iteration exceeds this wall-clock duration.")
        var thresholdSeconds: Double = 10.0

        @Option(name: .customLong("output"), help: "Directory to store benchmark outputs and synthetic fixtures.")
        var outputDirectory: String?

        @Option(name: .customLong("metrics-json"), help: "Optional path to write benchmark metrics as JSON.")
        var metricsJSONPath: String?

        @Flag(name: .customLong("keep-output"), help: "Retain per-iteration outputs instead of cleaning them up.")
        var keepOutputs: Bool = false

        @Option(name: .customLong("baseline"), help: "Optional path to a baseline metrics JSON for regression comparison.")
        var baselinePath: String?

        @Option(name: .customLong("tolerance-average"), help: "Multiplier tolerance for average duration regression checks (default 2.0).")
        var toleranceAverage: Double = 2.0

        @Option(name: .customLong("tolerance-max"), help: "Multiplier tolerance for max duration regression checks (default 2.0).")
        var toleranceMax: Double = 2.0

        @Flag(name: .customLong("fail-on-regression"), help: "Exit non-zero if regression detected against baseline.")
        var failOnRegression: Bool = false
    }

    public func run(arguments: [String]) -> BenchmarkCommandResult {
        let trimmedArguments = Array(arguments.dropFirst())
        if trimmedArguments.contains("--help") || trimmedArguments.contains("-h") {
            return BenchmarkCommandResult(exitCode: 0, output: BenchmarkCommandHelp().render())
        }

        do {
            let parsedOptions = try CLIOptions.parse(trimmedArguments)
            let options = try resolveOptions(from: parsedOptions)
            let outputDirectory = try resolveOutputDirectory(path: options.outputDirectory)
            let fixtureURL = try resolveFixture(from: options, outputDirectory: outputDirectory)
            let fixtureSize = try BenchmarkFixtureBuilder.directorySize(at: fixtureURL)

            let configuration = PerformanceBenchmarkHarness.Configuration(
                fixtureURL: fixtureURL,
                iterations: options.iterations,
                thresholdSeconds: options.thresholdSeconds,
                outputDirectory: outputDirectory.appendingPathComponent("runs", isDirectory: true),
                keepOutputs: options.keepOutputs)

            let result = try harness.run(configuration: configuration)
            if let metricsPath = options.metricsJSONPath {
                let metricsURL = URL(fileURLWithPath: metricsPath).standardizedFileURL
                let encoder = DeterministicJSONEncoder.makeEncoder()
                let metrics = result.makeMetrics(
                    fixtureURL: fixtureURL,
                    fixtureSizeBytes: fixtureSize)
                let data = try encoder.encode(metrics)
                try data.write(to: metricsURL, options: .atomic)
            }

            let metrics = result.makeMetrics(
                fixtureURL: fixtureURL,
                fixtureSizeBytes: fixtureSize)

            var messages: [String] = []
            var passed = result.passed

            if let baseline = try loadBaselineIfNeeded(options: options) {
                let tolerance = BenchmarkComparator.Tolerance(
                    averageMultiplier: options.toleranceAverage,
                    maxMultiplier: options.toleranceMax)
                let comparison = comparator.compare(
                    baseline: baseline,
                    candidate: metrics,
                    tolerance: tolerance,
                    thresholdSeconds: options.thresholdSeconds)
                messages.append(contentsOf: comparison.messages)
                if options.failOnRegression && !comparison.passed {
                    passed = false
                }
            }

            let summary = renderSummary(
                fixtureURL: fixtureURL,
                fixtureSize: fixtureSize,
                result: result,
                messages: messages)
            return BenchmarkCommandResult(
                exitCode: passed ? 0 : 1,
                output: summary)
        } catch let error as CLIError {
            return BenchmarkCommandResult(exitCode: 64, output: error.description)
        } catch let error as ValidationError {
            return BenchmarkCommandResult(exitCode: 64, output: error.description)
        } catch {
            return BenchmarkCommandResult(exitCode: 64, output: String(describing: error))
        }
    }

    private func resolveOptions(from options: CLIOptions) throws -> CLIOptions {
        guard options.iterations > 0 else {
            throw CLIError.iterationsMustBePositive
        }
        guard options.thresholdSeconds > 0 else {
            throw CLIError.thresholdMustBePositive
        }
        guard options.toleranceAverage > 0, options.toleranceMax > 0 else {
            throw CLIError.toleranceMustBePositive
        }
        return options
    }

    private func resolveFixture(from options: CLIOptions, outputDirectory: URL) throws -> URL {
        if let synthesize = options.synthesizeMegabytes {
            let baseFixture = try resolvedBaseFixture(path: options.fixturePath)
            let targetBytes = Int(synthesize * 1024 * 1024)
            let synthDirectory = outputDirectory.appendingPathComponent("synthetic-fixture", isDirectory: true)
            if fileManager.fileExists(atPath: synthDirectory.path) {
                try fileManager.removeItem(at: synthDirectory)
            }
            try fileManager.createDirectory(at: synthDirectory, withIntermediateDirectories: true)
            return try fixtureBuilder.synthesizeBenchmarkFixture(
                baseFixtureURL: baseFixture,
                targetSizeBytes: targetBytes,
                destinationDirectory: synthDirectory)
        }

        return try resolvedBaseFixture(path: options.fixturePath)
    }

    private func resolvedBaseFixture(path: String?) throws -> URL {
        if let providedPath = path {
            let url = URL(fileURLWithPath: providedPath).standardizedFileURL
            guard fileManager.fileExists(atPath: url.path) else {
                throw CLIError.missingFixture
            }
            return url
        }

        let cwd = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
        let defaultFixture = cwd
            .appendingPathComponent("Fixtures", isDirectory: true)
            .appendingPathComponent("ArticleReference.doccarchive", isDirectory: true)
        guard fileManager.fileExists(atPath: defaultFixture.path) else {
            throw CLIError.missingFixture
        }
        return defaultFixture
    }

    private func resolveOutputDirectory(path: String?) throws -> URL {
        let url: URL
        if let path = path {
            url = URL(fileURLWithPath: path, isDirectory: true).standardizedFileURL
        } else {
            url = fileManager.temporaryDirectory.appendingPathComponent(
                "docc2context-benchmark",
                isDirectory: true)
        }

        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }

    private func renderSummary(
        fixtureURL: URL,
        fixtureSize: Int,
        result: PerformanceBenchmarkHarness.Result,
        messages: [String]
    ) -> String {
        let fixtureLabel = fixtureURL.lastPathComponent
        let sizeMB = Double(fixtureSize) / (1024 * 1024)
        var lines: [String] = []
        lines.append("Benchmark: \(fixtureLabel) (\(String(format: "%.2f", sizeMB)) MB)")
        lines.append("Iterations: \(result.samples.count)")
        lines.append("Threshold (max): \(String(format: "%.3f", result.thresholdSeconds))s")
        lines.append("Average: \(String(format: "%.3f", result.averageSeconds))s")
        lines.append("Max: \(String(format: "%.3f", result.maxSeconds))s")
        lines.append("Status: \(result.passed ? "PASS" : "FAIL")")
        if !messages.isEmpty {
            lines.append("Regression checks:")
            lines.append(contentsOf: messages.map { "- \($0)" })
        }
        return lines.joined(separator: "\n")
    }

    private func loadBaselineIfNeeded(options: CLIOptions) throws -> PerformanceBenchmarkHarness.BenchmarkMetrics? {
        guard let baselinePath = options.baselinePath else {
            return nil
        }
        let url = URL(fileURLWithPath: baselinePath).standardizedFileURL
        guard fileManager.fileExists(atPath: url.path) else {
            throw CLIError.baselineMissing(url.path)
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = DeterministicJSONEncoder.makeDecoder()
            return try decoder.decode(PerformanceBenchmarkHarness.BenchmarkMetrics.self, from: data)
        } catch {
            throw CLIError.invalidBaseline(error.localizedDescription)
        }
    }
}

public struct BenchmarkCommandHelp {
    public init() {}

    public func render() -> String {
        """
        docc2context-benchmark – Performance harness for DocC conversions

        Usage:
          docc2context-benchmark [--fixture <path>] [--synthesize-megabytes <size>] [--iterations <n>] [--threshold-seconds <seconds>] [--output <dir>] [--metrics-json <path>] [--baseline <path>] [--tolerance-average <x>] [--tolerance-max <x>] [--fail-on-regression] [--keep-output]

        Options:
          -h, --help                 Show this help message and exit.
          --fixture <path>           DocC bundle or archive to benchmark. Defaults to Fixtures/ArticleReference.doccarchive when present.
          --synthesize-megabytes <n> Create a synthetic benchmark bundle of approximately N megabytes using the base fixture.
          --iterations <n>           Number of benchmark iterations to run (default: 3).
          --threshold-seconds <n>    Fail if the slowest iteration exceeds this duration (default: 10 seconds).
          --output <dir>             Directory to store benchmark outputs and synthetic fixtures (default: system temp).
          --metrics-json <path>      Optional path to write benchmark metrics as JSON.
          --baseline <path>          Optional baseline metrics JSON to compare against.
          --tolerance-average <x>    Multiplier tolerance for average duration (default: 2.0).
          --tolerance-max <x>        Multiplier tolerance for max duration (default: 2.0).
          --fail-on-regression       Exit non-zero when regression checks fail (default: off).
          --keep-output              Retain per-iteration outputs instead of cleaning them up.
        """
    }
}
