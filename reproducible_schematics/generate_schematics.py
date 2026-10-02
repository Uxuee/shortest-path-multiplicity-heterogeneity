"""Deterministic explanatory replacements, NOT recovered submission figures.
Python 3.10+ standard library only. Run: python -B generate_schematics.py
Outputs stay beside this script under outputs/. No simulation ensembles are run.
"""
from pathlib import Path
from collections import deque
from itertools import combinations
from math import sqrt,cos,sin,pi,log
import json,html,hashlib,sys

BASE=Path(__file__).resolve().parent
OUT=BASE/'outputs';OUT.mkdir(exist_ok=True)
COL={'outside':'#b7c9df','inside':'#f6bbc5','shell':'#cf334f','source':'#152c41','target':'#d87908','path':'#dc850d'}

def bfs(n,edges,source):
    adj=[[] for _ in range(n)]
    for a,b in edges: adj[a].append(b);adj[b].append(a)
    for a in adj:a.sort()
    dist={source:0};count={source:1};parents={source:[]};queue=deque([source])
    while queue:
        u=queue.popleft()
        for v in adj[u]:
            if v not in dist:
                dist[v]=dist[u]+1;count[v]=0;parents[v]=[];queue.append(v)
            if dist[v]==dist[u]+1:count[v]+=count[u];parents[v].append(u)
    return dist,count,parents

def enumerate_paths(parents,s,t):
    if t==s:return [[s]]
    return [p+[t] for u in parents[t] for p in enumerate_paths(parents,s,u)]

def text(x,y,s,size=16,color='#243c50',anchor='start'):
    return f'<text x="{x:.2f}" y="{y:.2f}" font-family="Arial, sans-serif" font-size="{size}" fill="{color}" text-anchor="{anchor}">{html.escape(s)}</text>'

def make(name,title,subtitle,points,edges,source,rg,target=None,protocol=None):
    dist,count,parents=bfs(len(points),edges,source)
    shell=sorted(v for v in dist if dist[v]==rg);ball=sorted(v for v in dist if dist[v]<=rg)
    if target is None:target=max(shell,key=lambda v:(count[v],-v))
    assert target in shell and count[target]>1
    paths=enumerate_paths(parents,source,target)
    assert len(paths)==count[target]
    assert all(len(p)-1==rg and p[0]==source and p[-1]==target for p in paths)
    edgeset={tuple(sorted(e)) for e in edges}
    assert all(tuple(sorted((u,v))) in edgeset for p in paths for u,v in zip(p,p[1:]))
    path_edges={tuple(sorted((u,v))) for p in paths for u,v in zip(p,p[1:])}
    logs=[log(count[v]) for v in shell];mean=sum(logs)/len(logs)
    clog=(sum(abs(a-mean)**3 for a in logs)/len(logs))**(1/3)
    record={'status':'new reproducible schematic replacement; not recovered original',
      'protocol':protocol,'random_seed':None,'randomness':'none',
      'vertices':[{'id':i,'coordinates':p} for i,p in enumerate(points)],'edges':edges,
      'source':source,'target':target,'graph_radius':rg,'ball':ball,'shell':shell,
      'distances':dist,'shortest_path_counts':count,'target_shortest_paths':paths,
      'shell_log_counts':logs,'C_log':clog,'checks':{'all_target_paths_enumerated':True,'shortest_path_lengths_verified':True}}
    (OUT/(name+'.json')).write_text(json.dumps(record,indent=2)+'\n',encoding='utf8')
    svg=['<svg xmlns="http://www.w3.org/2000/svg" width="1100" height="690" viewBox="0 0 1100 690">',
      '<rect width="1100" height="690" fill="white"/>',text(35,36,title,25),text(35,63,subtitle,14),
      text(35,95,'(a) Graph ball and shell',19),text(575,95,'(b) All shortest paths to one shell target',19)]
    xy=[p[:2] for p in points];xmin=min(p[0] for p in xy);xmax=max(p[0] for p in xy);ymin=min(p[1] for p in xy);ymax=max(p[1] for p in xy)
    scale=min(450/(xmax-xmin),390/(ymax-ymin))
    for panel,left in enumerate([35,575]):
        positions=[(left+240+scale*(x-(xmin+xmax)/2),315-scale*(y-(ymin+ymax)/2)) for x,y in xy]
        for u,v in edges:
            x1,y1=positions[u];x2,y2=positions[v]
            color='#dbe3ed';width=1.2
            if dist.get(u,999)<=rg and dist.get(v,999)<=rg:color='#ecc0c9';width=1.8
            if panel==1 and tuple(sorted((u,v))) in path_edges:color=COL['path'];width=3.7
            svg.append(f'<line x1="{x1:.2f}" y1="{y1:.2f}" x2="{x2:.2f}" y2="{y2:.2f}" stroke="{color}" stroke-width="{width}"/>')
        for v,(x,y) in enumerate(positions):
            kind='source' if v==source else 'target' if panel==1 and v==target else 'shell' if v in shell else 'inside' if v in ball else 'outside'
            radius=6 if kind in ['source','target','shell'] else 3.8
            svg.append(f'<circle cx="{x:.2f}" cy="{y:.2f}" r="{radius}" fill="{COL[kind]}" stroke="white" stroke-width="0.7"/>')
            if v==source or (panel==1 and v==target):svg.append(text(x+9,y-9,'p' if v==source else 'q',18))
        if panel==0:
            svg.extend([text(left,550,f'r_g = {rg}     |B| = {len(ball)}     |S| = {len(shell)}',17),text(left,577,'B = {v : d_G(p,v) <= r_g}',17),text(left,602,'S = {v : d_G(p,v) = r_g}',17)])
        else:
            svg.extend([text(left,550,f'd_G(p,q) = {rg}     N_geo(p,q) = {count[target]}',17),text(left,577,'Orange edges: union of all shortest paths to q',15),text(left,602,'Collect log N_geo(p,v) over every v in S',15)])
    for x,label,kind in [(35,'source p','source'),(205,'inside ball','inside'),(395,'shell','shell'),(535,'outside ball','outside'),(735,'target q','target')]:
        svg.append(f'<circle cx="{x}" cy="634" r="5" fill="{COL[kind]}"/>');svg.append(text(x+12,639,label,14))
    svg.extend([text(35,673,'REPRODUCIBLE REPLACEMENT - explanatory graph only; not a recovered experimental realization',13,'#637487'),'</svg>'])
    (OUT/(name+'.svg')).write_text('\n'.join(svg)+'\n',encoding='utf8')
    return {'name':name,'nodes':len(points),'edges':len(edges),'source':source,'target':target,'radius':rg,'multiplicity':count[target],'C_log':clog}

points=[(x,y,0) for y in range(-4,5) for x in range(-4,5)]
edges=[(i,j) for i,j in combinations(range(len(points)),2) if abs(points[i][0]-points[j][0])+abs(points[i][1]-points[j][1])==1]
first=make('figure1_replacement','Graph ball, graph shell and shortest-path multiplicity','Unweighted undirected square lattice; graph distance counts edges.',points,edges,points.index((0,0,0)),4,points.index((3,1,0)),{'construction':'9 by 9 square grid; Manhattan nearest-neighbor edges'})
assert first['multiplicity']==4
points=[]
for i in range(60):
    r=1.2+3.8*(i+0.5)/60;theta=i*pi*(3-sqrt(5))
    points.append((r*cos(theta),r*sin(theta),2*sqrt(r-1)))
edges=set()
for i,p in enumerate(points):
    near=sorted((sum((a-b)**2 for a,b in zip(p,q)),j) for j,q in enumerate(points) if j!=i)[:4]
    for _,j in near:edges.add(tuple(sorted((i,j))))
source=20
second=make('figure2_replacement','The same definitions on an irregular spatial graph','Deterministic points on a Flamm surface (M = 1/2); ambient 3D union 4-NN edges, shown in x-y projection.',points,sorted(edges),source,3,protocol={'construction':'60 deterministic annular golden-angle points on z=2 sqrt(r-1)','r_formula':'1.2+3.8*(i+0.5)/60','theta_formula':'i*pi*(3-sqrt(5))','k':4,'metric':'ambient Euclidean 3D','symmetrization':'undirected union','display':'x-y projection','role':'definition illustration; no inference about curvature or submitted graph protocol'})
(OUT/'validation.json').write_text(json.dumps({'python':sys.version,'figures':[first,second],'validation':'BFS path counts checked by exhaustive target-path enumeration; grid count also equals binomial(4,1)'},indent=2)+'\n',encoding='utf8')
print(json.dumps([first,second]))
