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
		
		# Skip files that shouldn't be displayed in coverage reports
		if _should_skip_file_for_coverage_display(file_name):
			continue
		
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
	
	# Calculate test coverage percentages
	var total_files = files_with_tests.size() + files_without_tests.size()
	var test_coverage_percentage = (float(files_with_tests.size()) / float(total_files)) * 100.0 if total_files > 0 else 0.0
	
	# Calculate test coverage for files that actually need tests
	var files_that_need_tests = _get_files_that_need_tests()
	var files_that_need_tests_and_have_tests = _get_files_that_need_tests_and_have_tests(files_with_tests)
	var test_coverage_required_files_percentage = (float(files_that_need_tests_and_have_tests.size()) / float(files_that_need_tests.size())) * 100.0 if files_that_need_tests.size() > 0 else 0.0
	
	# Add test coverage percentages to the breakdown
	print("  • Test coverage (ALL files): %.1f%% of files have tests" % test_coverage_percentage)
	print("  • Test coverage (files that need tests): %.1f%% of required files have tests" % test_coverage_required_files_percentage)
	print("  • Files that need tests: %d files" % files_that_need_tests.size())
	print("  • Files that need tests AND have tests: %d files" % files_that_need_tests_and_have_tests.size())
	
	# Check total coverage requirement (if 90% of files that need tests have tests)
	if test_coverage_required_files_percentage >= TEST_COVERAGE_THRESHOLD:
		if total_coverage_all_files < COVERAGE_TARGET_TOTAL:
			validation_errors.append("Total coverage across ALL files %.1f%% is below target %.1f%% (required when %.1f%% of files that need tests have tests)" % [total_coverage_all_files, COVERAGE_TARGET_TOTAL, TEST_COVERAGE_THRESHOLD])
	else:
		print("ℹ️ Total coverage requirement waived (only %.1f%% of files that need tests have tests, need %.1f%%)" % [test_coverage_required_files_percentage, TEST_COVERAGE_THRESHOLD])
	
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
	print("🔍 Building test files cache...")
	var test_files_cache = _build_test_files_cache()
	print("🔍 Found %d test files in cache" % test_files_cache.size())
	
	var files_with_tests = []
	_find_script_files_with_tests("res://scripts", files_with_tests, test_files_cache)
	print("🔍 Found %d files with tests" % files_with_tests.size())
	return files_with_tests

func _build_test_files_cache() -> Array:
	# Build a cache of all test files to avoid repeated recursive searches
	var test_files_cache = []
	_collect_test_files_recursive("res://tests/unit", test_files_cache)
	_collect_test_files_recursive("res://tests/integration", test_files_cache)
	return test_files_cache

func _collect_test_files_recursive(directory: String, test_files_cache: Array):
	# Recursively collect all test files into cache
	var dir = DirAccess.open(directory)
	if !dir:
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var full_path = directory + "/" + file_name
		if dir.current_is_dir():
			_collect_test_files_recursive(full_path, test_files_cache)
		elif file_name.begins_with("test_") and file_name.ends_with(".gd"):
			test_files_cache.append(file_name)
		file_name = dir.get_next()

func _find_script_files_with_tests(directory: String, files_with_tests: Array, test_files_cache: Array):
	# Recursively search for script files and check if they have tests using cache
	var dir = DirAccess.open(directory)
	if !dir:
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var full_path = directory + "/" + file_name
		if dir.current_is_dir():
			# Recursively search subdirectories
			_find_script_files_with_tests(full_path, files_with_tests, test_files_cache)
		elif file_name.ends_with(".gd"):
			# Skip files that don't need direct tests (using mocks)
			if _should_skip_file_for_test_check(file_name):
				file_name = dir.get_next()
				continue
				
			# Convert CamelCase to snake_case for test file matching
			var base_name = file_name.get_basename()  # Remove .gd extension
			var snake_case_name = _camel_to_snake_case(base_name)
			var test_file_name = "test_" + snake_case_name + ".gd"

			# Check if exact test file exists in cache
			if test_file_name in test_files_cache:
				files_with_tests.append(full_path)
			else:
				# Check for multiple smaller test files (e.g., test_main_controller_*.gd)
				var has_multiple_test_files = _check_for_multiple_test_files(snake_case_name, test_files_cache)
				if has_multiple_test_files:
					files_with_tests.append(full_path)
		file_name = dir.get_next()



func _should_skip_file_for_test_check(file_name: String) -> bool:
	# Files that don't need direct tests because they use mocks
	var skip_files = [
		"TowerManagerInterface.gd",  # Uses mocks for DI testing
		"GridManagerInterface.gd",   # Interface - tested through implementations and mocks
		"MineManagerInterface.gd",   # Interface - tested through implementations and mocks
		"WaveManagerInterface.gd",   # Interface - tested through implementations and mocks
		"ProgramDataPacketManagerInterface.gd", # Interface - tested through implementations
		"RivalHackerManagerInterface.gd", # Interface - tested through implementations
		"CurrencyManagerInterface.gd", # Interface - tested through implementations
		"GameManagerInterface.gd",   # Interface - tested through implementations
		"Clickable.gd",              # Interface - tested through implementations
		"Mine.gd",                   # Interface - tested through implementations
		"TargetingUtil.gd"           # Interface - tested through implementations
	]
	return file_name in skip_files

func _should_skip_file_for_coverage_display(file_name: String) -> bool:
	# Files that should not be shown in coverage reports because they have special testing approaches
	var skip_display_files = [
		"TowerManagerInterface.gd",  # Uses mocks - no coverage expected
		"GridManagerInterface.gd",   # Interface - no coverage expected
		"MineManagerInterface.gd",   # Interface - no coverage expected
		"WaveManagerInterface.gd",   # Interface - no coverage expected
		"ProgramDataPacketManagerInterface.gd", # Interface - no coverage expected
		"RivalHackerManagerInterface.gd", # Interface - no coverage expected
		"CurrencyManagerInterface.gd", # Interface - no coverage expected
		"GameManagerInterface.gd",   # Interface - no coverage expected
		"Clickable.gd",              # Interface - no coverage expected
		"Mine.gd",                   # Interface - no coverage expected
		"TargetingUtil.gd"           # Interface - no coverage expected
	]
	return file_name in skip_display_files

func _should_skip_file_for_test_requirement(file_name: String) -> bool:
	# Files that don't need tests at all (interfaces, special cases, etc.)
	var skip_requirement_files = [
		"TowerManagerInterface.gd",  # Interface - uses mocks for testing
		"GridManagerInterface.gd",   # Interface - tested through implementations and mocks
		"MineManagerInterface.gd",   # Interface - tested through implementations and mocks
		"Clickable.gd",              # Interface - tested through implementations
		"CurrencyManagerInterface.gd", # Interface - tested through implementations
		"GameManagerInterface.gd",   # Interface - tested through implementations
		"ProgramDataPacketManagerInterface.gd", # Interface - tested through implementations
		"RivalHackerManagerInterface.gd", # Interface - tested through implementations
		"WaveManagerInterface.gd",   # Interface - tested through implementations and mocks
		"Mine.gd",                   # Interface - tested through implementations
		"TargetingUtil.gd"           # Interface - tested through implementations
	]
	return file_name in skip_requirement_files

func _check_for_multiple_test_files(base_name: String, test_files_cache: Array) -> bool:
	# Check if there are multiple test files for this base name
	# e.g., for "main_controller", check for "test_main_controller_*.gd"
	var prefix = "test_" + base_name + "_"
	var count = 0
	
	for test_file in test_files_cache:
		if test_file.begins_with(prefix):
			count += 1
			if count >= 2:  # Need at least 2 test files to count as "multiple"
				return true
	
	return false

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

func _get_files_that_need_tests() -> Array:
	# Get all script files that actually need tests (excluding interfaces and special cases)
	var all_script_files = []
	_find_all_script_files("res://scripts", all_script_files)
	
	var files_that_need_tests = []
	for file_path in all_script_files:
		var file_name = file_path.get_file()
		if not _should_skip_file_for_test_requirement(file_name):
			files_that_need_tests.append(file_path)
	
	return files_that_need_tests

func _get_files_that_need_tests_and_have_tests(files_with_tests: Array) -> Array:
	# Get files that need tests AND have tests
	var files_that_need_tests = _get_files_that_need_tests()
	var result = []
	
	for file_path in files_that_need_tests:
		if file_path in files_with_tests:
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
