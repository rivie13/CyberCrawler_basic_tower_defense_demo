extends GutTest

# Unit tests for TowerManager class
# These tests cover tower placement, validation, counting, and management functionality

var tower_manager: TowerManager
var mock_grid_manager: MockGridManager
var mock_currency_manager: MockCurrencyManager
var mock_wave_manager: MockWaveManager

func before_each():
	tower_manager = TowerManager.new()
	mock_grid_manager = MockGridManager.new()
	mock_currency_manager = MockCurrencyManager.new()
	mock_wave_manager = MockWaveManager.new()
	
	add_child_autofree(tower_manager)
	add_child_autofree(mock_grid_manager)
	add_child_autofree(mock_currency_manager)
	add_child_autofree(mock_wave_manager)

# ========================================
# INITIALIZATION TESTS
# ========================================

func test_initial_state():
	# Test initial state before initialization
	assert_eq(tower_manager.towers_placed.size(), 0, "Should start with no towers")
	assert_null(tower_manager.grid_manager, "Grid manager should be null initially")
	assert_null(tower_manager.currency_manager, "Currency manager should be null initially")
	assert_null(tower_manager.wave_manager, "Wave manager should be null initially")

func test_initialize():
	# Test proper initialization
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	assert_eq(tower_manager.grid_manager, mock_grid_manager, "Grid manager should be set")
	assert_eq(tower_manager.currency_manager, mock_currency_manager, "Currency manager should be set")
	assert_eq(tower_manager.wave_manager, mock_wave_manager, "Wave manager should be set")

# ========================================
# TOWER PLACEMENT VALIDATION TESTS
# ========================================

func test_attempt_tower_placement_without_managers():
	# Test tower placement when managers are not set
	var result = tower_manager.attempt_tower_placement(Vector2i(1, 1))
	
	assert_false(result, "Should fail when managers are not set")

func test_attempt_tower_placement_invalid_grid_position():
	# Test tower placement with invalid grid position
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_grid_manager.is_valid_position = false
	
	watch_signals(tower_manager)
	var result = tower_manager.attempt_tower_placement(Vector2i(1, 1))
	
	assert_false(result, "Should fail with invalid grid position")
	assert_signal_emitted_with_parameters(tower_manager, "tower_placement_failed", ["Invalid grid position"])

func test_attempt_tower_placement_occupied_position():
	# Test tower placement on occupied position
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_grid_manager.is_valid_position = true
	mock_grid_manager.is_occupied = true
	
	watch_signals(tower_manager)
	var result = tower_manager.attempt_tower_placement(Vector2i(1, 1))
	
	assert_false(result, "Should fail on occupied position")
	assert_signal_emitted_with_parameters(tower_manager, "tower_placement_failed", ["Grid position already occupied"])

func test_attempt_tower_placement_blocked_position():
	# Test tower placement on blocked position
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_grid_manager.is_valid_position = true
	mock_grid_manager.is_occupied = false
	# Set the position as blocked using the method
	mock_grid_manager.set_grid_blocked(Vector2i(1, 1), true)
	
	watch_signals(tower_manager)
	var result = tower_manager.attempt_tower_placement(Vector2i(1, 1))
	
	assert_false(result, "Should fail on blocked position")
	assert_signal_emitted_with_parameters(tower_manager, "tower_placement_failed", ["Grid position is blocked"])

func test_attempt_tower_placement_on_enemy_path():
	# Test tower placement on enemy path
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_grid_manager.is_valid_position = true
	mock_grid_manager.is_occupied = false
	# Ensure position is not blocked
	mock_grid_manager.set_grid_blocked(Vector2i(1, 1), false)
	mock_grid_manager.is_on_path = true
	
	watch_signals(tower_manager)
	var result = tower_manager.attempt_tower_placement(Vector2i(1, 1))
	
	assert_false(result, "Should fail on enemy path")
	assert_signal_emitted_with_parameters(tower_manager, "tower_placement_failed", ["Cannot place tower on enemy path"])

func test_attempt_tower_placement_insufficient_funds():
	# Test tower placement with insufficient funds
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_grid_manager.is_valid_position = true
	mock_grid_manager.is_occupied = false
	# Ensure position is not blocked
	mock_grid_manager.set_grid_blocked(Vector2i(1, 1), false)
	mock_grid_manager.is_on_path = false
	mock_currency_manager.set_currency(0)  # Set currency to 0 to make it insufficient
	
	watch_signals(tower_manager)
	var result = tower_manager.attempt_tower_placement(Vector2i(1, 1))
	
	assert_false(result, "Should fail with insufficient funds")
	assert_signal_emitted_with_parameters(tower_manager, "tower_placement_failed", ["Insufficient funds for basic tower"])

# ========================================
# SUCCESSFUL TOWER PLACEMENT TESTS
# ========================================

func test_attempt_tower_placement_success():
	# Test successful tower placement
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_grid_manager.is_valid_position = true
	mock_grid_manager.is_occupied = false
	# Ensure position is not blocked
	mock_grid_manager.set_grid_blocked(Vector2i(1, 1), false)
	mock_grid_manager.is_on_path = false
	mock_currency_manager.set_currency(1000)  # Set sufficient currency
	mock_grid_manager.world_position = Vector2(100, 200)
	
	watch_signals(tower_manager)
	var result = tower_manager.attempt_tower_placement(Vector2i(1, 1))
	
	assert_true(result, "Should succeed with valid parameters")
	assert_signal_emitted_with_parameters(tower_manager, "tower_placed", [Vector2i(1, 1), "basic"])

func test_attempt_basic_tower_placement_backwards_compatibility():
	# Test backwards compatibility method
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_grid_manager.is_valid_position = true
	mock_grid_manager.is_occupied = false
	# Ensure position is not blocked
	mock_grid_manager.set_grid_blocked(Vector2i(1, 1), false)
	mock_grid_manager.is_on_path = false
	mock_currency_manager.set_currency(1000)  # Set sufficient currency
	mock_grid_manager.world_position = Vector2(100, 200)
	
	var result = tower_manager.attempt_basic_tower_placement(Vector2i(1, 1))
	
	assert_true(result, "Backwards compatibility method should work")

func test_place_tower_success():
	# Test direct tower placement
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_currency_manager.set_currency(1000)  # Set sufficient currency
	mock_grid_manager.world_position = Vector2(100, 200)
	
	watch_signals(tower_manager)
	var result = tower_manager.place_tower(Vector2i(1, 1), "basic")
	
	assert_true(result, "Should place tower successfully")
	assert_signal_emitted_with_parameters(tower_manager, "tower_placed", [Vector2i(1, 1), "basic"])
	assert_eq(tower_manager.towers_placed.size(), 1, "Should have one tower placed")

func test_place_powerful_tower_success():
	# Test powerful tower placement
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_currency_manager.set_currency(1000)  # Set sufficient currency
	mock_grid_manager.world_position = Vector2(100, 200)
	
	watch_signals(tower_manager)
	var result = tower_manager.place_tower(Vector2i(1, 1), "powerful")
	
	assert_true(result, "Should place powerful tower successfully")
	assert_signal_emitted_with_parameters(tower_manager, "tower_placed", [Vector2i(1, 1), "powerful"])
	assert_eq(tower_manager.towers_placed.size(), 1, "Should have one tower placed")

func test_place_tower_unknown_type():
	# Test placement with unknown tower type
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_currency_manager.set_currency(1000)  # Set sufficient currency
	mock_grid_manager.world_position = Vector2(100, 200)
	
	var result = tower_manager.place_tower(Vector2i(1, 1), "unknown_type")
	
	assert_false(result, "Should fail with unknown tower type")
	assert_eq(tower_manager.towers_placed.size(), 0, "Should not have any towers placed")

# ========================================
# TOWER MANAGEMENT TESTS
# ========================================

func test_get_enemies_for_towers_with_wave_manager():
	# Test getting enemies when wave manager is available
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	# Use the helper method to add enemies
	mock_wave_manager.add_mock_enemy(Enemy.new())
	mock_wave_manager.add_mock_enemy(Enemy.new())
	
	var enemies = tower_manager.get_enemies_for_towers()
	
	assert_eq(enemies.size(), 2, "Should return enemies from wave manager")

func test_get_enemies_for_towers_without_wave_manager():
	# Test getting enemies when wave manager is not available
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, null)
	
	var enemies = tower_manager.get_enemies_for_towers()
	
	assert_eq(enemies.size(), 0, "Should return empty array when no wave manager")

func test_get_towers():
	# Test getting all placed towers
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_currency_manager.set_currency(1000)  # Set sufficient currency
	mock_grid_manager.world_position = Vector2(100, 200)
	
	tower_manager.place_tower(Vector2i(1, 1), "basic")
	tower_manager.place_tower(Vector2i(2, 2), "powerful")
	
	var towers = tower_manager.get_towers()
	
	assert_eq(towers.size(), 2, "Should return all placed towers")

func test_get_tower_count():
	# Test tower counting
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_currency_manager.set_currency(1000)  # Set sufficient currency
	mock_grid_manager.world_position = Vector2(100, 200)
	
	assert_eq(tower_manager.get_tower_count(), 0, "Should start with 0 towers")
	
	tower_manager.place_tower(Vector2i(1, 1), "basic")
	assert_eq(tower_manager.get_tower_count(), 1, "Should have 1 tower after placement")
	
	tower_manager.place_tower(Vector2i(2, 2), "powerful")
	assert_eq(tower_manager.get_tower_count(), 2, "Should have 2 towers after second placement")

func test_get_tower_count_by_type():
	# Test counting towers by type
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_currency_manager.set_currency(1000)  # Set sufficient currency
	mock_grid_manager.world_position = Vector2(100, 200)
	
	# Place some towers
	tower_manager.place_tower(Vector2i(1, 1), "basic")
	tower_manager.place_tower(Vector2i(2, 2), "basic")
	tower_manager.place_tower(Vector2i(3, 3), "powerful")
	
	assert_eq(tower_manager.get_tower_count_by_type("basic"), 2, "Should count 2 basic towers")
	assert_eq(tower_manager.get_tower_count_by_type("powerful"), 1, "Should count 1 powerful tower")
	assert_eq(tower_manager.get_tower_count_by_type("unknown"), 0, "Should count 0 unknown towers")

func test_remove_tower():
	# Test tower removal
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_currency_manager.set_currency(1000)  # Set sufficient currency
	mock_grid_manager.world_position = Vector2(100, 200)
	
	tower_manager.place_tower(Vector2i(1, 1), "basic")
	assert_eq(tower_manager.get_tower_count(), 1, "Should have 1 tower before removal")
	
	var tower = tower_manager.towers_placed[0]
	tower_manager.remove_tower(tower)
	
	assert_eq(tower_manager.get_tower_count(), 0, "Should have 0 towers after removal")

# ========================================
# TOWER CONTROL TESTS
# ========================================

func test_stop_all_towers():
	# Test stopping all towers
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_currency_manager.set_currency(1000)  # Set sufficient currency
	mock_grid_manager.world_position = Vector2(100, 200)
	
	tower_manager.place_tower(Vector2i(1, 1), "basic")
	tower_manager.place_tower(Vector2i(2, 2), "powerful")
	
	tower_manager.stop_all_towers()
	
	# Should execute without errors
	assert_true(true, "Should stop all towers without errors")

func test_cleanup_all_towers():
	# Test cleaning up all towers
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_currency_manager.set_currency(1000)  # Set sufficient currency
	mock_grid_manager.world_position = Vector2(100, 200)
	
	tower_manager.place_tower(Vector2i(1, 1), "basic")
	tower_manager.place_tower(Vector2i(2, 2), "powerful")
	
	assert_eq(tower_manager.get_tower_count(), 2, "Should have 2 towers before cleanup")
	
	tower_manager.cleanup_all_towers()
	
	assert_eq(tower_manager.get_tower_count(), 0, "Should have 0 towers after cleanup")

# ========================================
# POWER LEVEL CALCULATION TESTS
# ========================================

func test_get_total_power_level_empty():
	# Test power level calculation with no towers
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	var power_level = tower_manager.get_total_power_level()
	
	assert_eq(power_level, 0.0, "Should have 0 power level with no towers")

func test_get_total_power_level_with_towers():
	# Test power level calculation with towers
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_currency_manager.set_currency(1000)  # Set sufficient currency
	mock_grid_manager.world_position = Vector2(100, 200)
	
	tower_manager.place_tower(Vector2i(1, 1), "basic")
	tower_manager.place_tower(Vector2i(2, 2), "powerful")
	
	var power_level = tower_manager.get_total_power_level()
	
	assert_gte(power_level, 0.0, "Should have non-negative power level")
	assert_true(power_level > 0.0, "Should have positive power level with towers")

# ========================================
# EDGE CASE TESTS
# ========================================

func test_place_tower_purchase_failure():
	# Test tower placement when purchase fails
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_currency_manager.set_currency(0)  # Set currency to 0 to make purchase fail
	
	var result = tower_manager.place_tower(Vector2i(1, 1), "basic")
	
	assert_false(result, "Should fail when purchase fails")
	assert_eq(tower_manager.towers_placed.size(), 0, "Should not have any towers placed")

func test_place_tower_without_grid_container():
	# Test tower placement when grid container is not available
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_currency_manager.set_currency(1000)  # Set sufficient currency
	mock_grid_manager.world_position = Vector2(100, 200)
	mock_grid_manager.grid_container = null
	
	var result = tower_manager.place_tower(Vector2i(1, 1), "basic")
	
	assert_true(result, "Should still place tower even without grid container")
	assert_eq(tower_manager.get_tower_count(), 1, "Should have one tower placed")

func test_remove_nonexistent_tower():
	# Test removing a tower that doesn't exist
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	var fake_tower = Node.new()
	tower_manager.remove_tower(fake_tower)
	
	# Should not crash
	assert_true(true, "Should handle removing nonexistent tower gracefully")

func test_get_tower_count_by_type_with_invalid_towers():
	# Test counting with invalid towers in the array
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_currency_manager.set_currency(1000)  # Set sufficient currency
	mock_grid_manager.world_position = Vector2(100, 200)
	
	tower_manager.place_tower(Vector2i(1, 1), "basic")
	
	# Add an invalid tower to the array
	tower_manager.towers_placed.append(null)
	
	var count = tower_manager.get_tower_count_by_type("basic")
	
	assert_eq(count, 1, "Should only count valid towers")

# ========================================
# CONSTANT TESTS
# ========================================

func test_tower_scene_constants():
	# Test that tower scene constants are properly set
	assert_not_null(TowerManager.TOWER_SCENE, "TOWER_SCENE should be set")
	assert_not_null(TowerManager.POWERFUL_TOWER_SCENE, "POWERFUL_TOWER_SCENE should be set")

func test_tower_type_constants():
	# Test that tower type constants are inherited from interface
	assert_eq(TowerManager.BASIC_TOWER, "basic", "BASIC_TOWER should be 'basic'")
	assert_eq(TowerManager.POWERFUL_TOWER, "powerful", "POWERFUL_TOWER should be 'powerful'") 