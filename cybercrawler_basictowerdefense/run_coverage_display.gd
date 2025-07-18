extends SceneTree

const Coverage = preload("res://addons/coverage/coverage.gd")

func _init():
	print("🔥 RUNNING COVERAGE DISPLAY 🔥")
	
	# First run the tests to generate coverage data
	print("=== Running Tests to Generate Coverage ===")
	
	# Initialize coverage
	var exclude_paths = [
		"res://addons/*",
		"res://tests/*", 
		"res://scenes/*",
		"res://tools/*"
	]
	
	Coverage.new(self, exclude_paths)
	Coverage.instance.instrument_scripts("res://scripts/")
	
	# Run a simple test to generate some coverage
	test_simple_function()
	
	# Now display the coverage results
	print("\n=== COVERAGE RESULTS ===")
	
	var coverage = Coverage.instance
	if !coverage:
		print("❌ No coverage instance found!")
		quit()
		return
	
	var total_coverage: float = coverage.coverage_percent()
	var coverage_count: int = coverage.coverage_count()
	var total_lines: int = coverage.coverage_line_count()
	
	print("Lines Covered: ", coverage_count)
	print("Total Lines: ", total_lines)
	print("Coverage: %.1f%%" % total_coverage)
	
	# Show detailed results
	print("\n--- Detailed Coverage Results ---")
	Coverage.finalize(Coverage.Verbosity.FAILING_FILES)
	
	print("\n=== Coverage Analysis Complete ===")
	quit()

func test_simple_function():
	var result = 2 + 2
	print("Test result: ", result)
	assert(result == 4) 