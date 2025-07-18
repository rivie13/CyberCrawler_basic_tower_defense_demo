extends SceneTree

const Coverage = preload("res://addons/coverage/coverage.gd")

func _init():
	print("🔥 SHOWING CURRENT COVERAGE RESULTS 🔥")
	
	var coverage = Coverage.instance
	if !coverage:
		print("❌ No coverage instance found!")
		print("Run the tests first to generate coverage data.")
		quit()
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
	quit() 