@echo off
set "GODOT=C:\Users\EDY\Desktop\Godot_4.7.2\Godot_v4.7.2-stable_win64_console.exe"
set "GAME=C:\Users\EDY\Desktop\GUT_CREW_GODOT"
"%GODOT%" --headless --editor --quit --path "%GAME%" || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/phase3_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/phase4_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/character_models_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/character_animation_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/character_v3_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/map_visual_v2_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/character_v4_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/map_v3_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/skill_vfx_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/enemy_models_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/phase5_visual_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/clay_surface_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/phase6_smoke.gd || goto fail
"%GODOT%" --headless --path "%GAME%" -s res://tests/map_v4_smoke.gd || goto fail
echo.
echo QA_GODOT_PHASE6_OK
exit /b 0
:fail
echo.
echo QA_GODOT_PHASE6_FAILED
exit /b 1
