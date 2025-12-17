import Foundation

public struct DoccSymbolPage: Equatable {
    public struct TopicSection: Equatable {
        public let title: String
        public let identifiers: [String]

        public init(title: String, identifiers: [String]) {
            self.title = title
            self.identifiers = identifiers
        }
    }

    public struct RelationshipSection: Equatable {
        public let title: String
        public let identifiers: [String]

        public init(title: String, identifiers: [String]) {
            self.title = title
            self.identifiers = identifiers
        }
    }

    public struct Declaration: Equatable {
        public let language: String?
        public let text: String

        public init(language: String?, text: String) {
            self.language = language
            self.text = text
        }
    }

    public struct Reference: Equatable {
        public let identifier: String
        public let kind: String
        public let title: String
        public let urlPath: String?

        public init(identifier: String, kind: String, title: String, urlPath: String?) {
            self.identifier = identifier
            self.kind = kind
            self.title = title
            self.urlPath = urlPath
        }
    }

    public let identifier: String
    public let title: String
    public let abstract: [DoccDocumentationCatalog.AbstractItem]
    public let symbolKind: String?
    public let roleHeading: String?
    public let moduleName: String?
    public let topicSections: [TopicSection]
    public let relationshipSections: [RelationshipSection]
    public let declarations: [Declaration]
    public let referencesByIdentifier: [String: Reference]

    public init(
        identifier: String,
        title: String,
        abstract: [DoccDocumentationCatalog.AbstractItem],
        symbolKind: String?,
        roleHeading: String?,
        moduleName: String?,
        topicSections: [TopicSection],
        relationshipSections: [RelationshipSection],
        declarations: [Declaration],
        referencesByIdentifier: [String: Reference]
    ) {
        self.identifier = identifier
        self.title = title
        self.abstract = abstract
        self.symbolKind = symbolKind
        self.roleHeading = roleHeading
        self.moduleName = moduleName
        self.topicSections = topicSections
        self.relationshipSections = relationshipSections
        self.declarations = declarations
        self.referencesByIdentifier = referencesByIdentifier
    }
}

