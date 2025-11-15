import Foundation

public struct DoccMarkdownRenderer {
    public init() {}

    public func renderTutorialVolumeOverview(
        catalog: DoccDocumentationCatalog,
        volume: DoccTutorialVolume
    ) -> String {
        var sections: [String] = []
        sections.append("# \(volume.title)")

        sections.append(makeMetadataSection(catalog: catalog, volume: volume))

        if let abstract = makeAbstractSection(from: catalog.abstract) {
            sections.append(abstract)
        }

        sections.append(makeChaptersSection(from: volume))

        return sections.joined(separator: "\n\n") + "\n"
    }

    private func makeMetadataSection(
        catalog: DoccDocumentationCatalog,
        volume: DoccTutorialVolume
    ) -> String {
        var lines: [String] = ["## Volume Metadata"]
        lines.append("- **Identifier:** \(volume.identifier)")
        lines.append("- **Catalog Kind:** \(catalog.kind)")
        if let role = catalog.role {
            lines.append("- **Catalog Role:** \(role)")
        }
        return lines.joined(separator: "\n")
    }

    private func makeAbstractSection(
        from abstractItems: [DoccDocumentationCatalog.AbstractItem]
    ) -> String? {
        guard !abstractItems.isEmpty else { return nil }
        let text = abstractItems
            .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !text.isEmpty else { return nil }
        return (["## Abstract"] + text).joined(separator: "\n")
    }

    private func makeChaptersSection(from volume: DoccTutorialVolume) -> String {
        var lines: [String] = ["## Chapters"]
        for chapter in volume.chapters {
            lines.append("")
            lines.append("### \(chapter.title)")
            for identifier in chapter.pageIdentifiers {
                lines.append("- \(identifier)")
            }
        }
        return lines.joined(separator: "\n")
    }
}
