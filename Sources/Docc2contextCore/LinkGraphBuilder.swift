import Foundation

public struct LinkGraph: Equatable, Codable {
    public struct AdjacencyEntry: Equatable, Codable {
        public let source: String
        public let targets: [String]

        public init(source: String, targets: [String]) {
            self.source = source
            self.targets = targets
        }
    }

    /// Adjacency map: page identifier → list of linked page identifiers
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
        var allReferencedIds = Set<String>()
        var adjacencyMap = [String: Set<String>]()

        // 1. Extract tutorial page identifiers and build adjacency from chapters
        for volume in bundleModel.tutorialVolumes {
            allPageIds.insert(volume.identifier)
            for chapter in volume.chapters {
                // Chapter references its tutorial pages
                for pageId in chapter.pageIdentifiers {
                    allPageIds.insert(pageId)
                    allReferencedIds.insert(pageId)
                    // Add link from volume to pages
                    adjacencyMap[volume.identifier, default: Set()].insert(pageId)
                }
            }
        }

        // 2. Extract documentation catalog topic identifiers
        for topic in bundleModel.documentationCatalog.topics {
            for identifier in topic.identifiers {
                allPageIds.insert(identifier)
                allReferencedIds.insert(identifier)
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

        // 5. Find unresolved references (referenced but not defined)
        let unresolvedRefs = allReferencedIds.subtracting(allPageIds)

        // 6. Build deterministic adjacency map (sorted keys and values)
        let sortedAdjacency = adjacencyMap
            .mapValues { Array($0).sorted() }
            .reduce(into: [String: [String]]()) { dict, pair in
                dict[pair.key] = pair.value
            }

        let linkGraph = LinkGraph(
            adjacency: sortedAdjacency.isEmpty ? [:] : sortedAdjacency,
            allPageIdentifiers: allPageIds.sorted(),
            unresolvedReferences: unresolvedRefs.sorted()
        )

        return linkGraph
    }
}
