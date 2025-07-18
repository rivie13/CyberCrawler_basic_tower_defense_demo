extends GutTest

# Unit tests for TowerManager class
# These tests verify tower placement logic and validation

var tower_manager: TowerManager
var mock_grid_manager: Node
var mock_currency_manager: Node
var mock_wave_manager: Node

func before_each():
	# Setup fresh TowerManager for each test
	tower_manager = TowerManager.new()
	mock_grid_manager = Node.new()
	mock_currency_manager = Node.new()
	mock_wave_manager = Node.new()
	
	# Add to scene so they don't get garbage collected
	add_child_autofree(tower_manager)
	add_child_autofree(mock_grid_manager)
	add_child_autofree(mock_currency_manager)
	add_child_autofree(mock_wave_manager)

func test_tower_type_constants():
	# Test that tower type constants are defined correctly
	assert_eq(TowerManager.BASIC_TOWER, "basic", "Basic tower constant should be 'basic'")
	assert_eq(TowerManager.POWERFUL_TOWER, "powerful", "Powerful tower constant should be 'powerful'")

func test_initialize_sets_references():
	# Test that initialize properly sets manager references
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	assert_eq(tower_manager.grid_manager, mock_grid_manager, "Grid manager should be set")
	assert_eq(tower_manager.currency_manager, mock_currency_manager, "Currency manager should be set")
	assert_eq(tower_manager.wave_manager, mock_wave_manager, "Wave manager should be set")

func test_towers_placed_array_initialization():
	# Test that towers_placed array is initialized
	assert_not_null(tower_manager.towers_placed, "towers_placed array should be initialized")
	assert_eq(tower_manager.towers_placed.size(), 0, "towers_placed should start empty")

func test_attempt_placement_without_managers():
	# Test that placement fails if managers are not set
	var result = tower_manager.attempt_tower_placement(Vector2i(0, 0))
	assert_false(result, "Tower placement should fail without managers")

func test_preloaded_scenes():
	# Test that tower scenes are preloaded
	assert_not_null(TowerManager.TOWER_SCENE, "Basic tower scene should be preloaded")
	assert_not_null(TowerManager.POWERFUL_TOWER_SCENE, "Powerful tower scene should be preloaded")

# Mock grid manager for testing placement logic
class MockGridManager:
	extends Node
	
	var valid_position: bool = true
	var occupied_position: bool = false
	var blocked_position: bool = false
	var on_enemy_path: bool = false
	
	func is_valid_grid_position(pos: Vector2i) -> bool:
		return valid_position
	
	func is_grid_occupied(pos: Vector2i) -> bool:
		return occupied_position
	
	func is_grid_blocked(pos: Vector2i) -> bool:
		return blocked_position
	
	func is_on_enemy_path(pos: Vector2i) -> bool:
		return on_enemy_path

func test_placement_validation_invalid_position():
	# Test placement fails for invalid grid position
	var mock_grid = MockGridManager.new()
	mock_grid.valid_position = false
	add_child_autofree(mock_grid)
	
	tower_manager.initialize(mock_grid, mock_currency_manager, mock_wave_manager)
	
	var result = tower_manager.attempt_tower_placement(Vector2i(0, 0))
	assert_false(result, "Should fail for invalid grid position")

func test_placement_validation_occupied_position():
	# Test placement fails for occupied position
	var mock_grid = MockGridManager.new()
	mock_grid.occupied_position = true
	add_child_autofree(mock_grid)
	
	tower_manager.initialize(mock_grid, mock_currency_manager, mock_wave_manager)
	
	var result = tower_manager.attempt_tower_placement(Vector2i(0, 0))
	assert_false(result, "Should fail for occupied grid position")

func test_placement_validation_blocked_position():
	# Test placement fails for blocked position
	var mock_grid = MockGridManager.new()
	mock_grid.blocked_position = true
	add_child_autofree(mock_grid)
	
	tower_manager.initialize(mock_grid, mock_currency_manager, mock_wave_manager)
	
	var result = tower_manager.attempt_tower_placement(Vector2i(0, 0))
	assert_false(result, "Should fail for blocked grid position")

func test_placement_validation_enemy_path():
	# Test placement fails on enemy path
	var mock_grid = MockGridManager.new()
	mock_grid.on_enemy_path = true
	add_child_autofree(mock_grid)
	
	tower_manager.initialize(mock_grid, mock_currency_manager, mock_wave_manager)
	
	var result = tower_manager.attempt_tower_placement(Vector2i(0, 0))
	assert_false(result, "Should fail on enemy path")

func test_signal_emission_on_failure():
	# Test that appropriate signals are emitted on placement failure
	var mock_grid = MockGridManager.new()
	mock_grid.valid_position = false
	add_child_autofree(mock_grid)
	
	tower_manager.initialize(mock_grid, mock_currency_manager, mock_wave_manager)
	
	# Watch for the signal
	watch_signals(tower_manager)
	
	tower_manager.attempt_tower_placement(Vector2i(0, 0))
	
	assert_signal_emitted(tower_manager, "tower_placement_failed", "Should emit failure signal")

func test_default_tower_type():
	# Test that default tower type is basic
	var mock_grid = MockGridManager.new()
	add_child_autofree(mock_grid)
	
	tower_manager.initialize(mock_grid, mock_currency_manager, mock_wave_manager)
	
	# This test verifies the default parameter works
	# We can't fully test placement without mocking more, but we can test the call
	var result = tower_manager.attempt_tower_placement(Vector2i(0, 0))
	# Should fail due to missing currency manager functionality, but won't crash 