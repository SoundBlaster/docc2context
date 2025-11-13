import XCTest
@testable import docc2contextCore

final class docc2contextTests: XCTestCase {
    func testVersionResolverFallsBackWhenBundleIsMissing() {
        // There is no Info.plist when tests run, so the fallback string should be returned.
        XCTAssertEqual(VersionResolver.docc2contextVersion, "0.0.0-dev")
    }
}
