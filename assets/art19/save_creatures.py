"""Create editable creature master using installed Blender; never overwrite."""
from pathlib import Path
import bpy
from mathutils import Vector
root=Path(__file__).resolve().parent
folder=root/'editable_source';folder.mkdir(exist_ok=True)
(folder/'.gdignore').touch()
dst=folder/'GUT_CREW_ART19_CREATURES_STORY.blend'
if dst.exists():raise RuntimeError('Preserving existing master: '+str(dst))
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
for i,name in enumerate(['hairball','platelet','parasite','mochi','hand']):
    before=set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=str(root/(name+'_art19.glb')))
    added=set(bpy.data.objects)-before
    col=bpy.data.collections.new(name.upper()+' | ART19');bpy.context.scene.collection.children.link(col)
    for obj in added:
        for old in list(obj.users_collection):old.objects.unlink(obj)
        col.objects.link(obj)
        if obj.parent is None:obj.location+=Vector((i*3 if i<3 else (13 if i==3 else 23),0,0))
        if obj.type=='MESH':
            for poly in obj.data.polygons:poly.use_smooth=True
bpy.context.scene['status']='Editable indexed meshes; animation anchors retained in Godot'
bpy.ops.wm.save_as_mainfile(filepath=str(dst))
print('BLENDER_ART19_MASTER_OK',str(dst))
