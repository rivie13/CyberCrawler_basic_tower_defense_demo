extends GutTest

# Unit tests for MineManagerInterface class
# These tests verify the mine manager interface functionality

var test_interface: MineManagerInterface

# Mock mine manager class for testing abstract methods
class MockMineManager extends MineManagerInterface:
	var mock_mines: Array[Mine] = []
	var mock_grid_manager: GridManager
	var mock_currency_manager: CurrencyManagerInterface
	var mock_can_place_result: bool = true
	var mock_place_result: bool = true
	var mock_mine_cost: int = 10
	
	func initialize(grid_mgr: GridManager, currency_mgr: CurrencyManagerInterface):
		mock_grid_manager = grid_mgr
		mock_currency_manager = currency_mgr
	
	func can_place_mine_at(grid_pos: Vector2i, mine_type: String = "freeze") -> bool:
		return mock_can_place_result
	
	func place_mine(grid_pos: Vector2i, mine_type: String = "freeze") -> bool:
		if mock_place_result:
			var mock_mine = MockMine.new()
			mock_mine.grid_position = grid_pos
			mock_mines.append(mock_mine)
			mine_placed.emit(mock_mine)
		else:
			mine_placement_failed.emit("Mock placement failed")
		return mock_place_result
	
	func create_mine_at_position(grid_pos: Vector2i, mine_type: String = "freeze") -> Mine:
		var mock_mine = MockMine.new()
		mock_mine.grid_position = grid_pos
		return mock_mine
	
	func get_mines() -> Array[Mine]:
		return mock_mines
	
	func get_mine_count() -> int:
		return mock_mines.size()
	
	func clear_all_mines():
		mock_mines.clear()
	
	func get_mine_cost(mine_type: String = "freeze") -> int:
		return mock_mine_cost

# Mock mine class for testing
class MockMine extends Mine:
	func trigger_mine():
		is_triggered = true
	
	func get_mine_type() -> String:
		return "mock"
	
	func get_mine_name() -> String:
		return "Mock Mine"

func before_each():
	# Setup fresh mock mine manager for each test
	test_interface = MockMineManager.new()
	add_child_autofree(test_interface)

func test_initial_state():
	# Test that MineManagerInterface starts with correct initial state
	assert_true(test_interface is MineManagerInterface, "Should be instance of MineManagerInterface")
	assert_true(test_interface is Node, "Should inherit from Node")

func test_initialize_abstract_method():
	# Test that initialize method is implemented and works
	var mock_grid = GridManager.new()
	var mock_currency = CurrencyManager.new()
	add_child_autofree(mock_grid)
	add_child_autofree(mock_currency)
	
	test_interface.initialize(mock_grid, mock_currency)
	
	# Verify the mock implementation stored the references
	assert_eq(test_interface.mock_grid_manager, mock_grid, "Should store grid manager reference")
	assert_eq(test_interface.mock_currency_manager, mock_currency, "Should store currency manager reference")

func test_can_place_mine_at_abstract_method():
	# Test that can_place_mine_at method is implemented and works
	var test_pos = Vector2i(5, 10)
	
	# Test successful placement
	test_interface.mock_can_place_result = true
	var result = test_interface.can_place_mine_at(test_pos, "freeze")
	assert_true(result, "Should return true when mock allows placement")
	
	# Test failed placement
	test_interface.mock_can_place_result = false
	result = test_interface.can_place_mine_at(test_pos, "freeze")
	assert_false(result, "Should return false when mock denies placement")

func test_place_mine_abstract_method():
	# Test that place_mine method is implemented and works
	var test_pos = Vector2i(3, 7)
	watch_signals(test_interface)
	
	# Test successful placement
	test_interface.mock_place_result = true
	var result = test_interface.place_mine(test_pos, "freeze")
	assert_true(result, "Should return true when placement succeeds")
	assert_eq(test_interface.get_mine_count(), 1, "Should have one mine after successful placement")
	assert_signal_emitted(test_interface, "mine_placed", "Should emit mine_placed signal")
	
	# Test failed placement
	test_interface.mock_place_result = false
	result = test_interface.place_mine(test_pos, "freeze")
	assert_false(result, "Should return false when placement fails")
	assert_signal_emitted(test_interface, "mine_placement_failed", "Should emit mine_placement_failed signal")

func test_create_mine_at_position_abstract_method():
	# Test that create_mine_at_position method is implemented and works
	var test_pos = Vector2i(2, 4)
	
	var mine = test_interface.create_mine_at_position(test_pos, "freeze")
	assert_not_null(mine, "Should create a mine instance")
	assert_true(mine is Mine, "Should return a Mine instance")
	assert_eq(mine.grid_position, test_pos, "Should set correct grid position")

func test_get_mines_abstract_method():
	# Test that get_mines method is implemented and works
	assert_eq(test_interface.get_mines().size(), 0, "Should return empty array initially")
	
	# Add a mine and test
	var mock_mine = MockMine.new()
	test_interface.mock_mines.append(mock_mine)
	add_child_autofree(mock_mine)
	
	var mines = test_interface.get_mines()
	assert_eq(mines.size(), 1, "Should return array with one mine")
	assert_eq(mines[0], mock_mine, "Should return the correct mine")

func test_get_mine_count_abstract_method():
	# Test that get_mine_count method is implemented and works
	assert_eq(test_interface.get_mine_count(), 0, "Should return 0 initially")
	
	# Add mines and test
	var mock_mine1 = MockMine.new()
	var mock_mine2 = MockMine.new()
	test_interface.mock_mines.append(mock_mine1)
	test_interface.mock_mines.append(mock_mine2)
	add_child_autofree(mock_mine1)
	add_child_autofree(mock_mine2)
	
	assert_eq(test_interface.get_mine_count(), 2, "Should return correct count")

func test_clear_all_mines_abstract_method():
	# Test that clear_all_mines method is implemented and works
	var mock_mine1 = MockMine.new()
	var mock_mine2 = MockMine.new()
	test_interface.mock_mines.append(mock_mine1)
	test_interface.mock_mines.append(mock_mine2)
	add_child_autofree(mock_mine1)
	add_child_autofree(mock_mine2)
	
	assert_eq(test_interface.get_mine_count(), 2, "Should have 2 mines before clearing")
	
	test_interface.clear_all_mines()
	assert_eq(test_interface.get_mine_count(), 0, "Should have 0 mines after clearing")

func test_get_mine_cost_abstract_method():
	# Test that get_mine_cost method is implemented and works
	test_interface.mock_mine_cost = 25
	
	var cost = test_interface.get_mine_cost("freeze")
	assert_eq(cost, 25, "Should return correct mine cost")
	
	# Test with different mine type
	cost = test_interface.get_mine_cost("explosive")
	assert_eq(cost, 25, "Should return same cost for different mine type (mock implementation)")

func test_signal_definitions():
	# Test that all required signals are defined
	assert_true(test_interface.has_signal("mine_placed"), "Should have mine_placed signal")
	assert_true(test_interface.has_signal("mine_placement_failed"), "Should have mine_placement_failed signal")
	assert_true(test_interface.has_signal("mine_triggered"), "Should have mine_triggered signal")
	assert_true(test_interface.has_signal("mine_depleted"), "Should have mine_depleted signal")

func test_signal_emission():
	# Test signal emission functionality
	watch_signals(test_interface)
	
	# Test mine_placed signal
	var mock_mine = MockMine.new()
	add_child_autofree(mock_mine)
	test_interface.mine_placed.emit(mock_mine)
	assert_signal_emitted(test_interface, "mine_placed", "Should emit mine_placed signal")
	
	# Test mine_placement_failed signal
	test_interface.mine_placement_failed.emit("Test failure reason")
	assert_signal_emitted(test_interface, "mine_placement_failed", "Should emit mine_placement_failed signal")
	
	# Test mine_triggered signal
	test_interface.mine_triggered.emit(mock_mine)
	assert_signal_emitted(test_interface, "mine_triggered", "Should emit mine_triggered signal")
	
	# Test mine_depleted signal
	test_interface.mine_depleted.emit(mock_mine)
	assert_signal_emitted(test_interface, "mine_depleted", "Should emit mine_depleted signal")

func test_interface_contract():
	# Test that the interface contract is properly defined
	assert_true(test_interface.has_method("initialize"), "Should implement initialize")
	assert_true(test_interface.has_method("can_place_mine_at"), "Should implement can_place_mine_at")
	assert_true(test_interface.has_method("place_mine"), "Should implement place_mine")
	assert_true(test_interface.has_method("create_mine_at_position"), "Should implement create_mine_at_position")
	assert_true(test_interface.has_method("get_mines"), "Should implement get_mines")
	assert_true(test_interface.has_method("get_mine_count"), "Should implement get_mine_count")
	assert_true(test_interface.has_method("clear_all_mines"), "Should implement clear_all_mines")
	assert_true(test_interface.has_method("get_mine_cost"), "Should implement get_mine_cost")

func test_abstract_method_error_handling():
	# Test that calling abstract methods on base interface throws errors
	var base_interface = MineManagerInterface.new()
	add_child_autofree(base_interface)
	
	# These should cause push_error calls, but we can't easily test that in GUT
	# Instead, we test that the methods exist and return expected default values
	assert_true(base_interface.has_method("initialize"), "Should have initialize method")
	assert_true(base_interface.has_method("can_place_mine_at"), "Should have can_place_mine_at method")
	assert_true(base_interface.has_method("place_mine"), "Should have place_mine method")
	assert_true(base_interface.has_method("create_mine_at_position"), "Should have create_mine_at_position method")
	assert_true(base_interface.has_method("get_mines"), "Should have get_mines method")
	assert_true(base_interface.has_method("get_mine_count"), "Should have get_mine_count method")
	assert_true(base_interface.has_method("clear_all_mines"), "Should have clear_all_mines method")
	assert_true(base_interface.has_method("get_mine_cost"), "Should have get_mine_cost method")
	
	# Test that abstract methods return expected default values
	assert_false(base_interface.can_place_mine_at(Vector2i.ZERO), "Abstract can_place_mine_at should return false")
	assert_false(base_interface.place_mine(Vector2i.ZERO), "Abstract place_mine should return false")
	assert_null(base_interface.create_mine_at_position(Vector2i.ZERO), "Abstract create_mine_at_position should return null")
	assert_eq(base_interface.get_mines().size(), 0, "Abstract get_mines should return empty array")
	assert_eq(base_interface.get_mine_count(), 0, "Abstract get_mine_count should return 0")
	assert_eq(base_interface.get_mine_cost(), 0, "Abstract get_mine_cost should return 0")

func test_integration_with_real_managers():
	# Test integration with actual manager classes
	var grid_manager = GridManager.new()
	var currency_manager = CurrencyManager.new()
	add_child_autofree(grid_manager)
	add_child_autofree(currency_manager)
	
	test_interface.initialize(grid_manager, currency_manager)
	
	# Test that the interface can work with real managers
	assert_not_null(test_interface.mock_grid_manager, "Should store grid manager")
	assert_not_null(test_interface.mock_currency_manager, "Should store currency manager")
	assert_true(test_interface.mock_grid_manager is GridManager, "Should store correct grid manager type")
	assert_true(test_interface.mock_currency_manager is CurrencyManager, "Should store correct currency manager type")
