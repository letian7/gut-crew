@echo off
setlocal
set "ROOT=%~dp0"
set "GODOT=%ROOT%Godot_4.7.2\Godot_v4.7.2-stable_win64_console.exe"
call "%ROOT%QA_GODOT_PHASE32.bat"
if errorlevel 1 exit /b 1
"%GODOT%" --headless --path "%ROOT%." -s res://tests/phase33_kaka_physics_smoke.gd
if errorlevel 1 exit /b 1
echo QA_GODOT_PHASE33_OK
endlocal
