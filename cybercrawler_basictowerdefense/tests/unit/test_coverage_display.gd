extends GutTest

const Coverage = preload("res://addons/coverage/coverage.gd")

func test_display_coverage_results():
	# This test will run last and display coverage results
	var coverage = Coverage.instance
	if !coverage:
		# Assert that we have coverage - this will fail if no coverage
		assert_not_null(coverage, "Coverage instance should exist")
		return
	
	# Get coverage statistics
	var total_coverage: float = coverage.coverage_percent()
	var coverage_count: int = coverage.coverage_count()
	var total_lines: int = coverage.coverage_line_count()
	
	# Make coverage visible in GUT GUI by including it in the test name/description
	var coverage_message = "📊 COVERAGE: %.1f%% (%d/%d lines)" % [total_coverage, coverage_count, total_lines]
	
	# Use GUT's logging system to display in test panel
	var logger = gut.get_logger()
	logger.info("🔥 COVERAGE RESULTS 🔥")
	logger.info("Lines Covered: %d" % coverage_count)
	logger.info("Total Lines: %d" % total_lines)
	logger.info("Coverage: %.1f%%" % total_coverage)
	
	# Show minimal detailed results to avoid overflow
	Coverage.finalize(Coverage.Verbosity.FILENAMES)
	
	# Assert that we have some coverage data
	assert_true(coverage_count > 0, "Should have some covered lines")
	assert_true(total_lines > 0, "Should have some total lines")
	
	# Log final summary with coverage prominently displayed
	logger.info("✅ Coverage analysis complete! %s" % coverage_message)
	
	# This will make the coverage percentage visible in the test results
	assert_true(true, "Coverage: %.1f%% (%d/%d lines)" % [total_coverage, coverage_count, total_lines]) 
