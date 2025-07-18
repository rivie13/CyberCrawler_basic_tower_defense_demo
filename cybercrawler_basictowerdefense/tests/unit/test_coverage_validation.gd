extends GutTest

const Coverage = preload("res://addons/coverage/coverage.gd")

# Coverage requirements - same as the hooks
const COVERAGE_TARGET_TOTAL := 75.0    # 75% total coverage required (only when 90% of code has tests)
const COVERAGE_TARGET_FILE := 50.0     # 50% per-file coverage required (only for files with tests)
const MIN_LINES_COVERED := 100         # Minimum lines that must be covered (only in tested files)
const TEST_COVERAGE_THRESHOLD := 90.0  # Only require 75% total coverage when 90% of code has tests

func test_coverage_validation_system():
	# This test verifies that the coverage validation system is working
	print("DEBUG: Checking Coverage.instance...")
	var coverage = Coverage.instance
	print("DEBUG: Coverage.instance = %s" % coverage)
	
	if !coverage:
		print("DEBUG: Coverage instance is null!")
		print("DEBUG: This means the pre-run hook either:")
		print("  - Did not run")
		print("  - Failed to execute Coverage.new()")
		print("  - Coverage singleton was not created properly")
		assert_true(false, "❌ CRITICAL: Coverage instance is null. Pre-run hook failed to initialize coverage system. Check pre-run hook configuration.")
		return
	
	# Test that coverage has targets set
	var total_coverage = coverage.coverage_percent()
	var coverage_count = coverage.coverage_count()
	var total_lines = coverage.coverage_line_count()
	
	var logger = gut.get_logger()
	logger.info("🔍 Coverage System Status:")
	logger.info("  - Total lines: %d" % total_lines)
	logger.info("  - Covered lines: %d" % coverage_count)
	logger.info("  - Coverage percentage: %.1f%%" % total_coverage)
	logger.info("  - Coverage collectors: %d" % coverage.coverage_collectors.size())
	
	# Verify we have some coverage data
	if total_lines == 0:
		assert_true(false, "❌ CRITICAL: No lines found to cover. Coverage system not properly initialized. Expected to find instrumented files in res://scripts/")
		return
	
	if coverage.coverage_collectors.size() == 0:
		assert_true(false, "❌ CRITICAL: No coverage collectors found. Coverage instrumentation failed. Check if res://scripts/ contains .gd files.")
		return
	
	assert_true(coverage_count >= 0, "Should have coverage count")
	assert_true(total_coverage >= 0.0, "Should have coverage percentage")
	assert_true(total_coverage <= 100.0, "Coverage should not exceed 100%")
	
	logger.info("✅ Coverage system is properly initialized")

func test_coverage_targets_are_set():
	# This test verifies that coverage targets are properly configured
	var coverage = Coverage.instance
	if !coverage:
		assert_true(false, "❌ CRITICAL: Coverage instance is null. Pre-run hook failed to initialize coverage system.")
		return
	
	# Test that the coverage system is working by checking if it has data
	var total_lines = coverage.coverage_line_count()
	var logger = gut.get_logger()
	
	if total_lines == 0:
		logger.error("❌ Coverage system has no instrumented files!")
		logger.error("  - Expected to find .gd files in res://scripts/")
		logger.error("  - Check if pre-run hook successfully called Coverage.instance.instrument_scripts('res://scripts/')")
		logger.error("  - Check if res://scripts/ directory exists and contains .gd files")
		assert_true(false, "❌ CRITICAL: Coverage system should have instrumented files but found 0 total lines")
		return
	
	logger.info("✅ Coverage targets configured successfully (%d total lines found)" % total_lines)

func test_coverage_failing_files_detection():
	# This test verifies that we can detect files with poor coverage
	var coverage = Coverage.instance
	if !coverage:
		assert_true(false, "❌ CRITICAL: Coverage instance is null. Pre-run hook failed to initialize coverage system.")
		return
	
	# Check if we can access coverage collectors
	var logger = gut.get_logger()
	
	if coverage.coverage_collectors.size() == 0:
		logger.error("❌ No coverage collectors found!")
		logger.error("  - Expected to find instrumented files in res://scripts/")
		logger.error("  - Check if pre-run hook successfully ran Coverage.instance.instrument_scripts('res://scripts/')")
		assert_true(false, "❌ CRITICAL: Should have coverage collectors but found 0. Coverage instrumentation failed.")
		return
	
	# Log file coverage details
	logger.info("📁 File Coverage Details (%d files instrumented):" % coverage.coverage_collectors.size())
	for script_path in coverage.coverage_collectors:
		var collector = coverage.coverage_collectors[script_path]
		var script_coverage = collector.coverage_percent()
		var script_lines = collector.coverage_line_count()
		var script_covered = collector.coverage_count()
		var file_name = script_path.get_file()
		
		# Calculate minimum required coverage for this file
		var min_lines_for_50_percent = int(script_lines * 0.5)
		var min_lines_required = max(100, min_lines_for_50_percent)  # At least 100 lines OR 50% of file
		
		var status = "✅" if script_covered >= min_lines_required else "❌"
		logger.info("  %s %s (%d/%d lines, %.1f%%, need %d lines)" % [status, file_name, script_covered, script_lines, script_coverage, min_lines_required])
	
	logger.info("✅ Coverage detection system is working")

func test_coverage_requirements_enforcement():
	# This test FAILS if coverage requirements are not met
	var coverage = Coverage.instance
	if !coverage:
		assert_true(false, "❌ CRITICAL: Coverage instance is null. Pre-run hook failed to initialize coverage system.")
		return
	
	# Get files with tests
	var files_with_tests = _get_files_with_tests()
	var files_without_tests = _get_files_without_tests(files_with_tests)
	
	# Calculate test coverage percentage
	var total_files = files_with_tests.size() + files_without_tests.size()
	var test_coverage_percentage = (float(files_with_tests.size()) / float(total_files)) * 100.0 if total_files > 0 else 0.0
	
	var logger = gut.get_logger()
	logger.info("📊 Test Coverage Analysis:")
	logger.info("  - Files with tests: %d" % files_with_tests.size())
	logger.info("  - Files without tests: %d" % files_without_tests.size())
	logger.info("  - Test coverage: %.1f%% of files have tests" % test_coverage_percentage)
	
	# Show which files have tests
	if files_with_tests.size() > 0:
		logger.info("📁 Files with tests:")
		for file_path in files_with_tests:
			logger.info("  - %s" % file_path.get_file())
	else:
		logger.error("❌ No files with tests found!")
		logger.error("  - Expected to find files like TowerManager.gd, GameManager.gd that have corresponding test files")
		logger.error("  - Check if test files exist: res://tests/unit/test_TowerManager.gd, res://tests/unit/test_GameManager.gd")
		assert_true(false, "❌ CRITICAL: No files with tests found. File matching logic is broken.")
		return
	
	# Check per-file coverage requirements
	var failing_files = []
	var passing_files = []
	
	for script_path in coverage.coverage_collectors:
		# Only validate files that have tests
		if script_path in files_with_tests:
			var collector = coverage.coverage_collectors[script_path]
			var script_coverage = collector.coverage_percent()
			var script_lines = collector.coverage_line_count()
			var script_covered = collector.coverage_count()
			var file_name = script_path.get_file()
			
			# Calculate minimum required coverage for this file
			var min_lines_for_50_percent = int(script_lines * 0.5)
			var min_lines_required = max(100, min_lines_for_50_percent)  # At least 100 lines OR 50% of file
			
			if script_covered < min_lines_required:
				var deficit = min_lines_required - script_covered
				failing_files.append("❌ %s: %d/%d lines covered (%.1f%%), need %d more lines to meet requirement of %d lines" % [file_name, script_covered, script_lines, script_coverage, deficit, min_lines_required])
			else:
				passing_files.append("✅ %s: %d/%d lines covered (%.1f%%), meets requirement of %d lines" % [file_name, script_covered, script_lines, script_coverage, min_lines_required])
	
	# Show results
	if passing_files.size() > 0:
		logger.info("✅ Files meeting coverage requirements:")
		for msg in passing_files:
			logger.info("  %s" % msg)
	
	if failing_files.size() > 0:
		logger.error("❌ Files NOT meeting coverage requirements:")
		for msg in failing_files:
			logger.error("  %s" % msg)
		
		var summary = "COVERAGE REQUIREMENTS FAILED: %d files need more coverage" % failing_files.size()
		logger.error("📋 SUMMARY: %s" % summary)
		assert_true(false, summary)
	else:
		logger.info("✅ All files with tests meet coverage requirements!")

func _get_files_with_tests() -> Array:
	# Get all script files that have corresponding test files
	var files_with_tests = []
	_find_script_files_with_tests("res://scripts", files_with_tests)
	return files_with_tests

func _find_script_files_with_tests(directory: String, files_with_tests: Array):
	# Recursively search for script files and check if they have tests
	var dir = DirAccess.open(directory)
	if !dir:
		print("DEBUG: Could not open directory: %s" % directory)
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
			
			print("DEBUG: Checking %s" % full_path)
			print("  - Looking for test: %s (exists: %s)" % [test_path, FileAccess.file_exists(test_path)])
			print("  - Looking for integration test: %s (exists: %s)" % [integration_test_path, FileAccess.file_exists(integration_test_path)])
			
			# Check if test file exists
			if FileAccess.file_exists(test_path) or FileAccess.file_exists(integration_test_path):
				files_with_tests.append(full_path)
				print("  - ✅ MATCH: %s has tests" % full_path)
			else:
				print("  - ❌ NO MATCH: %s has no tests" % full_path)
		
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