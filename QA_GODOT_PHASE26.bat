@echo off
setlocal
set "ROOT=%~dp0"
set "GODOT=%ROOT%Godot_4.7.2\Godot_v4.7.2-stable_win64_console.exe"
set "LOG=%ROOT%GUT_CREW_QA_SHOTS\phase26_regression.log"
rem Original coordinate-specific fixtures remain separate from production-size tests.
set "GUT_CREW_QA_LEGACY_LAYOUT=1"
cmd /d /c call "%ROOT%QA_GODOT_PHASE23.bat" > "%LOG%" 2>&1
if errorlevel 1 goto fail
set "GUT_CREW_QA_LEGACY_LAYOUT="
call :check phase24_world_scale_smoke GODOT_PHASE24_WORLD_SCALE_OK
if errorlevel 1 goto fail
call :check phase25_world_polish_smoke GODOT_PHASE25_WORLD_POLISH_OK
if errorlevel 1 goto fail
call :check phase26_minimap_feedback_smoke GODOT_PHASE26_MINIMAP_FEEDBACK_OK
if errorlevel 1 goto fail
call :check phase3_smoke GODOT_PHASE3_FULL_ROUND_OK
if errorlevel 1 goto fail
call :check phase23_hud_smoke GODOT_PHASE23_HUD_OK
if errorlevel 1 goto fail
echo QA_GODOT_PHASE26_OK >> "%LOG%"
echo QA_GODOT_PHASE26_OK
exit /b 0
:check
set "STEP=%ROOT%GUT_CREW_QA_SHOTS\phase26_%~1.log"
"%GODOT%" --headless --path "%ROOT%." --fixed-fps 60 -s "res://tests/%~1.gd" > "%STEP%" 2>&1
set "RESULT=%ERRORLEVEL%"
type "%STEP%" >> "%LOG%"
type "%STEP%"
if not "%RESULT%"=="0" exit /b 1
findstr /C:"SCRIPT ERROR:" /C:"ERROR:" /C:"TIMEOUT" "%STEP%" >nul && exit /b 1
findstr /C:"%~2" "%STEP%" >nul || exit /b 1
exit /b 0
:fail
echo QA_GODOT_PHASE26_FAILED >> "%LOG%"
echo QA_GODOT_PHASE26_FAILED
exit /b 1
