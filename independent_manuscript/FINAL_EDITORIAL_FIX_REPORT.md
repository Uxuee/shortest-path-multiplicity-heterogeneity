# Final editorial fix report

## Scope and outcome

The two editorial issues in FINAL_AUDIT_REPORT.md are addressed. This pass changes documentation, bibliography ordering/punctuation and one rendering-script pointer only. No scientific computation or figure-generation script was run. The manuscript remains twelve pages.

## Exact changes

1. CLAIMS_AND_PROVENANCE_TABLE.md explicitly inventories angular sampling [0,2π]; alternative boundary 2M+0.2=1.2; Figure3 candidate N1000/k16/seed1234; Figure4 candidate N500/k14/seed1234; its five-admissible-row bin threshold; three-decimal Spearman rounding; Figure1 illustrative radius4/multiplicity4; Figure2 radius3/distance3/multiplicity3; and the Flamm embedding z=2√[2M(r−2M)] with M=1/2. Rows distinguish protocol constants, mathematical definitions and illustrative values from empirical results. Candidate settings retain their execution-state qualification.
2. Replaced stale current-state descriptions of copied schematic PNGs and unchanged plot bytes with accurate descriptions of vector and title-free derivatives. Removed the stale assertion that anisotropy remains in plot titles; LogCMD remains on axes. Retained original-source and partial-provenance distinctions.
3. Added independent_manuscript/figure_design/build_clean_figures.py alongside reproducible_schematics in the table and manuscript data statement.
4. Reordered the same eight bibliography entries to first-citation order: Barthelemy2011, Penrose2003, CostaSilva2006, Brandes2001, Forman2003, Ollivier2009, Ni2019, Expert2011. Normalized terminal periods; existing DOI links uniformly use https://doi.org/... with punctuation outside the link. No DOI identifiers or references were added, removed or changed.
5. Recompiled manuscript.tex to manuscript.pdf and updated the retained build log. The earlier FINAL_AUDIT_REPORT.md is preserved as the historical audit; this report records resolution of its editorial findings.

## Verification

- PASS: generated LaTeX citation mappings are exactly1–8 in requested order; rendered Related Work citations and bibliography agree. No unresolved citation markers.
- PASS: direct source comparison confirms the entire manuscript outside the bibliography is identical except the single rendering-script pointer. All equations, scientific statements, numeric results, table bodies, captions and Figure5 uncertainty wording remain unchanged.
- PASS: SHA256 checks confirm every file in figures/ is unchanged from the start of this pass. No figures were regenerated.
- PASS: affected pages2,11,12 rendered and visually inspected for numbering, typography, path wrapping and bibliography layout. No clipping or overfull boxes. Three pre-existing underfull-box warnings remain cosmetic.
- PASS: all writes, build output, temporary files and caches used D:. No protected folder was modified.

Compilation and PDF inspection are document production, not scientific recomputation. The outstanding scientific provenance gaps remain exactly as disclosed; this pass does not resolve missing graph realizations or establish curvature specificity. Stopped after the requested editorial fixes.
