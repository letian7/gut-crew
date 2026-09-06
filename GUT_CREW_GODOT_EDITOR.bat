@echo off
set "ROOT=%~dp0"
set "GAME=%ROOT:~0,-1%"
start "" "%ROOT%Godot_4.7.2\Godot_v4.7.2-stable_win64.exe" --editor --path "%GAME%"
exit /b 0
