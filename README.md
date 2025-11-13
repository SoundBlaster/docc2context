# docc2context
Utility to convert DocC bundles into deterministic Markdown + link graphs suitable for LLM ingestion.

## Getting Started

docc2context is a Swift Package Manager workspace targeting Swift 5.9.

```bash
swift build
```

Running the executable today prints a bootstrap placeholder message. Future tasks will flesh out the CLI flags and conversion pipeline described in the PRD.

## Testing

Use `swift test` to exercise the XCTest bundle. The GitHub Actions workflow mirrors this command on both Ubuntu and macOS runners.

```bash
swift test --enable-code-coverage
```
