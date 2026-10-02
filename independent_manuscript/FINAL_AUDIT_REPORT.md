# Final audit report

Audit date: 2026-10-02. Audited commit: 97173b2e804a1e3c0b16f71dea8be24a8a2b6cce, branch independent_manuscript_revision_from_reviews. Scope: the current 12-page independent manuscript, cleaned figures, captions, bibliography and claim inventory. This is an editorial/provenance audit, not an independent reproduction of results.

Only this report was written. Manuscript source/PDF, figures, claims table and protected folders were not modified. No compilation, graph generation, statistical recomputation or experiment was run. Checks used source/PDF text extraction, saved schematic metadata, the existing visual review and recorded plot-comparison validation. Bibliographic formatting and citation links were checked locally; this audit did not repeat the Pass2 online literature verification.

## Checklist

| Item | Result | Evidence and finding |
| --- | --- | --- |
| 1. Minimal Figures1–2 artwork | PASS | Extracted text from each clean PDF contains only (a), (b), p and q, with p repeated for the two panels. No titles, subtitles, paragraphs or equations remain. The inspected vector artwork has unclipped panel labels and LaTeX node typography. |
| 2. Self-contained captions | PASS | Both captions define B using distance <= radius, S using distance = radius, and d_G as shortest-path edge count. They identify dark source, light-pink interior, red shell, blue exterior, orange target and shortest-path edges, and explain that the statistic uses all shell targets. Both explicitly identify illustrative replacement schematics. The stated radius/multiplicity pairs (4,4) and (3,3) agree with stored schematic JSON; no path counting was rerun. |
| 3. Anisotropy terminology | PASS | Exactly one occurrence in manuscript.tex and the rendered PDF, in the Introduction (source line30; PDF page1): the explanation of earlier terminology. It is followed by the permutation-invariance qualification. No current scientific claim or clean figure title uses anisotropy. |
| 4. Figure5 uncertainty | PASS | Section5.4, caption, Table1 and Section4.3 consistently specify sample SD of realization-level Pearson correlations over three seeds, fixed r_g=3. Caption explicitly says seeds1–3 and +/- one sample SD. No claim that bars are variation across radii, SE or CI. Five-seed text estimates and the three-seed k=16 point remain distinguished. |
| 5. Every numerical claim explicitly inventoried | FAIL — documentation completeness | Every headline numerical result is covered, but several numeric protocol details and schematic values are only implicitly grouped under broad rows rather than explicitly listed. See inventory below. This is not evidence that those numbers are wrong. |
| 6. Data/provenance tone | PASS, with packaging note | The final statement is factual and professional. It states available evidence, specific missing data, the Figure4 conflict and the absence of exact end-to-end recovery without apologetic language. Keep these limitations. Its schematic-generator pointer does not yet name the new figure_design rendering layer. |
| 7. Bibliography formatting and order | FAIL — editorial polish | All eight bibliography keys are cited, all citations resolve, and entries are readable. However first-use numbers are 4,5,6,7,2,1,3,8, rather than an ordered numeric sequence. Ordering is neither alphabetical nor first-citation order. Terminal punctuation and DOI presentation differ between inherited and added entries. No target journal style has been specified; this is a consistency issue, not a universally prohibited citation style. |
| 8. Audit report and restricted scope | PASS | This report records all checks, remaining issues, archive suitability and proposed future experiments. No manuscript fixes or scientific work were performed. |

## Numerical inventory coverage

| Manuscript content | Claims-table coverage | Audit finding |
| --- | --- | --- |
| Flamm -0.960 +/-0.015 | Section5.1/Eq9 row: five-seed mean/sample SD, source files and settings | Explicitly covered. |
| Matched-flat 0.180 +/-0.315 | Section5.1/Eq10 row, same evidence/unit | Explicitly covered. |
| Pearson approximately0.912, 12 plotted bins | Section5.2/Eq11/Figure4 row | Explicitly covered, including plot-versus-table discrepancy. Abstract/caption repetitions refer to the same claim. |
| Spearman0.5320,0.5630,0.6636 at N200,500,1000 | Section5.3/Table2 row | Explicitly covered, with changing k/seed counts and saved-summary limitation. |
| Figure3 profile, separate realization/common bins | Figure3 row and protocol row | Covered at asset/analysis level, not as a transcription of every plotted coordinate. |
| Figure5 N1000; k12,14,16,18,20; three seeds; r_g3; 12 bins; sample SD | Figure5 row | Explicitly covered. Individual plotted values remain traceable via cited raw/summary files, not individually enumerated. |
| Radius[1.05,5], M1/2, ambient3D, radius multiplier1.15; alternative lower boundary1.2 | Construction rows | Covered. The exact alternative expression 2M+0.2 and full angular interval[0,2pi] are implicit rather than transcribed. |
| Shell exclusion <=2 and logarithmic offset10^-12 | Method/implementation row | Explicitly covered. |
| Figure3 candidate N1000,k16,seed1234; Figure4 candidate N500,k14,seed1234 | Table1 row and referenced notebook inputs | Grouped under result-specific settings; exact single-realization settings and seed1234 are not enumerated in the claims table itself. |
| Figure4 bins require at least five admissible rows | No explicit numeric entry | Missing explicit threshold. Add a protocol subrow pointing to the already identified binning routine, without treating it as certified graph-state recovery. |
| Spearman coefficients rounded to three decimal places before averaging | Table2 row says rounded, but does not state precision | Missing explicit three-decimal detail. |
| Figure1 r_g4,N_geo4; Figure2 r_g3,d_G3,N_geo3 | Replacement-schematic row only | Values not explicitly listed. Stored figure1_replacement.json and figure2_replacement.json confirm them. These are illustrative, not new experimental results. |
| K=48M^2/r^6 and affine log relation; cubic-moment definition | Reference/definition rows | Covered as mathematical definitions, not estimated numerical results. The Flamm embedding formula is not separately enumerated. |

A literal complete numeric inventory should distinguish empirical results, protocol constants, mathematical definitions and illustrative schematic values. Bibliographic years, page ranges, equation numbers and figure numbers are identifiers rather than numerical scientific claims. The existing table is sufficient to locate the main results but does not yet meet the strict every-number standard requested here.

## Remaining issues and recommended editorial actions — not applied

1. Expand the claims table with the explicit protocol and schematic details above. Retain the distinction between recovered summaries, candidate implementation evidence and unrecovered original graph state.
2. Update current-state asset descriptions in that table. Its main rows still say figure bytes are unchanged and schematic PNGs were copied; a later addendum correctly explains the clean derivatives, but readers must reconcile the two. Its older sentence about anisotropy labels remaining in plots is stale after title removal; LogCMD remains on axes.
3. Add the current independent_manuscript/figure_design/build_clean_figures.py rendering pointer alongside reproducible_schematics in the data statement or accompanying documentation. The latter remains the correct location for original replacement-graph data, but not the complete route to the new vector artwork. No public repository/deposit URL has been established by the statement; include the supporting files when archiving.
4. Normalize bibliography punctuation and choose one ordering convention. For first-citation numeric order, use Barthelemy2011, Penrose2003, CostaSilva2006, Brandes2001, Forman2003, Ollivier2009, Ni2019, Expert2011. Renumber through LaTeX and inspect the rebuilt PDF in a separately authorized edit pass.
5. Preserve substantive unresolved issues: missing original realizations/kernel state, incompatible construction definitions, missing raw/bin-membership data, and the unexplained Figure4 final-bin/mean-reference discrepancy. None was resolved by artwork cleanup or this audit.

The earlier figure validation records identical pixels below the removed title bands at216dpi for Figures3–5. This audit read that record rather than rerunning its comparison. No change to numerical content was found by this review.

## Suitability as an archived independent draft

**Yes, with the stated limitations and this audit attached.** It is suitable as a clearly identified exploratory independent draft supported by partial computational provenance. The two failed checks are documentation/formatting issues and do not overturn the displayed results. This is not certification of exact computational reproducibility, curvature specificity, statistical adequacy for journal acceptance, or submission readiness. Keep source, PDF, original assets, clean derivatives, generation scripts and provenance records together. Address the small editorial issues before presenting it as a polished submission.

## New work needed for a stronger publication — proposed only

1. Establish one explicit construction protocol and run a new, versioned realization ensemble with saved point clouds, edge lists, seeds/RNG state, path counts, bin assignments and software environment. Label it new computation, not recovery of the historical graphs. Determine replication adequacy from a documented precision target; do not presume three seeds suffice.
2. Strengthen matched-flat controls by comparing sampling measure, radial occupancy, local edge scale, degree/shell sizes and boundary exposure. Study domain and boundary sensitivity and distinguish ambient-distance, intrinsic-distance and edge-rule effects.
3. Compare C_log with standard deviation of log counts, shell size, degree, clustering, occupancy and edge scale on the same graphs and analysis units. Test whether it adds information beyond those baselines.
4. Use homogeneous isotropic spatial null ensembles under the same construction and measure their multiplicity fluctuations. Additional graph null ensembles can address different structural confounders but should not replace spatial controls.
5. Separate generic radial association from geometric specificity: compare an intrinsic reference for the sampled surface and established graph-curvature measures, while controlling the radial trend and construction differences. Such results would support a stronger interpretation only if the controls warrant it.
6. Design a controlled N/connectivity-scale/r_g study with realization-level uncertainty and unrounded stored coefficients. Current Table2 changes N, k and seed counts together; current Figure5 covers fixed r_g only.
7. Add directional measurements only if directional-anisotropy claims are desired. Additional geometries or real-data benchmarks are optional scope extensions, not prerequisites for preserving the present narrow story.

No listed study was launched, and no additional numerical claim is made here.

## Audited artifact fingerprints

- manuscript.tex SHA256: ed71b400ec65d56954f64b9e2cce7157340462168ffd767c4bbfc01af2ef3dc6
- manuscript.pdf SHA256: 2132fd3508a63d389b229fd812583f3c5616968f147650fc90ce86d977883af5

These identify the unchanged files to which this report applies.
