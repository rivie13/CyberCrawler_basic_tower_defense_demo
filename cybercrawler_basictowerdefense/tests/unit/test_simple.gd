extends GutTest

# Very simple test to verify GUT is working
# This should always pass

func test_basic_functionality():
	# Simple assertions that should always pass
	assert_true(true, "True should be true")
	assert_false(false, "False should be false")
	assert_eq(1, 1, "1 should equal 1")
	assert_ne(1, 2, "1 should not equal 2")

func test_godot_node_creation():
	# Test creating a basic Godot node
	var node = Node.new()
	assert_not_null(node, "Node should be created")
	assert_eq(node.get_class(), "Node", "Should be a Node")
	node.queue_free()

func test_vector_math():
	# Test basic vector operations
	var vec1 = Vector2i(1, 2)
	var vec2 = Vector2i(3, 4)
	var result = vec1 + vec2
	assert_eq(result, Vector2i(4, 6), "Vector addition should work")

func test_string_operations():
	# Test string operations
	var hello = "Hello"
	var world = "World"
	var result = hello + " " + world
	assert_eq(result, "Hello World", "String concatenation should work")

func test_array_operations():
	# Test array operations
	var arr = [1, 2, 3, 4, 5]
	assert_eq(arr.size(), 5, "Array should have 5 elements")
	assert_eq(arr[0], 1, "First element should be 1")
	assert_eq(arr[4], 5, "Last element should be 5") 