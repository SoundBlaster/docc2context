import XCTest
@testable import Docc2contextCore

/// Tests for PRD Phase D task D1 (structured logging).
final class LoggingTests: XCTestCase {
    func testEmitsPhaseLifecycleEvents() throws {
        let logger = StructuredLogger()
        logger.beginPhase("ingest")
        logger.endPhase("ingest")

        XCTAssertEqual(logger.lifecycleEvents.count, 2)
        XCTAssertEqual(logger.lifecycleEvents.first?.message, "BEGIN: ingest")
        XCTAssertEqual(logger.lifecycleEvents.last?.message, "END: ingest")
    }

    func testRecordsSummaryCounts() throws {
        let logger = StructuredLogger()
        logger.recordSummary(phase: "render", counts: ["tutorials": 3, "articles": 5])

        XCTAssertEqual(logger.summaryEvents.count, 1)
        XCTAssertTrue(logger.summaryEvents[0].message.contains("articles: 5"))
        XCTAssertTrue(logger.summaryEvents[0].message.contains("tutorials: 3"))
    }

    func testFormatsErrorEvents() throws {
        let logger = StructuredLogger()
        logger.logError("Missing index", context: ["bundle": "Sample", "phase": "parse"])

        XCTAssertEqual(logger.errorEvents.count, 1)
        let message = logger.errorEvents[0].message
        XCTAssertTrue(message.contains("ERROR: Missing index"))
        XCTAssertTrue(message.contains("bundle=Sample"))
        XCTAssertTrue(message.contains("phase=parse"))
    }
}
