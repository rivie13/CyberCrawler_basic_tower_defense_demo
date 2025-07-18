@echo off
echo Running Godot tests with coverage...
echo.

REM Change to the project directory
cd /d "%~dp0"

REM Run Godot with GUT - the hooks are configured in .gutconfig.json
"C:\Program Files\Godot\Godot_v4.4.1-stable_win64.exe" --headless --quit --script "res://addons/gut/gut_cmdln.gd"

echo.
echo Test run completed.
pause 