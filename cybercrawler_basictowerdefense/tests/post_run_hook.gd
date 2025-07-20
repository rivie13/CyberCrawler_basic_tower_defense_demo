extends GutHookScript

const Coverage = preload("res://addons/coverage/coverage.gd")

# Coverage requirements - tests will fail if these aren't met
const COVERAGE_TARGET_TOTAL := 75.0    # 75% total coverage required (only when 90% of code has tests)
const COVERAGE_TARGET_FILE := 50.0     # 50% per-file coverage required (only for files with tests)
const MIN_LINES_COVERED := 100         # Minimum lines that must be covered (only in tested files)
const TEST_COVERAGE_THRESHOLD := 90.0  # Only require 75% total coverage when 90% of code has tests

func run():
	print("🔥 POST-RUN HOOK IS RUNNING! 🔥")
	print("=== Final Coverage Validation ===")
	
	# Validate coverage requirements now that tests have run
	_validate_coverage_requirements()
	
	# Finalize coverage system and show report
	Coverage.finalize(Coverage.Verbosity.NONE)
	print("=== Coverage Validation Complete ===")

func _validate_coverage_requirements():
	var coverage = Coverage.instance
	if !coverage:
		print("❌ No coverage instance found!")
		_fail_tests("Coverage system not initialized")
		return
	
	# Find which files actually have tests
	var files_with_tests = _get_files_with_tests()
	var files_without_tests = _get_files_without_tests(files_with_tests)
	
	print("--- Test Coverage Analysis ---")
	print("Files with tests: %d" % files_with_tests.size())
	print("Files without tests: %d (IGNORED)" % files_without_tests.size())
	
	if files_with_tests.size() == 0:
		print("❌ CRITICAL: No files with tests found!")
		print("❌ Expected to find files like GameManager.gd that have corresponding test files")
		print("❌ Check if test files exist with correct naming pattern")
		_fail_tests("No files with tests found. File matching logic broken.")
		return
	
	# Calculate coverage only for files that have tests
	var total_lines_tested_files = 0
	var covered_lines_tested_files = 0
	
	# Check per-file coverage (validate ONLY files that have dedicated tests)
	var failing_files = []
	var file_coverage_details = []
	
	for script_path in coverage.coverage_collectors:
		var collector = coverage.coverage_collectors[script_path]
		var script_coverage = collector.coverage_percent()
		var script_lines = collector.coverage_line_count()
		var script_covered = collector.coverage_count()
		var file_name = script_path.get_file()
		
		# Only validate files that have dedicated tests
		var has_tests = script_path in files_with_tests
		var has_coverage = script_covered > 0
		
		if has_tests:
			# Add to tested files totals
			total_lines_tested_files += script_lines
			covered_lines_tested_files += script_covered
			
			# Calculate minimum required coverage for this file (50% of file OR 100 lines minimum, whichever is LESS)
			var percent_required = int(script_lines * 0.5)  # 50% of file
			var min_lines_required = min(percent_required, MIN_LINES_COVERED)  # 50% OR 100 lines, whichever is LESS
			
			var status = "✅" if script_covered >= min_lines_required else "❌"
			var test_status = "📝" if has_tests else "❌"
			var requirement_explanation = ""
			if min_lines_required == MIN_LINES_COVERED:
				requirement_explanation = "min %d < 50%% of %d" % [MIN_LINES_COVERED, script_lines]
			else:
				requirement_explanation = "50%% of %d" % script_lines
			file_coverage_details.append("%s %s %s (%d/%d lines, %.1f%%, need %d lines - %s)" % [status, test_status, file_name, script_covered, script_lines, script_coverage, min_lines_required, requirement_explanation])
			
			if script_covered < min_lines_required:
				var reason = "no tests" if not has_tests else "insufficient coverage"
				failing_files.append("%s (%d/%d lines, need %d more) - %s" % [file_name, script_covered, script_lines, min_lines_required - script_covered, reason])
	
	# Calculate total coverage for tested files only
	var total_coverage_tested_files = 0.0
	if total_lines_tested_files > 0:
		total_coverage_tested_files = (float(covered_lines_tested_files) / float(total_lines_tested_files)) * 100.0
	
	# Calculate TOTAL coverage across ALL files (including files without tests)
	var total_lines_all_files = 0
	var covered_lines_all_files = 0
	for script_path in coverage.coverage_collectors:
		var collector = coverage.coverage_collectors[script_path]
		total_lines_all_files += collector.coverage_line_count()
		covered_lines_all_files += collector.coverage_count()
	
	var total_coverage_all_files = 0.0
	if total_lines_all_files > 0:
		total_coverage_all_files = (float(covered_lines_all_files) / float(total_lines_all_files)) * 100.0
	
	print("🔥🔥🔥 COVERAGE SUMMARY 🔥🔥🔥")
	print("📊 TOTAL COVERAGE (ALL CODE): %.1f%% (%d/%d lines)" % [total_coverage_all_files, covered_lines_all_files, total_lines_all_files])
	print("📊 VALIDATED FILES COVERAGE: %.1f%% (%d/%d lines)" % [total_coverage_tested_files, covered_lines_tested_files, total_lines_tested_files])
	print("🔥🔥🔥 END COVERAGE SUMMARY 🔥🔥🔥")
	
	# Show detailed breakdown
	print("\n📋 COVERAGE BREAKDOWN:")
	print("  • Files with tests: %d files" % files_with_tests.size())
	print("  • Files without tests: %d files (IGNORED)" % files_without_tests.size())
	print("  • Total script files: %d files" % (files_with_tests.size() + files_without_tests.size()))
	
	# Show file-by-file coverage for validated files
	if file_coverage_details.size() > 0:
		print("\n📁 Files Being Validated (✅=meets coverage, 📝=has tests, ❌=fails):")
		for detail in file_coverage_details:
			print("  %s" % detail)
	
	# Show ALL files with their coverage percentages
	print("\n--- All Files Coverage Breakdown ---")
	var files_with_tests_and_coverage = []
	var files_without_tests_but_coverage = []
	var files_without_coverage = []
	
	for script_path in coverage.coverage_collectors:
		var collector = coverage.coverage_collectors[script_path]
		var script_coverage = collector.coverage_percent()
		var script_lines = collector.coverage_line_count()
		var script_covered = collector.coverage_count()
		var file_name = script_path.get_file()
		
		# Check if this file has tests
		var has_tests = script_path in files_with_tests
		
		if script_covered > 0:
			if has_tests:
				# File has tests - check if it meets requirements
				var percent_required = int(script_lines * 0.5)  # 50% of file
				var min_lines_required = min(percent_required, MIN_LINES_COVERED)  # 50% OR 100 lines, whichever is LESS
				var status = "✅" if script_covered >= min_lines_required else "❌"
				files_with_tests_and_coverage.append("%s %.1f%% %s (%d/%d lines)" % [status, script_coverage, file_name, script_covered, script_lines])
			else:
				# File has no tests but has coverage (not validated)
				files_without_tests_but_coverage.append("📝 %.1f%% %s (%d/%d lines) - NO TESTS" % [script_coverage, file_name, script_covered, script_lines])
		else:
			if has_tests:
				# File has tests but no coverage (should fail)
				files_without_coverage.append("❌ 0.0%% %s (%d lines) - HAS TESTS" % [file_name, script_lines])
			else:
				# File has no tests and no coverage (not validated)
				files_without_coverage.append("📝 0.0%% %s (%d lines) - NO TESTS" % [file_name, script_lines])
	
	# Show files with tests that have coverage
	if files_with_tests_and_coverage.size() > 0:
		print("📊 Files with Tests and Coverage (%d files):" % files_with_tests_and_coverage.size())
		for file_info in files_with_tests_and_coverage:
			print("  %s" % file_info)
	
	# Show files without tests but with coverage
	if files_without_tests_but_coverage.size() > 0:
		print("📊 Files without Tests but with Coverage (%d files):" % files_without_tests_but_coverage.size())
		for file_info in files_without_tests_but_coverage:
			print("  %s" % file_info)
	
	# Show files with no coverage
	if files_without_coverage.size() > 0:
		print("📊 Files with No Coverage (%d files):" % files_without_coverage.size())
		for file_info in files_without_coverage:
			print("  %s" % file_info)
	
	# Validate coverage requirements
	var validation_errors = []
	
	# Calculate test coverage percentage
	var total_files = files_with_tests.size() + files_without_tests.size()
	var test_coverage_percentage = (float(files_with_tests.size()) / float(total_files)) * 100.0 if total_files > 0 else 0.0
	
	# Add test coverage percentage to the breakdown
	print("  • Test coverage: %.1f%% of files have tests" % test_coverage_percentage)
	
	# Check total coverage requirement (if 90% of files have tests)
	if test_coverage_percentage >= TEST_COVERAGE_THRESHOLD:
		if total_coverage_all_files < COVERAGE_TARGET_TOTAL:
			validation_errors.append("Total coverage across ALL files %.1f%% is below target %.1f%% (required when %.1f%% of files have tests)" % [total_coverage_all_files, COVERAGE_TARGET_TOTAL, TEST_COVERAGE_THRESHOLD])
	else:
		print("ℹ️ Total coverage requirement waived (only %.1f%% of files have tests, need %.1f%%)" % [test_coverage_percentage, TEST_COVERAGE_THRESHOLD])
	
	# Add per-file failures to validation errors
	if failing_files.size() > 0:
		validation_errors.append("Files with insufficient coverage: %s" % ", ".join(failing_files))
	
	# CHECK FOR VALIDATION FAILURES
	if validation_errors.size() > 0:
		# Coverage requirements not met
		print("❌ COVERAGE VALIDATION FAILED!")
		for error in validation_errors:
			print("  - %s" % error)
		
		# Fail the test run
		_fail_tests("Coverage requirements not met: " + "; ".join(validation_errors))
	else:
		# Coverage requirements met
		print("✅ COVERAGE VALIDATION PASSED!")
		print("✅ All files with tests meet coverage requirements (50%% OR %d lines minimum, whichever is LESS)!" % MIN_LINES_COVERED)

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
			# Convert CamelCase to snake_case for test file matching
			var base_name = file_name.get_basename()  # Remove .gd extension
			var snake_case_name = _camel_to_snake_case(base_name)
			var test_file_name = "test_" + snake_case_name + ".gd"
			
			# Check if this script file has a corresponding test file
			var test_path = "res://tests/unit/" + test_file_name
			var integration_test_path = "res://tests/integration/" + test_file_name
			
			# Check if test file exists
			if FileAccess.file_exists(test_path) or FileAccess.file_exists(integration_test_path):
				files_with_tests.append(full_path)
		
		file_name = dir.get_next()

func _camel_to_snake_case(camel_case: String) -> String:
	# Convert CamelCase to snake_case
	# GameManager -> game_manager
	# TowerManager -> tower_manager
	var result = ""
	for i in range(camel_case.length()):
		var char = camel_case[i]
		if char.to_upper() == char and i > 0:
			result += "_"
		result += char.to_lower()
	return result

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

func _fail_tests(reason: String):
	# Log the coverage failure prominently
	print("🚫 COVERAGE VALIDATION FAILED: %s" % reason)
	print("❌ Tests will be FAILED due to insufficient coverage!")
	
	# Push error for logging
	push_error("COVERAGE VALIDATION FAILED: " + reason)
	
	print("🔥 FORCING IMMEDIATE EXIT WITH CODE 1")
	
	# Force immediate exit with code 1 - this should make GitHub Actions fail
	if gut and gut.get_tree():
		gut.get_tree().quit(1)
	else:
		# Fallback: force exit with code 1
		OS.kill(OS.get_process_id()) 
