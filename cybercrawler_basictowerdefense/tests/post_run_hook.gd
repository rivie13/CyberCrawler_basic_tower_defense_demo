extends GutHookScript

const Coverage = preload("res://addons/coverage/coverage.gd")

# Coverage targets
const COVERAGE_TARGET_TOTAL := 75.0    # 75% total coverage target
const COVERAGE_TARGET_FILE := 50.0     # 50% per-file coverage target

func run():
	print("🔥 POST-RUN HOOK IS RUNNING! 🔥")
	print("\n=== Finalizing Code Coverage ===")
	
	var coverage = Coverage.instance
	if !coverage:
		print("❌ No coverage instance found!")
		return
	
	# Save coverage file if environment variable is set
	var coverage_file := OS.get_environment("COVERAGE_FILE") if OS.has_environment("COVERAGE_FILE") else ""
	if coverage_file:
		print("💾 Saving coverage to: ", coverage_file)
		coverage.save_coverage_file(coverage_file)
	
	# Set coverage targets
	coverage.set_coverage_targets(COVERAGE_TARGET_TOTAL, COVERAGE_TARGET_FILE)
	
	# Get coverage statistics
	var total_coverage: float = coverage.coverage_percent()
	var coverage_count: int = coverage.coverage_count()
	var total_lines: int = coverage.coverage_line_count()
	
	print("\n--- Coverage Summary ---")
	print("Lines Covered: ", coverage_count)
	print("Total Lines: ", total_lines)
	print("Coverage: %.1f%%" % total_coverage)
	print("Target: %.1f%%" % COVERAGE_TARGET_TOTAL)
	
	# Finalize coverage with detailed reporting
	var verbosity = Coverage.Verbosity.FAILING_FILES
	if total_coverage >= COVERAGE_TARGET_TOTAL:
		verbosity = Coverage.Verbosity.FILENAMES
	
	Coverage.finalize(verbosity)
	
	# Check if coverage targets are met
	var coverage_passing = coverage.coverage_passing()
	var logger = gut.get_logger()
	
	if coverage_passing:
		print("✅ Coverage targets met!")
		logger.passed("Coverage: %.1f%% (target: %.1f%% total, %.1f%% per file)" % [total_coverage, COVERAGE_TARGET_TOTAL, COVERAGE_TARGET_FILE])
	else:
		print("❌ Coverage targets not met!")
		logger.failed("Coverage: %.1f%% - Target of %.1f%% total (%.1f%% per file) was not met" % [total_coverage, COVERAGE_TARGET_TOTAL, COVERAGE_TARGET_FILE])
		set_exit_code(2)
	
	print("=== Coverage Analysis Complete ===\n") 