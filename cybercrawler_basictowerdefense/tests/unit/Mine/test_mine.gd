extends GutTest

# Unit tests for Mine interface class
# These tests verify the base mine interface functionality

var test_mine: Mine

# Mock mine class for testing abstract methods
class MockMine extends Mine:
	func trigger_mine():
		# Mock implementation
		is_triggered = true
	
	func get_mine_type() -> String:
		return "mock"
	
	func get_mine_name() -> String:
		return "Mock Mine"

func before_each():
	# Setup fresh mock mine for each test
	test_mine = MockMine.new()
	add_child_autofree(test_mine)

func test_initial_state():
	# Test that Mine starts with correct initial values
	assert_eq(test_mine.grid_position, Vector2i.ZERO, "Should start with zero grid position")
	assert_eq(test_mine.cost, 0, "Should start with zero cost")
	assert_true(test_mine.is_active, "Should start as active")
	assert_false(test_mine.is_triggered, "Should start as not triggered")

func test_grid_position_setter():
	# Test setting grid position
	var test_pos = Vector2i(5, 10)
	test_mine.grid_position = test_pos
	assert_eq(test_mine.grid_position, test_pos, "Should set grid position correctly")

func test_cost_setter():
	# Test setting cost
	var test_cost = 25
	test_mine.cost = test_cost
	assert_eq(test_mine.cost, test_cost, "Should set cost correctly")

func test_is_active_setter():
	# Test setting active state
	test_mine.is_active = false
	assert_false(test_mine.is_active, "Should set active state to false")
	
	test_mine.is_active = true
	assert_true(test_mine.is_active, "Should set active state to true")

func test_is_triggered_setter():
	# Test setting triggered state
	test_mine.is_triggered = true
	assert_true(test_mine.is_triggered, "Should set triggered state to true")
	
	test_mine.is_triggered = false
	assert_false(test_mine.is_triggered, "Should set triggered state to false")

func test_trigger_mine_abstract_method():
	# Test that trigger_mine() is implemented and works
	assert_false(test_mine.is_triggered, "Should start as not triggered")
	test_mine.trigger_mine()
	assert_true(test_mine.is_triggered, "Should be triggered after calling trigger_mine()")

func test_get_mine_type_abstract_method():
	# Test that get_mine_type() is implemented and returns correct value
	var mine_type = test_mine.get_mine_type()
	assert_eq(mine_type, "mock", "Should return correct mine type")

func test_get_mine_name_abstract_method():
	# Test that get_mine_name() is implemented and returns correct value
	var mine_name = test_mine.get_mine_name()
	assert_eq(mine_name, "Mock Mine", "Should return correct mine name")

func test_inheritance_from_node2d():
	# Test that Mine properly extends Node2D
	assert_true(test_mine is Node2D, "Should inherit from Node2D")
	assert_true(test_mine is Mine, "Should be instance of Mine")

func test_property_initialization():
	# Test that all properties are properly initialized
	var new_mine = MockMine.new()
	add_child_autofree(new_mine)
	
	assert_eq(new_mine.grid_position, Vector2i.ZERO, "Grid position should be initialized to zero")
	assert_eq(new_mine.cost, 0, "Cost should be initialized to zero")
	assert_true(new_mine.is_active, "Is active should be initialized to true")
	assert_false(new_mine.is_triggered, "Is triggered should be initialized to false")

func test_abstract_method_error_handling():
	# Test that calling abstract methods on base Mine class throws errors
	var base_mine = Mine.new()
	add_child_autofree(base_mine)
	
	# These should cause push_error calls, but we can't easily test that in GUT
	# Instead, we test that the methods exist and return expected default values
	assert_true(base_mine.has_method("trigger_mine"), "Should have trigger_mine method")
	assert_true(base_mine.has_method("get_mine_type"), "Should have get_mine_type method")
	assert_true(base_mine.has_method("get_mine_name"), "Should have get_mine_name method")
	
	# Test that abstract methods return expected default values
	assert_eq(base_mine.get_mine_type(), "", "Abstract get_mine_type should return empty string")
	assert_eq(base_mine.get_mine_name(), "", "Abstract get_mine_name should return empty string")

func test_mine_state_transitions():
	# Test various state transitions
	assert_true(test_mine.is_active, "Should start active")
	assert_false(test_mine.is_triggered, "Should start not triggered")
	
	# Test triggering
	test_mine.trigger_mine()
	assert_true(test_mine.is_triggered, "Should be triggered after trigger_mine()")
	
	# Test deactivation
	test_mine.is_active = false
	assert_false(test_mine.is_active, "Should be inactive after setting is_active to false")

func test_mine_property_combinations():
	# Test various property combinations
	test_mine.grid_position = Vector2i(3, 7)
	test_mine.cost = 50
	test_mine.is_active = false
	test_mine.is_triggered = true
	
	assert_eq(test_mine.grid_position, Vector2i(3, 7), "Grid position should be set correctly")
	assert_eq(test_mine.cost, 50, "Cost should be set correctly")
	assert_false(test_mine.is_active, "Is active should be set correctly")
	assert_true(test_mine.is_triggered, "Is triggered should be set correctly")

func test_mine_interface_contract():
	# Test that the interface contract is properly defined
	assert_true(test_mine.has_method("trigger_mine"), "Should implement trigger_mine")
	assert_true(test_mine.has_method("get_mine_type"), "Should implement get_mine_type")
	assert_true(test_mine.has_method("get_mine_name"), "Should implement get_mine_name")
	
	# Test that required properties exist
	assert_true("grid_position" in test_mine, "Should have grid_position property")
	assert_true("cost" in test_mine, "Should have cost property")
	assert_true("is_active" in test_mine, "Should have is_active property")
	assert_true("is_triggered" in test_mine, "Should have is_triggered property")