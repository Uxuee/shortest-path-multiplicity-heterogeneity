# Revision Pass 2 — literature and public-manuscript polish

Starting point: Pass1 commit fc42179e9aa21cc3856ad357941f20500bedaaa4 on independent_manuscript_revision_from_reviews.

- Removed internal title-page pass label; retained the approved title.
- Rewrote the abstract around the method and case study while retaining permutation invariance, radial-reference interpretation and missing original graph realizations/execution state.
- Expanded related work with five verified sources covering spatial networks, random geometric graphs, distance shells, shortest-path counts and spatial null models. Discussed the existing Ni graph-curvature application. See REFERENCES_VERIFIED_PASS2.md.
- Removed seven uncited inherited bibliography entries; retained three cited entries. Eight references now support the public text.
- Reduced repeated archived/recovery wording in the introduction and results. Kept essential Section4 provenance and the substantive Discussion limitations.
- Moved notebook evaluation-state details, Figure4 RNG sequence and unresolved final-bin/mean-reference-column discrepancy to the final Data and provenance statement; retained an explicit main-text pointer.
- Shortened all figure captions and Table2 caption. Figures1–2 remain labelled reproducible replacement schematics. Figure5 remains sample SD across three seeded realizations at fixed rg=3.
- Preserved every displayed equation, reported numerical result and figure asset. No graph generation, numerical experiments, baselines or schematic regeneration were run.

Validation: successful Tectonic build; twelve pages rendered and visually inspected; no unresolved citations or references, no overfull boxes. Three underfull-box warnings are cosmetic. PASS2_VALIDATION.json records comparisons and hashes. All changed files are under independent_manuscript; frozen folders and baseline refs were not modified.

Historical Pass1 documents remain unchanged. DIFF_PASS2_AGAINST_PASS1.patch records this pass against its starting source. Stop after Pass2.
