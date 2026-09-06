from pathlib import Path
import bpy
root=Path(__file__).resolve().parent
folder=root/'editable_source'
folder.mkdir(exist_ok=True)
dst=folder/'GUT_CREW_ART19_CAPSULE.blend'
if dst.exists():raise RuntimeError('Preserving existing master')
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(root/'capsule_art19.glb'))
bpy.ops.wm.save_as_mainfile(filepath=str(dst))
print('BLENDER_ART19_CAPSULE_OK')