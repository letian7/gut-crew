@echo off
set "ROOT=%~dp0"
set "LOG=%ROOT%GUT_CREW_QA_SHOTS\phase18_regression.log"
set "STEP=%ROOT%GUT_CREW_QA_SHOTS\phase18_art_step.log"
cmd /d /c call "%ROOT%QA_GODOT_PHASE17.bat" > "%LOG%" 2>&1
if errorlevel 1 goto fail
"%ROOT%Godot_4.7.2\Godot_v4.7.2-stable_win64_console.exe" --headless --path "%ROOT%." --quit-after 3600 -s res://tests/phase18_art_smoke.gd > "%STEP%" 2>&1
set "RESULT=%ERRORLEVEL%"
type "%STEP%" >> "%LOG%"
type "%STEP%"
if not "%RESULT%"=="0" goto fail
findstr /C:"SCRIPT ERROR:" /C:"ERROR:" "%STEP%" >nul && goto fail
findstr /C:"GODOT_PHASE18_ART_OK" "%STEP%" >nul || goto fail
echo QA_GODOT_PHASE18_OK >> "%LOG%"
echo QA_GODOT_PHASE18_OK
exit /b 0
:fail
echo QA_GODOT_PHASE18_FAILED >> "%LOG%"
echo QA_GODOT_PHASE18_FAILED
exit /b 1
