# GUT CREW Godot Phase 10 - Frontend & Interaction UI

Date: 2026-08-29
Godot: 4.7.2 stable

## Implemented
- Chinese-first bilingual clay-styled main menu
- START GAME opens case / level selection
- Cat Stomach CASE 01 is playable
- Frog and Whale case cards show locked development status
- Existing four-role selection follows the selected case
- ESC opens pause during gameplay
- ESC backs out of submenus and opens exit confirmation on main menu
- Pause menu: resume, options, reselect level, main menu, exit
- Exit confirmation prevents accidental quitting
- Settings: master volume, mouse sensitivity, third-person FOV, fullscreen
- Pause freezes player physics and body-event timers
- Existing LMB / RMB combat and F interaction remain unchanged

## Files
- scripts/frontend_ui.gd
- scripts/main.gd
- tests/phase10_frontend_smoke.gd
- tests/phase10_capture.gd
- QA_GODOT_PHASE10.bat
- GUT_CREW_QA_SHOTS/phase10_*.png

## Verification
- Godot parse: 0 errors
- GODOT_PHASE10_FRONTEND_OK
- GODOT_PHASE10_CAPTURE_OK
- QA_GODOT_PHASE10_OK
