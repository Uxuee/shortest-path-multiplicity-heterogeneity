import pymupdf as f,json
from pathlib import Path
from PIL import Image,ImageDraw
w=Path(__file__).resolve().parent.parent
checks=[]
for name in ['flamm_matched_flat_common_bins','binned_estimator_vs_logK','k_sensitivity_matched_flat_flamm_N1000_errors']:
 a=f.open(w/'figures'/(name+'.pdf'));b=f.open(w/'figures'/(name+'_clean.pdf'))
 rect=f.Rect(0,10,a[0].rect.width,a[0].rect.height)
 same=a[0].get_pixmap(matrix=f.Matrix(3,3),clip=rect).samples==b[0].get_pixmap(matrix=f.Matrix(3,3),clip=rect).samples
 assert same,name
 checks.append({'figure':name,'all_pixels_below_title_identical_at_216dpi':same})
d=f.open(w/'manuscript.pdf');out=w/'figure_design';thumbs=[]
for i,p in enumerate(d):
 pix=p.get_pixmap(matrix=f.Matrix(1,1));im=Image.frombytes('RGB',(pix.width,pix.height),pix.samples);im.thumbnail((420,600));tile=Image.new('RGB',(440,640),'#ddd');tile.paste(im,(10,25));ImageDraw.Draw(tile).text((10,5),str(i+1),fill='black');thumbs.append(tile)
for k in range(0,len(thumbs),4):
 canvas=Image.new('RGB',(880,1280),'white')
 for j,im in enumerate(thumbs[k:k+4]):canvas.paste(im,((j%2)*440,(j//2)*640))
 canvas.save(out/('review_%s.png'%(k//4+1)))
for n in [1,2]:
 p=f.open(w/'figures'/('figure%s_clean.pdf'%n));p[0].get_pixmap(matrix=f.Matrix(2,2)).save(out/('figure%s_clean.png'%n))
(w/'figure_design/VALIDATION.json').write_text(json.dumps({'pages':len(d),'numerical_plot_checks':checks},indent=2))
print(len(d),checks)
