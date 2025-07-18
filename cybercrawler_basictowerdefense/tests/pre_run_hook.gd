extends GutHookScript

const Coverage = preload("res://addons/coverage/coverage.gd")

# Exclude paths from coverage analysis
const exclude_paths = [
	"res://addons/*",          # Exclude all addons (GUT, coverage, etc.)
	"res://tests/*",           # Exclude test scripts themselves
	"res://scenes/*",          # Exclude scene files (we only want script coverage)
	"res://tools/*"            # Exclude utility tools
]

func run():
	print("🔥 PRE-RUN HOOK IS RUNNING! 🔥")
	print("=== Initializing Code Coverage ===")
	
	# Create coverage instance with scene tree and exclusions
	Coverage.new(gut.get_tree(), exclude_paths)
	
	# Instrument all scripts in the scripts directory
	Coverage.instance.instrument_scripts("res://scripts/")
	
	print("✓ Coverage instrumentation complete")
	print("✓ Monitoring coverage for: res://scripts/")
	print("✓ Excluded paths: ", exclude_paths) 