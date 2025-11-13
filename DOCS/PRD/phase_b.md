# Phase B – CLI Contract & Input Validation

**Progress Tracker:** `0/6 tasks complete (0%)`

- [ ] **B1 – Specify CLI Interface via Failing Tests**
  - Write XCTest cases describing required arguments, flags, and error messages.
  - Include help/usage snapshot expectations to lock UI text.
  - Document scenarios (missing input, invalid output path) to ensure coverage before implementation.
- [ ] **B2 – Implement Argument Parsing to Satisfy Tests**
  - Use `swift-argument-parser` to wire flags defined in B1; keep parsing logic minimal and testable.
  - Ensure `--help`, `--version`, verbosity, and dry-run behaviors match the snapshots.
  - Update README usage snippet to mirror the verified interface.
- [ ] **B3 – Detect Input Type**
  - Implement validation that distinguishes DocC directories vs `.doccarchive` bundles and rejects invalid paths.
  - Normalize to bundle layout and surface explicit error messages when expectations are not met.
  - Cover permutations via unit tests using fixtures and temporary directories.
- [ ] **B4 – Extract Archive Inputs**
  - Provide deterministic extraction routine for `.doccarchive` inputs with stable temp paths and cleanup.
  - Record hash/log output so determinism scripts can compare runs.
  - Extend tests with fixture archives verifying behavior under repeated execution.
- [ ] **B5 – Parse DocC Metadata**
  - Load `Info.plist`, documentation catalog data, tutorials, and symbol graph references.
  - Handle corrupted/missing files with descriptive error types bubbled to the CLI layer.
  - Add fixtures and tests ensuring metadata structures are populated correctly.
- [ ] **B6 – Build Internal Model**
  - Define Swift structs/classes representing tutorials, articles, symbols, and metadata relationships.
  - Serialize/deserialize the model in tests to guarantee stability for downstream Markdown generation.
  - Capture notes on how the model maps to Phase C generators for easy reference.
