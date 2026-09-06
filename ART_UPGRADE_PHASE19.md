# GUT CREW — Art upgrade checkpoint / Phase 19
Date: 2026-09-02. Production project remains in this directory.

## Implemented
- Four imported, articulated clay character GLBs; existing skill, KO and first-person APIs preserved.
- Closed organic room shells and four sculpted transition passages; physical routes retained.
- Three sculpted enemies: hairball, platelet worker, parasite.
- Sculpted Mochi rescue Boss with head and paw animation bindings.
- New returning-hand mesh and wristband; revised reunion pose.
- Return capsule with hatch, windows, landing supports and boarding steps.
- Shared clay surface normals, isolated enemy hit-flash materials, reduced legacy pink lighting.
- Hidden obsolete floating wall decorations; original nodes remain available to legacy APIs.
- Fixed expired-node removal in typed gameplay arrays and idle-animation-dependent test assertion.

## Editable sources
- assets/art18/editable_source/GUT_CREW_ART18_MASTER.blend
- assets/art19/editable_source/GUT_CREW_ART19_CREATURES_STORY.blend
- assets/art19/editable_source/GUT_CREW_ART19_CAPSULE.blend
- Procedural source generators are retained beside their GLBs.
- Portable Blender is in Desktop/GUT_CREW_ART_TOOLS; no system PATH change.

## Verification
- Run QA_GODOT_PHASE19.bat for the complete existing Phase 2–17 suite plus Art 18/19 checks.
- GUT_CREW_QA_SHOTS contains regression logs and actual Godot screenshots.
- phase19_live_combat_r2.log: 960 rendered frames across four roles; 23.52s, no script errors.
- The rendered benchmark is approximately 41fps on Intel UHD, not a 60fps guarantee.
## Scope and remaining quality work
This is a verified art-upgrade checkpoint, not a claim that the whole game has final shipping art.
Some world dressing, BODY MART props, the electronic mouse and clinic scenery still use older assets.
Only the existing cat rescue scenario is implemented; frog/whale/dragon maps are not claimed complete.
Network snapshot tests are not four-client multiplayer verification.
Further performance, animation, camera and art-direction review remains necessary before final-quality sign-off.

## Recovery
BACKUPS contains dated Phase18 and Phase19 checkpoints.
Do not restore an entire backup over later user work; compare and restore only the intended files.
Launch normally with GUT_CREW_GODOT_PLAY.bat; paths remain relative to the project folder.
Latest integration notes:
- Capsule seating is a visual-only +0.40m offset; mission interaction origin is unchanged.
- Legacy gate petals and free-floating muscle rods are hidden; connected terrain passages remain.
- Continuous combat capture now has a 70-second watchdog and forced final render.
- Actual saved captures include phase19_return_capsule.png and phase19_story_0..3.png.
- A failed/silent earlier capture is not counted as passing verification; use the successful named logs above.