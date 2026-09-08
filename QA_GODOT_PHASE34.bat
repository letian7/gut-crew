@echo off
setlocal
set "ROOT=%~dp0"
call "%ROOT%QA_GODOT_PHASE33.bat"
if errorlevel 1 exit /b 1
"%ROOT%Godot_4.7.2\Godot_v4.7.2-stable_win64_console.exe" --headless --path "%ROOT%." -s res://tests/phase34_art_smoke.gd > "%ROOT%GUT_CREW_QA_SHOTS\phase34_art.log" 2>&1
if errorlevel 1 exit /b 1
type "%ROOT%GUT_CREW_QA_SHOTS\phase34_art.log"
findstr /C:"ERROR:" /C:"TIMEOUT" "%ROOT%GUT_CREW_QA_SHOTS\phase34_art.log" >nul && exit /b 1
findstr /C:"GODOT_PHASE34_ART_OK" "%ROOT%GUT_CREW_QA_SHOTS\phase34_art.log" >nul || exit /b 1
echo QA_GODOT_PHASE34_OK
