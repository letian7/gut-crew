# GUT CREW Godot Phase 12 - Combat Reactions

Date: 2026-08-31
Godot: 4.7.2 stable
Backup: BACKUPS/PHASE12_COMBAT_POLISH_20260831_102913

## Combat feedback
- Central crosshair changes to a role-colored X on confirmed damage
- Kill confirmation receives a longer red hit marker
- FLOW hit rhythm is displayed in the top HUD and expires after combat pauses
- Existing damage numbers, hit flash, camera shake, clay impact, and SYNC remain active

## Same-role skill reactions
### Spark
- Arc Stream hitting the active Conductive Mark chains to a nearby second enemy
- Chain arc deals light damage and a micro-stun without replacing team SYNC

### Kaka
- Bone nails now track embedded pin count on enemies
- Enemy labels display BONE xN
- Bone Charge shatters embedded nails for extra damage, stun, knockback, and dedicated shard VFX

### Bubble
- Mega Roll can physically kick Split Decoy
- Kicked decoy becomes a living pinball and explodes when it hits an enemy
- Pinball burst damages and goo-slows nearby enemies

### Shroom
- Ferment Burst already enlarges active puppets; enlarged puppets now enter OVERDRIVE
- Overdrive puppets attack faster, deal stronger impact, and create spore-bloom feedback
- Enemy labels distinguish normal PUPPET from PUPPET OVERDRIVE

## Visual tuning
- Bubble burst ring opacity and scale reduced after in-engine capture
- Decoy crash now uses one dedicated splash layer instead of stacked generic hit rings
- Spark chain effect lifetime slightly increased
- Four Phase 12 screenshots were captured and inspected

## Files
- scripts/main.gd
- scripts/skill_vfx.gd
- tests/phase12_combat_reactions_smoke.gd
- tests/phase12_capture.gd
- QA_GODOT_PHASE12.bat
- GUT_CREW_QA_SHOTS/phase12_*.png

## Verification
- Godot editor parse: 0 errors
- GODOT_PHASE12_CAPTURE_OK
- GODOT_PHASE12_REACTIONS_OK chain=3.0 shatter=51.0 overdrive=17.0 flow=7
- GODOT_PHASE3_FULL_ROUND_OK clues=3 phase=win
- GODOT_NETWORK_STATE_OK bytes=367
- QA_GODOT_PHASE12_OK
