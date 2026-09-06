# GUT CREW Godot Phase 11 - Role Combat Redesign

Date: 2026-08-31
Godot: 4.7.2 stable
Backup: BACKUPS/PHASE11_COMBAT_20260829_172702

## Implemented

### Spark
- LMB Arc Stream: fast low-damage lightning fire
- RMB Lightning Form: 7.2 m rapid pass with line damage and brief invulnerability
- Q Conductive Mark: marks enemy or physical wall; Q again recalls/teleports
- E Neural Storm: 5.4 m paralysis field; reacts with body structures

### Kaka
- LMB Bone Nails: tap fire or hold to grow a visible seven-nail orbit and release a volley
- Bone nails are simulated projectiles and remain pinned to enemies or physical walls
- RMB Bone Hook preserved with pull and short pin
- Q Long Bone preserved
- E Bone Charge: rush damage and crew collision/launch support

### Bubble
- LMB Mega Roll: hold to grow, release to roll, damage, knock back, and slow
- RMB Plasma Sling: hold to charge a ballistic leap; landing deals splash damage
- Q Split Decoy: creates a physical kickable lure for enemies
- E Regurgitation Cannon: swallows an enemy payload and ejects it on the second press

### Shroom
- LMB Spore Bloom: infection stacks, slow, and third-hit area bloom
- RMB Puppet Thread: controls enemies and commands an active puppet
- Dead teammate clay-body interface can be temporarily reanimated as an attacking crew puppet
- Q Fungus Network: wider persistent biological network with cross-skill reactions
- E Ferment Burst: detonates spores and extends controlled enemies, patches, and clay puppets

## Feedback and VFX
- HUD reports each role's LMB/RMB charge state and two-stage Q/E state
- Added dedicated arc, conductor, paralysis, bone orbit/impact, charge rails, bubble roll/sling/splash, spores, and puppet threads
- Neural Storm rings were reduced after in-engine capture to avoid obscuring third-person play
- Existing 12 fps clay animation controller receives charge, rush, growth, sling, and casting states

## Files
- scripts/main.gd
- scripts/skill_vfx.gd
- tests/phase11_role_combat_smoke.gd
- tests/phase11_capture.gd
- QA_GODOT_PHASE11.bat
- GUT_CREW_QA_SHOTS/phase11_*.png

## Verification
- Godot editor parse: 0 errors
- GODOT_PHASE11_CAPTURE_OK
- GODOT_PHASE11_ROLE_COMBAT_OK dash=7.19999980926514 nails=1 corpse=8.7
- GODOT_PHASE3_FULL_ROUND_OK clues=3 phase=win
- GODOT_NETWORK_STATE_OK bytes=367
- QA_GODOT_PHASE11_OK
