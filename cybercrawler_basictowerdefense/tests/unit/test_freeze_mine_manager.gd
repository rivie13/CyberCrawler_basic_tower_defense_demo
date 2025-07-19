extends GutTest

# Unit tests for FreezeMineManager class
# These tests verify the freeze mine management functionality

var freeze_mine_manager: FreezeMineManager
var mock_grid_manager: MockGridManager
var mock_currency_manager: MockCurrencyManager

func before_each():
	# Setup fresh FreezeMineManager for each test
	freeze_mine_manager = FreezeMineManager.new()
	mock_grid_manager = MockGridManager.new()
	mock_currency_manager = MockCurrencyManager.new()
	
	add_child_autofree(freeze_mine_manager)
	add_child_autofree(mock_grid_manager)
	add_child_autofree(mock_currency_manager)

func test_initial_state():
	# Test that FreezeMineManager starts with correct initial values
	assert_null(freeze_mine_manager.grid_manager, "Should start with no grid manager")
	assert_null(freeze_mine_manager.currency_manager, "Should start with no currency manager")
	assert_eq(freeze_mine_manager.freeze_mines.size(), 0, "Should start with no freeze mines")

func test_initialize():
	# Test that initialize sets manager references
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	
	assert_eq(freeze_mine_manager.grid_manager, mock_grid_manager, "Should set grid manager")
	assert_eq(freeze_mine_manager.currency_manager, mock_currency_manager, "Should set currency manager")

func test_can_place_freeze_mine_at_valid_position():
	# Test placement validation with valid position
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	mock_grid_manager.is_valid_position = true
	mock_grid_manager.is_occupied = false
	mock_grid_manager.is_on_path = false
	
	var result = freeze_mine_manager.can_place_freeze_mine_at(Vector2i(2, 2))
	assert_true(result, "Should allow placement at valid position")

func test_can_place_freeze_mine_at_invalid_position():
	# Test placement validation with invalid position
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	mock_grid_manager.is_valid_position = false
	
	var result = freeze_mine_manager.can_place_freeze_mine_at(Vector2i(-1, -1))
	assert_false(result, "Should not allow placement at invalid position")

func test_can_place_freeze_mine_at_occupied_position():
	# Test placement validation with occupied position
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	mock_grid_manager.is_valid_position = true
	mock_grid_manager.is_occupied = true
	
	var result = freeze_mine_manager.can_place_freeze_mine_at(Vector2i(2, 2))
	assert_false(result, "Should not allow placement at occupied position")

func test_can_place_freeze_mine_at_enemy_path():
	# Test placement validation on enemy path
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	mock_grid_manager.is_valid_position = true
	mock_grid_manager.is_occupied = false
	mock_grid_manager.is_on_path = true
	
	var result = freeze_mine_manager.can_place_freeze_mine_at(Vector2i(2, 2))
	assert_false(result, "Should not allow placement on enemy path")

func test_place_freeze_mine_insufficient_currency():
	# Test placement with insufficient currency
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	mock_currency_manager.current_currency = 10  # Less than 15 cost
	watch_signals(freeze_mine_manager)
	
	var result = freeze_mine_manager.place_freeze_mine(Vector2i(2, 2))
	
	assert_false(result, "Should fail with insufficient currency")
	assert_signal_emitted(freeze_mine_manager, "freeze_mine_placement_failed", "Should emit failure signal")

func test_place_freeze_mine_invalid_position():
	# Test placement at invalid position
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	mock_grid_manager.is_valid_position = false
	watch_signals(freeze_mine_manager)
	
	var result = freeze_mine_manager.place_freeze_mine(Vector2i(-1, -1))
	
	assert_false(result, "Should fail at invalid position")
	assert_signal_emitted(freeze_mine_manager, "freeze_mine_placement_failed", "Should emit failure signal")

func test_place_freeze_mine_success():
	# Test successful placement
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	mock_currency_manager.current_currency = 20  # More than 15 cost
	mock_grid_manager.is_valid_position = true
	mock_grid_manager.is_occupied = false
	mock_grid_manager.is_on_path = false
	mock_grid_manager.world_position = Vector2(100, 100)
	watch_signals(freeze_mine_manager)
	
	# Set up a current scene for the test
	var test_scene = Node2D.new()
	get_tree().current_scene = test_scene
	add_child_autofree(test_scene)
	
	var result = freeze_mine_manager.place_freeze_mine(Vector2i(2, 2))
	
	assert_true(result, "Should succeed with valid placement")
	assert_eq(freeze_mine_manager.freeze_mines.size(), 1, "Should track the placed mine")
	assert_eq(mock_currency_manager.spent_amount, 15, "Should spend 15 currency")
	assert_signal_emitted(freeze_mine_manager, "freeze_mine_placed", "Should emit success signal")

func test_create_freeze_mine_at_position():
	# Test freeze mine creation
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	mock_grid_manager.world_position = Vector2(150, 200)
	
	# Set up a current scene for the test
	var test_scene = Node2D.new()
	get_tree().current_scene = test_scene
	add_child_autofree(test_scene)
	
	var freeze_mine = freeze_mine_manager.create_freeze_mine_at_position(Vector2i(3, 4))
	
	assert_not_null(freeze_mine, "Should create freeze mine")
	assert_eq(freeze_mine.global_position, Vector2(150, 200), "Should set correct world position")
	assert_eq(freeze_mine.grid_position, Vector2i(3, 4), "Should set correct grid position")
	assert_true(freeze_mine is FreezeMine, "Should be FreezeMine instance")

func test_on_freeze_mine_triggered():
	# Test freeze mine triggered signal handling
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	watch_signals(freeze_mine_manager)
	
	var mock_mine = FreezeMine.new()
	add_child_autofree(mock_mine)
	
	freeze_mine_manager._on_freeze_mine_triggered(mock_mine)
	
	assert_signal_emitted(freeze_mine_manager, "freeze_mine_triggered", "Should emit triggered signal")

func test_on_freeze_mine_depleted():
	# Test freeze mine depleted signal handling
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	watch_signals(freeze_mine_manager)
	
	var mock_mine = FreezeMine.new()
	mock_mine.grid_position = Vector2i(2, 2)
	add_child_autofree(mock_mine)
	
	# Add to tracking
	freeze_mine_manager.freeze_mines.append(mock_mine)
	
	freeze_mine_manager._on_freeze_mine_depleted(mock_mine)
	
	assert_eq(freeze_mine_manager.freeze_mines.size(), 0, "Should remove from tracking")
	assert_eq(mock_grid_manager.unblocked_positions.size(), 1, "Should unblock grid position")
	assert_signal_emitted(freeze_mine_manager, "freeze_mine_depleted", "Should emit depleted signal")

func test_get_freeze_mines():
	# Test getting freeze mines array
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	
	var mock_mine1 = FreezeMine.new()
	var mock_mine2 = FreezeMine.new()
	add_child_autofree(mock_mine1)
	add_child_autofree(mock_mine2)
	
	freeze_mine_manager.freeze_mines.append(mock_mine1)
	freeze_mine_manager.freeze_mines.append(mock_mine2)
	
	var mines = freeze_mine_manager.get_freeze_mines()
	assert_eq(mines.size(), 2, "Should return all freeze mines")
	assert_eq(mines[0], mock_mine1, "Should include first mine")
	assert_eq(mines[1], mock_mine2, "Should include second mine")

func test_get_freeze_mine_count():
	# Test getting freeze mine count
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	
	assert_eq(freeze_mine_manager.get_freeze_mine_count(), 0, "Should return 0 for empty array")
	
	var mock_mine = FreezeMine.new()
	add_child_autofree(mock_mine)
	freeze_mine_manager.freeze_mines.append(mock_mine)
	
	assert_eq(freeze_mine_manager.get_freeze_mine_count(), 1, "Should return 1 for single mine")

func test_clear_all_freeze_mines():
	# Test clearing all freeze mines
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	
	var mock_mine1 = FreezeMine.new()
	var mock_mine2 = FreezeMine.new()
	mock_mine1.grid_position = Vector2i(1, 1)
	mock_mine2.grid_position = Vector2i(2, 2)
	add_child_autofree(mock_mine1)
	add_child_autofree(mock_mine2)
	
	freeze_mine_manager.freeze_mines.append(mock_mine1)
	freeze_mine_manager.freeze_mines.append(mock_mine2)
	
	freeze_mine_manager.clear_all_freeze_mines()
	
	assert_eq(freeze_mine_manager.freeze_mines.size(), 0, "Should clear all mines")
	assert_eq(mock_grid_manager.unblocked_positions.size(), 2, "Should unblock all grid positions")

func test_get_freeze_mine_cost():
	# Test getting freeze mine cost
	var cost = freeze_mine_manager.get_freeze_mine_cost()
	assert_eq(cost, 15, "Should return correct cost")

func test_signal_connections():
	# Test that signals are properly connected when placing mines
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	mock_currency_manager.current_currency = 20
	mock_grid_manager.is_valid_position = true
	mock_grid_manager.is_occupied = false
	mock_grid_manager.is_on_path = false
	mock_grid_manager.world_position = Vector2(100, 100)
	
	# Set up a current scene for the test
	var test_scene = Node2D.new()
	get_tree().current_scene = test_scene
	add_child_autofree(test_scene)
	
	var result = freeze_mine_manager.place_freeze_mine(Vector2i(2, 2))
	
	assert_true(result, "Should place mine successfully")
	assert_eq(freeze_mine_manager.freeze_mines.size(), 1, "Should have one mine")
	
	# Test that signals are connected
	var placed_mine = freeze_mine_manager.freeze_mines[0]
	assert_true(placed_mine.mine_triggered.is_connected(freeze_mine_manager._on_freeze_mine_triggered), "Should connect triggered signal")
	assert_true(placed_mine.mine_depleted.is_connected(freeze_mine_manager._on_freeze_mine_depleted), "Should connect depleted signal")

func test_grid_occupation_management():
	# Test that grid positions are properly managed
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	mock_currency_manager.current_currency = 20
	mock_grid_manager.is_valid_position = true
	mock_grid_manager.is_occupied = false
	mock_grid_manager.is_on_path = false
	mock_grid_manager.world_position = Vector2(100, 100)
	
	# Set up a current scene for the test
	var test_scene = Node2D.new()
	get_tree().current_scene = test_scene
	add_child_autofree(test_scene)
	
	var result = freeze_mine_manager.place_freeze_mine(Vector2i(3, 4))
	
	assert_true(result, "Should place mine successfully")
	assert_eq(mock_grid_manager.occupied_positions.size(), 1, "Should mark position as occupied")
	assert_eq(mock_grid_manager.occupied_positions[0], Vector2i(3, 4), "Should occupy correct position")

# Mock classes for testing
class MockGridManager extends GridManager:
	var is_valid_position: bool = true
	var is_occupied: bool = false
	var is_on_path: bool = false
	var world_position: Vector2 = Vector2.ZERO
	var occupied_positions: Array[Vector2i] = []
	var unblocked_positions: Array[Vector2i] = []
	
	func is_valid_grid_position(pos: Vector2i) -> bool:
		return is_valid_position
	
	func is_grid_occupied(pos: Vector2i) -> bool:
		return is_occupied
	
	func is_on_enemy_path(pos: Vector2i) -> bool:
		return is_on_path
	
	func grid_to_world(pos: Vector2i) -> Vector2:
		return world_position
	
	func set_grid_occupied(pos: Vector2i, occupied: bool):
		if occupied:
			occupied_positions.append(pos)
		else:
			occupied_positions.erase(pos)
	
	func set_grid_blocked(pos: Vector2i, blocked: bool):
		if not blocked:
			unblocked_positions.append(pos)

class MockCurrencyManager extends CurrencyManager:
	var current_currency: int = 100
	var spent_amount: int = 0
	
	func get_currency() -> int:
		return current_currency
	
	func spend_currency(amount: int) -> bool:
		if current_currency >= amount:
			current_currency -= amount
			spent_amount = amount
			return true
		return false 