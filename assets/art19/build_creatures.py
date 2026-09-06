"""ART19 creature meshes; shares ART18's deterministic clay authoring primitives."""
import sys
from pathlib import Path
DEST=Path(__file__).resolve().parent
sys.path.insert(0,str(DEST.parent/'art18' if (DEST.parent/'art18').is_dir() else DEST))
from build_roles import *
MATERIALS.extend([('Mochi ginger','c2956e',.94,0),('Mochi muzzle','eddbb7',.94,0),
    ('Mochi stripe','956d52',.96,0),('Mochi inner ear','c99b97',.96,0),('Iris jade','788d65',.65,0)])

def eyes(s,y,gap,z,group='Static',pivot=(0,0,0),size=1,front=-1):
    for side in (-1,1):
        x=side*gap
        for name,c,sc,m in [('Eye',(x,y,z),(.11*size,.145*size,.055*size),2),
            ('Pupil',(x+.008*size,y-.006*size,z+front*.045*size),(.054*size,.095*size,.022*size),3),
            ('Eye_spark',(x-.015*size,y+.036*size,z+front*.066*size),(.017*size,.024*size,.009*size),7)]:
            s.pebble(name,c,sc,m,n=18,rings=12,group=group,pivot=pivot)

def hairball():
    s=Scene('Hairball_Art19')
    s.loft('Tangled_clay_core',[[.17,0,0,0,0],[.23,.33,.29,0,0],[.50,.56,.44,-.025,0],
        [.84,.54,.46,.025,0],[1.12,.35,.30,0,0],[1.23,0,0,0,0]],21,n=32,rings=24,clay=.022)
    for k in range(18):
        a=k*2.4;pts=[]
        for t in np.linspace(-1,1,25):
            th=a+t*.6;y=.7+.41*math.sin(t*1.4+k*.39)
            radius=.53*math.sqrt(max(.15,1-((y-.7)/.64)**2))
            pts.append((radius*math.cos(th),y,.83*radius*math.sin(th)))
        s.tube('Interwoven_fur_rope',pts,.036 if k%3 else .048,21 if k%2 else 14,sides=7)
    eyes(s,.83,.205,-.434)
    s.pebble('Mouth_recess',(0,.51,-.427),(.17,.087,.045),3,n=20,rings=12)
    s.loft('Floppy_tongue',[[-.06,0,0,0,0],[-.035,.09,.065,0,0],[.04,.11,.065,0,0],[.08,0,0,0,0]],
        18,(0,.47,-.50),n=20,rings=14,group='Tongue',pivot=(0,.47,-.56))
    for side in (-1,1):s.pebble('Tiny_flat_foot',(side*.27,.09,.005),(.16,.089,.23),14,n=18,rings=12)
    return s

def platelet():
    s=Scene('Platelet_Art19')
    s.loft('Soft_cell_body',[[.32,0,0,0,0],[.39,.33,.27,0,0],[.60,.43,.34,0,0],
        [.88,.38,.31,0,0],[1.08,.20,.17,0,0],[1.14,0,0,0,0]],18,n=32,rings=24)
    eyes(s,.81,.18,-.308,size=.88)
    helmet=(0,1.20,0)
    s.loft('Crafted_safety_helmet',[[1.035,0,0,0,0],[1.05,.48,.42,0,0],
        [1.12,.48,.42,0,0],[1.16,.385,.34,0,0],[1.36,.29,.25,0,0],[1.47,0,0,0,0]],
        0,n=36,rings=24,group='HelmetDome',pivot=helmet)
    s.tube('Helmet_center_ridge',[(0,1.36+.11*math.sin(t*math.pi),-.25+.5*t) for t in np.linspace(0,1,25)],.027,2,sides=8,group='HelmetDome',pivot=helmet)
    s.pebble('Safety_vest',(0,.59,-.294),(.29,.135,.06),6,exp=.75,n=24,rings=16)
    for side in (-1,1):
        s.tube('Reflective_strip',[(side*.19,.48,-.321),(side*.19,.60,-.350),(side*.19,.69,-.324)],.018,2,sides=6)
        g='PlateletArm' if side<0 else 'PlateletArm2';pivot=(side*.55,.67,0)
        s.pebble('Soft_shoulder',(side*.425,.78,0),(.19,.115,.13),18,n=20,rings=14,group=g,pivot=pivot)
        s.loft('Cell_arm',[[-.26,0,0,0,0],[-.20,.08,.075,0,0],[.10,.08,.08,0,0],[.23,0,0,0,0]],
            18,pivot,n=18,rings=16,group=g,pivot=pivot)
        s.pebble('Gloved_hand',(side*.55,.43,-.02),(.11,.11,.10),2,n=18,rings=12,group=g,pivot=pivot)
        s.pebble('Boot',(side*.25,.10,-.04),(.14,.099,.21),8,n=20,rings=14,exp=.8)
        s.pebble('Shin',(side*.25,.25,.01),(.08,.14,.085),8,n=18,rings=12)
    return s

def parasite():
    s=Scene('Parasite_Art19')
    s.tube('Continuous_slug_body',[(.055*math.sin(t*5),.61-.15*t,.12+1.86*t) for t in np.linspace(0,1,49)],
        [.34*(1-t*.89) for t in np.linspace(0,1,49)],22,sides=18)
    s.loft('Suction_head',[[.43,0,0,0,0],[.48,.24,.25,0,0],[.77,.38,.34,0,0],
        [1.03,.33,.29,0,0],[1.20,.15,.16,0,0],[1.24,0,0,0,0]],22,(0,0,-.25),n=32,rings=24)
    eyes(s,1.07,.19,-.486,size=.78)
    pivot=(0,.82,-.72)
    s.pebble('Sucker_cavity',(0,.77,-.576),(.237,.236,.034),8,n=24,rings=18,group='ParasiteMouth',pivot=pivot)
    s.tube('Soft_suction_lip',[(.245*math.cos(t),.77+.245*math.sin(t),-.615) for t in np.linspace(0,TAU,49)],
        .046,19,sides=10,group='ParasiteMouth',pivot=pivot)
    for k in range(8):
        a=k*TAU/8
        s.pebble('Milk_tooth',(.172*math.cos(a),.77+.172*math.sin(a),-.633),(.034,.044,.028),2,n=12,rings=10,group='ParasiteMouth',pivot=pivot)
    for k in range(6):
        t=(k+.5)/7;r=.34*(1-t*.89)
        s.tube('Body_groove',[(.055*math.sin(t*5)+r*math.cos(a),.61-.15*t+r*math.sin(a),.12+1.86*t)
            for a in np.linspace(.1,math.pi-.1,19)],.018,17,sides=6)
    return s

def mochi():
    s=Scene('Mochi_Art19');head=(0,4.3,.7)
    s.loft('Resting_cat_body',[[.2,0,0,0,0],[.45,2.7,3.1,0,-1.9],[1.4,3.3,3.55,0,-1.9],
        [3.1,3.15,3.4,0,-2],[4.3,2.5,2.8,0,-2.1],[4.8,1.6,1.8,0,-2.1],[4.95,0,0,0,-2.1]],24,n=52,rings=38)
    s.pebble('Cream_bib',(0,2.4,1.38),(1.95,1.68,.39),25,n=40,rings=28)
    s.loft('Sculpted_feline_head',[[-1.55,0,0,0,.03],[-1.30,1.20,1.1,0,.07],[-.8,2.0,1.45,0,.02],
        [0,2.48,1.61,0,0],[.72,2.3,1.52,0,-.07],[1.38,1.66,1.21,0,-.12],[1.70,.9,.75,0,-.18],
        [1.83,0,0,0,-.2]],24,head,n=64,rings=42,clay=.006,group='CatHead',pivot=head)
    def p(name,c,sc,m,**kw):s.pebble(name,c,sc,m,group='CatHead',pivot=head,**kw)
    def tube(name,pts,r,m):s.tube(name,pts,r,m,group='CatHead',pivot=head,sides=10)
    for side in (-1,1):
        ear=(side*1.66,6.0,.36)
        s.loft('Rounded_feline_ear',[[-.5,0,0,0,0],[-.35,.85,.50,0,0],[.0,.73,.43,side*.06,0],
            [.65,.41,.28,side*.25,-.07],[1.18,.13,.12,side*.37,-.13],[1.31,0,0,side*.36,-.14]],
            24,ear,n=36,rings=28,exponent=.75,group='CatHead',pivot=head)
        s.loft('Soft_inner_ear',[[-.23,0,0,0,0],[-.13,.47,.08,0,0],[.3,.39,.075,side*.10,-.03],
            [.85,.16,.045,side*.24,-.10],[1,0,0,side*.29,-.14]],27,(ear[0],ear[1],.73),
            n=28,rings=22,group='CatHead',pivot=head)
        p('Eye_socket',(side*.94,4.52,2.20),(.61,.56,.17),26,n=36,rings=24)
        p('Warm_eye',(side*.94,4.54,2.34),(.52,.46,.16),2,n=36,rings=24)
        p('Jade_iris',(side*.94,4.54,2.467),(.325,.37,.055),28,n=32,rings=24)
        p('Vertical_pupil',(side*.94,4.54,2.507),(.13,.31,.035),3,n=28,rings=22)
        p('Eye_catchlight',(side*.83,4.68,2.54),(.075,.095,.023),7,n=20,rings=14)
        p('Muzzle_pad',(side*.48,3.67,2.23),(.76,.45,.46),25,n=36,rings=26)
        for k in range(3):
            tube('Curving_whisker',[(side*(.85+1.95*t),3.79-k*.18+.14*math.sin(t*2),2.39-.15*t)
                for t in np.linspace(0,1,24)],.025,25)
        tube('Eyebrow',[(side*(.46+1.0*t),5.10+.16*math.sin(t*math.pi),2.105-.21*t)
            for t in np.linspace(0,1,25)],.075,26)
        for k in range(3):
            p('Whisker_root',(side*(.78+.15*(k%2)),3.76-.14*(k//2),2.64),(.026,.027,.016),26,n=12,rings=8)
    p('Heart_nose',(0,3.99,2.73),(.27,.175,.14),27,n=32,rings=20)
    for side in (-1,1):
        tube('Muzzle_smile',[(side*.05,3.80,2.67),(side*.17,3.59,2.65),(side*.43,3.57,2.64),(side*.65,3.66,2.58)],.035,26)
    for k in range(3):
        x=(k-1)*.56
        tube('Tabby_forehead_mark',[(x*(1-.15*t),5.24+.62*t,2.08-.44*t) for t in np.linspace(0,1,24)],.088,26)
    for side in (-1,1):
        g='LeftPaw' if side<0 else 'RightPaw';pivot=(side*2.5,.72,2.1)
        s.loft('Rounded_front_paw',[[-.71,0,0,0,0],[-.65,.72,1.02,0,.1],[-.33,1.02,1.36,0,.1],
            [.17,.96,1.26,0,-.08],[.59,.66,.87,0,-.20],[.72,0,0,0,-.24]],25,pivot,n=40,rings=28,group=g,pivot=pivot)
        for toe in range(3):
            x=side*2.5+(toe-1)*.46
            s.tube('Toe_fold',[(x,.66+.09*math.sin(t*math.pi),3.18+.17*t) for t in np.linspace(0,1,12)],
                .028,26,sides=6,group=g,pivot=pivot)
    s.tube('Continuous_curling_tail',[(3.0+math.sin(t*2.8)*2.1,.70+math.sin(t*2.8)*.75,-4.3+t*4.8)
        for t in np.linspace(0,1,70)],[.46-.17*t for t in np.linspace(0,1,70)],24,sides=20)
    return s

def hand():
    s=Scene('Returning_hand_Art19')
    skin=len(MATERIALS);MATERIALS.append(('Warm clay skin','d5ad91',.95,0))
    s.pebble('Sculpted_palm',(0,0,.02),(.66,.21,.70),skin,exp=.8,n=40,rings=28)
    s.tube('Wrist_and_sleeve',[((.02+.025*t),-.01,-.40-7.0*t) for t in np.linspace(0,1,42)],
        [.36+.025*t for t in np.linspace(0,1,42)],skin,sides=24)
    # Four curved, softly rounded fingers, slightly different in length.
    for i,length in enumerate([.91,1.16,1.08,.79]):
        x=-.43+i*.285
        pts=[(x+(i-1.5)*.025*t,-.015-.10*t*t,.41+length*t) for t in np.linspace(0,1,28)]
        radii=[.135*(1-.18*t) for t in np.linspace(0,1,28)]
        s.tube('Continuous_finger',pts,radii,skin,sides=14)
        s.pebble('Soft_fingertip',pts[-1],(.112,.112,.112),skin,n=18,rings=12)
        s.pebble('Small_nail',(pts[-1][0],pts[-1][1]+.087,pts[-1][2]-.04),(.066,.025,.09),25,n=16,rings=10)
    pts=[(-.45-.45*t,-.015-.10*t,.04+.57*t) for t in np.linspace(0,1,25)]
    s.tube('Curved_thumb',pts,[.19-.065*t for t in np.linspace(0,1,25)],skin,sides=18)
    s.pebble('Thumb_tip',pts[-1],(.13,.13,.13),skin,n=18,rings=14)
    for z in [-.79,-.95]:
        s.tube('Hospital_band_edge',[(.38*math.cos(a),.38*math.sin(a)-.01,z) for a in np.linspace(0,TAU,49)],.036,20,sides=8)
    s.pebble('Hospital_band',(0,.365,-.87),(.28,.035,.12),20,exp=.72,n=24,rings=12)
    for x in [-.09,-.03,.03,.09]:s.pebble('Band_print',(x,.403,-.87),(.009,.003,.048),1,n=10,rings=8)
    return s

if __name__=='__main__':
    import json
    report=[]
    for name,scene in [('hairball',hairball()),('platelet',platelet()),('parasite',parasite()),('mochi',mochi()),('hand',hand())]:
        report.append(export_glb(scene,DEST/(name+'_art19.glb')))
    (DEST/'creature_manifest.json').write_text(json.dumps(report,indent=2))
    print('ART19_CREATURE_MESHES_OK',json.dumps(report),flush=True)
