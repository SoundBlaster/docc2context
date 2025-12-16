import Foundation

enum TestProcessRunner {
    private final class OutputBuffer: @unchecked Sendable {
        private let lock = NSLock()
        private var data = Data()

        func append(_ chunk: Data) {
            lock.lock()
            data.append(chunk)
            lock.unlock()
        }

        func snapshot() -> Data {
            lock.lock()
            let current = data
            lock.unlock()
            return current
        }
    }

    struct Result {
        let exitCode: Int32
        let output: String
    }

    enum Error: Swift.Error, CustomStringConvertible {
        case timedOut(seconds: TimeInterval)
        case unreadableOutput

        var description: String {
            switch self {
            case .timedOut(let seconds):
                return "Process timed out after \(seconds) seconds"
            case .unreadableOutput:
                return "Unable to decode process output as UTF-8"
            }
        }
    }

    static func run(
        executableURL: URL,
        arguments: [String],
        currentDirectoryURL: URL? = nil,
        environment: [String: String]? = nil,
        timeoutSeconds: TimeInterval = 30
    ) throws -> Result {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments
        process.currentDirectoryURL = currentDirectoryURL
        process.environment = environment

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        let outputBuffer = OutputBuffer()
        let handle = pipe.fileHandleForReading
        handle.readabilityHandler = { readableHandle in
            let chunk = readableHandle.availableData
            if chunk.isEmpty {
                readableHandle.readabilityHandler = nil
                return
            }
            outputBuffer.append(chunk)
        }

        let finished = DispatchSemaphore(value: 0)
        process.terminationHandler = { _ in finished.signal() }

        try process.run()

        if finished.wait(timeout: .now() + timeoutSeconds) == .timedOut {
            handle.readabilityHandler = nil
            if process.isRunning {
                process.terminate()
            }
            _ = finished.wait(timeout: .now() + 5)
            throw Error.timedOut(seconds: timeoutSeconds)
        }

        handle.readabilityHandler = nil
        let remaining = handle.readDataToEndOfFile()
        outputBuffer.append(remaining)
        let combinedOutput = outputBuffer.snapshot()

        guard let outputString = String(data: combinedOutput, encoding: .utf8) else {
            throw Error.unreadableOutput
        }

        return Result(exitCode: process.terminationStatus, output: outputString)
    }
}
