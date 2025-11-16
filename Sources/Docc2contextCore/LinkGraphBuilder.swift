import Foundation

public struct LinkGraph: Equatable, Codable {
    /// Adjacency map: page identifier → list of linked page identifiers (sorted)
    public let adjacency: [String: [String]]

    /// All page identifiers discovered in the bundle (tutorials, articles, symbols)
    public let allPageIdentifiers: [String]

    /// References that appear in the bundle but don't resolve to any page
    public let unresolvedReferences: [String]

    public init(
        adjacency: [String: [String]],
        allPageIdentifiers: [String],
        unresolvedReferences: [String]
    ) {
        self.adjacency = adjacency
        self.allPageIdentifiers = allPageIdentifiers
        self.unresolvedReferences = unresolvedReferences
    }
}

public struct LinkGraphBuilder {
    public init() {}

    public func buildLinkGraph(from bundleModel: DoccBundleModel) throws -> LinkGraph {
        // Collect all page identifiers
        var allPageIds = Set<String>()
        var adjacencyMap = [String: Set<String>]()

        // 1. Extract tutorial page identifiers and build adjacency from chapters
        for volume in bundleModel.tutorialVolumes {
            allPageIds.insert(volume.identifier)
            for chapter in volume.chapters {
                // Chapter references its tutorial pages
                for pageId in chapter.pageIdentifiers {
                    allPageIds.insert(pageId)
                    // Add link from volume to pages
                    adjacencyMap[volume.identifier, default: Set()].insert(pageId)
                }
            }
        }

        // 2. Extract documentation catalog topic identifiers
        for topic in bundleModel.documentationCatalog.topics {
            for identifier in topic.identifiers {
                allPageIds.insert(identifier)
                // Catalog itself links to these pages
                adjacencyMap[bundleModel.documentationCatalog.identifier, default: Set()].insert(identifier)
            }
        }

        // 3. Add symbol reference identifiers
        for symbolRef in bundleModel.symbolReferences {
            allPageIds.insert(symbolRef.identifier)
        }

        // 4. Add documentation catalog as a page
        allPageIds.insert(bundleModel.documentationCatalog.identifier)

        // 5. Note: Unresolved references would require additional metadata (e.g., explicit link targets)
        //    that is not available in the current DoccBundleModel structure. For now, we track
        //    only the pages and references that are explicitly defined in the bundle.
        let unresolvedRefs = Set<String>()

        // 6. Build deterministic adjacency map (sorted keys and values)
        let sortedAdjacency = adjacencyMap
            .mapValues { Array($0).sorted() }
            .reduce(into: [String: [String]]()) { dict, pair in
                dict[pair.key] = pair.value
            }

        let linkGraph = LinkGraph(
            adjacency: sortedAdjacency,
            allPageIdentifiers: allPageIds.sorted(),
            unresolvedReferences: unresolvedRefs.sorted()
        )

        return linkGraph
    }
}
