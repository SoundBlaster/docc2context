# CI – Coverage Gate: `Docc2contextCore.swift` ≥ 90%

## Objective
Unblock CI by raising `llvm-cov report` coverage for `Sources/Docc2contextCore/Docc2contextCore.swift` above the 90% threshold enforced by the coverage gate.

## Relevant PRD / Rules
- `DOCS/PRD/docc2context_prd.md` — Quality gates and regression prevention expectations (coverage is enforced by CI).
- `DOCS/RULES/01_TDD.md` — Add tests first to cover missing branches.

## Root Cause
`Docc2contextCommand.run(arguments:)` had several error-handling branches that weren’t exercised by tests:
- `CLIError` cases used only for user-facing strings.
- `catch let error as ValidationError` path for `ArgumentParser` validation failures.
- Generic `catch` fallback path for non-`LocalizedError` failures.

## Fix
- Added tests covering:
  - `Docc2contextCommand.CLIError` description strings for previously-uncovered cases.
  - A `ValidationError` scenario by invoking the CLI with an option missing its value.
  - The non-`LocalizedError` fallback path by injecting a `MarkdownGenerationPipeline` writer that throws a plain `Error`.

## Files Changed
- `Tests/Docc2contextCoreTests/Docc2contextCommandTests.swift`

## Validation Evidence
- `swift test --enable-code-coverage`
- `llvm-cov report … | rg 'Sources/Docc2contextCore/Docc2contextCore.swift'` now shows coverage ≥ 90% for that file.

