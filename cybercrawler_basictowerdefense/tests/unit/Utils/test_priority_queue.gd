extends GutTest

# Unit tests for PriorityQueue class
# These tests verify the min-heap priority queue functionality

var priority_queue: PriorityQueue

func before_each():
	# Setup fresh PriorityQueue for each test
	priority_queue = PriorityQueue.new()

func test_initial_state():
	# Test that PriorityQueue starts with correct initial values
	assert_eq(priority_queue.size(), 0, "Should start with size 0")

func test_push_and_size():
	# Test pushing items and size tracking
	priority_queue.push("item1", 5)
	assert_eq(priority_queue.size(), 1, "Should have size 1 after first push")
	
	priority_queue.push("item2", 3)
	assert_eq(priority_queue.size(), 2, "Should have size 2 after second push")
	
	priority_queue.push("item3", 7)
	assert_eq(priority_queue.size(), 3, "Should have size 3 after third push")

func test_pop_empty_queue():
	# Test popping from empty queue
	var result = priority_queue.pop()
	assert_null(result, "Should return null when popping from empty queue")

func test_pop_single_item():
	# Test popping single item
	priority_queue.push("test_item", 5)
	var result = priority_queue.pop()
	assert_eq(result, "test_item", "Should return the pushed item")
	assert_eq(priority_queue.size(), 0, "Should have size 0 after popping")

func test_min_heap_property():
	# Test that items are popped in priority order (min-heap)
	priority_queue.push("high_priority", 1)
	priority_queue.push("medium_priority", 5)
	priority_queue.push("low_priority", 10)
	
	var first = priority_queue.pop()
	var second = priority_queue.pop()
	var third = priority_queue.pop()
	
	assert_eq(first, "high_priority", "Should pop highest priority first")
	assert_eq(second, "medium_priority", "Should pop medium priority second")
	assert_eq(third, "low_priority", "Should pop lowest priority last")

func test_same_priority_order():
	# Test items with same priority (min-heap doesn't guarantee insertion order)
	priority_queue.push("first", 5)
	priority_queue.push("second", 5)
	priority_queue.push("third", 5)
	
	var first = priority_queue.pop()
	var second = priority_queue.pop()
	var third = priority_queue.pop()
	
	# Min-heap doesn't guarantee insertion order for same priority
	# Just verify we get all three items with the same priority
	assert_true(first == "first" or first == "second" or first == "third", "Should pop one of the items with same priority")
	assert_true(second == "first" or second == "second" or second == "third", "Should pop one of the remaining items with same priority")
	assert_true(third == "first" or third == "second" or third == "third", "Should pop the last item with same priority")
	
	# Verify all items have the same priority (5)
	assert_eq(priority_queue.size(), 0, "Should have popped all items")

func test_mixed_priorities():
	# Test complex priority ordering
	priority_queue.push("a", 10)
	priority_queue.push("b", 5)
	priority_queue.push("c", 15)
	priority_queue.push("d", 1)
	priority_queue.push("e", 8)
	
	var results = []
	for i in range(5):
		results.append(priority_queue.pop())
	
	assert_eq(results[0], "d", "Should pop priority 1 first")
	assert_eq(results[1], "b", "Should pop priority 5 second")
	assert_eq(results[2], "e", "Should pop priority 8 third")
	assert_eq(results[3], "a", "Should pop priority 10 fourth")
	assert_eq(results[4], "c", "Should pop priority 15 last")

func test_push_after_pop():
	# Test pushing items after popping some
	priority_queue.push("item1", 5)
	priority_queue.push("item2", 3)
	
	var popped = priority_queue.pop()
	assert_eq(popped, "item2", "Should pop higher priority item")
	
	priority_queue.push("item3", 1)
	priority_queue.push("item4", 7)
	
	var next_popped = priority_queue.pop()
	assert_eq(next_popped, "item3", "Should pop new highest priority item")

func test_large_number_of_items():
	# Test with many items to ensure heap property is maintained
	for i in range(100):
		priority_queue.push("item" + str(i), 100 - i)
	
	var last_priority = -1
	for i in range(100):
		var item = priority_queue.pop()
		var priority = 100 - int(item.substr(4))  # Extract number from "itemX"
		assert_gte(priority, last_priority, "Items should be popped in ascending priority order")
		last_priority = priority

func test_negative_priorities():
	# Test with negative priority values
	priority_queue.push("negative", -5)
	priority_queue.push("zero", 0)
	priority_queue.push("positive", 5)
	
	var first = priority_queue.pop()
	var second = priority_queue.pop()
	var third = priority_queue.pop()
	
	assert_eq(first, "negative", "Should pop negative priority first")
	assert_eq(second, "zero", "Should pop zero priority second")
	assert_eq(third, "positive", "Should pop positive priority last")

func test_float_priorities():
	# Test with float priority values
	priority_queue.push("float1", 3.5)
	priority_queue.push("float2", 3.2)
	priority_queue.push("float3", 3.8)
	
	var first = priority_queue.pop()
	var second = priority_queue.pop()
	var third = priority_queue.pop()
	
	assert_eq(first, "float2", "Should pop lowest float priority first")
	assert_eq(second, "float1", "Should pop middle float priority second")
	assert_eq(third, "float3", "Should pop highest float priority last")

func test_complex_objects():
	# Test with complex objects as values
	var obj1 = {"name": "object1", "data": 123}
	var obj2 = {"name": "object2", "data": 456}
	var obj3 = {"name": "object3", "data": 789}
	
	priority_queue.push(obj1, 5)
	priority_queue.push(obj2, 3)
	priority_queue.push(obj3, 7)
	
	var first = priority_queue.pop()
	var second = priority_queue.pop()
	var third = priority_queue.pop()
	
	assert_eq(first["name"], "object2", "Should pop object2 first (priority 3)")
	assert_eq(second["name"], "object1", "Should pop object1 second (priority 5)")
	assert_eq(third["name"], "object3", "Should pop object3 last (priority 7)")

func test_heap_property_maintenance():
	# Test that heap property is maintained after multiple operations
	priority_queue.push("a", 10)
	priority_queue.push("b", 5)
	priority_queue.push("c", 15)
	
	# Pop one item
	var popped = priority_queue.pop()
	assert_eq(popped, "b", "Should pop highest priority")
	assert_eq(priority_queue.size(), 2, "Should have 2 items remaining")
	
	# Push more items
	priority_queue.push("d", 1)
	priority_queue.push("e", 20)
	
	# Pop all remaining items
	var results = []
	for i in range(4):
		results.append(priority_queue.pop())
	
	# Verify they come out in priority order
	assert_eq(results[0], "d", "Should pop priority 1 first")
	assert_eq(results[1], "a", "Should pop priority 10 second")
	assert_eq(results[2], "c", "Should pop priority 15 third")
	assert_eq(results[3], "e", "Should pop priority 20 last") 