import XCTest
@testable import Docc2contextCore

/// Placeholder tests for PRD Phase B task B4 (archive extraction).
///
/// These tests will be replaced with concrete failing specs once the
/// deterministic archive builder helper lands. They currently act as
/// scaffolding so the START ritual can document scenarios and link to
/// a tangible test target.
final class ArchiveExtractionTests: XCTestCase {
    func testExtractsDoccarchiveIntoDeterministicDirectoryPlaceholder() throws {
        throw XCTSkip("B4 – Replace with fixture-backed failing test verifying deterministic extraction paths.")
    }

    func testCleansUpTemporaryDirectoryOnFailurePlaceholder() throws {
        throw XCTSkip("B4 – Replace with fixture-backed failing test verifying cleanup when downstream conversion fails.")
    }

    func testSurfacesCorruptedArchiveErrorsPlaceholder() throws {
        throw XCTSkip("B4 – Replace with fixture-backed failing test verifying descriptive error propagation.")
    }
}
