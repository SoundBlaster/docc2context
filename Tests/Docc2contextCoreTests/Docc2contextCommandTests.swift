import XCTest
@testable import Docc2contextCore

final class Docc2contextCommandTests: XCTestCase {
    func testHelpFlagReturnsUsage() throws {
        let result = Docc2contextCommand().run(arguments: ["docc2context", "--help"])
        XCTAssertEqual(result.exitCode, 0)
        XCTAssertTrue(result.output.contains("Usage:"))
        XCTAssertTrue(result.output.contains("docc2context"))
    }

    func testDefaultInvocationRemindsUserAboutInputRequirement() throws {
        let result = Docc2contextCommand().run(arguments: ["docc2context"])
        XCTAssertEqual(result.exitCode, 64)
        XCTAssertTrue(result.output.lowercased().contains("input"))
    }
}
