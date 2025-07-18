extends GutTest

# Simple example test to verify GUT setup works correctly
# This should be your first test to run after installing GUT

func test_passes():
	# This test will pass - good for testing GUT installation
	assert_eq(1, 1, "One should equal one")
	assert_true(true, "True should be true")

func test_basic_math():
	# Test basic math operations
	assert_eq(2 + 2, 4, "2 + 2 should equal 4")
	assert_eq(10 - 5, 5, "10 - 5 should equal 5")
	assert_eq(3 * 4, 12, "3 * 4 should equal 12")

func test_string_operations():
	# Test string operations
	var greeting = "Hello"
	var target = "World"
	var result = greeting + " " + target
	assert_eq(result, "Hello World", "String concatenation should work")

func test_array_operations():
	# Test array operations
	var test_array = [1, 2, 3]
	assert_eq(test_array.size(), 3, "Array should have 3 elements")
	assert_eq(test_array[0], 1, "First element should be 1")
	assert_eq(test_array[2], 3, "Third element should be 3")

func test_godot_basics():
	# Test basic Godot node creation
	var node = Node.new()
	assert_not_null(node, "Node should be created successfully")
	assert_eq(node.get_class(), "Node", "Node should be of class Node")
	node.queue_free()

func test_vector_operations():
	# Test Godot Vector2i operations
	var vec1 = Vector2i(1, 2)
	var vec2 = Vector2i(3, 4)
	var result = vec1 + vec2
	assert_eq(result, Vector2i(4, 6), "Vector addition should work correctly")

# This test demonstrates the before_each and after_each functionality
var test_counter: int = 0

func before_each():
	# This runs before each test
	test_counter = 0

func after_each():
	# This runs after each test
	# Good place for cleanup
	pass

func test_before_each_works():
	# Test that before_each resets counter
	assert_eq(test_counter, 0, "Counter should start at 0")
	test_counter += 1
	assert_eq(test_counter, 1, "Counter should increment to 1")

func test_before_each_resets():
	# Test that counter is reset by before_each
	assert_eq(test_counter, 0, "Counter should be reset to 0 by before_each")
	test_counter += 5
	assert_eq(test_counter, 5, "Counter should increment to 5") 