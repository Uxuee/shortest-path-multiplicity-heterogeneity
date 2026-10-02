# Public-safety audit

## Release decision

The selected public snapshot passed the checks below. This is a content/privacy/size audit, not a guarantee against every possible undiscovered secret and not a scientific reproducibility validation. No scientific computation, figure generation or manuscript compilation was run.

## Checks

- No review pages, reviewer text, acceptance emails or private correspondence are included. The review-change ledger and associated internal planning material are omitted.
- Retained source/data/docs were scanned for review-page markers, common access-token/API-key/private-key patterns, personal absolute paths and credential-like assignments. No credential indicators were found. No local configuration, environment files, search logs, build caches or Git evidence bundles are included.
- Eighteen PDFs were inspected through extracted text and metadata; no suspicious local-path/review/credential markers or embedded attachments were found. Six PNG metadata records were checked. The only email in retained manuscript text/PDFs is the author contact already printed in the paper; it is not private correspondence.
- Machine-specific absolute paths were removed from public documentation and source-recovery records. Figure scripts now resolve repository-relative paths and use Tectonic on PATH or TECTONIC_BIN. Python syntax was checked without executing generators.
- Required manuscript, source, claims inventory, audit/editorial reports, figure design, schematic data, repair evidence, citation metadata and license-decision placeholder are present.
- SHA256 comparisons confirm manuscript.tex, manuscript.pdf and every manuscript figure asset match the pre-publication local archive exactly. No numerical result, caption, conclusion or error bar was changed.
- The provenance/source-recovery directories were explicitly screened. The former is a curated public subset; omissions and source-record sanitization are disclosed. The public subset has a fresh SHA256 manifest.
- Oversized bundles, the full exploratory notebook, repository ZIPs, unreachable Git objects and unrelated benchmark outputs are excluded. The largest retained file is the approximately2MB recovered baseline PDF. The selected package is approximately5.77MB before this report.
- The pre-existing GitHub history contains two README-only commits. Publication adds one audited snapshot on top; the local archive commit, exploratory branches, old tag objects and embedded historical bundles are not ancestors or objects reachable from the published branch/tag.

## Preservation and omissions

PUBLIC_OMISSIONS.md lists every omitted original tracked path. The complete local archive and the older historical/exploratory project remain available locally and are not published. Original protected historical files were not edited; public records with sanitized paths are explicitly derivatives. Historical reports retained here may reference omitted local evidence, and do not claim that all original provenance is public.

The full notebook is replaced by selected indexed input cells and saved output excerpts relevant to the retained claims. The new public manifest applies only to the subset. All underlying limitations, including missing original graph realizations and ambiguous execution state, remain.

## Published references

Commit message: Archive audited independent manuscript draft

Release tag: independent_draft_editorial_clean_oct2026

Remote: https://github.com/Uxuee/shortest-path-multiplicity-heterogeneity
