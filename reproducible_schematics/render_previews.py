"""Optional SVG previews. Requires PyMuPDF 1.28.2 (used for this repair)."""
from pathlib import Path
import pymupdf
p=Path(__file__).resolve().parent/'outputs'
for name in ['figure1_replacement','figure2_replacement']:
    d=pymupdf.open(p/(name+'.svg'))
    d[0].get_pixmap().save(p/(name+'.png'))
