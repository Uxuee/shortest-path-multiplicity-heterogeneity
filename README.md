# Shortest-Path Multiplicity Heterogeneity

This repository contains an independent manuscript draft and provenance package for the project:

**“Shortest-Path Multiplicity Heterogeneity as a Graph Diagnostic for Radial Organization in Sampled Geometries”**

The manuscript studies a shell-based graph observable, \(C_{\log}(p,r_g)\), defined from the dispersion of logarithmic shortest-path multiplicities from a source node to targets at fixed graph distance. The quantity is interpreted as **multiplicity heterogeneity**, not directional anisotropy: it is invariant under permutations of shell targets and does not encode directions by itself.

## Current status

This repository is an **audited independent draft**, not a fully reproducible final publication package.

The current manuscript:

- preserves the accepted/submitted manuscript lineage;
- corrects the terminology from “anisotropy” to “multiplicity heterogeneity”;
- preserves the archived numerical results for the Flamm–Schwarzschild versus matched-flat case study;
- corrects the interpretation of Figure 5 error bars;
- uses cleaned schematic and plot figures;
- includes a claims/provenance table;
- documents known provenance gaps.

The main numerical results are retained from archived plotting records and summaries. No new scientific computation was performed during the independent revision and editorial cleanup.

## Important limitations

This package does **not** claim exact end-to-end reproducibility of the original numerical experiments.

Known limitations include:

- original graph realizations were not recovered;
- the original notebook execution state was not recovered;
- some source definitions conflict across recovered versions;
- original point clouds, complete graphs, raw per-source path data, and complete node-to-bin assignments are unavailable;
- the current results should be read as an exploratory archived case study, not as a certified curvature reconstruction method.

The manuscript explicitly treats the Schwarzschild Kretschmann scalar as an external radial reference profile associated with the parent spacetime, not as intrinsic curvature of the sampled spatial graph.

## Repository structure

```text
independent_manuscript/
  manuscript.tex
  manuscript.pdf
  figures/
  figure_design/
  CLAIMS_AND_PROVENANCE_TABLE.md
  FINAL_AUDIT_REPORT.md
  FINAL_EDITORIAL_FIX_REPORT.md

computational_provenance_frozen/
  public-safe subset of plotting evidence, summaries, selected cells, and file hashes

provenance_repair/
  verification outputs, repair reports, and numerical traceability notes

reproducible_schematics/
  deterministic schematic graph data and generators for Figures 1–2

source_recovery/
  reconstructed manuscript source and baseline recovery records
```

## Figures

Figures 1–2 are reproducible schematic replacements. They are pedagogical illustrations and are not experimental graph realizations.

Figures 3–5 preserve the archived numerical plot data. The current versions remove in-figure titles for presentation clarity, but do not change plotted values, axes, or error bars.

Figure 5 error bars represent plus or minus one sample standard deviation across three seeded realizations at fixed \(r_g=3\). They are not variation across graph radii, standard errors, or confidence intervals.

## Claims and provenance

The file `independent_manuscript/CLAIMS_AND_PROVENANCE_TABLE.md` maps retained manuscript claims to available evidence. It distinguishes:

- empirical numerical results;
- protocol constants;
- mathematical definitions;
- illustrative schematic values;
- candidate implementation evidence;
- unresolved provenance gaps.

This distinction is important: the repository preserves and audits the historical evidence, but it does not silently reconstruct missing original graph states.

## Suggested citation

No formal citation is available yet. If citing this repository informally, use:

```text
A. U. Palomino Ylla, “Shortest-Path Multiplicity Heterogeneity as a Graph Diagnostic for Radial Organization in Sampled Geometries,” independent manuscript draft, 2026.
```

## Next steps for a stronger publication

A stronger publishable version should use a new, clean, versioned computational experiment rather than relying only on recovered historical provenance. Future work should include:

- saved point clouds, edge lists, graph realizations, seeds, and software environment;
- controlled matched-flat and spatial null ensembles;
- comparisons with simpler graph statistics such as shell size, degree, clustering, local edge scale, radial occupancy, and standard deviation of log multiplicities;
- comparison with established graph-curvature measures;
- controlled variation of \(N\), \(k\), \(r_g\), and construction rule;
- optional directional measurements if directional anisotropy claims are desired.

## License

No project-wide license has been selected. See LICENSE_TODO.md; inclusion does not grant a new license. Source-specific license notices are retained.

## Public-safety scope

This release excludes private review material, old Git bundles/history, unrelated exploratory outputs, local configuration and temporary build files. See [public-safety audit](PUBLIC_SAFETY_AUDIT.md) and [omissions](PUBLIC_OMISSIONS.md). The complete frozen archive is retained locally; the public provenance directory is a documented subset. Historical reports may refer to omitted local evidence.

The current [PDF](independent_manuscript/manuscript.pdf), [source](independent_manuscript/manuscript.tex) and [build instructions](independent_manuscript/BUILD.md) are included. Figure build scripts use repository-relative outputs and an installed Tectonic executable. Portability edits were statically checked; no generators were run during publication.
