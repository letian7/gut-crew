# Phase 35: mouth induction and bidirectional bone hook

Mouth entry now has six alternating left/right teaching stations, four pickup supplies and a ceiling practice anchor. F collects nearby supplies; Tab shows consumable stocks. Medkits restore 35 HP and cannot be wasted at full health; soda gives the existing 16-second movement effect. The starter allowance grants 15 credits and the bottle cap enters the normal salvage bag. Pickup nodes cannot grant duplicate rewards. Lessons remain optional so the original story route is accessible.

Kaka hook now starts at the right-hand HookMuzzle marker. Camera aim selects a destination; a swept ray from the actual hook catches intervening surfaces. Small enemies are reeled with collision-aware movement. The cat boss, heavy/elite-tagged enemies, RAMMER and SPLITTER instead anchor the rope and pull the player. Wall, floor and ceiling hits are valid anchors. Moving anchors use collider-local coordinates; blocked ropes, expired ropes and deleted anchors release safely.

Ceiling ropes retain tangential momentum. WASD steers, holding RMB reels in, tapping RMB detaches, and Space releases with a jump impulse. A short airborne grace period preserves momentum after release. Attached ropes last at most 12 seconds. Player movement continues through CharacterBody3D collision handling rather than teleporting through terrain.

Validation: phase35_grapple_training_smoke checks hand origin, wall/floor/ceiling hits, self-pull on heavy enemies and the actual cat boss, intervening-wall occlusion, release momentum, pickup/use/duplicate prevention and mouth exit. phase35_capture records four rendered views. QA_GODOT_PHASE35 chains the existing regressions.
