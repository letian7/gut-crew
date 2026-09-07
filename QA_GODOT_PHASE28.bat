@echo off
setlocal
set "ROOT=%~dp0"
set "GODOT=%ROOT%Godot_4.7.2\Godot_v4.7.2-stable_win64_console.exe"
set "LOG=%ROOT%GUT_CREW_QA_SHOTS\phase28_regression.log"
cmd /d /c call "%ROOT%QA_GODOT_PHASE27.bat" > "%LOG%" 2>&1
if errorlevel 1 goto fail
set "STEP=%ROOT%GUT_CREW_QA_SHOTS\phase28_emergency_relay.log"
"%GODOT%" --headless --path "%ROOT%." --fixed-fps 60 -s res://tests/phase28_emergency_relay_smoke.gd > "%STEP%" 2>&1
set "RESULT=%ERRORLEVEL%"
type "%STEP%" >> "%LOG%"
type "%STEP%"
if not "%RESULT%"=="0" goto fail
findstr /C:"SCRIPT ERROR:" /C:"ERROR:" /C:"TIMEOUT" "%STEP%" >nul && goto fail
findstr /C:"GODOT_PHASE28_EMERGENCY_RELAY_OK" "%STEP%" >nul || goto fail
echo QA_GODOT_PHASE28_OK >> "%LOG%"
echo QA_GODOT_PHASE28_OK
exit /b 0
:fail
echo QA_GODOT_PHASE28_FAILED >> "%LOG%"
echo QA_GODOT_PHASE28_FAILED
exit /b 1
