import Foundation

enum FixtureLoader {
    struct Manifest: Decodable, Equatable {
        struct FixtureBundle: Decodable, Equatable {
            struct Source: Decodable, Equatable {
                let url: String
                let reference: String
                let license: String
            }

            struct Checksum: Decodable, Equatable {
                let algorithm: String
                let value: String

                enum CodingKeys: String, CodingKey {
                    case algorithm
                    case value
                }
            }

            let id: String
            let name: String
            let source: Source
            let type: String
            let checksum: Checksum
            let sizeBytes: Int
            let notes: String

            enum CodingKeys: String, CodingKey {
                case id
                case name
                case source
                case type
                case checksum
                case sizeBytes = "size_bytes"
                case notes
            }
        }

        let schemaVersion: Int
        let bundles: [FixtureBundle]

        enum CodingKeys: String, CodingKey {
            case schemaVersion = "_schema"
            case bundles
        }
    }

    private static let fileManager = FileManager.default

    static func fixturesDirectory() -> URL {
        TestSupportPaths.fixturesDirectory
    }

    static func manifestURL() -> URL {
        fixturesDirectory().appendingPathComponent("manifest.json", isDirectory: false)
    }

    static func loadManifest() throws -> Manifest {
        let data = try Data(contentsOf: manifestURL())
        let decoder = JSONDecoder()
        return try decoder.decode(Manifest.self, from: data)
    }

    /// Convenience helper used by future tests to locate fixture bundles by name.
    static func urlForBundle(named bundleName: String) -> URL {
        fixturesDirectory().appendingPathComponent(bundleName)
    }
}
