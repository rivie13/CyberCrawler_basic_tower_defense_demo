extends GutTest

# Simple test to verify coverage is working
func test_coverage_basic():
	# This test should be covered by coverage
	var result = 2 + 2
	assert_eq(result, 4, "Basic math should work")
	
	# Test a simple function call
	var test_string = "Hello Coverage!"
	assert_eq(test_string.length(), 15, "String length should be correct")

func test_coverage_conditional():
	# Test conditional logic for coverage
	var value = 10
	
	if value > 5:
		assert_true(true, "Value should be greater than 5")
	else:
		assert_true(false, "This should not execute")
	
	# Test another condition
	if value < 20:
		assert_true(true, "Value should be less than 20")
	else:
		assert_true(false, "This should not execute")

func test_coverage_loop():
	# Test loop coverage
	var sum = 0
	for i in range(5):
		sum += i
	
	assert_eq(sum, 10, "Sum should be 0+1+2+3+4 = 10") 