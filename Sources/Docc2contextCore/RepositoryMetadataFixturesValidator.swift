import Crypto
import Foundation

public struct RepositoryMetadataFixturesValidator {
    public struct Manifest: Decodable, Equatable {
        public struct Fixture: Decodable, Equatable {
            public let id: String
            public let relativePath: String
            public let sha256: String
            public let sizeBytes: Int

            enum CodingKeys: String, CodingKey {
                case id
                case relativePath = "relative_path"
                case sha256
                case sizeBytes = "size_bytes"
            }
        }

        public let schemaVersion: Int
        public let fixtures: [Fixture]

        enum CodingKeys: String, CodingKey {
            case schemaVersion = "_schema"
            case fixtures
        }
    }

    public struct InvalidEntry: Equatable {
        public let id: String
        public let path: String
        public let expectedSHA256: String
        public let actualSHA256: String?
        public let expectedSize: Int
        public let actualSize: Int?
        public let reason: String
    }

    public struct Result: Equatable {
        public let invalidEntries: [InvalidEntry]

        public var isValid: Bool {
            invalidEntries.isEmpty
        }
    }

    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func loadManifest(from url: URL) throws -> Manifest {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(Manifest.self, from: data)
    }

    public func validate(fixturesDirectory: URL, manifestURL: URL) throws -> Result {
        let manifest = try loadManifest(from: manifestURL)
        var invalidEntries: [InvalidEntry] = []

        for fixture in manifest.fixtures {
            let fileURL = fixturesDirectory.appendingPathComponent(fixture.relativePath)
            guard fileManager.fileExists(atPath: fileURL.path) else {
                invalidEntries.append(
                    InvalidEntry(
                        id: fixture.id,
                        path: fixture.relativePath,
                        expectedSHA256: fixture.sha256,
                        actualSHA256: nil,
                        expectedSize: fixture.sizeBytes,
                        actualSize: nil,
                        reason: "missing file"
                    )
                )
                continue
            }

            let data = try Data(contentsOf: fileURL)
            let actualHash = sha256Hex(for: data)
            let actualSize = data.count

            var mismatches: [String] = []
            if actualHash != fixture.sha256 {
                mismatches.append("hash mismatch")
            }
            if actualSize != fixture.sizeBytes {
                mismatches.append("size mismatch")
            }

            if !mismatches.isEmpty {
                invalidEntries.append(
                    InvalidEntry(
                        id: fixture.id,
                        path: fixture.relativePath,
                        expectedSHA256: fixture.sha256,
                        actualSHA256: actualHash,
                        expectedSize: fixture.sizeBytes,
                        actualSize: actualSize,
                        reason: mismatches.joined(separator: ", ")
                    )
                )
            }
        }

        return Result(invalidEntries: invalidEntries)
    }

    private func sha256Hex(for data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
}
