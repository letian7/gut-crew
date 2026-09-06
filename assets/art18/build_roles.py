"""Four distinctive articulated clay-mesh characters. Numpy-only authoring.
Use Blender's bundled Python or a local numpy Python. No installer/dependency fetch.
"""
import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from build_assets import *
MATERIALS.extend([
    ('Bone ivory','ddd3ba',.89,0),('Bone warm edge','b0a48d',.93,0),
    ('Clay coral','c88870',.87,0),('Plasma teal','76bdb7',.75,0),
    ('Plasma pale','b5dace',.83,0),('Spore plum','886d9b',.91,0),
    ('Spore mint','9fbea8',.91,0),('Gill cream','d4c6ad',.95,0)
])

def face(s,prefix,head_name,head_pos,eye_y,gap,z,mouth_pos,brow=True):
    for side in (-1,1):
        s.pebble('Recessed_socket',(side*gap,eye_y,z+.025),(.124,.158,.04),17,
            group=head_name,pivot=head_pos)
        s.pebble('Ivory_eye',(side*gap,eye_y,z),(.100,.135,.039),2,group=head_name,pivot=head_pos)
        s.pebble('Pupil',(side*gap+.011,eye_y-.01,z-.033),(.056,.088,.025),3,group=head_name,pivot=head_pos)
        s.pebble('Catchlight',(side*gap-.007,eye_y+.025,z-.054),(.018,.023,.008),7,n=12,rings=10,group=head_name,pivot=head_pos)
        if brow:
            bn=prefix+'Brow'+('L' if side<0 else 'R');bp=(side*gap,eye_y+.18,z)
            s.tube('Pressed_brow',[(side*(gap-.08+.16*t),eye_y+.18+.018*math.sin(t*math.pi),z+.025)
                for t in np.linspace(0,1,12)],.022,17,group=bn,pivot=bp)
    s.tube('Soft_smile',[(mouth_pos[0]+x,mouth_pos[1]-.03*(1-(x/.12)**2),mouth_pos[2]+.032*(x/.12)**2)
        for x in np.linspace(-.12,.12,16)],.017,3,group=prefix+'Mouth',pivot=mouth_pos)

def kaka():
    s=Scene('Kaka_Art18');body=(0,.88,0);head=(0,1.72,-.02)
    s.loft('Sculpted_ribcage',[[-.49,0,0,0,0],[-.43,.31,.23,0,0],[-.20,.43,.29,0,0],
        [.18,.47,.28,0,0],[.43,.31,.22,0,0],[.51,0,0,0,0]],16,body,exponent=.68,group='KakaBody',pivot=body)
    s.loft('Sculpted_skull',[[-.36,0,0,0,-.02],[-.29,.25,.23,0,-.04],[-.12,.40,.30,0,0],
        [.09,.45,.335,0,.01],[.30,.39,.30,0,0],[.39,.20,.20,0,0],[.415,0,0,0,0]],
        16,head,n=48,rings=32,exponent=.75,clay=.005,group='KakaHead',pivot=head)
    face(s,'Kaka','KakaHead',head,1.78,.20,-.352,(0,1.49,-.39))
    s.pebble('Soft_jaw',(0,1.443,-.20),(.27,.094,.18),16,exp=.7,group='KakaHead',pivot=head)
    for x in (-.15,-.05,.05,.15):
        s.pebble('Rounded_tooth',(x,1.466,-.368),(.035,.05,.03),2,n=14,rings=10,group='KakaHead',pivot=head)
    s.pebble('Nose_socket',(0,1.66,-.345),(.047,.061,.025),17,group='KakaHead',pivot=head)
    for k in range(3):
        y=1.11-k*.17
        s.tube('Curving_rib',[(x,y-.053*(1-(x/.34)**2),-.309+.085*(x/.34)**2)
            for x in np.linspace(-.34,.34,28)],.041,2,group='KakaBody',pivot=body)
    s.tube('Sternum',[(0,.67,-.316),(0,.83,-.328),(0,1.17,-.323)],.029,17,group='KakaBody',pivot=body)
    s.tube('Leather_work_belt',[(.398*math.cos(t),.50,.277*math.sin(t)) for t in np.linspace(0,TAU,52)],.04,6,group='KakaBody',pivot=body)
    for side in (-1,1):
        suffix='L' if side<0 else 'R';arm=(side*.66,.95,0);leg=(side*.28,.25,0);fist=(side*.74,.53,-.02)
        s.loft('Hand_carved_arm_bone',[[-.39,0,0,0,0],[-.34,.122,.12,0,0],[-.24,.082,.075,0,0],
            [.15,.091,.082,0,0],[.29,.13,.125,0,0],[.36,0,0,0,0]],16,arm,n=26,rings=22,group='KakaArm'+suffix,pivot=arm)
        s.pebble('Shoulder_pad',(side*.57,1.27,.015),(.22,.15,.21),6,exp=.7,group='KakaBody',pivot=body)
        s.pebble('Knuckle_mitten',fist,(.16,.145,.16),16,exp=.8,group='KakaFist'+suffix,pivot=fist)
        for k in range(3):
            s.tube('Knuckle_crease',[(fist[0]+(k-1)*.07,.49,-.159),(fist[0]+(k-1)*.07,.57,-.168)],.006,17,sides=6,group='KakaFist'+suffix,pivot=fist)
        s.pebble('Shin_bone',leg,(.11,.22,.11),16,group='KakaLeg'+suffix,pivot=leg)
        s.pebble('Kneecap',(side*.28,.30,-.097),(.14,.10,.07),6,group='KakaLeg'+suffix,pivot=leg)
        s.pebble('Soft_bone_boot',(side*.28,.135,-.09),(.18,.134,.247),8,exp=.65,group='KakaLeg'+suffix,pivot=leg)
        s.pebble('Tool_pocket',(side*.43,.63,-.15),(.11,.17,.105),6,exp=.65,group='KakaBody',pivot=body)
    for k in range(5):
        s.pebble('Back_vertebra',(0,.60+k*.13,.29),(.12,.075,.055),17,n=18,rings=12,group='KakaBody',pivot=body)
    # Recognisable bone wrench, swept instead of a box stuck on a cylinder.
    s.tube('Bone_wrench_handle',[(.53,.62,.12),(.59,.86,.16),(.68,1.15,.18)],.046,2,sides=12,group='KakaBody',pivot=body)
    s.tube('Open_wrench_jaw',[(.68+.13*math.cos(t),1.20+.13*math.sin(t),.18)
        for t in np.linspace(.15*math.pi,1.85*math.pi,30)],.049,2,sides=12,group='KakaBody',pivot=body)
    return s

def bubble():
    s=Scene('Bubble_Art18');body=(0,.96,0);head=(0,1.58,-.03)
    # Single readable droplet torso; opaque satin clay rather than stacked glow spheres.
    s.loft('Pear_drop_body',[[-.82,0,0,0,0],[-.77,.25,.25,0,0],[-.52,.48,.37,0,0],
        [-.19,.52,.40,0,0],[.20,.43,.34,0,-.01],[.48,.30,.25,0,-.01],[.63,0,0,0,0]],
        19,body,n=44,rings=34,group='BubbleBody',pivot=body)
    s.loft('Soft_drop_face',[[-.39,0,0,0,0],[-.29,.36,.31,0,0],[-.03,.44,.365,0,0],
        [.20,.37,.32,0,.015],[.39,.21,.17,.06,.03],[.53,.095,.08,.11,.045],
        [.65,0,0,.055,.04]],19,head,n=44,rings=34,group='BubbleHead',pivot=head)
    face(s,'Bubble','BubbleHead',head,1.65,.18,-.368,(0,1.43,-.378),False)
    for side in (-1,1):
        suffix='L' if side<0 else 'R';a=(side*.55,.90,0);f=(side*.26,.18,-.05)
        s.loft('Flipper_arm',[[-.35,0,0,side*.10,-.03],[-.26,.14,.13,side*.07,-.04],
            [.02,.13,.13,0,0],[.21,.11,.12,-side*.04,0],[.25,0,0,-side*.06,0]],
            19,a,n=24,rings=22,group='BubbleArm'+suffix,pivot=a)
        s.pebble('Rolling_flipper_foot',(side*.26,.103,-.08),(.205,.102,.246),20,exp=.8,group='BubbleFoot'+suffix,pivot=f)
        s.pebble('Soft_blush',(side*.29,1.50,-.30),(.069,.045,.016),18,group='BubbleHead',pivot=head)
    s.pebble('Plasma_chest_patch',(0,.93,-.385),(.25,.23,.032),20,group='BubbleBody',pivot=body)
    core=(0,.88,-.12)
    s.pebble('Coral_heart_left',(-.065,.955,-.427),(.098,.11,.03),18,group='BubbleCore',pivot=core)
    s.pebble('Coral_heart_right',(.065,.955,-.427),(.098,.11,.03),18,group='BubbleCore',pivot=core)
    s.loft('Coral_heart_tip',[[.775,0,0,0,0],[.85,.10,.03,0,0],[.956,.144,.03,0,0],[1,0,0,0,0]],
        18,(0,0,-.427),n=24,rings=18,group='BubbleCore',pivot=core)
    for side in (-1,1):
        for k in range(3):
            s.pebble('Pressed_bubble_mark',(side*(.34+.022*k),.58+k*.17,-.268),(.027,.032,.008),20,n=12,rings=10,group='BubbleBody',pivot=body)
    s.tube('Back_wave_seam',[(.27*math.sin(t*math.pi*1.2),.40+.90*t,.33+.045*math.sin(t*math.pi))
        for t in np.linspace(0,1,35)],.018,20,sides=8,group='BubbleBody',pivot=body)
    return s

def shroom():
    s=Scene('Shroom_Art18');body=(0,.82,0);head=(0,1.34,-.05);cap=(0,1.88,.02)
    s.loft('Mycelium_coat',[[-.64,0,0,0,0],[-.59,.29,.26,0,0],[-.37,.39,.31,0,0],
        [.10,.31,.26,0,0],[.32,.23,.21,0,0],[.46,0,0,0,0]],22,body,n=36,rings=28,group='ShroomBody',pivot=body)
    s.loft('Cream_stem_face',[[-.33,0,0,0,0],[-.26,.26,.23,0,0],[0,.31,.28,0,0],
        [.25,.29,.255,0,0],[.43,.25,.23,0,0],[.48,0,0,0,0]],23,head,n=36,rings=26,group='ShroomFace',pivot=head)
    face(s,'Shroom','ShroomFace',head,1.40,.15,-.314,(0,1.20,-.315),False)
    s.loft('Sculpted_mushroom_canopy',[[-.21,0,0,0,0],[-.195,.42,.38,0,0],[-.17,.70,.63,0,0],
        [-.095,.86,.75,0,0],[.025,.80,.71,-.025,0],[.21,.62,.55,-.05,0],
        [.36,.33,.30,-.05,0],[.41,0,0,-.05,0]],21,cap,n=60,rings=32,clay=.008,group='ShroomCap',pivot=cap)
    for t in np.linspace(0,TAU,28,endpoint=False):
        pts=[(math.cos(t)*r,1.678+.075*(r/.77)**3,.02+math.sin(t)*r*.87) for r in np.linspace(.28,.77,14)]
        s.tube('Radial_gill',pts,.012,23,sides=6,group='ShroomCap',pivot=cap)
    for k in range(9):
        t=k*2.40;r=.30 if k<3 else .55
        x=math.cos(t)*r-.035;z=math.sin(t)*r*.9+.02
        y=2.30-.34*(r/.8)**2
        s.pebble('Pressed_canopy_spot',(x,y,z),(.083+.013*(k%2),.028,.077),22,n=18,rings=12,group='ShroomCap',pivot=cap)
    for side in (-1,1):
        suffix='L' if side<0 else 'R';a=(side*.48,.88,0);f=(side*.24,.17,-.04)
        s.loft('Sleeved_arm',[[-.35,0,0,side*.04,0],[-.30,.115,.12,side*.04,0],
            [.06,.13,.125,0,0],[.23,.105,.11,-side*.02,0],[.27,0,0,-side*.025,0]],
            22,a,n=24,rings=22,group='ShroomArm'+suffix,pivot=a)
        s.pebble('Soft_mitten',(side*.53,.51,-.035),(.13,.13,.13),23,group='ShroomArm'+suffix,pivot=a)
        s.pebble('Plum_boot',(side*.24,.105,-.07),(.19,.104,.22),21,exp=.8,group='ShroomFoot'+suffix,pivot=f)
    s.tube('Folded_collar',[(.255*math.cos(t),1.10+.022*math.cos(4*t),.238*math.sin(t))
        for t in np.linspace(0,TAU,48)],.043,23,group='ShroomBody',pivot=body)
    s.pebble('Medic_satchel',(.39,.68,.18),(.15,.19,.12),21,exp=.65,group='ShroomBody',pivot=body)
    s.tube('Satchel_strap',[(-.25,1.12,-.11),(-.05,1.0,-.268),(.24,.81,-.21),(.40,.67,.14)],.026,23,group='ShroomBody',pivot=body)
    for k in range(3):
        s.pebble('Coat_button',(-.075,.45+k*.15,-.294),(.025,.026,.012),21,n=12,rings=10,group='ShroomBody',pivot=body)
    return s

def build_all():
    report=[]
    for scene,filename in [(spark(),'spark_art18.glb'),(kaka(),'kaka_art18.glb'),(bubble(),'bubble_art18.glb'),(shroom(),'shroom_art18.glb'),(corridor(),'rugae_passage_art18.glb')]:
        report.append(export_glb(scene,OUT/filename))
    (OUT/'asset_manifest.json').write_text(json.dumps(dict(stage='INTEGRATION_CANDIDATE',assets=report),indent=2))
    print('ART18_FOUR_ROLES_MESHES_OK',json.dumps(report),flush=True)

if __name__=='__main__':build_all()
