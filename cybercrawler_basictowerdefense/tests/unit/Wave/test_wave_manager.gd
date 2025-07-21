extends GutTest

# Unit tests for WaveManager class
# These tests verify the wave management, enemy spawning, and path creation functionality

var wave_manager: WaveManager
var mock_grid_manager: GridManager

func before_each():
	# Setup fresh WaveManager for each test
	wave_manager = WaveManager.new()
	mock_grid_manager = GridManager.new()
	add_child_autofree(wave_manager)
	add_child_autofree(mock_grid_manager)

func test_initial_state():
	# Test that WaveManager starts with correct initial values
	assert_eq(wave_manager.current_wave, 1, "Should start with wave 1")
	assert_eq(wave_manager.enemies_per_wave, 5, "Should start with 5 enemies per wave")
	assert_eq(wave_manager.enemies_spawned_this_wave, 0, "Should start with 0 enemies spawned")
	assert_false(wave_manager.wave_active, "Should not have active wave initially")
	assert_eq(wave_manager.time_between_enemies, 1.0, "Should have 1.0 second between enemies")
	assert_eq(wave_manager.time_between_waves, 3.0, "Should have 3.0 seconds between waves")
	assert_eq(wave_manager.max_waves, 10, "Should have 10 max waves")
	assert_eq(wave_manager.enemies_alive.size(), 0, "Should start with no alive enemies")
	assert_eq(wave_manager.enemy_path.size(), 0, "Should start with no enemy path")

func test_ready_creates_timers():
	# Test that _ready() creates the necessary timers and adds to group
	wave_manager._ready()
	
	# Check timers were created
	assert_not_null(wave_manager.enemy_spawn_timer, "Should create enemy spawn timer")
	assert_not_null(wave_manager.wave_timer, "Should create wave timer")
	
	# Check timer configuration
	assert_eq(wave_manager.enemy_spawn_timer.wait_time, 1.0, "Enemy spawn timer should match time_between_enemies")
	assert_eq(wave_manager.wave_timer.wait_time, 3.0, "Wave timer should match time_between_waves")
	assert_true(wave_manager.wave_timer.one_shot, "Wave timer should be one-shot")
	
	# Check group membership
	assert_true(wave_manager.is_in_group("main_controller"), "Should be in main_controller group")

func test_initialize_sets_grid_references():
	# Test that initialize properly sets grid references
	wave_manager.initialize(mock_grid_manager)
	
	assert_eq(wave_manager.grid_manager, mock_grid_manager, "Grid manager should be set")
	assert_not_null(wave_manager.grid_layout, "Grid layout should be created")
	assert_not_null(wave_manager.selected_layout_type, "Layout type should be selected")

func test_setup_enemy_spawning():
	# Test enemy spawning setup
	wave_manager.setup_enemy_spawning()
	
	assert_not_null(wave_manager.enemy_spawn_timer, "Should create enemy spawn timer")
	assert_not_null(wave_manager.wave_timer, "Should create wave timer")
	assert_true(wave_manager.enemy_spawn_timer.timeout.is_connected(wave_manager._on_enemy_spawn_timer_timeout), "Should connect enemy spawn timeout")
	assert_true(wave_manager.wave_timer.timeout.is_connected(wave_manager._on_wave_timer_timeout), "Should connect wave timeout")

func test_get_current_wave():
	# Test current wave getter
	assert_eq(wave_manager.get_current_wave(), 1, "Should return current wave")
	
	wave_manager.current_wave = 5
	assert_eq(wave_manager.get_current_wave(), 5, "Should return updated current wave")

func test_get_max_waves():
	# Test max waves getter
	assert_eq(wave_manager.get_max_waves(), 10, "Should return max waves")

func test_is_wave_active():
	# Test wave active status
	assert_false(wave_manager.is_wave_active(), "Should not be active initially")
	
	wave_manager.wave_active = true
	assert_true(wave_manager.is_wave_active(), "Should return true when active")

func test_are_enemies_alive():
	# Test enemies alive check
	assert_false(wave_manager.are_enemies_alive(), "Should have no enemies alive initially")
	
	# Add a mock enemy to the array
	var mock_enemy = Enemy.new()
	add_child_autofree(mock_enemy)
	wave_manager.enemies_alive.append(mock_enemy)
	assert_true(wave_manager.are_enemies_alive(), "Should detect alive enemies")

func test_get_enemies():
	# Test enemies getter
	var enemies_list = wave_manager.get_enemies()
	assert_true(enemies_list is Array, "Should return an array")
	assert_eq(enemies_list.size(), 0, "Should start with empty array")
	
	# Add mock enemy
	var mock_enemy = Enemy.new()
	add_child_autofree(mock_enemy)
	wave_manager.enemies_alive.append(mock_enemy)
	
	enemies_list = wave_manager.get_enemies()
	assert_eq(enemies_list.size(), 1, "Should return array with one enemy")
	assert_eq(enemies_list[0], mock_enemy, "Should return the correct enemy")

func test_get_enemy_path():
	# Test enemy path getter
	var path = wave_manager.get_enemy_path()
	assert_true(path is Array, "Should return an array")
	assert_eq(path.size(), 0, "Should start with empty path")
	
	# Set up a test path
	wave_manager.enemy_path = [Vector2(0, 0), Vector2(100, 0), Vector2(100, 100)]
	path = wave_manager.get_enemy_path()
	assert_eq(path.size(), 3, "Should return path with 3 points")
	assert_eq(path[0], Vector2(0, 0), "Should return correct first point")

func test_start_wave():
	# Test starting a wave
	wave_manager.setup_enemy_spawning()
	watch_signals(wave_manager)
	
	wave_manager.start_wave()
	
	assert_true(wave_manager.wave_active, "Wave should be active")
	assert_eq(wave_manager.enemies_spawned_this_wave, 0, "Should reset enemies spawned counter")
	assert_signal_emitted(wave_manager, "wave_started", "Should emit wave_started signal")

func test_start_wave_prevents_double_start():
	# Test that start_wave prevents starting when already active
	wave_manager.setup_enemy_spawning()
	wave_manager.wave_active = true
	watch_signals(wave_manager)
	
	wave_manager.start_wave()
	
	assert_signal_not_emitted(wave_manager, "wave_started", "Should not emit signal when already active")

func test_start_wave_prevents_after_max_waves():
	# Test that start_wave prevents starting after max waves
	wave_manager.setup_enemy_spawning()
	wave_manager.current_wave = 11  # Beyond max_waves (10)
	watch_signals(wave_manager)
	
	wave_manager.start_wave()
	
	assert_false(wave_manager.wave_active, "Should not start wave after max waves")
	assert_signal_not_emitted(wave_manager, "wave_started", "Should not emit signal after max waves")

func test_on_enemy_died():
	# Test enemy death handling
	var mock_enemy = Enemy.new()
	add_child_autofree(mock_enemy)
	wave_manager.enemies_alive.append(mock_enemy)
	watch_signals(wave_manager)
	
	wave_manager._on_enemy_died(mock_enemy)
	
	assert_false(mock_enemy in wave_manager.enemies_alive, "Should remove enemy from alive list")
	assert_signal_emitted(wave_manager, "enemy_died", "Should emit enemy_died signal")

func test_on_enemy_reached_end():
	# Test enemy reaching end handling
	var mock_enemy = Enemy.new()
	add_child_autofree(mock_enemy)
	wave_manager.enemies_alive.append(mock_enemy)
	watch_signals(wave_manager)
	
	wave_manager._on_enemy_reached_end(mock_enemy)
	
	assert_false(mock_enemy in wave_manager.enemies_alive, "Should remove enemy from alive list")
	assert_signal_emitted(wave_manager, "enemy_reached_end", "Should emit enemy_reached_end signal")

func test_get_wave_timer_time_left():
	# Test wave timer time left
	assert_eq(wave_manager.get_wave_timer_time_left(), 0.0, "Should return 0 when no timer")
	
	wave_manager.setup_enemy_spawning()
	assert_eq(wave_manager.get_wave_timer_time_left(), 0.0, "Should return 0 when timer not started")
	
	wave_manager.wave_timer.start()
	assert_gt(wave_manager.get_wave_timer_time_left(), 0.0, "Should return positive time when timer running")

func test_stop_all_timers():
	# Test stopping all timers
	wave_manager.setup_enemy_spawning()
	wave_manager.enemy_spawn_timer.start()
	wave_manager.wave_timer.start()
	wave_manager.wave_active = true
	
	wave_manager.stop_all_timers()
	
	assert_false(wave_manager.enemy_spawn_timer.is_processing(), "Enemy spawn timer should be stopped")
	assert_false(wave_manager.wave_timer.is_processing(), "Wave timer should be stopped")
	assert_false(wave_manager.wave_active, "Wave should not be active")

func test_cleanup_all_enemies():
	# Test enemy cleanup
	var mock_enemy1 = Enemy.new()
	var mock_enemy2 = Enemy.new()
	add_child_autofree(mock_enemy1)
	add_child_autofree(mock_enemy2)
	
	wave_manager.enemies_alive.append(mock_enemy1)
	wave_manager.enemies_alive.append(mock_enemy2)
	
	wave_manager.cleanup_all_enemies()
	
	assert_eq(wave_manager.enemies_alive.size(), 0, "Should clear enemies alive array")

func test_on_enemy_spawn_timer_timeout_spawns_enemy():
	# Test enemy spawning on timer timeout
	wave_manager.setup_enemy_spawning()
	wave_manager.enemy_path = [Vector2(0, 0), Vector2(100, 0)]
	wave_manager.enemies_spawned_this_wave = 2
	wave_manager.enemies_per_wave = 5
	
	var initial_count = wave_manager.enemies_alive.size()
	wave_manager._on_enemy_spawn_timer_timeout()
	
	assert_eq(wave_manager.enemies_spawned_this_wave, 3, "Should increment spawned counter")

func test_on_enemy_spawn_timer_timeout_completes_wave():
	# Test wave completion when enough enemies spawned
	wave_manager.setup_enemy_spawning()
	wave_manager.enemies_spawned_this_wave = 5
	wave_manager.enemies_per_wave = 5
	wave_manager.wave_active = true
	watch_signals(wave_manager)
	
	wave_manager._on_enemy_spawn_timer_timeout()
	
	assert_false(wave_manager.enemy_spawn_timer.is_processing(), "Should stop spawn timer")
	assert_false(wave_manager.wave_active, "Should deactivate wave")
	assert_signal_emitted(wave_manager, "wave_completed", "Should emit wave_completed signal")

func test_on_wave_timer_timeout_starts_next_wave():
	# Test next wave start on timer timeout
	wave_manager.setup_enemy_spawning()
	wave_manager.current_wave = 3
	wave_manager.enemies_per_wave = 5
	
	var initial_wave = wave_manager.current_wave
	var initial_enemies_per_wave = wave_manager.enemies_per_wave
	
	wave_manager._on_wave_timer_timeout()
	
	assert_eq(wave_manager.current_wave, initial_wave + 1, "Should increment wave number")
	assert_eq(wave_manager.enemies_per_wave, initial_enemies_per_wave + 2, "Should increase difficulty")
	assert_true(wave_manager.wave_active, "Should start new wave")

func test_on_wave_timer_timeout_completes_all_waves():
	# Test all waves completion
	wave_manager.setup_enemy_spawning()
	wave_manager.current_wave = 10  # At max waves
	watch_signals(wave_manager)
	
	wave_manager._on_wave_timer_timeout()
	
	assert_signal_emitted(wave_manager, "all_waves_completed", "Should emit all_waves_completed signal")

func test_get_path_grid_positions():
	# Test getting path grid positions
	wave_manager.initialize(mock_grid_manager)
	
	var grid_positions = wave_manager.get_path_grid_positions()
	assert_true(grid_positions is Array, "Should return an array")

func test_pause_enemies():
	# Test pausing enemies
	var mock_enemy = Enemy.new()
	add_child_autofree(mock_enemy)
	wave_manager.enemies_alive.append(mock_enemy)
	
	wave_manager._pause_enemies()
	
	assert_true(mock_enemy.paused, "Should pause the enemy")

func test_handle_enemies_on_path_change():
	# Test handling enemies when path changes
	var mock_enemy = Enemy.new()
	add_child_autofree(mock_enemy)
	wave_manager.enemies_alive.append(mock_enemy)
	wave_manager.enemy_path = [Vector2(0, 0), Vector2(100, 0)]
	
	# This method is complex but should not crash
	wave_manager._handle_enemies_on_path_change()
	
	assert_true(true, "Should handle path change without crashing") 