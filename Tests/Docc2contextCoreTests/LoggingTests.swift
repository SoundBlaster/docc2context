import XCTest
@testable import Docc2contextCore

private final class BufferingSink: LogSink {
    private(set) var lines: [String] = []
    func write(_ message: String) {
        lines.append(message.trimmingCharacters(in: .newlines))
    }
}

final class LoggingTests: XCTestCase {
    func testEmitsPhaseLifecycleEvents() {
        let sink = BufferingSink()
        let logger = StructuredLogger(sink: sink)

        logger.logPhase("convert", state: .started)
        logger.logPhase("convert", state: .finished)

        XCTAssertEqual(logger.phaseEvents, [
            PhaseLifecycleEvent(phase: "convert", state: .started),
            PhaseLifecycleEvent(phase: "convert", state: .finished),
        ])
        XCTAssertEqual(sink.lines, ["phase=convert state=started", "phase=convert state=finished"])
    }

    func testRecordsSummaryCounts() {
        let sink = BufferingSink()
        let logger = StructuredLogger(sink: sink)

        logger.recordSummary(tutorialVolumes: 2, chapters: 3, articles: 5, symbols: 8)

        XCTAssertEqual(logger.summaryEvents, [
            SummaryLogEvent(tutorialVolumes: 2, chapters: 3, articles: 5, symbols: 8),
        ])
        XCTAssertEqual(sink.lines, ["summary tutorialVolumes=2 chapters=3 articles=5 symbols=8"])
    }

    func testFormatsErrorEvents() {
        struct FixtureError: LocalizedError { var errorDescription: String? { "failed to render" } }

        let sink = BufferingSink()
        let logger = StructuredLogger(sink: sink)

        logger.logError(phase: "render", error: FixtureError())

        XCTAssertEqual(logger.errorEvents, [
            ErrorLogEvent(phase: "render", message: "failed to render"),
        ])
        XCTAssertEqual(sink.lines, ["error phase=render message=failed to render"])
    }
}
