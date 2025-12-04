import Foundation

public struct StructuredLogEvent: Equatable {
    public let category: String
    public let message: String
}

public final class StructuredLogger {
    private(set) var lifecycleEvents: [StructuredLogEvent] = []
    private(set) var summaryEvents: [StructuredLogEvent] = []
    private(set) var errorEvents: [StructuredLogEvent] = []

    public init() {}

    public func beginPhase(_ name: String) {
        lifecycleEvents.append(StructuredLogEvent(category: "phase", message: "BEGIN: \(name)"))
    }

    public func endPhase(_ name: String) {
        lifecycleEvents.append(StructuredLogEvent(category: "phase", message: "END: \(name)"))
    }

    public func recordSummary(phase: String, counts: [String: Int]) {
        let countDescription = counts.sorted { $0.key < $1.key }
            .map { "\($0): \($1)" }
            .joined(separator: ", ")
        summaryEvents.append(StructuredLogEvent(category: "summary", message: "\(phase): \(countDescription)"))
    }

    public func logError(_ message: String, context: [String: String]? = nil) {
        var formatted = "ERROR: \(message)"
        if let context {
            let renderedContext = context.keys.sorted().map { key in
                "\(key)=\(context[key] ?? "")"
            }.joined(separator: " ")
            formatted += " (\(renderedContext))"
        }
        errorEvents.append(StructuredLogEvent(category: "error", message: formatted))
    }
}
