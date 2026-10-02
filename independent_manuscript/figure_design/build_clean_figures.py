"""Redraw saved illustrative graphs only; no graph generation or scientific computation.
Run python -B figure_design/build_clean_figures.py
Requires pymupdf and Tectonic on PATH (or set TECTONIC_BIN).
"""
from pathlib import Path
import json, os, subprocess
import pymupdf as fitz
BASE=Path(__file__).resolve().parent
WORK=BASE.parent
ROOT=WORK.parent

env=dict(os.environ)
(ROOT/'tmp').mkdir(exist_ok=True)
(ROOT/'.cache/tectonic').mkdir(parents=True,exist_ok=True)
env.update(TEMP=str(ROOT/'tmp'),TMP=str(ROOT/'tmp'),TMPDIR=str(ROOT/'tmp'),TECTONIC_CACHE_DIR=str(ROOT/'.cache/tectonic'))
colors={'outside':'B7C9DF','inside':'F6BBC5','shell':'CF334F','source':'152C41','target':'D87908','path':'DC850D'}
for number in (1,2):
    data=json.loads((ROOT/f'reproducible_schematics/outputs/figure{number}_replacement.json').read_text())
    points=[v['coordinates'][:2] for v in data['vertices']]
    xs,ys=zip(*points);cx=(max(xs)+min(xs))/2;cy=(max(ys)+min(ys))/2
    scale=min(6.7/(max(xs)-min(xs)),6.2/(max(ys)-min(ys)))
    shell=set(data['shell']);ball=set(data['ball']);source=data['source'];target=data['target']
    path_edges={tuple(sorted((u,v))) for p in data['target_shortest_paths'] for u,v in zip(p,p[1:])}
    tex=[r'\documentclass[tikz,border=3pt]{standalone}',r'\usepackage{tikz}',r'\pagestyle{empty}',r'\setlength{\parindent}{0pt}']
    tex += [r'\definecolor{'+k+'}{HTML}{'+v+'}' for k,v in colors.items()]
    tex += [r'\begin{document}',r'\noindent\begin{tikzpicture}[x=1cm,y=1cm]',r'\path[use as bounding box] (0,0) rectangle (16,7.4);']
    for panel,center in enumerate((4,12)):
        pos=[(center+scale*(x-cx),3.6+scale*(y-cy)) for x,y in points]
        tex.append(r'\node[anchor=north west,font=\large] at ('+str(center-3.6)+',7.3) {('+('a' if panel==0 else 'b')+')};')
        for u,v in data['edges']:
            col='outside!55';width='0.45pt'
            if u in ball and v in ball:col='inside';width='0.65pt'
            if panel==1 and tuple(sorted((u,v))) in path_edges:col='path';width='1.4pt'
            tex.append(r'\draw['+col+',line width='+width+'] '+str(pos[u])+' -- '+str(pos[v])+';')
        for v,(x,y) in enumerate(pos):
            kind='source' if v==source else 'target' if panel==1 and v==target else 'shell' if v in shell else 'inside' if v in ball else 'outside'
            radius='2.5pt' if kind in ('source','target','shell') else '1.5pt'
            tex.append(r'\filldraw[fill='+kind+',draw=white,line width=0.3pt] '+str((x,y))+' circle ('+radius+');')
            if v==source or (panel==1 and v==target):
                label='p' if v==source else 'q'
                tex.append(r'\node[anchor=south west,inner sep=1pt,fill=white,font=\large] at '+str((x+0.08,y+0.08))+' {$'+label+'$};')
    tex += [r'\end{tikzpicture}',r'\end{document}']
    out=BASE/f'figure{number}_clean.tex';out.write_text('\n'.join(tex)+'\n')
    subprocess.run([os.environ.get('TECTONIC_BIN','tectonic'),'--keep-logs','--outdir',str(BASE),str(out)],cwd=WORK,env=env,check=True)
    (WORK/f'figures/figure{number}_clean.pdf').write_bytes(out.with_suffix('.pdf').read_bytes())
# Text-only redactions preserve every numerical vector path, marker and error bar.
checks=[]
for name in ('flamm_matched_flat_common_bins','binned_estimator_vs_logK','k_sensitivity_matched_flat_flamm_N1000_errors'):
    src=WORK/'figures'/(name+'.pdf');doc=fitz.open(src);page=doc[0]
    before=[str(d) for d in page.get_drawings()]
    titles=[b for b in page.get_text('blocks') if b[1]<1 and b[3]<10]
    assert len(titles)==1,(name,titles)
    title=titles[0];page.add_redact_annot(fitz.Rect(title[:4]),fill=False)
    page.apply_redactions(images=0,graphics=0,text=0)
    after=[str(d) for d in page.get_drawings()]
    # Drawing sequence numbers may shift when a text operation disappears.
    assert len(before)==len(after)
    dest=WORK/'figures'/(name+'_clean.pdf');doc.save(dest)
    checks.append({'source':src.name,'output':dest.name,'removed_text':title[4].strip(),'drawings_before':len(before),'drawings_after':len(after)})
(BASE/'figure_edit_checks.json').write_text(json.dumps(checks,indent=2)+'\n')
