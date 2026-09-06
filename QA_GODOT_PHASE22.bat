@echo off
setlocal
set "ROOT=%~dp0"
set "LOG=%ROOT%GUT_CREW_QA_SHOTS\phase22_regression.log"
set "STEP=%ROOT%GUT_CREW_QA_SHOTS\phase22_art_step.log"
cmd /d /c call "%ROOT%QA_GODOT_PHASE21.bat" > "%LOG%" 2>&1
if errorlevel 1 goto fail
"%ROOT%Godot_4.7.2\Godot_v4.7.2-stable_win64_console.exe" --headless --path "%ROOT%." -s res://tests/phase22_art_bugfix_smoke.gd > "%STEP%" 2>&1
set "RESULT=%ERRORLEVEL%"
type "%STEP%" >> "%LOG%"
type "%STEP%"
if not "%RESULT%"=="0" goto fail
findstr /C:"SCRIPT ERROR:" /C:"ERROR:" /C:"TIMEOUT" "%STEP%" >nul && goto fail
findstr /C:"GODOT_PHASE22_ART_BUGFIX_OK" "%STEP%" >nul || goto fail
echo QA_GODOT_PHASE22_OK >> "%LOG%"
echo QA_GODOT_PHASE22_OK
exit /b 0
:fail
echo QA_GODOT_PHASE22_FAILED >> "%LOG%"
echo QA_GODOT_PHASE22_FAILED
exit /b 1
