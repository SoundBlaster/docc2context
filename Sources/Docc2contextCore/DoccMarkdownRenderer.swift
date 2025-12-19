import Foundation

/// Renders decoded DocC models into deterministic Markdown.
///
/// The renderer is intentionally conservative: it prefers stable, predictable output over attempting to
/// reproduce every DocC presentation feature. Snapshot tests in `Tests/__Snapshots__/` lock the exact
/// Markdown emitted for representative fixtures.
public struct DoccMarkdownRenderer {
    public init() {}

    public func renderSymbolPage(
        catalog: DoccDocumentationCatalog,
        symbol: DoccSymbolPage
    ) -> String {
        var sections: [String] = []
        sections.append("# \(symbol.title)")
        sections.append(makeSymbolMetadataSection(catalog: catalog, symbol: symbol))

        if let summary = makeSymbolSummarySection(from: symbol.abstract) {
            sections.append(summary)
        }

        if let discussionSection = makeSymbolDiscussionSection(from: symbol.discussion) {
            sections.append(discussionSection)
        }

        if let declarationsSection = makeDeclarationsSection(from: symbol.declarations) {
            sections.append(declarationsSection)
        }

        if let topicsSection = makeSymbolTopicsSection(
            from: symbol.topicSections,
            referencesByIdentifier: symbol.referencesByIdentifier
        ) {
            sections.append(topicsSection)
        }

        if let relationshipsSection = makeSymbolRelationshipsSection(
            from: symbol.relationshipSections,
            referencesByIdentifier: symbol.referencesByIdentifier
        ) {
            sections.append(relationshipsSection)
        }

        return sections.joined(separator: "\n\n") + "\n"
    }

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

    public func renderTutorialChapterPage(
        catalog: DoccDocumentationCatalog,
        volume: DoccTutorialVolume,
        chapter: DoccTutorialChapter,
        tutorials: [DoccTutorial]
    ) -> String {
        var sections: [String] = []
        sections.append("# \(chapter.title)")
        sections.append(makeChapterMetadataSection(
            catalog: catalog,
            volume: volume,
            chapter: chapter,
            tutorialCount: tutorials.count))
        sections.append(makeTutorialsSection(from: tutorials))
        sections.append(makeNavigationSection(in: volume, chapter: chapter))
        return sections.joined(separator: "\n\n") + "\n"
    }

    public func renderTutorialPage(
        catalog: DoccDocumentationCatalog,
        volume: DoccTutorialVolume,
        chapter: DoccTutorialChapter,
        tutorial: DoccTutorial
    ) -> String {
        var sections: [String] = []
        sections.append("# \(tutorial.title)")
        sections.append(makeTutorialMetadataSection(
            catalog: catalog,
            volume: volume,
            chapter: chapter,
            tutorial: tutorial
        ))

        if let introduction = tutorial.introduction?.trimmingCharacters(in: .whitespacesAndNewlines),
           !introduction.isEmpty
        {
            sections.append(["## Introduction", introduction].joined(separator: "\n"))
        }

        if !tutorial.steps.isEmpty {
            sections.append((["## Sections", "### Steps"] + makeStepLines(for: tutorial.steps)).joined(separator: "\n"))
        }

        if !tutorial.assessments.isEmpty {
            sections.append((["## Assessments"] + makeAssessmentLines(for: tutorial.assessments)).joined(separator: "\n"))
        }

        return sections.joined(separator: "\n\n") + "\n"
    }

    public func renderReferenceArticle(
        catalog: DoccDocumentationCatalog,
        article: DoccArticle
    ) -> String {
        var sections: [String] = []
        sections.append("# \(article.title)")
        sections.append(makeArticleMetadataSection(catalog: catalog, article: article))
        if let abstract = makeArticleAbstractSection(from: article.abstract) {
            sections.append(abstract)
        }
        sections.append(makeArticleSectionsSection(from: article.sections))
        if let topicsSection = makeArticleTopicsSection(from: article.topics) {
            sections.append(topicsSection)
        }
        if let referencesSection = makeArticleReferencesSection(from: article.references) {
            sections.append(referencesSection)
        }
        return sections.joined(separator: "\n\n") + "\n"
    }

    private func makeSymbolMetadataSection(
        catalog: DoccDocumentationCatalog,
        symbol: DoccSymbolPage
    ) -> String {
        var lines: [String] = ["## Symbol Metadata"]
        lines.append("- **Identifier:** \(symbol.identifier)")
        if let moduleName = symbol.moduleName {
            lines.append("- **Module:** \(moduleName)")
        }
        if let symbolKind = symbol.symbolKind {
            lines.append("- **Symbol Kind:** \(symbolKind)")
        }
        if let roleHeading = symbol.roleHeading {
            lines.append("- **Role Heading:** \(roleHeading)")
        }

        // Add availability metadata
        if let availability = symbol.availability, !availability.isEmpty {
            lines.append("- **Availability:**")
            for constraint in availability {
                lines.append("  - \(constraint)")
            }
        }

        // Add deprecation metadata
        if symbol.isDeprecated {
            lines.append("- **Status:** ⚠️ Deprecated")
            if let summary = symbol.deprecatedSummary {
                lines.append("- **Deprecation Notice:** \(summary)")
            }
        }

        // Add default implementations metadata
        if let defaults = symbol.defaultImplementations, !defaults.isEmpty {
            lines.append("- **Default Implementations:** \(defaults.count) types")
        }

        lines.append("- **Catalog Identifier:** \(catalog.identifier)")
        lines.append("- **Catalog Title:** \(catalog.title)")
        return lines.joined(separator: "\n")
    }

    private func makeSymbolSummarySection(from abstractText: String?) -> String? {
        let text = (abstractText ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }
        return ["## Summary", text].joined(separator: "\n")
    }

    private func makeSymbolDiscussionSection(from discussionBlocks: [String]) -> String? {
        let blocks = discussionBlocks
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !blocks.isEmpty else { return nil }
        return (["## Discussion"] + blocks).joined(separator: "\n\n")
    }

    private func makeDeclarationsSection(from declarations: [DoccSymbolPage.Declaration]) -> String? {
        guard !declarations.isEmpty else { return nil }
        let language = declarations.compactMap(\.language).first ?? "swift"
        let renderedDeclarations = declarations
            .map { $0.text }
            .filter { !$0.isEmpty }
        guard !renderedDeclarations.isEmpty else { return nil }
        let code = renderedDeclarations.joined(separator: "\n")
        return ["## Declarations", "```\(language)", code, "```"].joined(separator: "\n")
    }

    private func makeSymbolTopicsSection(
        from topicSections: [DoccSymbolPage.TopicSection],
        referencesByIdentifier: [String: DoccSymbolPage.Reference]
    ) -> String? {
        guard !topicSections.isEmpty else { return nil }
        var lines: [String] = ["## Topics"]
        for section in topicSections {
            lines.append("")
            lines.append("### \(section.title)")
            for identifier in section.identifiers {
                let title = referencesByIdentifier[identifier]?.title ?? identifier
                lines.append("- \(title)")
            }
        }
        return lines.joined(separator: "\n")
    }

    private func makeSymbolRelationshipsSection(
        from relationshipSections: [DoccSymbolPage.RelationshipSection],
        referencesByIdentifier: [String: DoccSymbolPage.Reference]
    ) -> String? {
        guard !relationshipSections.isEmpty else { return nil }
        var lines: [String] = ["## Relationships"]
        for section in relationshipSections {
            lines.append("")
            lines.append("### \(section.title)")
            for identifier in section.identifiers {
                let title = referencesByIdentifier[identifier]?.title ?? identifier
                lines.append("- \(title)")
            }
        }
        return lines.joined(separator: "\n")
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

    private func makeChapterMetadataSection(
        catalog: DoccDocumentationCatalog,
        volume: DoccTutorialVolume,
        chapter: DoccTutorialChapter,
        tutorialCount: Int
    ) -> String {
        var lines: [String] = ["## Chapter Metadata"]
        lines.append("- **Volume Title:** \(volume.title)")
        lines.append("- **Volume Identifier:** \(volume.identifier)")
        lines.append("- **Chapter Title:** \(chapter.title)")
        lines.append("- **Tutorial Count:** \(tutorialCount)")
        return lines.joined(separator: "\n")
    }

    private func makeTutorialsSection(from tutorials: [DoccTutorial]) -> String {
        var lines: [String] = ["## Tutorials"]
        guard !tutorials.isEmpty else {
            lines.append("_No tutorial content available for this chapter._")
            return lines.joined(separator: "\n")
        }

        for tutorial in tutorials {
            lines.append("")
            lines.append("### \(tutorial.title)")

            if let introduction = tutorial.introduction?.trimmingCharacters(in: .whitespacesAndNewlines),
                !introduction.isEmpty {
                lines.append("")
                lines.append("#### Introduction")
                lines.append(introduction)
            }

            if !tutorial.steps.isEmpty {
                lines.append("")
                lines.append("#### Steps")
                lines.append(contentsOf: makeStepLines(for: tutorial.steps))
            }

            if !tutorial.assessments.isEmpty {
                lines.append("")
                lines.append("#### Assessments")
                lines.append(contentsOf: makeAssessmentLines(for: tutorial.assessments))
            }
        }

        return lines.joined(separator: "\n")
    }

    private func makeTutorialMetadataSection(
        catalog: DoccDocumentationCatalog,
        volume: DoccTutorialVolume,
        chapter: DoccTutorialChapter,
        tutorial: DoccTutorial
    ) -> String {
        var lines: [String] = ["## Tutorial Metadata"]
        lines.append("- **Identifier:** \(tutorial.identifier)")
        lines.append("- **Catalog Identifier:** \(catalog.identifier)")
        lines.append("- **Catalog Title:** \(catalog.title)")
        lines.append("- **Volume Title:** \(volume.title)")
        lines.append("- **Volume Identifier:** \(volume.identifier)")
        lines.append("- **Chapter Title:** \(chapter.title)")
        return lines.joined(separator: "\n")
    }

    private func makeStepLines(for steps: [DoccTutorial.Step]) -> [String] {
        var lines: [String] = []
        for (index, step) in steps.enumerated() {
            lines.append("\(index + 1). **\(step.title)**")
            let normalizedContent = step.content
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            for entry in normalizedContent {
                let isMultiLine = entry.contains("\n")
                let isCodeFence = entry.hasPrefix("```")
                let isTableRow = entry.hasPrefix("|")
                let isHeading = entry.hasPrefix("#")
                let isListItem = entry.hasPrefix("- ")
                let isOrderedListItem = entry.range(of: #"^\d+\.\s"#, options: .regularExpression) != nil

                if isMultiLine || isCodeFence || isTableRow || isHeading || isListItem || isOrderedListItem {
                    lines.append(contentsOf: entry.split(separator: "\n", omittingEmptySubsequences: false).map { "   \($0)" })
                } else {
                    lines.append("   - \(entry)")
                }
            }
        }
        return lines
    }

    private func makeAssessmentLines(for assessments: [DoccTutorial.Assessment]) -> [String] {
        var lines: [String] = []
        for (index, assessment) in assessments.enumerated() {
            lines.append("##### \(assessment.title)")
            for item in assessment.items {
                lines.append("- Prompt: \(item.prompt)")
                if !item.choices.isEmpty {
                    lines.append("- Choices:")
                    for (choiceIndex, choice) in item.choices.enumerated() {
                        lines.append("  \(choiceIndex + 1). \(choice)")
                    }
                }
                lines.append("- Answer Index: \(item.answer + 1)")
            }
            if index < assessments.count - 1 {
                lines.append("")
            }
        }
        return lines
    }

    private func makeNavigationSection(
        in volume: DoccTutorialVolume,
        chapter: DoccTutorialChapter
    ) -> String {
        let chapterIndex = volume.chapters.firstIndex(of: chapter)
        let previousTitle = chapterIndex.flatMap { index -> String? in
            guard index - 1 >= 0 else { return nil }
            return volume.chapters[index - 1].title
        }
        let nextTitle = chapterIndex.flatMap { index -> String? in
            guard index + 1 < volume.chapters.count else { return nil }
            return volume.chapters[index + 1].title
        }

        var lines: [String] = ["## Navigation"]
        lines.append("- **Previous Chapter:** \(previousTitle ?? "_None_")")
        lines.append("- **Next Chapter:** \(nextTitle ?? "_None_")")
        return lines.joined(separator: "\n")
    }

    private func makeArticleMetadataSection(
        catalog: DoccDocumentationCatalog,
        article: DoccArticle
    ) -> String {
        var lines: [String] = ["## Article Metadata"]
        lines.append("- **Identifier:** \(article.identifier)")
        lines.append("- **Article Kind:** \(article.kind)")
        lines.append("- **Catalog Identifier:** \(catalog.identifier)")
        lines.append("- **Catalog Title:** \(catalog.title)")
        lines.append("- **Catalog Kind:** \(catalog.kind)")
        if let role = catalog.role {
            lines.append("- **Catalog Role:** \(role)")
        }
        lines.append("- **Section Count:** \(article.sections.count)")
        lines.append("- **Reference Count:** \(article.references.count)")
        return lines.joined(separator: "\n")
    }

    private func makeArticleAbstractSection(
        from abstractItems: [DoccArticle.AbstractItem]
    ) -> String? {
        guard !abstractItems.isEmpty else { return nil }
        let text = abstractItems
            .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !text.isEmpty else { return nil }
        return (["## Abstract"] + text).joined(separator: "\n")
    }

    private func makeArticleSectionsSection(
        from sections: [DoccArticle.Section]
    ) -> String {
        var lines: [String] = ["## Sections"]
        guard !sections.isEmpty else {
            lines.append("_No sections available for this article._")
            return lines.joined(separator: "\n")
        }

        for section in sections {
            lines.append("")
            lines.append("### \(section.title)")
            if section.content.isEmpty {
                lines.append("_No content available for this section._")
            } else {
                for entry in section.content {
                    let trimmed = entry.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { continue }

                    let isMultiLine = trimmed.contains("\n")
                    let isCodeFence = trimmed.hasPrefix("```")
                    let isTableRow = trimmed.hasPrefix("|")
                    let isListItem = trimmed.hasPrefix("- ")
                    let isOrderedListItem = trimmed.range(of: #"^\d+\.\s"#, options: .regularExpression) != nil

                    if isMultiLine || isCodeFence || isTableRow || isListItem || isOrderedListItem {
                        lines.append(trimmed)
                    } else {
                        lines.append("- \(trimmed)")
                    }
                }
            }
        }

        return lines.joined(separator: "\n")
    }

    private func makeArticleTopicsSection(
        from topics: [DoccArticle.TopicSection]
    ) -> String? {
        guard !topics.isEmpty else { return nil }
        var lines: [String] = ["## Topics"]
        for topic in topics {
            lines.append("")
            lines.append("### \(topic.title)")
            if topic.identifiers.isEmpty {
                lines.append("_No topic identifiers available._")
            } else {
                for identifier in topic.identifiers {
                    lines.append("- \(identifier)")
                }
            }
        }
        return lines.joined(separator: "\n")
    }

    private func makeArticleReferencesSection(
        from references: [DoccArticle.Reference]
    ) -> String? {
        guard !references.isEmpty else { return nil }
        var lines: [String] = ["## References"]
        for reference in references {
            lines.append("")
            lines.append("### \(reference.title)")
            lines.append("- **Kind:** \(reference.kind)")
            lines.append("- **Identifier:** \(reference.identifier)")
        }
        return lines.joined(separator: "\n")
    }
}
