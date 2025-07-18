extends GutHookScript

const Coverage = preload("res://addons/coverage/coverage.gd")

# Exclude paths from coverage analysis
const exclude_paths = [
	"res://addons/*",          # Exclude all addons (GUT, coverage, etc.)
	"res://tests/*",           # Exclude test scripts themselves
	"res://scenes/*",          # Exclude scene files (we only want script coverage)
	"res://tools/*"            # Exclude utility tools
]

var is_pre_run = true

func run():
	if is_pre_run:
		# Pre-run hook - always run this to ensure fresh coverage
		print("🔥 PRE-RUN HOOK IS RUNNING! 🔥")
		print("=== Initializing Code Coverage ===")
		
				# Check if coverage instance already exists, only create if it doesn't
	if !Coverage.instance:
		# Create fresh coverage instance with scene tree and exclusions
		Coverage.new(gut.get_tree(), exclude_paths)
		
		# Instrument all scripts in the scripts directory
		Coverage.instance.instrument_scripts("res://scripts/")
		
		print("✓ Coverage instrumentation complete")
		print("✓ Monitoring coverage for: res://scripts/")
		print("✓ Excluded paths: ", exclude_paths)
		
		is_pre_run = false
	else:
		# Post-run hook
		print("🔥 POST-RUN HOOK IS RUNNING! 🔥")
		print("\n=== Finalizing Code Coverage ===")
		
		var coverage = Coverage.instance
		if !coverage:
			print("❌ No coverage instance found!")
			return
		
		# Get coverage statistics
		var total_coverage: float = coverage.coverage_percent()
		var coverage_count: int = coverage.coverage_count()
		var total_lines: int = coverage.coverage_line_count()
		
		# Use GUT's logging system for cleaner output
		var logger = gut.get_logger()
		logger.info("📊 Coverage: %.1f%% (%d/%d lines)" % [total_coverage, coverage_count, total_lines])
		
		# Finalize coverage with minimal reporting to avoid overflow
		Coverage.finalize(Coverage.Verbosity.FILENAMES)
		
		print("=== Coverage Analysis Complete ===\n")
		
		# Reset for next run
		is_pre_run = true 
