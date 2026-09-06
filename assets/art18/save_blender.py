"""Run in Blender after build_roles.py. Imports all deliverables into editable collections."""
from pathlib import Path
import bpy
from mathutils import Vector
ROOT=Path(__file__).resolve().parent
source_dir=ROOT/'editable_source'
source_dir.mkdir(exist_ok=True)
(source_dir/'.gdignore').write_text('')
dst=source_dir/'GUT_CREW_ART18_MASTER.blend'
if dst.exists():raise RuntimeError('Preserving existing editable master: '+str(dst))
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
for i,name in enumerate(['spark','kaka','bubble','shroom','rugae_passage']):
    before=set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=str(ROOT/(name+'_art18.glb')))
    added=set(bpy.data.objects)-before
    col=bpy.data.collections.new(name.upper()+' | ART18');bpy.context.scene.collection.children.link(col)
    for obj in added:
        for old in list(obj.users_collection):old.objects.unlink(obj)
        col.objects.link(obj)
        if obj.parent is None:obj.location+=Vector((i*2.6 if i<4 else 15,0,0))
        if obj.type=='MESH':
            for p in obj.data.polygons:p.use_smooth=True
            obj['source']='Procedural editable authoring; named articulation groups'
scene=bpy.context.scene
scene['status']='ART18 imported editable meshes; gameplay is in Godot project'
scene['coordinate_note']='GLB Y-up/-Z facing is converted to Blender Z-up/+Y facing'
bpy.ops.wm.save_as_mainfile(filepath=str(dst))
print('BLENDER_ART18_MASTER_OK',str(dst))
