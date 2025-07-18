@echo off
echo Testing Code Coverage Setup...
echo.

REM Change to the project directory
cd /d "%~dp0"

REM Run the simple coverage test
"C:\Program Files\Godot\Godot_v4.4.1-stable_win64.exe" --headless --quit --script "res://test_coverage_simple.gd"

echo.
echo Coverage test completed.
pause 