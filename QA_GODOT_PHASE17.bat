@echo off
set "ROOT=%~dp0"
set "GAME=%ROOT:~0,-1%"
set "GODOT=%ROOT%Godot_4.7.2\Godot_v4.7.2-stable_win64_console.exe"
set "LOG=%ROOT%GUT_CREW_QA_SHOTS\phase17_regression.log"
set "STEPLOG=%ROOT%GUT_CREW_QA_SHOTS\phase17_qa_step.log"
"%GODOT%" --headless --editor --quit --path "%GAME%" > "%STEPLOG%" 2>&1
set "RESULT=%ERRORLEVEL%"
type "%STEPLOG%" > "%LOG%"
type "%STEPLOG%"
if not "%RESULT%"=="0" goto fail
findstr /C:"SCRIPT ERROR:" /C:"ERROR:" "%STEPLOG%" >nul && goto fail
call :run res://tests/smoke.gd || goto fail
call :run res://tests/phase3_smoke.gd || goto fail
call :run res://tests/phase4_smoke.gd || goto fail
call :run res://tests/character_models_smoke.gd || goto fail
call :run res://tests/character_animation_smoke.gd || goto fail
call :run res://tests/character_v4_smoke.gd || goto fail
call :run res://tests/skill_vfx_smoke.gd || goto fail
call :run res://tests/enemy_models_smoke.gd || goto fail
call :run res://tests/phase5_visual_smoke.gd || goto fail
call :run res://tests/phase6_smoke.gd || goto fail
call :run res://tests/map_v4_smoke.gd || goto fail
call :run res://tests/phase7_smoke.gd || goto fail
call :run res://tests/network_state_smoke.gd || goto fail
call :run res://tests/scale_v1_smoke.gd || goto fail
call :run res://tests/phase8_economy_smoke.gd || goto fail
call :run res://tests/phase9_combat_smoke.gd || goto fail
call :run res://tests/phase10_frontend_smoke.gd || goto fail
call :run res://tests/phase11_role_combat_smoke.gd || goto fail
call :run res://tests/phase12_combat_reactions_smoke.gd || goto fail
call :run res://tests/phase13_world_story_smoke.gd || goto fail
call :run res://tests/phase14_anatomy_character_smoke.gd || goto fail
call :run res://tests/phase15_organ_world_smoke.gd || goto fail
call :run res://tests/phase16_host_boss_smoke.gd || goto fail
call :run res://tests/phase17_terrain_smoke.gd || goto fail
echo QA_GODOT_PHASE17_OK
echo QA_GODOT_PHASE17_OK >> "%LOG%"
exit /b 0
:run
"%GODOT%" --headless --path "%GAME%" --quit-after 3600 -s "%~1" > "%STEPLOG%" 2>&1
set "RESULT=%ERRORLEVEL%"
type "%STEPLOG%" >> "%LOG%"
type "%STEPLOG%"
if not "%RESULT%"=="0" exit /b 1
findstr /C:"SCRIPT ERROR:" /C:"ERROR:" "%STEPLOG%" >nul && exit /b 1
findstr /C:"_OK" "%STEPLOG%" >nul || exit /b 1
exit /b 0
:fail
echo QA_GODOT_PHASE17_FAILED
echo QA_GODOT_PHASE17_FAILED >> "%LOG%"
exit /b 1
