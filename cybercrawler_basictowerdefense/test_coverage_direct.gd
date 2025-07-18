extends SceneTree

const Coverage = preload("res://addons/coverage/coverage.gd")

func _init():
	print("🔥 Testing Code Coverage Directly 🔥")
	
	# Initialize coverage
	var exclude_paths = [
		"res://addons/*",
		"res://tests/*",
		"res://scenes/*",
		"res://tools/*"
	]
	
	print("=== Initializing Coverage ===")
	Coverage.new(self, exclude_paths)
	
	# Instrument scripts
	print("=== Instrumenting Scripts ===")
	Coverage.instance.instrument_scripts("res://scripts/")
	
	# Run a simple test
	print("=== Running Test ===")
	test_coverage_function()
	
	# Finalize coverage
	print("=== Finalizing Coverage ===")
	var coverage = Coverage.instance
	var total_coverage = coverage.coverage_percent()
	var coverage_count = coverage.coverage_count()
	var total_lines = coverage.coverage_line_count()
	
	print("\n--- Coverage Results ---")
	print("Lines Covered: ", coverage_count)
	print("Total Lines: ", total_lines)
	print("Coverage: %.1f%%" % total_coverage)
	
	# Show detailed results
	Coverage.finalize(Coverage.Verbosity.FAILING_FILES)
	
	print("=== Coverage Test Complete ===")
	quit()

func test_coverage_function():
	var result = 2 + 2
	print("Test result: ", result)
	assert(result == 4, "Basic math should work") 