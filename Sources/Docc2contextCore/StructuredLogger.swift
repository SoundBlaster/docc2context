import Foundation

public enum PhaseLifecycleState: Equatable {
    case started
    case finished
}

public struct PhaseLifecycleEvent: Equatable {
    public let phase: String
    public let state: PhaseLifecycleState
}

public struct SummaryLogEvent: Equatable {
    public let tutorialVolumes: Int
    public let chapters: Int
    public let articles: Int
    public let symbols: Int
}

public struct ErrorLogEvent: Equatable {
    public let phase: String
    public let message: String
}

public protocol LogSink {
    func write(_ message: String)
}

public final class StructuredLogger {
    public private(set) var phaseEvents: [PhaseLifecycleEvent] = []
    public private(set) var summaryEvents: [SummaryLogEvent] = []
    public private(set) var errorEvents: [ErrorLogEvent] = []

    private let sink: LogSink

    public init(sink: LogSink = StandardErrorSink()) {
        self.sink = sink
    }

    public func logPhase(_ phase: String, state: PhaseLifecycleState) {
        let event = PhaseLifecycleEvent(phase: phase, state: state)
        phaseEvents.append(event)
        sink.write("phase=\(phase) state=\(state)\n")
    }

    public func recordSummary(tutorialVolumes: Int, chapters: Int, articles: Int, symbols: Int) {
        let event = SummaryLogEvent(
            tutorialVolumes: tutorialVolumes,
            chapters: chapters,
            articles: articles,
            symbols: symbols)
        summaryEvents.append(event)
        sink.write("summary tutorialVolumes=\(tutorialVolumes) chapters=\(chapters) articles=\(articles) symbols=\(symbols)\n")
    }

    public func logError(phase: String, error: Error) {
        let message: String
        if let localized = error as? LocalizedError, let description = localized.errorDescription {
            message = description
        } else {
            message = String(describing: error)
        }
        let event = ErrorLogEvent(phase: phase, message: message)
        errorEvents.append(event)
        sink.write("error phase=\(phase) message=\(message)\n")
    }
}

public struct StandardErrorSink: LogSink {
    public init() {}
    public func write(_ message: String) {
        if let data = message.data(using: .utf8) {
            FileHandle.standardError.write(data)
        }
    }
}
