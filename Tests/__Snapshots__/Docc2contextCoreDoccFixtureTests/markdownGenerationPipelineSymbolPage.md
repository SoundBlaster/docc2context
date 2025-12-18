# MarkdownGenerationPipeline

## Symbol Metadata
- **Identifier:** doc://Docc2contextCore/documentation/Docc2contextCore/MarkdownGenerationPipeline
- **Module:** Docc2contextCore
- **Symbol Kind:** struct
- **Role Heading:** Structure
- **Catalog Identifier:** doc://Docc2contextCore/documentation/Docc2contextCore
- **Catalog Title:** Docc2contextCore

## Summary
Converts a DocC bundle into deterministic Markdown and a link graph.

## Discussion

### Overview

Use this type when you want a , filesystem-based export that is suitable for feeding into downstream tooling (for example, LLM context ingestion) without requiring Xcode.

The pipeline is designed to be:

### Usage

Convert a DocC archive directory to Markdown:

## Declarations
```swift
struct MarkdownGenerationPipeline
```

## Topics

### Structures
- MarkdownGenerationPipeline.Summary

### Initializers
- init(fileManager:metadataParser:modelBuilder:renderer:linkGraphBuilder:markdownWriter:dataWriter:)

### Instance Methods
- generateMarkdown(from:to:forceOverwrite:technologyFilter:symbolLayout:)

### Enumerations
- MarkdownGenerationPipeline.Error
- MarkdownGenerationPipeline.SymbolLayout
