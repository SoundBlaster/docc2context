# B1 – CLI Interface Tests

## Objective
Define the docc2context CLI contract through XCTest cases that exercise required arguments (`input`, `--output`), supported flags (`--force`, `--format`), and error messaging so that subsequent implementation work has an unambiguous specification to satisfy.

## Relevant PRD Paragraphs
- PRD §Phase B (Table row B1) – requires specifying CLI arguments and error outputs before implementation.
- PRD §4.2 Functional Requirements (Input Handling & CLI Experience) – mandates argument layout, error codes, and help messaging.

## Test Plan
- Author XCTest cases under `Tests/Docc2contextCoreTests/` describing expected exit codes, stdout/stderr text, and default behaviors.
- Exercise combinations of `docc2context <input> --output <dir> [--format markdown] [--force]`.
- Validate failures for missing input/output, unsupported formats, and attempts to overwrite existing output without `--force`.
- Execute `swift test` locally and in CI to ensure regression coverage once B2 implements the parser.

## Dependencies
- **A2 – TDD Harness utilities**: rely on shared fixture/temp directory helpers for deterministic CLI tests. Current harness partially implemented; coordinate with A2 owner for reusable utilities once ready.
- Swift Argument Parser adoption planned in B2 to satisfy the tests.

## Blocking Questions
1. Should CLI expose shorthand aliases (`-o`, `-f`) in addition to long-form flags? Need confirmation from PRD/UX perspective.
2. Confirm desired exit code for validation errors (`EX_USAGE`/64 vs generic non-zero) to encode in tests.

## Checklist
- [x] Capture scope + validation plan in this INPROGRESS note.
- [x] Draft failing CLI tests for `--output` requirement and missing input handling.
- [x] Add coverage for `--force` overwrite semantics and confirmation messaging.
- [x] Specify supported formats (default `markdown`, future `json`) with failing tests for unsupported values.
- [x] Update README/usage docs once CLI contract solidified.

## Completion Summary — 2025-11-14
- Added `testForceFlagEnablesOverwriteMode` to verify that `--force` is accepted without values and that output text surfaces overwrite intent alongside the success exit code.
- Expanded CLI help + contract documentation in README (previous change) so B2+ tasks inherit a stable spec.
- Confirmed the test suite now covers missing input, missing `--output`, unsupported formats, help text documentation, and `--force` behavior per PRD §4.2 + Phase B table.

## Validation Evidence
- 2025-11-14 — `swift test` on Linux: `Docc2contextCLITests` and `Docc2contextCommandTests` executed 7 total tests with 0 failures (0 unexpected) in 0.212 seconds.

## Follow-Ups
- No immediate follow-ups surfaced beyond the planned B2 parser implementation. CLI shorthand aliases remain a backlog question for UX review.
