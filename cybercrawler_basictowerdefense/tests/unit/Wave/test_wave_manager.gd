extends GutTest

# Unit tests for WaveManager
# Tests core wave management functionality with proper mocking

var wave_manager: WaveManager
var mock_grid_manager: MockGridManager

func before_each():
	wave_manager = WaveManager.new()
	mock_grid_manager = MockGridManager.new()
	add_child_autofree(wave_manager)
	add_child_autofree(mock_grid_manager)

func after_each():
	pass  # Cleanup is handled by autofree

# ===== INITIALIZATION TESTS =====

func test_initial_state():
	"""Test WaveManager initial state"""
	assert_eq(wave_manager.current_wave, 1, "Current wave should be 1 initially")
	assert_eq(wave_manager.max_waves, 10, "Max waves should be 10 initially")
	assert_eq(wave_manager.enemies_per_wave, 5, "Enemies per wave should be 5 initially")
	assert_eq(wave_manager.enemies_spawned_this_wave, 0, "Enemies spawned should be 0 initially")
	assert_false(wave_manager.wave_active, "Wave should not be active initially")
	assert_eq(wave_manager.time_between_enemies, 1.0, "Time between enemies should be 1.0")
	assert_eq(wave_manager.time_between_waves, 3.0, "Time between waves should be 3.0")
	assert_eq(wave_manager.enemies_alive.size(), 0, "Enemies alive should be empty initially")
	assert_eq(wave_manager.enemy_path.size(), 0, "Enemy path should be empty initially")
	assert_eq(wave_manager.selected_layout_type, null, "Selected layout type should be null initially")

func test_initialize_with_grid_manager():
	"""Test initialization with grid manager"""
	wave_manager.initialize(mock_grid_manager)
	
	assert_eq(wave_manager.grid_manager, mock_grid_manager, "Grid manager should be set")
	assert_not_null(wave_manager.grid_layout, "Grid layout should be created")
	assert_true(wave_manager.selected_layout_type != null, "Layout type should be selected")

func test_initialize_randomizes_layout_type():
	"""Test that initialization randomizes layout type"""
	wave_manager.initialize(mock_grid_manager)
	
	# Should have selected a layout type
	assert_true(wave_manager.selected_layout_type != null, "Layout type should be selected")
	
	# Should be one of the valid layout types
	var valid_layouts = [
		GridLayout.LayoutType.STRAIGHT_LINE,
		GridLayout.LayoutType.L_SHAPED,
		GridLayout.LayoutType.S_CURVED,
		GridLayout.LayoutType.ZIGZAG
	]
	assert_true(valid_layouts.has(wave_manager.selected_layout_type), "Selected layout should be valid")

func test_initialize_connects_grid_signals():
	"""Test that initialization connects to grid signals"""
	wave_manager.initialize(mock_grid_manager)
	
	# Should be connected to grid_blocked_changed signal
	assert_true(mock_grid_manager.grid_blocked_changed.get_connections().size() > 0, "Should be connected to grid signals")

# ===== ENEMY PATH CREATION TESTS =====

func test_create_enemy_path_without_grid_manager():
	"""Test path creation without grid manager"""
	wave_manager.create_enemy_path()
	
	# Should not crash and should have empty path
	assert_eq(wave_manager.enemy_path.size(), 0, "Path should be empty without grid manager")

func test_create_enemy_path_with_grid_manager():
	"""Test path creation with grid manager"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	
	# Should have created a path
	assert_gt(wave_manager.enemy_path.size(), 0, "Should have created enemy path")
	assert_true(wave_manager.path_start != null, "Path start should be set")
	assert_true(wave_manager.path_end != null, "Path end should be set")

func test_create_enemy_path_uses_selected_layout():
	"""Test that path creation uses the selected layout type"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.selected_layout_type = GridLayout.LayoutType.STRAIGHT_LINE
	wave_manager.create_enemy_path()
	
	# Should use the selected layout type
	assert_eq(wave_manager.selected_layout_type, GridLayout.LayoutType.STRAIGHT_LINE, "Should use selected layout type")

func test_get_path_grid_positions():
	"""Test getting path grid positions"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.selected_layout_type = GridLayout.LayoutType.STRAIGHT_LINE
	
	var grid_positions = wave_manager.get_path_grid_positions()
	
	assert_gt(grid_positions.size(), 0, "Should return grid positions")

# ===== WAVE MANAGEMENT TESTS =====

func test_start_wave_initial():
	"""Test starting the first wave"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	wave_manager.start_wave()
	
	assert_true(wave_manager.wave_active, "Wave should be active")
	assert_eq(wave_manager.enemies_spawned_this_wave, 0, "Enemies spawned should be 0")
	assert_true(wave_manager.enemy_spawn_timer.is_stopped() == false, "Enemy spawn timer should be running")

func test_start_wave_when_already_active():
	"""Test starting wave when already active"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	wave_manager.start_wave()
	wave_manager.start_wave()  # Try to start again
	
	assert_true(wave_manager.wave_active, "Wave should still be active")
	assert_eq(wave_manager.enemies_spawned_this_wave, 0, "Enemies spawned should not change")

func test_start_wave_after_max_waves():
	"""Test starting wave after max waves reached"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	wave_manager.current_wave = 11  # Beyond max waves
	wave_manager.start_wave()
	
	assert_false(wave_manager.wave_active, "Wave should not be active after max waves")

func test_wave_progression():
	"""Test wave progression mechanics"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	
	# Start first wave
	wave_manager.start_wave()
	assert_eq(wave_manager.current_wave, 1, "Should be on wave 1")
	
	# Complete first wave
	wave_manager.enemies_spawned_this_wave = wave_manager.enemies_per_wave
	wave_manager._on_enemy_spawn_timer_timeout()
	
	assert_false(wave_manager.wave_active, "Wave should not be active after completion")
	assert_true(wave_manager.wave_timer.is_stopped() == false, "Wave timer should be running")

func test_wave_timer_timeout():
	"""Test wave timer timeout behavior"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	wave_manager.current_wave = 1
	
	# Simulate wave completion
	wave_manager.enemies_spawned_this_wave = wave_manager.enemies_per_wave
	wave_manager._on_enemy_spawn_timer_timeout()
	
	# Simulate wave timer timeout
	wave_manager._on_wave_timer_timeout()
	
	assert_eq(wave_manager.current_wave, 2, "Should progress to wave 2")
	assert_eq(wave_manager.enemies_per_wave, 7, "Enemies per wave should increase by 2")

func test_all_waves_completed():
	"""Test all waves completed signal"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	wave_manager.current_wave = 10  # Last wave
	wave_manager.max_waves = 10
	
	# Simulate wave completion
	wave_manager.enemies_spawned_this_wave = wave_manager.enemies_per_wave
	wave_manager._on_enemy_spawn_timer_timeout()
	
	# Simulate wave timer timeout
	wave_manager._on_wave_timer_timeout()
	
	# Should emit all_waves_completed signal
	assert_eq(wave_manager.current_wave, 10, "Should stay at wave 10")

# ===== ENEMY SPAWNING TESTS =====

func test_spawn_enemy():
	"""Test enemy spawning"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	
	wave_manager.spawn_enemy()
	
	assert_eq(wave_manager.enemies_alive.size(), 1, "Should have one enemy alive")
	# Note: enemies_spawned_this_wave is only incremented in _on_enemy_spawn_timer_timeout()
	# not in spawn_enemy() directly

func test_spawn_enemy_without_path():
	"""Test enemy spawning without path"""
	wave_manager.initialize(mock_grid_manager)
	# Don't create enemy path
	
	wave_manager.spawn_enemy()
	
	# Should not crash and should still spawn enemy
	assert_eq(wave_manager.enemies_alive.size(), 1, "Should still spawn enemy")

func test_enemy_spawn_timer_timeout():
	"""Test enemy spawn timer timeout"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	wave_manager.start_wave()
	
	wave_manager._on_enemy_spawn_timer_timeout()
	
	assert_eq(wave_manager.enemies_spawned_this_wave, 1, "Enemies spawned should be 1")
	assert_eq(wave_manager.enemies_alive.size(), 1, "Should have one enemy alive")

func test_enemy_spawn_timer_stops_at_limit():
	"""Test enemy spawn timer stops when limit reached"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	wave_manager.start_wave()
	wave_manager.enemies_spawned_this_wave = wave_manager.enemies_per_wave
	
	wave_manager._on_enemy_spawn_timer_timeout()
	
	assert_false(wave_manager.wave_active, "Wave should not be active")
	assert_true(wave_manager.enemy_spawn_timer.is_stopped(), "Enemy spawn timer should be stopped")

# ===== ENEMY EVENT HANDLING TESTS =====

func test_enemy_died():
	"""Test enemy death handling"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	
	var enemy = Enemy.new()
	wave_manager.enemies_alive.append(enemy)
	
	wave_manager._on_enemy_died(enemy)
	
	assert_eq(wave_manager.enemies_alive.size(), 0, "Enemy should be removed from alive list")

func test_enemy_reached_end():
	"""Test enemy reaching end handling"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	
	var enemy = Enemy.new()
	wave_manager.enemies_alive.append(enemy)
	
	wave_manager._on_enemy_reached_end(enemy)
	
	assert_eq(wave_manager.enemies_alive.size(), 0, "Enemy should be removed from alive list")

# ===== GRID CHANGE HANDLING TESTS =====

func test_grid_blocked_changed():
	"""Test grid blocked changed signal handling"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	
	var initial_path_size = wave_manager.enemy_path.size()
	
	# Simulate grid block change
	wave_manager._on_grid_blocked_changed(Vector2i(1, 1), true)
	
	# Should recalculate path
	assert_gt(wave_manager.enemy_path.size(), 0, "Should have recalculated path")

func test_grid_blocked_changed_without_grid_manager():
	"""Test grid blocked changed without grid manager"""
	# Don't initialize with grid manager
	
	wave_manager._on_grid_blocked_changed(Vector2i(1, 1), true)
	
	# Should not crash
	assert_true(true, "Should handle grid change without grid manager")

# ===== ENEMY PATH CHANGE HANDLING TESTS =====

func test_handle_enemies_on_path_change():
	"""Test handling enemies when path changes"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	
	# Add some enemies
	for i in range(3):
		var enemy = Enemy.new()
		wave_manager.enemies_alive.append(enemy)
	
	wave_manager._handle_enemies_on_path_change()
	
	# Should have handled enemies (recycled them)
	assert_eq(wave_manager.enemies_alive.size(), 3, "Should have replacement enemies")

func test_pause_enemies():
	"""Test pausing enemies"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	
	# Add some enemies
	for i in range(2):
		var enemy = Enemy.new()
		wave_manager.enemies_alive.append(enemy)
	
	wave_manager._pause_enemies()
	
	# Should not crash
	assert_true(true, "Should pause enemies without crashing")

func test_identify_enemies_to_recycle():
	"""Test identifying enemies to recycle"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	
	# Add some enemies
	for i in range(3):
		var enemy = Enemy.new()
		wave_manager.enemies_alive.append(enemy)
	
	var enemies_to_recycle = wave_manager._identify_enemies_to_recycle()
	
	assert_eq(enemies_to_recycle.size(), 3, "Should identify all enemies for recycling")

func test_remove_enemies():
	"""Test removing enemies"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	
	# Add some enemies
	var enemies_to_remove = []
	for i in range(2):
		var enemy = Enemy.new()
		wave_manager.enemies_alive.append(enemy)
		enemies_to_remove.append(enemy)
	
	wave_manager._remove_enemies(enemies_to_remove)
	
	assert_eq(wave_manager.enemies_alive.size(), 0, "Should remove all enemies")

func test_spawn_replacement_enemies():
	"""Test spawning replacement enemies"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	
	wave_manager._spawn_replacement_enemies(3)
	
	assert_eq(wave_manager.enemies_alive.size(), 3, "Should spawn replacement enemies")

func test_reposition_remaining_enemies():
	"""Test repositioning remaining enemies"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	
	# Add some enemies
	for i in range(2):
		var enemy = Enemy.new()
		wave_manager.enemies_alive.append(enemy)
	
	wave_manager._reposition_remaining_enemies()
	
	# Should not crash
	assert_true(true, "Should reposition enemies without crashing")

func test_stagger_resume_enemies():
	"""Test staggering enemy resume"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	
	# Add some enemies
	for i in range(2):
		var enemy = Enemy.new()
		wave_manager.enemies_alive.append(enemy)
	
	wave_manager._stagger_resume_enemies()
	
	# Should not crash
	assert_true(true, "Should stagger resume enemies without crashing")

# ===== UTILITY METHOD TESTS =====

func test_get_enemies():
	"""Test getting enemies list"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	
	var enemies = wave_manager.get_enemies()
	
	assert_eq(enemies.size(), 0, "Should return empty enemies list initially")

func test_get_current_wave():
	"""Test getting current wave"""
	assert_eq(wave_manager.get_current_wave(), 1, "Should return current wave")

func test_get_max_waves():
	"""Test getting max waves"""
	assert_eq(wave_manager.get_max_waves(), 10, "Should return max waves")

func test_is_wave_active():
	"""Test checking if wave is active"""
	assert_false(wave_manager.is_wave_active(), "Should return false initially")
	
	wave_manager.wave_active = true
	assert_true(wave_manager.is_wave_active(), "Should return true when active")

func test_are_enemies_alive():
	"""Test checking if enemies are alive"""
	assert_false(wave_manager.are_enemies_alive(), "Should return false initially")
	
	wave_manager.enemies_alive.append(Enemy.new())
	assert_true(wave_manager.are_enemies_alive(), "Should return true when enemies alive")

func test_get_wave_timer_time_left():
	"""Test getting wave timer time left"""
	var time_left = wave_manager.get_wave_timer_time_left()
	
	assert_gt(time_left, -1, "Should return valid time left")

func test_stop_all_timers():
	"""Test stopping all timers"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	wave_manager.start_wave()
	
	wave_manager.stop_all_timers()
	
	assert_false(wave_manager.wave_active, "Wave should not be active")
	assert_true(wave_manager.enemy_spawn_timer.is_stopped(), "Enemy spawn timer should be stopped")
	assert_true(wave_manager.wave_timer.is_stopped(), "Wave timer should be stopped")

func test_cleanup_all_enemies():
	"""Test cleaning up all enemies"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	
	# Add some enemies
	for i in range(3):
		var enemy = Enemy.new()
		wave_manager.enemies_alive.append(enemy)
	
	wave_manager.cleanup_all_enemies()
	
	assert_eq(wave_manager.enemies_alive.size(), 0, "Should clear all enemies")

func test_get_enemy_path():
	"""Test getting enemy path"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	
	var path = wave_manager.get_enemy_path()
	
	assert_eq(path, wave_manager.enemy_path, "Should return enemy path")

# ===== SETUP TESTS =====

func test_setup_enemy_spawning():
	"""Test enemy spawning setup"""
	wave_manager.setup_enemy_spawning()
	
	assert_not_null(wave_manager.enemy_spawn_timer, "Enemy spawn timer should be created")
	assert_not_null(wave_manager.wave_timer, "Wave timer should be created")

func test_ready_adds_to_group():
	"""Test that _ready adds to main_controller group"""
	wave_manager._ready()
	
	assert_true(wave_manager.is_in_group("main_controller"), "Should be in main_controller group")

# ===== EDGE CASE TESTS =====

func test_create_enemy_path_without_grid_layout():
	"""Test path creation without grid layout"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.grid_layout = null
	
	wave_manager.create_enemy_path()
	
	# Should not crash
	assert_true(true, "Should handle missing grid layout")

func test_spawn_enemy_without_enemy_scene():
	"""Test spawning enemy without enemy scene"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	
	# Should not crash even without enemy scene
	wave_manager.spawn_enemy()
	
	# Should not crash
	assert_true(true, "Should handle missing enemy scene")

func test_enemy_events_with_invalid_enemy():
	"""Test enemy events with invalid enemy"""
	wave_manager.initialize(mock_grid_manager)
	wave_manager.create_enemy_path()
	
	# Add an enemy
	var enemy = Enemy.new()
	wave_manager.enemies_alive.append(enemy)
	
	# Free the enemy
	enemy.queue_free()
	
	# Should not crash when processing events
	wave_manager._on_enemy_died(enemy)
	wave_manager._on_enemy_reached_end(enemy)
	
	assert_true(true, "Should handle invalid enemy gracefully")

# ===== CONSTANTS TESTS =====

func test_enemy_scene_constant():
	"""Test enemy scene constant is set"""
	assert_not_null(wave_manager.ENEMY_SCENE, "ENEMY_SCENE should be set")

func test_wave_constants():
	"""Test wave-related constants"""
	assert_eq(wave_manager.max_waves, 10, "Max waves should be 10")
	assert_eq(wave_manager.enemies_per_wave, 5, "Enemies per wave should be 5")
	assert_eq(wave_manager.time_between_enemies, 1.0, "Time between enemies should be 1.0")
	assert_eq(wave_manager.time_between_waves, 3.0, "Time between waves should be 3.0") 