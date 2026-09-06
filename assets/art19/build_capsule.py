"""Return capsule: opaque ceramic clay shell, inset windows, repair-team fittings."""
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT))
from build_creatures import *

def capsule():
    s=Scene('Return_capsule_Art19')
    s.loft('Ceramic_pressure_shell',[[.13,0,0,0,0],[.20,.68,.65,0,0],[.45,.95,.85,0,0],
        [1.55,.97,.86,0,0],[2.13,.82,.75,0,0],[2.47,.42,.40,0,0],[2.59,0,0,0,0]],
        2,n=48,rings=38,clay=.004)
    for y,r in [(.39,.89),(1.02,.982),(1.97,.87)]:
        s.tube('Soft_metal_rim',[(r*math.cos(a),y,r*.9*math.sin(a)) for a in np.linspace(0,TAU,65)],.045,1,sides=10)
    # A broad, recessed hatch on the front; no blinding emissive cylinder.
    s.pebble('Hatch_frame',(0,1.17,.821),(.56,.78,.11),1,exp=.82,n=36,rings=28)
    s.pebble('Hatch_panel',(0,1.18,.925),(.45,.65,.052),20,exp=.82,n=32,rings=24)
    s.pebble('Hatch_window',(0,1.49,.973),(.31,.30,.034),1,n=32,rings=24)
    s.tube('Window_reflection',[(-.17,1.48,1.008),(-.16,1.64,1.008),(-.07,1.72,1.008)],.018,20,sides=8)
    s.pebble('Hatch_handle',(.29,.92,1.013),(.065,.15,.065),5,n=20,rings=14)
    for side in (-1,1):
        s.pebble('Side_port_frame',(side*.946,1.55,0),(.081,.34,.32),1,n=30,rings=22)
        s.pebble('Side_port_window',(side*1.01,1.55,0),(.028,.255,.239),19,n=28,rings=20)
        s.pebble('Landing_foot',(side*.75,.09,.40),(.27,.09,.39),8,n=24,rings=18,exp=.74)
        s.tube('Landing_support',[(side*.63,.43,.25),(side*.73,.25,.36),(side*.75,.14,.40)],.075,5,sides=10)
        s.tube('Top_service_handle',[(side*.33,2.41,-.05),(side*.33,2.67,-.05),(side*.13,2.76,-.05)],.052,1,sides=10)
    for z in [1.04,1.35]:s.pebble('Boarding_step',(0,.075 if z>1.2 else .17,z),(.55,.07,.22),1,n=28,rings=16,exp=.67)
    # A raised cross makes the rescue function readable at gameplay distance.
    s.pebble('Rescue_cross_vertical',(0,2.12,.776),(.046,.135,.025),18,n=20,rings=14,exp=.64)
    s.pebble('Rescue_cross_horizontal',(0,2.12,.779),(.128,.047,.026),18,n=20,rings=14,exp=.64)
    return s

if __name__=='__main__':
    import json
    result=export_glb(capsule(),ROOT/'capsule_art19.glb')
    (ROOT/'capsule_manifest.json').write_text(json.dumps(result,indent=2))
    print('ART19_CAPSULE_MESH_OK',result)
