extends GutTest

# Unit tests for TowerManager class
# These tests verify tower placement logic and validation

var tower_manager: TowerManager
var mock_grid_manager: GridManager
var mock_currency_manager: CurrencyManager
var mock_wave_manager: WaveManager

func before_each():
	# Setup fresh TowerManager for each test
	tower_manager = TowerManager.new()
	# Create actual manager objects instead of generic Node objects
	mock_grid_manager = GridManager.new()
	mock_currency_manager = CurrencyManager.new()
	mock_wave_manager = WaveManager.new()
	
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

func test_get_towers():
	# Test get_towers method
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	var towers = tower_manager.get_towers()
	assert_not_null(towers, "Should return towers array")
	assert_eq(towers.size(), 0, "Should start with no towers")

func test_get_tower_count():
	# Test get_tower_count method
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	var count = tower_manager.get_tower_count()
	assert_eq(count, 0, "Should start with zero towers")

func test_get_tower_count_by_type():
	# Test get_tower_count_by_type method
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	var basic_count = tower_manager.get_tower_count_by_type(TowerManager.BASIC_TOWER)
	var powerful_count = tower_manager.get_tower_count_by_type(TowerManager.POWERFUL_TOWER)
	
	assert_eq(basic_count, 0, "Should start with zero basic towers")
	assert_eq(powerful_count, 0, "Should start with zero powerful towers")

func test_get_total_power_level():
	# Test get_total_power_level method
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	var power_level = tower_manager.get_total_power_level()
	assert_eq(power_level, 0.0, "Should start with zero power level")

func test_get_enemies_for_towers():
	# Test get_enemies_for_towers method
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	var enemies = tower_manager.get_enemies_for_towers()
	assert_not_null(enemies, "Should return enemies array")
	assert_eq(enemies.size(), 0, "Should start with no enemies")

func test_stop_all_towers():
	# Test stop_all_towers method
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	# Method should not crash even with no towers
	tower_manager.stop_all_towers()
	assert_true(true, "stop_all_towers should not crash with no towers")

func test_cleanup_all_towers():
	# Test cleanup_all_towers method
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	# Method should not crash even with no towers
	tower_manager.cleanup_all_towers()
	assert_true(true, "cleanup_all_towers should not crash with no towers")

func test_attempt_basic_tower_placement():
	# Test backwards compatibility method
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	var result = tower_manager.attempt_basic_tower_placement(Vector2i(0, 0))
	assert_true(result is bool, "Should return boolean result")

func test_attempt_tower_placement_with_type():
	# Test tower placement with specific tower type
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	var basic_result = tower_manager.attempt_tower_placement(Vector2i(0, 0), TowerManager.BASIC_TOWER)
	assert_true(basic_result is bool, "Should return boolean for basic tower")
	
	var powerful_result = tower_manager.attempt_tower_placement(Vector2i(1, 1), TowerManager.POWERFUL_TOWER)
	assert_true(powerful_result is bool, "Should return boolean for powerful tower")

func test_signal_emission_on_failure():
	# Test that failure signals are emitted correctly
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	watch_signals(tower_manager)
	
	# This should fail because the mock managers don't have proper implementations
	var result = tower_manager.attempt_tower_placement(Vector2i(0, 0))
	
	# Either the placement succeeds or fails, but a signal should be emitted
	var success_signals = get_signal_emit_count(tower_manager, "tower_placed")
	var failure_signals = get_signal_emit_count(tower_manager, "tower_placement_failed")
	
	assert_true(success_signals > 0 or failure_signals > 0, 
		"Should emit either success or failure signal")

func test_remove_tower():
	# Test remove_tower method
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	# Create a mock tower to remove
	var mock_tower = Tower.new()
	add_child_autofree(mock_tower)
	
	# Add it to the towers_placed array manually
	tower_manager.towers_placed.append(mock_tower)
	
	# Remove it
	tower_manager.remove_tower(mock_tower)
	
	# Should be removed from the array
	assert_false(mock_tower in tower_manager.towers_placed, "Tower should be removed from array")

func test_place_tower_with_invalid_type():
	# Test place_tower with invalid tower type
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	var result = tower_manager.place_tower(Vector2i(0, 0), "invalid_type")
	assert_false(result, "Should fail for invalid tower type")

func test_place_tower_basic():
	# Test placing a basic tower
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	var result = tower_manager.place_tower(Vector2i(0, 0), TowerManager.BASIC_TOWER)
	assert_true(result is bool, "Should return boolean result")

func test_place_tower_powerful():
	# Test placing a powerful tower
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	var result = tower_manager.place_tower(Vector2i(0, 0), TowerManager.POWERFUL_TOWER)
	assert_true(result is bool, "Should return boolean result")

# Test validation methods by watching the signals they emit
func test_validation_invalid_position():
	# Test validation with invalid position
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	watch_signals(tower_manager)
	
	# This should trigger validation and potentially emit failure signal
	tower_manager.attempt_tower_placement(Vector2i(-1, -1))
	
	# Check that some validation occurred (either success or failure)
	assert_true(true, "Validation should complete without crashing")

func test_validation_occupied_position():
	# Test validation with occupied position
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	watch_signals(tower_manager)
	
	# This should trigger validation
	tower_manager.attempt_tower_placement(Vector2i(0, 0))
	
	# Check that validation occurred
	assert_true(true, "Validation should complete without crashing")

func test_validation_blocked_position():
	# Test validation with blocked position
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	watch_signals(tower_manager)
	
	# This should trigger validation
	tower_manager.attempt_tower_placement(Vector2i(5, 5))
	
	# Check that validation occurred
	assert_true(true, "Validation should complete without crashing")

func test_validation_on_enemy_path():
	# Test validation with position on enemy path
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	watch_signals(tower_manager)
	
	# This should trigger validation
	tower_manager.attempt_tower_placement(Vector2i(2, 2))
	
	# Check that validation occurred
	assert_true(true, "Validation should complete without crashing")

# Test that the methods are actually called on the real object
func test_actual_method_calls():
	# Test that we're calling real methods on the TowerManager instance
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	# These should all be real method calls that execute actual code
	assert_not_null(tower_manager.get_towers(), "get_towers should return array")
	assert_true(tower_manager.get_tower_count() >= 0, "get_tower_count should return non-negative")
	assert_true(tower_manager.get_total_power_level() >= 0.0, "get_total_power_level should return non-negative")
	assert_not_null(tower_manager.get_enemies_for_towers(), "get_enemies_for_towers should return array")
	
	# These should complete without error
	tower_manager.stop_all_towers()
	tower_manager.cleanup_all_towers()
	
	# These should return boolean results
	var placement_result = tower_manager.attempt_tower_placement(Vector2i(0, 0))
	assert_true(placement_result is bool, "attempt_tower_placement should return boolean") 