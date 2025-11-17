# D3 – Document Usage & Testing Workflow (Cycle 4)

## Overview
Documented the CLI usage, fixtures, automation workflow, and troubleshooting guidance required by Phase D3 while adding tooling that keeps README instructions trustworthy.

## Deliverables
1. **README Expansion** – Added sections for fixture usage, automation workflow, documentation linting, and a Troubleshooting & FAQ block so contributors can debug coverage, release gates, determinism, and Markdown lint failures without digging into `DOCS/`.
2. **Documentation Tests + Linting** – Introduced `DocumentationGuidanceTests` (XCTest) to guard key README strings and `Scripts/lint_markdown.py`, a helper invoked both locally and via a new CI `docs` job. The script enforces formatting (LF line endings, no tabs/trailing spaces) and asserts that required headings/snippets remain present.
3. **Process Updates** – CI no longer ignores documentation-only changes, and the docs job now gates Linux/macOS/determinism/coverage jobs. Phase D tracker + TODO list reflect the completion, and the INPROGRESS note captures execution details.

## Validation
- `swift test --filter DocumentationGuidanceTests` (red → green) followed by full `swift test`.
- `python3 Scripts/lint_markdown.py README.md DOCS/PRD/phase_d.md`.
- Verified the GitHub Actions workflow includes the new `docs` job and dependency chain.

## Status
**COMPLETE — 2025-11-16**
