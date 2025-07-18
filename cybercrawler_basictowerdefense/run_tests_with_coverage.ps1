Write-Host "Running Godot tests with coverage..." -ForegroundColor Green
Write-Host ""

# Change to the project directory
Set-Location $PSScriptRoot

# Run Godot with GUT - the hooks are configured in .gutconfig.json
& "C:\Program Files\Godot\Godot_v4.4.1-stable_win64.exe" --headless --quit --script "res://addons/gut/gut_cmdln.gd"

Write-Host ""
Write-Host "Test run completed." -ForegroundColor Green
Read-Host "Press Enter to continue" 