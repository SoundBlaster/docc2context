import XCTest
@testable import Docc2contextCore

/// Placeholder tests for PRD Phase B task B3 (input detection).
///
/// These will evolve into concrete failing tests once the detection API
/// surface is finalized per `DOCS/INPROGRESS/B3_InputDetection.md`.
final class InputDetectionTests: XCTestCase {
    func testDetectsDoccarchiveDirectoryPlaceholder() throws {
        throw XCTSkip("B3 – Replace with failing directory-detection spec during implementation.")
    }

    func testRejectsNonDoccDirectoryPlaceholder() throws {
        throw XCTSkip("B3 – Replace with failing invalid-bundle spec during implementation.")
    }

    func testDetectsDoccarchiveFilePlaceholder() throws {
        throw XCTSkip("B3 – Replace with failing file-detection spec during implementation.")
    }
}
