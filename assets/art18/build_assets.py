"""Deterministic, editable GUT CREW mesh authoring; no downloads or bpy required.
Y-up, meters, character faces -Z to match the existing Godot controller.
Run: python build_assets.py. Dependencies: numpy, scipy (already present here).
This creates OFFLINE ART CANDIDATES, never modifies the live project.
"""
from pathlib import Path
import json, struct, math, hashlib
import numpy as np

def PchipInterpolator(x, values, axis=0):
    """Bounded cubic Hermite authoring interpolation; numpy only for Blender."""
    x=np.asarray(x);v=np.asarray(values); h=np.diff(x); sec=np.diff(v,axis=0)/h[:,None]
    slopes=np.zeros_like(v);slopes[0]=sec[0];slopes[-1]=sec[-1]
    for i in range(1,len(x)-1):
        same=sec[i-1]*sec[i]>0
        slopes[i,same]=2*sec[i-1,same]*sec[i,same]/(sec[i-1,same]+sec[i,same])
    def evaluate(t):
        j=int(np.clip(np.searchsorted(x,t)-1,0,len(x)-2));u=(t-x[j])/h[j]
        return (2*u**3-3*u**2+1)*v[j]+(u**3-2*u**2+u)*h[j]*slopes[j]+(-2*u**3+3*u**2)*v[j+1]+(u**3-u**2)*h[j]*slopes[j+1]
    return evaluate

OUT = Path(__file__).resolve().parent
TAU = math.tau

def rgb(h):
    a = np.array([int(h[i:i+2],16)/255 for i in (0,2,4)])
    return np.where(a <= .04045, a/12.92, ((a+.055)/1.055)**2.4).tolist()

MATERIALS = [
    ('Saffron clay','e8b64f',.87,0), ('Deep teal cloth','38676b',.95,0),
    ('Cream ceramic','f3e4bd',.73,0), ('Ink eyes','233c43',.34,0),
    ('Terracotta blush','c97849',.96,0), ('Copper contacts','aa7045',.52,.35),
    ('Warm seam','b78238',.95,0), ('Eye highlight','fff5d5',.35,0),
    ('Soft sole','354e51',.94,0), ('Inner tissue','986476',.89,0),
    ('Tissue ridge','bb8490',.86,0), ('Muscle crevice','684753',.95,0),
    ('Moss mucus','7e925b',.47,0), ('Warm beacon','f5cd78',.6,0),
    ('Violet vein','74576d',.92,0), ('Tissue floor','ac7a75',.92,0),
]

class Scene:
    def __init__(self, name):
        self.name=name; self.parts=[]; self.pivots={}
    def add(self,name,v,f,material,group='Static',pivot=(0,0,0)):
        v=np.asarray(v,dtype=np.float64); f=np.asarray(f,dtype=np.int64)
        cross=np.cross(v[f[:,1]]-v[f[:,0]],v[f[:,2]]-v[f[:,0]])
        f=f[np.linalg.norm(cross,axis=1)>1e-10]
        self.parts.append(dict(name=name,v=v,f=f,material=material,group=group))
        old=self.pivots.setdefault(group, list(pivot))
        assert np.allclose(old,pivot), (group,old,pivot)
    def loft(self,name,profile,material,center=(0,0,0),n=40,rings=30,
             exponent=1.0,clay=.003,group='Static',pivot=(0,0,0)):
        """Sculpted outline: profile rows y, half-width, half-depth, x-offset, z-offset.
        Pole vertices are shared; periodic seam is welded, not duplicated.
        """
        p=np.array(profile,float); interp=PchipInterpolator(p[:,0],p[:,1:],axis=0)
        ys=np.linspace(p[0,0],p[-1,0],rings+2)[1:-1]; v=[]
        def point(y,t):
            rx,rz,ox,oz=interp(y); co=math.cos(t); si=math.sin(t)
            wob=1+clay*(math.sin(5*t+3*y)+.6*math.sin(11*t-7*y))
            return [ox+rx*np.sign(co)*abs(co)**exponent*wob,
                    y,oz+rz*np.sign(si)*abs(si)**exponent*wob]
        for y in ys:
            v.extend(point(y,TAU*j/n) for j in range(n))
        bottom=len(v); v.append([p[0,3],p[0,0],p[0,4]])
        top=len(v); v.append([p[-1,3],p[-1,0],p[-1,4]])
        f=[]
        for i in range(rings-1):
            for j in range(n):
                a=i*n+j;b=i*n+(j+1)%n;c=(i+1)*n+j;d=(i+1)*n+(j+1)%n
                f.extend(((a,c,b),(b,c,d)))
        for j in range(n):
            f.extend(((bottom,j,(j+1)%n), (top,(rings-1)*n+(j+1)%n,(rings-1)*n+j)))
        self.add(name,np.array(v)+center,f,material,group,pivot)
    def pebble(self,name,center,scale,material,n=22,rings=16,exp=1,clay=.002,
               group='Static',pivot=(0,0,0)):
        ys=np.linspace(-1,1,11)
        p=[[y*scale[1], math.sqrt(max(0,1-y*y))*scale[0],
            math.sqrt(max(0,1-y*y))*scale[2],0,0] for y in ys]
        self.loft(name,p,material,center,n,rings,exp,clay,group,pivot)
    def tube(self,name,points,radius,material,sides=10,group='Static',pivot=(0,0,0)):
        pts=np.asarray(points,float); v=[]
        rs=np.broadcast_to(radius,(len(pts),))
        for i,p in enumerate(pts):
            t=pts[min(i+1,len(pts)-1)]-pts[max(0,i-1)];t/=np.linalg.norm(t)
            ref=np.array([0,1,0]) if abs(t[1])<.9 else np.array([0,0,1])
            a=np.cross(t,ref); a/=np.linalg.norm(a); b=np.cross(t,a)
            v.extend(p+rs[i]*(math.cos(j*TAU/sides)*a+math.sin(j*TAU/sides)*b) for j in range(sides))
        f=[]
        for i in range(len(pts)-1):
            for j in range(sides):
                a=i*sides+j;b=i*sides+(j+1)%sides;c=a+sides;d=b+sides
                f.extend(((a,b,c),(b,d,c)))
        start=len(v);v.append(pts[0]);end=len(v);v.append(pts[-1])
        for j in range(sides):
            f.extend(((start,(j+1)%sides,j),(end,(len(pts)-1)*sides+j,(len(pts)-1)*sides+(j+1)%sides)))
        self.add(name,v,f,material,group,pivot)

def spark():
    s=Scene('Spark_Art18_OfflineCandidate')
    body=(0,.78,0);head=(0,1.58,-.02)
    s.loft('Tailored_suit',[[-.51,0,0,0,0],[-.43,.29,.24,0,0],[-.22,.39,.30,0,0],
        [.07,.37,.30,0,0],[.29,.32,.24,0,0],[.45,.21,.17,0,0],[.48,0,0,0,0]],
        0,body,exponent=.8,group='SparkBody',pivot=body)
    s.loft('Hand_shaped_head',[[-.51,0,0,0,0],[-.46,.29,.28,0,-.025],
        [-.30,.46,.39,-.015,-.01],[0,.56,.46,0,0],[.28,.52,.43,.01,.005],
        [.43,.39,.32,.01,0],[.51,.18,.16,0,0],[.535,0,0,0,0]],
        0,head,n=48,rings=38,clay=.003,group='SparkHead',pivot=head)
    def hp(name,c,sc,m,**kw):s.pebble(name,c,sc,m,group='SparkHead',pivot=head,**kw)
    def ht(name,p,r,m,**kw):s.tube(name,p,r,m,group='SparkHead',pivot=head,**kw)
    for side in (-1,1):
        x=side*.205
        hp('Inset_eye_socket', (x,1.65,-.421),(.162,.194,.064),6)
        hp('Cream_eye',(x,1.661,-.461),(.136,.166,.057),2)
        hp('Curious_pupil',(x+.017,1.654,-.506),(.077,.105,.029),3)
        hp('Glint',(x-.006,1.700,-.529),(.022,.025,.007),7,n=16,rings=12)
        hp('Pressed_cheek',(side*.365,1.48,-.359),(.100,.061,.018),4)
        s.tube('Expressive_brow',[(side*(.08+.25*t),1.876+.027*math.sin(t*math.pi),-.414+.052*t)
            for t in np.linspace(0,1,13)],.026,6,group='SparkBrow'+('L' if side<0 else 'R'),pivot=(side*.24,1.87,-.50))
        hp('Ear_cushion',(side*.51,1.6,.015),(.080,.179,.170),1)
        hp('Ear_plug',(side*.56,1.6,.015),(.037,.112,.104),5)
        ht('Temple_clay_press',[(side*(.459+.015*math.sin(t*math.pi)),1.73+.16*t,-.235+.035*t)
            for t in np.linspace(0,1,10)],.0085,6,sides=6)
    s.tube('Sculpted_smile',[(x,1.437-.037*(1-(x/.145)**2),-.487+.028*(x/.145)**2)
        for x in np.linspace(-.145,.145,22)],.017,6,group='SparkMouth',pivot=(0,1.37,-.52))
    hp('Button_nose',(.002,1.528,-.486),(.059,.046,.043),0)
    for side in (-1,1):
        arm=(side*.52,.82,0); leg=(side*.22,.24,0);glove=(side*.67,.48,-.04)
        s.loft('Padded_sleeve',[[-.31,0,0,0,0],[-.25,.12,.125,side*.07,0],
            [0,.155,.16,0,0],[.20,.15,.14,-side*.05,0],[.27,0,0,-side*.06,0]],
            1,arm,n=28,rings=20,group='SparkArm'+('L' if side<0 else 'R'),pivot=arm)
        g='SparkGlove'+('L' if side<0 else 'R')
        s.pebble('Sculpted_mitten',glove,(.155,.176,.155),2,group=g,pivot=glove)
        s.pebble('Mitten_thumb',(glove[0]-side*.105,glove[1]+.015,-.135),(.09,.12,.09),2,group=g,pivot=glove)
        s.tube('Glove_fold',[(glove[0]+side*.08,.425,-.17), (glove[0],.414,-.191),
            (glove[0]-side*.05,.433,-.174)],.008,6,group=g,pivot=glove,sides=6)
        g='SparkLeg'+('L' if side<0 else 'R')
        s.pebble('Trouser_leg',leg,(.129,.225,.136),1,group=g,pivot=leg)
        foot=(side*.22,.160,-.12)
        s.pebble('Rounded_work_boot',foot,(.191,.149,.249),2,exp=.7,group=g,pivot=leg)
        s.pebble('Rubber_sole',(side*.22,.047,-.12),(.199,.046,.257),8,exp=.7,group=g,pivot=leg)
        for k in range(2):
            s.tube('Boot_lace',[(side*.22-.09,.267-k*.02,-.16-k*.055),
                (side*.22,.281-k*.02,-.165-k*.055),(side*.22+.09,.267-k*.02,-.16-k*.055)],
                .011,6,group=g,pivot=leg,sides=6)
        prong=(side*.22,2.34,0);g='SparkProng'+('L' if side<0 else 'R')
        s.pebble('Insulated_base',(side*.225,2.092,.005),(.145,.082,.123),1,group=g,pivot=prong)
        s.tube('Bent_conductor',[(side*(.22+.05*t*t),2.10+.49*t,.01-.027*t)
            for t in np.linspace(0,1,18)],np.linspace(.073,.06,18),5,sides=16,group=g,pivot=prong)
        s.pebble('Contact_tip',(side*.27,2.60,-.017),(.070,.059,.066),2,group=g,pivot=prong)
        for y in (2.17,2.25):
            s.tube('Insulator_ridge',[(side*.226+.077*math.cos(t),y,.01+.074*math.sin(t))
                for t in np.linspace(0,TAU,33)],.015,2,sides=8,group=g,pivot=prong)
    s.pebble('Canvas_front_bib',(0,.93,-.273),(.258,.27,.058),1,exp=.72,group='SparkBody',pivot=body)
    for side in (-1,1):
        s.tube('Padded_shoulder_strap',[(side*.21,1.18,-.205),(side*.225,1.09,-.292),
            (side*.218,.94,-.326),(side*.2,.76,-.312)],.032,2,group='SparkBody',pivot=body)
        s.pebble('Strap_button',(side*.216,.956,-.352),(.03,.03,.012),5,n=16,rings=12,group='SparkBody',pivot=body)
    s.tube('Utility_belt',[(.398*math.cos(t),.582,.316*math.sin(t)) for t in np.linspace(0,TAU,61)],
        .035,8,group='SparkBody',pivot=body)
    s.pebble('Soft_tool_pouch',(-.315,.63,-.172),(.128,.143,.105),6,exp=.65,group='SparkBody',pivot=body)
    # Embossed lightning emblem is a closed extrusion, not a decal.
    poly=np.array([[-.019,1.091],[.081,1.091],[.012,.968],[.079,.968],[-.056,.792],[-.012,.940],[-.076,.940]])
    v=[[x,y,z] for z in (-.342,-.365) for x,y in poly];n=len(poly)
    f=[]
    # Concave lightning polygon: explicit triangles avoid fan self-overlap.
    tris=[(0,1,2),(0,2,6),(6,2,5),(5,2,3),(5,3,4)]
    for a,b,c in tris:f.extend(((a,b,c),(a+n,c+n,b+n)))
    for i in range(n):j=(i+1)%n;f.extend(((i,i+n,j),(j,i+n,j+n)))
    s.add('Raised_lightning_badge',v,[(a,c,b) for a,b,c in f],0,'SparkBody',body)
    s.pebble('Battery_backpack',(0,.88,.294),(.28,.325,.15),1,exp=.68,group='SparkBody',pivot=body)
    s.pebble('Battery_panel',(0,.90,.423),(.208,.221,.027),2,exp=.6,group='SparkBody',pivot=body)
    s.tube('Coiled_charge_cable',[(.30+.056*math.cos(t),.72+.019*t,.225+.056*math.sin(t))
        for t in np.linspace(0,5*TAU,121)],.017,5,sides=8,group='SparkBody',pivot=body)
    return s

def corridor():
    s=Scene('Rugae_Passage_Art18_OfflineCandidate'); n=80;m=65
    def center(t):return .24*math.sin(math.pi*t), .04*t, 8*t-4
    def section(t,a,outer=0):
        cx,cy,z=center(t); wave=.09*math.cos(10*math.pi*t+1.4*math.sin(a))
        r=3.07+.12*math.sin(2*math.pi*t)+wave+outer
        x=cx+r*math.cos(a)
        y=cy+.12+(5.2+.14*math.sin(3*math.pi*t)+wave+outer)*max(math.sin(a),0)
        y+= (.30+outer)*min(math.sin(a),0)
        # Baked longitudinal muscle folds, not a pile of floating spheres.
        fold=.082*(.5+.5*math.cos(20*a+1.1*math.sin(t*5)))**3*max(math.sin(a),0)
        x-=math.cos(a)*fold;y-=math.sin(a)*fold
        return [x,y,z]
    v=[section(t,a,o) for o in (0,.26) for t in np.linspace(0,1,m) for a in np.linspace(0,TAU,n,endpoint=False)]
    f=[]; layer=n*m
    for k in (0,1):
        for i in range(m-1):
            for j in range(n):
                a=k*layer+i*n+j;b=k*layer+i*n+(j+1)%n;c=a+n;d=b+n
                # Inner face into tunnel, outer face away from tunnel.
                f.extend(((a,c,b),(b,c,d)) if k==0 else ((a,b,c),(b,d,c)))
    for i in (0,m-1):
        for j in range(n):
            a=i*n+j;b=i*n+(j+1)%n;c=a+layer;d=b+layer
            f.extend(((a,b,c),(b,d,c)) if i==0 else ((a,c,b),(b,c,d)))
    s.add('Continuous_double_skin_tunnel',v,f,9)
    # Rugae follow the inside of the same arch and terminate at the actual floor.
    for k,t in enumerate(np.linspace(.025,.975,9)):
        pts=[]
        for a in np.linspace(.015,math.pi-.015,65):
            q=np.array(section(t+.01*math.sin(a*3+k),a));q[0]-=.05*math.cos(a);q[1]-=.05*math.sin(a);pts.append(q)
        s.tube('Fleshy_arch_%02d'%k,pts,.085+.012*math.sin(k),10,sides=12)
    # Unbroken walkable middle, shallow rolled lips along both edges.
    for side in (-1,1):
        pts=[(center(t)[0]+side*2.53,.14+center(t)[1]+.025*math.sin(15*t),center(t)[2])
            for t in np.linspace(0,1,81)]
        s.tube('Raised_floor_margin',pts,.115,15,sides=12)
        for k,t in enumerate(np.linspace(.06,.94,6)):
            cx,cy,z=center(t)
            s.pebble('Beacon_cup',(cx+side*2.56,cy+.28,z),(.17,.12,.19),12,n=20,rings=14)
            s.pebble('Warm_path_pearl',(cx+side*2.56,cy+.37,z),(.09,.10,.09),13,n=20,rings=14)
        for q in range(3):
            pts=[(center(t)[0]+side*(2.98-.12*q),.35+q*.27+.045*math.sin(18*t+q),center(t)[2])
                for t in np.linspace(0,1,100)]
            s.tube('Embedded_long_vein',pts,.025,14,sides=8)
    return s

def vertex_normals(v,f):
    n=np.zeros_like(v);c=np.cross(v[f[:,1]]-v[f[:,0]],v[f[:,2]]-v[f[:,0]])
    for k in range(3):np.add.at(n,f[:,k],c)
    length=np.linalg.norm(n,axis=1); assert np.all(length>1e-12)
    return n/length[:,None]

def export_glb(s,path):
    chunks=bytearray();views=[];acc=[];meshes=[];nodes=[]
    def accessor(a,kind,target):
        a=np.ascontiguousarray(a);offset=len(chunks);chunks.extend(a.tobytes())
        while len(chunks)%4:chunks.append(0)
        views.append(dict(buffer=0,byteOffset=offset,byteLength=a.nbytes,target=target))
        d=dict(bufferView=len(views)-1,componentType=5126 if a.dtype.kind=='f' else 5125,count=len(a),type=kind)
        if kind=='VEC3':d.update(min=a.min(axis=0).tolist(),max=a.max(axis=0).tolist())
        acc.append(d);return len(acc)-1
    mats=[dict(name=name,pbrMetallicRoughness=dict(baseColorFactor=rgb(c)+[1],metallicFactor=metal,roughnessFactor=rough))
        for name,c,rough,metal in MATERIALS]
    root=dict(name=s.name,children=[],extras=dict(stage='OFFLINE_CANDIDATE',physics='NONE',source='build_assets.py',facing='-Z',unit='meter'))
    nodes.append(root)
    for group,pivot in s.pivots.items():
        group_index=len(nodes);root['children'].append(group_index)
        g=dict(name=group,translation=pivot,children=[]);nodes.append(g)
        # Merge by material within animation group: preserve pivots without excessive draw calls.
        for material in sorted(set(p['material'] for p in s.parts if p['group']==group)):
            parts=[p for p in s.parts if p['group']==group and p['material']==material]
            verts=[];faces=[];offset=0
            for p in parts:verts.append(p['v']);faces.append(p['f']+offset);offset+=len(p['v'])
            v=np.concatenate(verts)-pivot;f=np.concatenate(faces);norm=vertex_normals(v,f)
            pos=accessor(v.astype('<f4'),'VEC3',34962);no=accessor(norm.astype('<f4'),'VEC3',34962)
            ix=accessor(f.reshape(-1).astype('<u4'),'SCALAR',34963)
            meshes.append(dict(name=group+'_'+MATERIALS[material][0],primitives=[dict(attributes=dict(POSITION=pos,NORMAL=no),indices=ix,material=material,mode=4)]))
            g['children'].append(len(nodes));nodes.append(dict(name=meshes[-1]['name'],mesh=len(meshes)-1))
    doc=dict(asset=dict(version='2.0',generator='GUT CREW offline art18 authoring'),scene=0,scenes=[dict(nodes=[0])],
        nodes=nodes,meshes=meshes,materials=mats,buffers=[dict(byteLength=len(chunks))],bufferViews=views,accessors=acc)
    js=json.dumps(doc,separators=(',',':')).encode();js+=b' '*((-len(js))%4)
    data=struct.pack('<4sII',b'glTF',2,12+8+len(js)+8+len(chunks))+struct.pack('<I4s',len(js),b'JSON')+js+struct.pack('<I4s',len(chunks),b'BIN\0')+chunks
    path.write_bytes(data)
    return dict(file=path.name,vertices=sum(len(p['v']) for p in s.parts),triangles=sum(len(p['f']) for p in s.parts),
        animation_groups=list(s.pivots),draw_surfaces=len(meshes),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())

def main():
    report=[]
    for scene,filename in [(spark(),'spark_art18.glb'),(corridor(),'rugae_passage_art18.glb')]:
        report.append(export_glb(scene,OUT/filename))
    (OUT/'asset_manifest.json').write_text(json.dumps(dict(status='OFFLINE_NOT_INTEGRATED',assets=report),indent=2),encoding='utf-8')
    print(json.dumps(report,indent=2))

if __name__=='__main__':main()
