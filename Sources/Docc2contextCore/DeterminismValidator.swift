import Foundation

/// Result of comparing two directories for determinism
public struct DeterminismResult {
    /// Whether the directories are byte-identical
    public let isDeterministic: Bool

    /// Whether the computed hashes match
    public let hashesMatch: Bool

    /// List of differences found (file paths that differ)
    public let differences: [String]

    /// Hash of the first directory
    public let firstDirectoryHash: String?

    /// Hash of the second directory
    public let secondDirectoryHash: String?
}

/// Validates determinism by computing and comparing file hashes
public class DeterminismValidator {
    /// Initialize a new determinism validator
    public init() {}

    /// Compute a hash of file content using a djb2-style algorithm
    /// - Parameter filePath: Path to the file to hash
    /// - Returns: Hex-encoded hash string
    /// - Throws: Error if file cannot be read
    public func hashFile(at filePath: String) throws -> String {
        let fileURL = URL(fileURLWithPath: filePath)
        let data = try Data(contentsOf: fileURL)

        // Use djb2-style hash algorithm processing all file bytes
        var hashValue: UInt64 = 5381
        for byte in data {
            hashValue = ((hashValue << 5) &+ hashValue) &+ UInt64(byte)
        }

        // Also create a checksum by adding all bytes and XOR with hash
        let checksum = data.reduce(0) { UInt64($0) &+ UInt64($1) }
        let combined = hashValue ^ checksum

        return String(format: "%016llx", combined)
    }

    /// Hash a directory recursively by processing all files in sorted order
    /// - Parameter directoryPath: Path to the directory to hash
    /// - Returns: Hex-encoded hash combining all files' hashes
    /// - Throws: Error if files cannot be read
    public func hashDirectory(at directoryPath: String) throws -> String {
        let fileManager = FileManager.default
        var combinedHash: UInt64 = 5381

        // Get all files recursively
        let enumerator = fileManager.enumerator(atPath: directoryPath)
        let sortedFilePaths = (enumerator?.allObjects as? [String] ?? [])
            .sorted()  // Deterministic order

        // Hash each file in order
        for relativePath in sortedFilePaths {
            let fullPath = (directoryPath as NSString).appendingPathComponent(relativePath)

            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: fullPath, isDirectory: &isDir), !isDir.boolValue {
                do {
                    let fileData = try Data(contentsOf: URL(fileURLWithPath: fullPath))
                    let pathData = (relativePath).data(using: .utf8) ?? Data()
                    let combined = fileData + pathData

                    // Compute hash using djb2-style algorithm
                    var fileHash: UInt64 = 5381
                    for byte in combined {
                        fileHash = ((fileHash << 5) &+ fileHash) &+ UInt64(byte)
                    }
                    // Combine hashes using djb2-style to maintain order sensitivity
                    combinedHash = ((combinedHash << 5) &+ combinedHash) &+ fileHash
                } catch {
                    // Propagate errors to prevent false positives from unreadable files
                    throw error
                }
            }
        }

        return String(format: "%016llx", combinedHash)
    }

    /// Compare two directories for determinism
    /// - Parameters:
    ///   - firstPath: Path to the first directory
    ///   - secondPath: Path to the second directory
    /// - Returns: DeterminismResult with comparison details
    /// - Throws: Error if files cannot be read or comparison fails
    public func compareDirectories(
        firstPath: String,
        secondPath: String
    ) throws -> DeterminismResult {
        let fileManager = FileManager.default
        var differences: [String] = []

        // Get all files from both directories
        let allFiles1 = Set(fileManager.enumerator(atPath: firstPath)?.allObjects as? [String] ?? [])
        let allFiles2 = Set(fileManager.enumerator(atPath: secondPath)?.allObjects as? [String] ?? [])

        // Check for missing or extra files
        for file in allFiles1.symmetricDifference(allFiles2) {
            differences.append("File missing or extra: \(file)")
        }

        // Compare content of common files
        for file in allFiles1.intersection(allFiles2).sorted() {
            let path1 = (firstPath as NSString).appendingPathComponent(file)
            let path2 = (secondPath as NSString).appendingPathComponent(file)

            var isDir1: ObjCBool = false
            var isDir2: ObjCBool = false

            if fileManager.fileExists(atPath: path1, isDirectory: &isDir1),
               fileManager.fileExists(atPath: path2, isDirectory: &isDir2) {

                // Skip directories
                guard !isDir1.boolValue && !isDir2.boolValue else { continue }

                do {
                    let hash1 = try hashFile(at: path1)
                    let hash2 = try hashFile(at: path2)

                    if hash1 != hash2 {
                        differences.append("Content differs: \(file)")
                    }
                } catch {
                    differences.append("Error reading file: \(file)")
                }
            }
        }

        // Compute directory hashes
        let dir1Hash = try hashDirectory(at: firstPath)
        let dir2Hash = try hashDirectory(at: secondPath)

        let isDeterministic = differences.isEmpty && dir1Hash == dir2Hash

        return DeterminismResult(
            isDeterministic: isDeterministic,
            hashesMatch: dir1Hash == dir2Hash,
            differences: differences,
            firstDirectoryHash: dir1Hash,
            secondDirectoryHash: dir2Hash
        )
    }
}
