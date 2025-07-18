extends GutTest

# Simple test to verify CI works with both coverage and test execution

func test_ci_basic_functionality():
	# This test should pass
	assert_true(true, "Basic test should pass")
	assert_eq(1 + 1, 2, "Math should work")

func test_ci_string_operations():
	# This test should also pass
	var test_string = "Hello"
	assert_eq(test_string.length(), 5, "String length should be correct")
	assert_true(test_string.begins_with("Hel"), "String should start with 'Hel'")

func test_ci_array_operations():
	# This test should pass
	var test_array = [1, 2, 3]
	assert_eq(test_array.size(), 3, "Array should have 3 elements")
	assert_true(test_array.has(2), "Array should contain 2")

# Uncomment this test to verify CI fails on test failures:
# func test_ci_intentional_failure():
# 	# This test would fail and cause CI to fail
# 	assert_true(false, "This test intentionally fails to verify CI catches test failures") 