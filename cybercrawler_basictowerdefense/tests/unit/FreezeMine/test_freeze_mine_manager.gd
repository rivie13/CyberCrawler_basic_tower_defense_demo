extends GutTest

# Unit tests for FreezeMineManager class
# These tests verify the freeze mine management functionality

var freeze_mine_manager: MineManagerInterface
var mock_grid_manager: MockGridManager
var mock_currency_manager: MockCurrencyManager

func before_each():
	# Setup fresh FreezeMineManager for each test (concrete implementation)
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
	assert_eq(freeze_mine_manager.mines.size(), 0, "Should start with no mines")

func test_initialize():
	# Test that initialize sets manager references
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	
	assert_eq(freeze_mine_manager.grid_manager, mock_grid_manager, "Should set grid manager")
	assert_eq(freeze_mine_manager.currency_manager, mock_currency_manager, "Should set currency manager")

func test_can_place_mine_at_valid_position():
	# Test placement validation with valid position
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	# MockGridManager defaults to valid positions, unoccupied, no path
	# No need to set anything - defaults are correct
	
	var result = freeze_mine_manager.can_place_mine_at(Vector2i(2, 2), "freeze")
	assert_true(result, "Should allow placement at valid position")

func test_can_place_mine_at_invalid_position():
	# Test placement validation with invalid position
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	# MockGridManager will return false for invalid positions like (-1, -1)
	
	var result = freeze_mine_manager.can_place_mine_at(Vector2i(-1, -1), "freeze")
	assert_false(result, "Should not allow placement at invalid position")

func test_can_place_mine_at_occupied_position():
	# Test placement validation with occupied position
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	mock_grid_manager.is_valid_position = true
	mock_grid_manager.is_occupied = true
	
	var result = freeze_mine_manager.can_place_mine_at(Vector2i(2, 2), "freeze")
	assert_false(result, "Should not allow placement at occupied position")

func test_can_place_mine_at_enemy_path():
	# Test placement validation on enemy path
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	mock_grid_manager.is_valid_position = true
	mock_grid_manager.is_occupied = false
	mock_grid_manager.is_on_path = true
	
	var result = freeze_mine_manager.can_place_mine_at(Vector2i(2, 2), "freeze")
	assert_false(result, "Should not allow placement on enemy path")

func test_place_mine_insufficient_currency():
	# Test placement with insufficient currency
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	mock_currency_manager.set_currency(10)  # Less than 15 cost
	watch_signals(freeze_mine_manager)
	
	var result = freeze_mine_manager.place_mine(Vector2i(2, 2), "freeze")
	
	assert_false(result, "Should fail with insufficient currency")
	assert_signal_emitted(freeze_mine_manager, "mine_placement_failed", "Should emit failure signal")

func test_place_mine_invalid_position():
	# Test placement at invalid position
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	mock_grid_manager.is_valid_position = false
	watch_signals(freeze_mine_manager)
	
	var result = freeze_mine_manager.place_mine(Vector2i(-1, -1), "freeze")
	
	assert_false(result, "Should fail at invalid position")
	assert_signal_emitted(freeze_mine_manager, "mine_placement_failed", "Should emit failure signal")

func test_place_mine_success():
	# Test successful freeze mine placement
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	mock_currency_manager.set_currency(20)
	mock_grid_manager.is_valid_position = true
	mock_grid_manager.is_occupied = false
	mock_grid_manager.is_on_path = false
	mock_grid_manager.world_position = Vector2(100, 100)
	
	# Watch signals for assertions
	watch_signals(freeze_mine_manager)
	
	var currency_before = mock_currency_manager.get_currency()
	var result = freeze_mine_manager.place_mine(Vector2i(2, 2), "freeze")
	var currency_after = mock_currency_manager.get_currency()
	
	assert_true(result, "Should succeed with valid placement")
	assert_eq(freeze_mine_manager.mines.size(), 1, "Should track the placed mine")
	assert_eq(currency_before - currency_after, 15, "Should spend 15 currency")
	assert_signal_emitted(freeze_mine_manager, "mine_placed", "Should emit success signal")

func test_create_mine_at_position():
	# Test freeze mine creation
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	mock_grid_manager.world_position = Vector2(150, 200)
	
	var freeze_mine = freeze_mine_manager.create_mine_at_position(Vector2i(3, 4), "freeze")
	
	assert_not_null(freeze_mine, "Should create freeze mine")
	assert_eq(freeze_mine.global_position, Vector2(150, 200), "Should set correct world position")
	assert_eq(freeze_mine.grid_position, Vector2i(3, 4), "Should set correct grid position")
	assert_true(freeze_mine is FreezeMine, "Should be FreezeMine instance")

func test_on_mine_triggered():
	# Test freeze mine triggered signal handling
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	watch_signals(freeze_mine_manager)
	
	var mock_mine = FreezeMine.new()
	add_child_autofree(mock_mine)
	
	freeze_mine_manager._on_mine_triggered(mock_mine)
	
	assert_signal_emitted(freeze_mine_manager, "mine_triggered", "Should emit triggered signal")

func test_on_mine_depleted():
	# Test freeze mine depleted signal handling
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	watch_signals(freeze_mine_manager)
	
	var mock_mine = FreezeMine.new()
	mock_mine.grid_position = Vector2i(2, 2)
	add_child_autofree(mock_mine)
	
	# Add to tracking
	freeze_mine_manager.mines.append(mock_mine)
	
	freeze_mine_manager._on_mine_depleted(mock_mine)
	
	assert_eq(freeze_mine_manager.mines.size(), 0, "Should remove from tracking")
	assert_eq(mock_grid_manager.unblocked_positions.size(), 1, "Should unblock grid position")
	assert_signal_emitted(freeze_mine_manager, "mine_depleted", "Should emit depleted signal")

func test_get_mines():
	# Test getting mines array
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	
	var mock_mine1 = FreezeMine.new()
	var mock_mine2 = FreezeMine.new()
	add_child_autofree(mock_mine1)
	add_child_autofree(mock_mine2)
	
	freeze_mine_manager.mines.append(mock_mine1)
	freeze_mine_manager.mines.append(mock_mine2)
	
	var mines = freeze_mine_manager.get_mines()
	assert_eq(mines.size(), 2, "Should return all mines")
	assert_eq(mines[0], mock_mine1, "Should include first mine")
	assert_eq(mines[1], mock_mine2, "Should include second mine")

func test_get_mine_count():
	# Test getting mine count
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	
	assert_eq(freeze_mine_manager.get_mine_count(), 0, "Should return 0 for empty array")
	
	var mock_mine = FreezeMine.new()
	add_child_autofree(mock_mine)
	freeze_mine_manager.mines.append(mock_mine)
	
	assert_eq(freeze_mine_manager.get_mine_count(), 1, "Should return 1 for single mine")

func test_clear_all_mines():
	# Test clearing all mines
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	
	var mock_mine1 = FreezeMine.new()
	var mock_mine2 = FreezeMine.new()
	mock_mine1.grid_position = Vector2i(1, 1)
	mock_mine2.grid_position = Vector2i(2, 2)
	add_child_autofree(mock_mine1)
	add_child_autofree(mock_mine2)
	
	freeze_mine_manager.mines.append(mock_mine1)
	freeze_mine_manager.mines.append(mock_mine2)
	
	freeze_mine_manager.clear_all_mines()
	
	assert_eq(freeze_mine_manager.mines.size(), 0, "Should clear all mines")
	assert_eq(mock_grid_manager.unblocked_positions.size(), 2, "Should unblock all grid positions")

func test_get_mine_cost():
	# Test getting freeze mine cost
	var cost = freeze_mine_manager.get_mine_cost("freeze")
	assert_eq(cost, 15, "Should return correct cost")

func test_signal_connections():
	# Test that signals are properly connected when placing mines
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	mock_currency_manager.set_currency(20)
	mock_grid_manager.is_valid_position = true
	mock_grid_manager.is_occupied = false
	mock_grid_manager.is_on_path = false
	mock_grid_manager.world_position = Vector2(100, 100)
	
	var result = freeze_mine_manager.place_mine(Vector2i(2, 2), "freeze")
	
	assert_true(result, "Should place mine successfully")
	assert_eq(freeze_mine_manager.mines.size(), 1, "Should have one mine")
	
	# Test that signals are connected
	var placed_mine = freeze_mine_manager.mines[0]
	assert_true(placed_mine.mine_triggered.is_connected(freeze_mine_manager._on_mine_triggered), "Should connect triggered signal")
	assert_true(placed_mine.mine_depleted.is_connected(freeze_mine_manager._on_mine_depleted), "Should connect depleted signal")

func test_grid_occupation_management():
	# Test that grid positions are properly managed
	freeze_mine_manager.initialize(mock_grid_manager, mock_currency_manager)
	mock_currency_manager.set_currency(20)
	mock_grid_manager.is_valid_position = true
	mock_grid_manager.is_occupied = false
	mock_grid_manager.is_on_path = false
	mock_grid_manager.world_position = Vector2(100, 100)
	
	var result = freeze_mine_manager.place_mine(Vector2i(3, 4), "freeze")
	
	assert_true(result, "Should place mine successfully")
	assert_eq(mock_grid_manager.occupied_positions.size(), 1, "Should mark position as occupied")
	assert_eq(mock_grid_manager.occupied_positions[0], Vector2i(3, 4), "Should occupy correct position")

# Mock classes for testing 
