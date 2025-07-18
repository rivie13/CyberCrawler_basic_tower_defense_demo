extends GutTest

const Coverage = preload("res://addons/coverage/coverage.gd")

func test_display_coverage_results():
	# This test will run last and display coverage results
	print("\n🔥 DISPLAYING COVERAGE RESULTS 🔥")
	
	var coverage = Coverage.instance
	if !coverage:
		print("❌ No coverage instance found!")
		# Assert that we have coverage - this will fail if no coverage
		assert_not_null(coverage, "Coverage instance should exist")
		return
	
	# Get coverage statistics
	var total_coverage: float = coverage.coverage_percent()
	var coverage_count: int = coverage.coverage_count()
	var total_lines: int = coverage.coverage_line_count()
	
	print("\n--- Coverage Summary ---")
	print("Lines Covered: ", coverage_count)
	print("Total Lines: ", total_lines)
	print("Coverage: %.1f%%" % total_coverage)
	
	# Show detailed results
	print("\n--- Detailed Coverage Results ---")
	Coverage.finalize(Coverage.Verbosity.FAILING_FILES)
	
	print("\n=== Coverage Analysis Complete ===")
	
	# Assert that we have some coverage data
	assert_true(coverage_count > 0, "Should have some covered lines")
	assert_true(total_lines > 0, "Should have some total lines") 