@echo off
set "ROOT=%~dp0"
set "GAME=%ROOT:~0,-1%"
set "GODOT=%ROOT%Godot_4.7.2\Godot_v4.7.2-stable_win64_console.exe"
"%GODOT%" --headless --editor --quit --path "%GAME%" || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/phase3_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/phase4_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/character_models_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/character_animation_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/character_v4_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/skill_vfx_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/enemy_models_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/phase5_visual_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/phase6_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/map_v4_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/phase7_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/network_state_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/scale_v1_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/phase8_economy_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/phase9_combat_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/phase10_frontend_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/phase11_role_combat_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/phase12_combat_reactions_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/phase13_world_story_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/phase14_anatomy_character_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/phase15_organ_world_smoke.gd || goto fail
echo QA_GODOT_PHASE15_OK
exit /b 0
:fail
echo QA_GODOT_PHASE15_FAILED
exit /b 1