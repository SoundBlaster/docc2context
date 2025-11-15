import XCTest

@testable import Docc2contextCore

final class DoccInternalModelSerializationTests: XCTestCase {
    func test_bundleModelIsCodable() {
        XCTAssertTrue(DoccBundleModel.self is Codable.Type, "DoccBundleModel must conform to Codable before serialization tests can encode it.")
        XCTAssertTrue(DoccTutorialVolume.self is Codable.Type, "DoccTutorialVolume must conform to Codable before serialization tests can encode it.")
        XCTAssertTrue(DoccTutorialChapter.self is Codable.Type, "DoccTutorialChapter must conform to Codable before serialization tests can encode it.")
    }
}
