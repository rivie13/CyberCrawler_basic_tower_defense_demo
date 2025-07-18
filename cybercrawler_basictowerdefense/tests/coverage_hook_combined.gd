extends GutHookScript

const Coverage = preload("res://addons/coverage/coverage.gd")

# Coverage requirements - tests will fail if these aren't met
const COVERAGE_TARGET_TOTAL := 75.0    # 75% total coverage required (only when 90% of code has tests)
const COVERAGE_TARGET_FILE := 50.0     # 50% per-file coverage required (only for files with tests)
const MIN_LINES_COVERED := 100         # Minimum lines that must be covered (only in tested files)
const TEST_COVERAGE_THRESHOLD := 90.0  # Only require 75% total coverage when 90% of code has tests

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
		# Pre-run hook - initialize coverage
		print("🔥 PRE-RUN HOOK IS RUNNING! 🔥")
		print("=== Initializing Code Coverage ===")
		
		# Create fresh coverage instance with scene tree and exclusions
		Coverage.new(gut.get_tree(), exclude_paths)
		
		# Instrument all scripts in the scripts directory
		Coverage.instance.instrument_scripts("res://scripts/")
		
		# Set coverage targets
		Coverage.instance.set_coverage_targets(COVERAGE_TARGET_TOTAL, COVERAGE_TARGET_FILE)
		
		print("✓ Coverage instrumentation complete")
		print("✓ Monitoring coverage for: res://scripts/")
		print("✓ Coverage targets: %.1f%% total, %.1f%% per file" % [COVERAGE_TARGET_TOTAL, COVERAGE_TARGET_FILE])
		print("✓ Excluded paths: ", exclude_paths)
		
		is_pre_run = false
	else:
		# Post-run hook - validate coverage and fail tests if insufficient
		print("🔥 POST-RUN HOOK IS RUNNING! 🔥")
		print("\n=== Validating Code Coverage ===")
		
		var coverage = Coverage.instance
		if !coverage:
			print("❌ No coverage instance found!")
			_fail_tests("Coverage system not initialized")
			return
		
		# Get coverage statistics
		var total_coverage: float = coverage.coverage_percent()
		var coverage_count: int = coverage.coverage_count()
		var total_lines: int = coverage.coverage_line_count()
		
		print("\n--- Coverage Summary ---")
		print("Lines Covered: %d" % coverage_count)
		print("Total Lines: %d" % total_lines)
		print("Coverage: %.1f%%" % total_coverage)
		
		# Find which files actually have tests
		var files_with_tests = _get_files_with_tests()
		var files_without_tests = _get_files_without_tests(files_with_tests)
		
		print("\n--- Test Coverage Analysis ---")
		print("Files with tests: %d" % files_with_tests.size())
		print("Files without tests: %d" % files_without_tests.size())
		
		# Calculate what percentage of code has tests
		var total_files = files_with_tests.size() + files_without_tests.size()
		var test_coverage_percentage = (float(files_with_tests.size()) / float(total_files)) * 100.0 if total_files > 0 else 0.0
		print("Code with tests: %.1f%%" % test_coverage_percentage)
		
		# Validate coverage requirements
		var validation_errors = []
		
		# Only check total coverage if 90% of code has tests
		if test_coverage_percentage >= TEST_COVERAGE_THRESHOLD:
			if total_coverage < COVERAGE_TARGET_TOTAL:
				validation_errors.append("Total coverage %.1f%% is below target %.1f%% (required when %.1f%% of code has tests)" % [total_coverage, COVERAGE_TARGET_TOTAL, TEST_COVERAGE_THRESHOLD])
		else:
			print("ℹ️ Total coverage requirement waived (only %.1f%% of code has tests, need %.1f%%)" % [test_coverage_percentage, TEST_COVERAGE_THRESHOLD])
		
		# Check minimum lines covered (only for files with tests)
		var covered_lines_in_tested_files = _get_covered_lines_in_tested_files(coverage, files_with_tests)
		if covered_lines_in_tested_files < MIN_LINES_COVERED:
			validation_errors.append("Only %d lines covered in tested files, minimum required: %d" % [covered_lines_in_tested_files, MIN_LINES_COVERED])
		
		# Check per-file coverage (only for files that have tests)
		var failing_files = []
		var file_coverage_details = []
		for script_path in coverage.coverage_collectors:
			# Only validate files that have tests
			if script_path in files_with_tests:
				var script_coverage = coverage.coverage_collectors[script_path].coverage_percent()
				var file_name = script_path.get_file()
				var status = "✅" if script_coverage >= COVERAGE_TARGET_FILE else "❌"
				file_coverage_details.append("%s %s (%.1f%%)" % [status, file_name, script_coverage])
				
				if script_coverage < COVERAGE_TARGET_FILE:
					failing_files.append("%s (%.1f%%)" % [file_name, script_coverage])
		
		if failing_files.size() > 0:
			validation_errors.append("Files with tests below %.1f%% coverage: %s" % [COVERAGE_TARGET_FILE, ", ".join(failing_files)])
		
		# Use GUT's logging system for output
		var logger = gut.get_logger()
		
		# ALWAYS show comprehensive coverage summary in GUT run summary
		_add_comprehensive_summary_to_gut(logger, total_coverage, coverage_count, total_lines, 
			test_coverage_percentage, files_with_tests, files_without_tests, 
			file_coverage_details, validation_errors)
		
		if validation_errors.size() > 0:
			# Coverage requirements not met - fail all tests
			logger.error("❌ COVERAGE VALIDATION FAILED!")
			for error in validation_errors:
				logger.error("  - %s" % error)
			
			# Finalize coverage with detailed reporting
			Coverage.finalize(Coverage.Verbosity.FAILING_FILES)
			
			# Fail the test run
			_fail_tests("Coverage requirements not met: " + "; ".join(validation_errors))
		else:
			# Coverage requirements met
			logger.info("✅ COVERAGE VALIDATION PASSED!")
			
			# Finalize coverage with minimal reporting
			Coverage.finalize(Coverage.Verbosity.FILENAMES)
		
		print("=== Coverage Validation Complete ===\n")
		
		# Reset for next run
		is_pre_run = true

func _get_files_with_tests() -> Array:
	# Get all script files that have corresponding test files
	var files_with_tests = []
	_find_script_files_with_tests("res://scripts", files_with_tests)
	return files_with_tests

func _find_script_files_with_tests(directory: String, files_with_tests: Array):
	# Recursively search for script files and check if they have tests
	var dir = DirAccess.open(directory)
	if !dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var full_path = directory + "/" + file_name
		
		if dir.current_is_dir():
			# Recursively search subdirectories
			_find_script_files_with_tests(full_path, files_with_tests)
		elif file_name.ends_with(".gd"):
			# Check if this script file has a corresponding test file
			var test_path = "res://tests/unit/test_" + file_name
			var integration_test_path = "res://tests/integration/test_" + file_name
			
			# Check if test file exists
			if FileAccess.file_exists(test_path) or FileAccess.file_exists(integration_test_path):
				files_with_tests.append(full_path)
		
		file_name = dir.get_next()

func _get_files_without_tests(files_with_tests: Array) -> Array:
	# Get all script files that don't have tests
	var files_without_tests = []
	_find_all_script_files("res://scripts", files_without_tests)
	
	# Remove files that have tests
	var result = []
	for file_path in files_without_tests:
		if file_path not in files_with_tests:
			result.append(file_path)
	
	return result

func _find_all_script_files(directory: String, all_files: Array):
	# Recursively find all script files
	var dir = DirAccess.open(directory)
	if !dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var full_path = directory + "/" + file_name
		
		if dir.current_is_dir():
			# Recursively search subdirectories
			_find_all_script_files(full_path, all_files)
		elif file_name.ends_with(".gd"):
			all_files.append(full_path)
		
		file_name = dir.get_next()

func _get_covered_lines_in_tested_files(coverage, files_with_tests: Array) -> int:
	# Count covered lines only in files that have tests
	var covered_lines = 0
	for script_path in coverage.coverage_collectors:
		if script_path in files_with_tests:
			covered_lines += coverage.coverage_collectors[script_path].coverage_count()
	return covered_lines

func _add_comprehensive_summary_to_gut(logger, total_coverage: float, coverage_count: int, total_lines: int, 
	test_coverage_percentage: float, files_with_tests: Array, files_without_tests: Array, 
	file_coverage_details: Array, validation_errors: Array):
	# Add comprehensive coverage information to GUT's run summary (always shown)
	logger.info("")
	logger.info("=== CODE COVERAGE SUMMARY ===")
	logger.info("📊 Overall Coverage: %.1f%% (%d/%d lines)" % [total_coverage, coverage_count, total_lines])
	logger.info("📋 Test Coverage: %.1f%% of code has tests (%d/%d files)" % [test_coverage_percentage, files_with_tests.size(), files_with_tests.size() + files_without_tests.size()])
	
	# Show file-by-file coverage for tested files
	if file_coverage_details.size() > 0:
		logger.info("")
		logger.info("📁 Files with Tests (Coverage):")
		for detail in file_coverage_details:
			logger.info("  %s" % detail)
	
	# Show files without tests
	if files_without_tests.size() > 0:
		logger.info("")
		logger.info("🚫 Files without Tests (ignored in validation):")
		for file_path in files_without_tests:
			logger.info("  - %s" % file_path.get_file())
	
	# Show validation status
	if validation_errors.size() > 0:
		logger.info("")
		logger.error("❌ COVERAGE VALIDATION FAILED!")
		for error in validation_errors:
			logger.error("  - %s" % error)
	else:
		logger.info("")
		logger.info("✅ COVERAGE VALIDATION PASSED!")
		if test_coverage_percentage < TEST_COVERAGE_THRESHOLD:
			logger.info("ℹ️ Total coverage requirement waived (need %.1f%% test coverage for %.1f%% total requirement)" % [TEST_COVERAGE_THRESHOLD, COVERAGE_TARGET_TOTAL])
	
	logger.info("")

func _fail_tests(reason: String):
	# Force GUT to fail the entire test run
	var logger = gut.get_logger()
	logger.error("🚫 TESTS FAILED: %s" % reason)
	
	# Set a flag that will cause GUT to exit with failure
	gut.set_exit_code(1)
	
	# Force immediate exit
	gut.end_run() 
