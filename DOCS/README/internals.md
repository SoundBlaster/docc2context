# Internals

## Internal model overview

<!-- INTERNAL_MODEL_DOC_START -->
`DoccInternalModelBuilder` wires the parsed metadata into a `DoccBundleModel` so subsequent Markdown + link graph generation can treat the internal model as the single source of truth. The model currently exposes:

- `DoccBundleModel` – top-level struct combining bundle metadata, `DoccDocumentationCatalog`, tutorial volumes, and `DoccSymbolReference` arrays.
- `DoccDocumentationCatalog` – captures the technology catalog identifier, title, and topic sections that seed tutorial ordering.
- `DoccTutorialVolume` – represents each technology catalog emitted by DocC; tutorial volumes preserve the order established by DocC so determinism is unaffected by filesystem traversal.
- `DoccTutorialChapter` – each chapter maps to a `DoccDocumentationCatalog.TopicSection`, and chapters maintain the DocC topic order described in the source JSON.
- `DoccSymbolReference` – symbol references stay sorted by identifier/module names to guarantee deterministic lookups once link graphs are generated.

Ordering guarantees:

1. `DoccTutorialVolume` instances are emitted in the order DocC writes technology catalogs (today fixtures contain a single catalog, but the builder will maintain order once multiple catalogs appear).
2. The chapters maintain the DocC topic order exposed in the catalog’s `topics` array, ensuring sequential tutorial walkthroughs remain intact.
3. Each `DoccTutorialChapter` retains the `pageIdentifiers` ordering provided by DocC so Markdown snapshots mirror DocC navigation.

This documentation is validated by `InternalModelDocumentationTests` to keep the docs synchronized with the internal model contract as serialization coverage expands.

Deterministic JSON encoding of `DoccBundleModel` is guarded by `DoccInternalModelSerializationTests` and the recorded snapshot at `Tests/__Snapshots__/DoccInternalModelSerializationTests/tutorial-catalog.json`, so Markdown generators can rely on a stable serialized representation.
<!-- INTERNAL_MODEL_DOC_END -->

