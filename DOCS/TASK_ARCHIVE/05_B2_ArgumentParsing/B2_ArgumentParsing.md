# B2 – Implement CLI Argument Parsing

## Objective
Replace the placeholder argument walker inside `Docc2contextCommand` with a real `swift-argument-parser`-powered implementation so that the failing CLI contract tests from task **B1** pass deterministically. This work unlocks downstream input detection (B3) plus logging/quality gates that rely on structured command inputs.

## References
- `DOCS/PRD/docc2context_prd.md` – Phase B table (task B2) plus priority metadata (High priority, 2 pts, requires swift-argument-parser).
- `DOCS/workplan.md` – Phase B sequencing showing B2 immediately after the completed B1 spec tests.
- `DOCS/todo.md` – B2 entry marked In Progress as of this selection note.
- Tests defined in `Tests/Docc2contextCoreTests/Docc2contextCLITests.swift` (B1 deliverable) describe the acceptance behaviors.

## Dependencies & Preconditions
- ✅ **B1** CLI interface tests exist and currently fail because parsing is still stubbed.
- ✅ **A2** harness utilities already exist to support CLI snapshot/failure tests.
- ⚠️ **A3** fixtures are still in progress but not a hard prerequisite for CLI argument parsing; just note that B3–B6 will require fixture availability.

## Definition of Done
1. Package manifest pulls in `swift-argument-parser` and wires it into both the library + executable targets without breaking Linux builds.
2. `Docc2contextCommand` (core target) exposes a representation that `swift-argument-parser` can drive, translating results back into the existing `Docc2contextCommandResult` type for tests.
3. `docc2context` executable entry point uses the new parser and ensures `--help`/`--version` output flows through the library helpers for deterministic logging.
4. All B1 tests pass locally via `swift test`, covering help text, missing argument failures, supported `--format` validation, and `--force` toggle behavior.
5. README/usage docs audited to confirm they reflect the implemented flags (update deferred unless gaps discovered during implementation).

## Test & Validation Plan
- Run `swift test --filter Docc2contextCLITests` iteratively until all assertions pass.
- Execute the full suite (`swift test`) to ensure no regressions in harness utilities.
- If `swift-argument-parser` adds runtime help output, capture/compare against `Docc2contextHelp.render()` to maintain deterministic text; add snapshot if necessary.

## Work Breakdown
- [x] Add `swift-argument-parser` to `Package.swift`, update `Package.resolved`, and ensure the dependency builds on Linux.
- [x] Refactor `Docc2contextCommand` to delegate parsing to a `ParsableArguments` helper backed by `ArgumentParser` instead of the manual loop.
- [x] Ensure `--format` validation hooks into the parser while maintaining the markdown-only restriction enforced by custom validation.
- [x] Preserve the existing `Docc2contextCommandResult` interface so the current tests remain valid; extend tests if parser introduces new behaviors (e.g., version flag), but only after initial green.
- [x] Document any follow-up tasks (e.g., CLI logging, `--version`) uncovered while integrating the parser and add TODO entries if necessary.

## Progress – 2025-11-14
- Added the `swift-argument-parser` dependency to both the core and executable targets and resolved it at v1.6.2 via `Package.resolved`.
- Introduced `Docc2contextCLIOptions` (a `ParsableArguments` helper) and rewired `Docc2contextCommand.run(arguments:)` to translate parser output into the existing `Docc2contextCommandResult` summaries and errors.
- Preserved the original help rendering while ensuring parser-generated validation errors surface deterministic text (missing input/output, unsupported `--format`, etc.).
- Verified the CLI contract by running `swift test`, which now reports all prior B1 interface tests passing under the new parser integration.【8dc085†L1-L33】
- Reviewed `README.md` to ensure the CLI usage section lists `--output`, `--format`, and `--force` with the behaviors now enforced by the parser; no updates required.

## Follow-ups
- None. CLI logging and `--version` enhancements will be scoped under later PRD items after the parsing foundation ships.

## Immediate Next Action
Archive this task (B2) and return to the planning flow to select the next ready item once fixtures (A3) unblock B3.
