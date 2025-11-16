# D3 – Document Usage & Testing Workflow (Cycle 4)

## Objective
- Expand the README so contributors can discover CLI usage, fixtures, release gates, coverage tooling, and troubleshooting steps without digging through scattered docs.
- Wire a Markdown/doc validation step into CI plus a local helper script so documentation stays trustworthy.
- Back the README guarantees with XCTest coverage so regressions are caught automatically.

## References
- PRD Phase D table (Task D3) – README usage/testing documentation and doc lint requirement.
- Workplan §Phase D – D3 follows D2 coverage hardening.
- TODO entry `D3 Document Usage & Testing Workflow` (this session).

## Execution Notes
- Add README sections for fixture manifest usage, automation overview, and troubleshooting FAQ.
- Introduce `Scripts/lint_markdown.py` that enforces formatting + required headings and run it in a new `docs` CI job.
- Add XCTest coverage (`DocumentationGuidanceTests`) ensuring README strings stay present.
- Update PRD Phase D tracker, TODO list, and archive summary when complete.

## Status
- **2025-11-16** – README expanded with fixtures/testing/troubleshooting content, doc lint script + CI job added, and the new `DocumentationGuidanceTests` ensure the guidance remains present. Task ready for ARCHIVE once merged.
