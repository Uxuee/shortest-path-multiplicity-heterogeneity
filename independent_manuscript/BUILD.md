# Build the independent manuscript

The included PDF is the reviewed twelve-page draft. It was built with Tectonic0.16.9. No build or experiment was rerun during public-safety packaging.

From this directory, with Tectonic installed on PATH:

```sh
tectonic --keep-logs --keep-intermediates --outdir build manuscript.tex
```

Create build/ first. Configure TEMP, TMP and TMPDIR to an absolute path resolving to the repository tmp/ directory, and TECTONIC_CACHE_DIR to the repository .cache/tectonic directory. Create those directories before use. Preserve the inherited environment. No local font configuration is included. Copy build/manuscript.pdf to manuscript.pdf only after validation.

Current vector figure sources are in figure_design/figure1_clean.tex and figure2_clean.tex. The optional build_clean_figures.py uses stored schematic JSON and the original numerical plot PDFs, with no new scientific graph generation. It requires Python, PyMuPDF, and Tectonic (or TECTONIC_BIN); its temporary/cache paths are repository-relative. The validation script also requires Pillow. These portability-only edits were statically inspected, not executed during this publication pass.

Historic build logs, cache files and obsolete machine-specific validation snapshots are intentionally omitted. See ../PUBLIC_SAFETY_AUDIT.md.
