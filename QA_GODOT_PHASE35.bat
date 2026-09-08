@echo off
setlocal
set "ROOT=%~dp0"
call "%ROOT%QA_GODOT_PHASE34.bat"
if errorlevel 1 exit /b 1
"%ROOT%Godot_4.7.2\Godot_v4.7.2-stable_win64_console.exe" --headless --path "%ROOT%." -s res://tests/phase35_grapple_training_smoke.gd > "%ROOT%GUT_CREW_QA_SHOTS\phase35_step.log" 2>&1
if errorlevel 1 goto fail
type "%ROOT%GUT_CREW_QA_SHOTS\phase35_step.log"
findstr /C:"ERROR:" /C:"TIMEOUT" "%ROOT%GUT_CREW_QA_SHOTS\phase35_step.log" >nul && goto fail
findstr /C:"GODOT_PHASE35_OK" "%ROOT%GUT_CREW_QA_SHOTS\phase35_step.log" >nul || goto fail
echo QA_GODOT_PHASE35_OK
exit /b 0
:fail
type "%ROOT%GUT_CREW_QA_SHOTS\phase35_step.log"
exit /b 1
