# G1 Output Directory Safety Guard

## Summary
Prevented destructive runs where `docc2context` targets its input bundle as the output directory. The pipeline now rejects output paths that match or reside within the input bundle, avoiding accidental deletion when `--force` is used and aligning with the security principle to avoid unsafe filesystem operations.

## Context
- Origin: Security & Safety guidance in the agent instructions (reject invalid paths and avoid unsafe deletions during archive extraction/output prep).
- Note: Work began under `DOCS/INPROGRESS/G1_OutputOverlapSafety.md` and was completed via the START command.

## Changes
- Added validation to `MarkdownGenerationPipeline` that standardizes paths and throws `outputDirectoryOverlapsInput` when the output matches or nests inside the input bundle.
- Introduced two unit tests covering identical-path and nested-path scenarios to guard against regressions.

## Validation
- `swift test --filter MarkdownGenerationPipelineTests`

## Follow-ups
- None identified; the guard blocks the primary destructive path overlap scenario.
