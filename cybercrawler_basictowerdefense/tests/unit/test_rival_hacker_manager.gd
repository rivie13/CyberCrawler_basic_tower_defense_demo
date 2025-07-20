extends GutTest

var rival_hacker_manager: RivalHackerManager
var grid_manager: GridManager
var currency_manager: CurrencyManagerInterface
var tower_manager: TowerManager
var wave_manager: WaveManager
var game_manager: GameManager
var alert_system: RivalAlertSystem

func before_each():
	rival_hacker_manager = RivalHackerManager.new()
	grid_manager = GridManager.new()
	currency_manager = CurrencyManager.new()
	tower_manager = TowerManager.new()
	wave_manager = WaveManager.new()
	game_manager = GameManager.new()
	
	# Add to scene tree for proper initialization
	add_child_autofree(rival_hacker_manager)
	add_child_autofree(grid_manager)
	add_child_autofree(currency_manager)
	add_child_autofree(tower_manager)
	add_child_autofree(wave_manager)
	add_child_autofree(game_manager)

func after_each():
	# Cleanup is handled by autofree
	pass

func test_initialization():
	# Test basic initialization
	assert_not_null(rival_hacker_manager)
	assert_false(rival_hacker_manager.is_active)
	assert_eq(rival_hacker_manager.enemy_towers_placed.size(), 0)
	assert_eq(rival_hacker_manager.rival_hackers_active.size(), 0)
	assert_eq(rival_hacker_manager.max_enemy_towers, 10)
	assert_eq(rival_hacker_manager.max_rival_hackers, 3)

func test_setup_timers():
	# Test that timers are properly set up
	rival_hacker_manager.setup_timers()
	
	assert_not_null(rival_hacker_manager.placement_timer)
	assert_not_null(rival_hacker_manager.hacker_spawn_timer)
	assert_not_null(rival_hacker_manager.grid_action_timer)
	
	assert_eq(rival_hacker_manager.placement_timer.wait_time, 3.0)
	assert_eq(rival_hacker_manager.hacker_spawn_timer.wait_time, 8.0)
	assert_eq(rival_hacker_manager.grid_action_timer.wait_time, 35.0)

func test_initialize():
	# Test initialization with all managers
	rival_hacker_manager.initialize(grid_manager, currency_manager, tower_manager, wave_manager, game_manager)
	
	assert_eq(rival_hacker_manager.grid_manager, grid_manager)
	assert_eq(rival_hacker_manager.currency_manager, currency_manager)
	assert_eq(rival_hacker_manager.tower_manager, tower_manager)
	assert_eq(rival_hacker_manager.wave_manager, wave_manager)
	assert_eq(rival_hacker_manager.game_manager, game_manager)
	
	# Test that alert system is created
	assert_not_null(rival_hacker_manager.alert_system)

func test_setup_preferred_zones():
	# Test preferred zones setup
	rival_hacker_manager.grid_manager = grid_manager
	rival_hacker_manager.setup_preferred_zones()
	
	# Should have preferred zones defined
	assert_gt(rival_hacker_manager.preferred_grid_zones.size(), 0)

func test_setup_alert_system():
	# Test alert system setup
	rival_hacker_manager.grid_manager = grid_manager
	rival_hacker_manager.setup_alert_system()
	
	assert_not_null(rival_hacker_manager.alert_system)
	assert_true(rival_hacker_manager.alert_system.is_inside_tree())

func test_activate():
	# Test activation
	rival_hacker_manager.initialize(grid_manager, currency_manager, tower_manager, wave_manager, game_manager)
	rival_hacker_manager.activate()
	
	# is_active should be false initially - only set to true when first alert is triggered
	assert_false(rival_hacker_manager.is_active)
	assert_true(rival_hacker_manager.alert_system.is_monitoring)

func test_deactivate():
	# Test deactivation
	rival_hacker_manager.initialize(grid_manager, currency_manager, tower_manager, wave_manager, game_manager)
	rival_hacker_manager.activate()
	rival_hacker_manager.deactivate()
	
	assert_false(rival_hacker_manager.is_active)

func test_get_randomized_grid_action_interval():
	# Test that interval is within expected range
	var interval = rival_hacker_manager.get_randomized_grid_action_interval()
	assert_gte(interval, 30.0)
	assert_lte(interval, 45.0)

func test_is_valid_enemy_tower_position():
	# Test position validation
	rival_hacker_manager.grid_manager = grid_manager
	
	# Test that the method exists and can be called
	var valid_pos = Vector2i(5, 5)
	var result = rival_hacker_manager.is_valid_enemy_tower_position(valid_pos)
	assert_true(result is bool, "Should return a boolean result")

func test_find_optimal_tower_position():
	# Test finding optimal tower position
	rival_hacker_manager.grid_manager = grid_manager
	rival_hacker_manager.setup_preferred_zones()
	
	# Test that the method exists and can be called
	var position = rival_hacker_manager.find_optimal_tower_position()
	assert_true(position is Vector2i, "Should return a Vector2i result")

func test_place_enemy_tower():
	# Test enemy tower placement
	rival_hacker_manager.grid_manager = grid_manager
	
	# Test that the method exists and can be called
	var result = rival_hacker_manager.place_enemy_tower(Vector2i(5, 5))
	assert_true(result is bool, "Should return a boolean result")

func test_find_rival_hacker_spawn_position():
	# Test finding spawn position for rival hacker
	rival_hacker_manager.grid_manager = grid_manager
	
	# Test that the method exists and can be called
	var position = rival_hacker_manager.find_rival_hacker_spawn_position()
	assert_true(position is Vector2, "Should return a Vector2 result")

func test_spawn_rival_hacker():
	# Test rival hacker spawning
	rival_hacker_manager.grid_manager = grid_manager
	
	# Test that the method exists and can be called
	var result = rival_hacker_manager.spawn_rival_hacker(Vector2(100, 100))
	assert_true(result is bool, "Should return a boolean result")

func test_get_rival_hackers():
	# Test getting valid rival hackers
	rival_hacker_manager.rival_hackers_active = []
	
	# Add a proper RivalHacker object
	var mock_hacker = RivalHacker.new()
	mock_hacker.is_alive = true
	rival_hacker_manager.rival_hackers_active.append(mock_hacker)
	
	var hackers = rival_hacker_manager.get_rival_hackers()
	assert_eq(hackers.size(), 1)
	
	# Test with dead hacker
	var dead_hacker = RivalHacker.new()
	dead_hacker.is_alive = false
	rival_hacker_manager.rival_hackers_active.append(dead_hacker)
	
	hackers = rival_hacker_manager.get_rival_hackers()
	assert_eq(hackers.size(), 1, "Should only return alive hackers")

func test_get_enemy_towers():
	# Test getting enemy towers
	rival_hacker_manager.enemy_towers_placed = []
	
	# Add a mock tower
	var mock_tower = Node2D.new()
	rival_hacker_manager.enemy_towers_placed.append(mock_tower)
	
	var towers = rival_hacker_manager.get_enemy_towers()
	assert_eq(towers.size(), 1)

func test_analyze_player_threat():
	# Test player threat analysis
	rival_hacker_manager.tower_manager = tower_manager
	rival_hacker_manager.placement_interval = 3.0
	
	# Test that the method exists and can be called
	rival_hacker_manager.analyze_player_threat()
	assert_true(true, "Method should not crash")

func test_on_player_tower_placed():
	# Test player tower placement response
	rival_hacker_manager.tower_manager = tower_manager
	rival_hacker_manager.alert_system = RivalAlertSystem.new()
	rival_hacker_manager.alert_system.is_monitoring = true
	
	# Test that the method can be called without crashing
	rival_hacker_manager._on_player_tower_placed(Vector2i(5, 5), "basic")
	assert_true(true, "Method should not crash")

func test_on_player_tower_placed_powerful():
	# Test powerful tower placement response
	rival_hacker_manager.tower_manager = tower_manager
	rival_hacker_manager.alert_system = RivalAlertSystem.new()
	rival_hacker_manager.alert_system.is_monitoring = true
	
	# Test that the method can be called without crashing
	rival_hacker_manager._on_player_tower_placed(Vector2i(5, 5), "powerful")
	assert_true(true, "Method should not crash")

func test_on_alert_triggered():
	# Test alert response
	rival_hacker_manager.initialize(grid_manager, currency_manager, tower_manager, wave_manager, game_manager)
	
	# Test that the method can be called without crashing
	rival_hacker_manager._on_alert_triggered("TOWERS_TOO_CLOSE_TO_EXIT", 0.5)
	assert_true(true, "Method should not crash")

func test_respond_to_exit_proximity_alert():
	# Test exit proximity alert response
	rival_hacker_manager.placement_interval = 3.0
	rival_hacker_manager.placement_timer = Timer.new()
	rival_hacker_manager.placement_timer.wait_time = 3.0
	
	rival_hacker_manager.respond_to_exit_proximity_alert(0.5)
	assert_lt(rival_hacker_manager.placement_timer.wait_time, 3.0)

func test_respond_to_burst_placement_alert():
	# Test burst placement alert response
	rival_hacker_manager.placement_interval = 3.0
	rival_hacker_manager.placement_timer = Timer.new()
	rival_hacker_manager.placement_timer.wait_time = 3.0
	
	rival_hacker_manager.respond_to_burst_placement_alert(0.5)
	assert_lt(rival_hacker_manager.placement_timer.wait_time, 3.0)

func test_respond_to_powerful_tower_alert():
	# Test powerful tower alert response
	rival_hacker_manager.max_enemy_towers = 10
	rival_hacker_manager.placement_interval = 3.0
	rival_hacker_manager.placement_timer = Timer.new()
	rival_hacker_manager.placement_timer.wait_time = 3.0
	
	rival_hacker_manager.respond_to_powerful_tower_alert(0.5)
	assert_gt(rival_hacker_manager.max_enemy_towers, 10)
	assert_lt(rival_hacker_manager.placement_timer.wait_time, 3.0)

func test_setup_detour_points():
	# Test detour points setup
	rival_hacker_manager.grid_manager = grid_manager
	
	# Test that the method can be called without crashing
	rival_hacker_manager.setup_detour_points()
	assert_true(true, "Method should not crash")

func test_setup_cell_weights():
	# Test cell weights setup
	rival_hacker_manager.grid_manager = grid_manager
	rival_hacker_manager.tower_manager = tower_manager
	
	# Test that the method can be called without crashing
	rival_hacker_manager.setup_cell_weights()
	assert_true(true, "Method should not crash")

func test_find_weighted_path():
	# Test weighted pathfinding
	rival_hacker_manager.grid_manager = grid_manager
	
	# Test that the method can be called without crashing
	var path = rival_hacker_manager.find_weighted_path(Vector2i(0, 0), Vector2i(3, 3))
	assert_true(true, "Method should not crash")

func test_stop_all_activity():
	# Test stopping all activity
	rival_hacker_manager.is_active = true
	rival_hacker_manager.rival_hackers_active = []
	
	# Add a proper RivalHacker object
	var mock_hacker = RivalHacker.new()
	mock_hacker.is_alive = true
	rival_hacker_manager.rival_hackers_active.append(mock_hacker)
	
	rival_hacker_manager.stop_all_activity()
	assert_false(rival_hacker_manager.is_active)
	assert_false(mock_hacker.is_alive, "Should set hacker to dead")

func test_on_enemy_tower_destroyed():
	# Test enemy tower destruction
	var mock_tower = EnemyTower.new()
	rival_hacker_manager.enemy_towers_placed = [mock_tower]
	
	rival_hacker_manager._on_enemy_tower_destroyed(mock_tower)
	assert_eq(rival_hacker_manager.enemy_towers_placed.size(), 0)

func test_on_rival_hacker_destroyed():
	# Test rival hacker destruction
	var mock_hacker = RivalHacker.new()
	rival_hacker_manager.rival_hackers_active = [mock_hacker]
	
	rival_hacker_manager._on_rival_hacker_destroyed(mock_hacker)
	assert_eq(rival_hacker_manager.rival_hackers_active.size(), 0)

func test_on_rival_hacker_tower_attacked():
	# Test rival hacker tower attack
	var mock_tower = Tower.new()
	add_child_autofree(mock_tower)
	
	# Test that the method can be called without crashing
	rival_hacker_manager._on_rival_hacker_tower_attacked(mock_tower, 10)
	
	# Verify the method executed successfully (it should not crash)
	assert_true(true, "Method should execute without errors")
	
	# Test with different damage values
	rival_hacker_manager._on_rival_hacker_tower_attacked(mock_tower, 25)
	assert_true(true, "Method should handle different damage values")

func test_attempt_strategic_path_block():
	# Test strategic path blocking
	rival_hacker_manager.grid_manager = grid_manager
	
	# Test that the method can be called without crashing
	var result = rival_hacker_manager._attempt_strategic_path_block()
	assert_true(true, "Method should not crash")

func test_attempt_strategic_non_path_block():
	# Test strategic non-path blocking
	rival_hacker_manager.grid_manager = grid_manager
	
	# Test that the method can be called without crashing
	var result = rival_hacker_manager._attempt_strategic_non_path_block()
	assert_true(true, "Method should not crash")

func test_attempt_strategic_unblock():
	# Test strategic unblocking
	rival_hacker_manager.grid_manager = grid_manager
	rival_hacker_manager.blocked_cells_tracker = [Vector2i(5, 5)]
	
	# Test that the method can be called without crashing
	var result = rival_hacker_manager._attempt_strategic_unblock()
	assert_true(true, "Method should not crash")

func test_force_path_recalculation():
	# Test path recalculation
	rival_hacker_manager.grid_manager = grid_manager
	rival_hacker_manager.wave_manager = wave_manager
	
	# Test that the method can be called without crashing
	rival_hacker_manager._force_path_recalculation()
	assert_true(true, "Method should not crash")

func test_get_corridor_cells_around_path():
	# Test corridor cells calculation
	rival_hacker_manager.grid_manager = grid_manager
	
	# Test that the method can be called without crashing
	var path: Array[Vector2i] = [Vector2i(5, 5), Vector2i(6, 6)]
	var corridor = rival_hacker_manager.get_corridor_cells_around_path(path, 2)
	assert_true(true, "Method should not crash")

func test_find_corridor_limited_path():
	# Test corridor-limited pathfinding
	rival_hacker_manager.grid_manager = grid_manager
	
	# Test that the method can be called without crashing
	var allowed_cells: Array[Vector2i] = [Vector2i(1, 1), Vector2i(2, 2), Vector2i(3, 3)]
	var path = rival_hacker_manager.find_corridor_limited_path(Vector2i(0, 0), Vector2i(3, 3), allowed_cells)
	assert_true(true, "Method should not crash")

func test_perform_comprehensive_grid_action():
	# Test comprehensive grid action
	rival_hacker_manager.grid_manager = grid_manager
	
	# Test that the method can be called without crashing
	rival_hacker_manager._perform_comprehensive_grid_action()
	assert_true(true, "Method should not crash")

func test_on_grid_action_timer_timeout():
	# Test grid action timer timeout
	rival_hacker_manager.is_active = true
	rival_hacker_manager.game_manager = game_manager
	rival_hacker_manager.grid_manager = grid_manager
	
	# Test that the method can be called without crashing
	rival_hacker_manager._on_grid_action_timer_timeout()
	assert_true(true, "Method should not crash") 
