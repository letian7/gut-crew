@echo off
set "GODOT=C:\Users\EDY\Desktop\Godot_4.7.2\Godot_v4.7.2-stable_win64_console.exe"
set "GAME=C:\Users\EDY\Desktop\GUT_CREW_GODOT"
"%GODOT%" --headless --editor --path "%GAME%" --quit || goto fail
"%GODOT%" --headless --path "%GAME%" --script res://tests/smoke.gd || goto fail
echo.
echo QA_GODOT_PHASE2_OK
exit /b 0
:fail
echo.
echo QA_GODOT_PHASE2_FAILED
exit /b 1
