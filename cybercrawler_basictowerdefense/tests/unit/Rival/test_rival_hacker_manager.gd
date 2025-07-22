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
	
	# All zones should be in the right half of the grid
	var grid_size = grid_manager.get_grid_size()
	for zone in rival_hacker_manager.preferred_grid_zones:
		assert_gte(zone.x, int(grid_size.x / 2), "Zone should be in right half of grid")
		assert_lt(zone.x, grid_size.x, "Zone should be within grid bounds")
		assert_gte(zone.y, 0, "Zone should be within grid bounds")
		assert_lt(zone.y, grid_size.y, "Zone should be within grid bounds")

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
	
	# Test valid position
	var valid_pos = Vector2i(5, 5)
	var result = rival_hacker_manager.is_valid_enemy_tower_position(valid_pos)
	assert_true(result is bool, "Should return a boolean result")
	
	# Test invalid position (outside grid)
	var invalid_pos = Vector2i(-1, -1)
	result = rival_hacker_manager.is_valid_enemy_tower_position(invalid_pos)
	assert_false(result, "Should return false for invalid position")
	
	# Test without grid manager
	rival_hacker_manager.grid_manager = null
	result = rival_hacker_manager.is_valid_enemy_tower_position(valid_pos)
	assert_false(result, "Should return false without grid manager")

func test_find_optimal_tower_position():
	# Test finding optimal tower position
	rival_hacker_manager.grid_manager = grid_manager
	rival_hacker_manager.setup_preferred_zones()
	
	# Test that the method returns a valid position
	var position = rival_hacker_manager.find_optimal_tower_position()
	assert_true(position is Vector2i, "Should return a Vector2i result")
	
	# If a valid position is found, it should be in preferred zones
	if position != Vector2i(-1, -1):
		assert_true(rival_hacker_manager.preferred_grid_zones.has(position), "Position should be in preferred zones")

func test_place_enemy_tower():
	# Test enemy tower placement
	rival_hacker_manager.grid_manager = grid_manager
	
	# Test valid placement
	var valid_pos = Vector2i(5, 5)
	var result = rival_hacker_manager.place_enemy_tower(valid_pos)
	assert_true(result, "Should successfully place tower at valid position")
	assert_eq(rival_hacker_manager.enemy_towers_placed.size(), 1, "Should add tower to placed list")
	
	# Test invalid placement (no grid manager)
	rival_hacker_manager.grid_manager = null
	result = rival_hacker_manager.place_enemy_tower(valid_pos)
	assert_false(result, "Should fail to place tower without grid manager")

func test_find_rival_hacker_spawn_position():
	# Test finding spawn position for rival hacker
	rival_hacker_manager.grid_manager = grid_manager
	
	# Test that the method returns a valid position
	var position = rival_hacker_manager.find_rival_hacker_spawn_position()
	assert_true(position is Vector2, "Should return a Vector2 result")
	
	# Position should not be zero if grid manager is available
	if rival_hacker_manager.grid_manager != null:
		assert_ne(position, Vector2.ZERO, "Should return non-zero position with grid manager")

func test_spawn_rival_hacker():
	# Test rival hacker spawning
	rival_hacker_manager.grid_manager = grid_manager
	
	# Test valid spawn
	var spawn_pos = Vector2(100, 100)
	var result = rival_hacker_manager.spawn_rival_hacker(spawn_pos)
	assert_true(result, "Should successfully spawn rival hacker")
	assert_eq(rival_hacker_manager.rival_hackers_active.size(), 1, "Should add hacker to active list")

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
	
	# Test with no player towers
	rival_hacker_manager.analyze_player_threat()
	assert_eq(rival_hacker_manager.player_threat_level, 0, "Should have zero threat with no towers")
	
	# Test with player towers
	var mock_tower = Tower.new()
	add_child_autofree(mock_tower)
	tower_manager.towers_placed = [mock_tower]
	
	rival_hacker_manager.analyze_player_threat()
	assert_eq(rival_hacker_manager.player_threat_level, 1, "Should calculate threat based on tower count")

func test_on_player_tower_placed():
	# Test player tower placement response
	rival_hacker_manager.tower_manager = tower_manager
	rival_hacker_manager.alert_system = RivalAlertSystem.new()
	rival_hacker_manager.alert_system.is_monitoring = true
	
	# Add a tower to the tower manager so it can be found
	var mock_tower = Tower.new()
	add_child_autofree(mock_tower)
	tower_manager.towers_placed = [mock_tower]
	
	# Test that the method calls alert system
	var initial_alert_count = rival_hacker_manager.alert_system.recent_tower_placements.size()
	rival_hacker_manager._on_player_tower_placed(Vector2i(5, 5), "basic")
	
	# Should have notified alert system
	assert_gt(rival_hacker_manager.alert_system.recent_tower_placements.size(), initial_alert_count, "Should notify alert system of tower placement")

func test_on_player_tower_placed_powerful():
	# Test powerful tower placement response
	rival_hacker_manager.tower_manager = tower_manager
	rival_hacker_manager.alert_system = RivalAlertSystem.new()
	rival_hacker_manager.alert_system.is_monitoring = true
	
	# Add a tower to the tower manager so it can be found
	var mock_tower = Tower.new()
	add_child_autofree(mock_tower)
	tower_manager.towers_placed = [mock_tower]
	
	# Test that the method calls alert system
	var initial_alert_count = rival_hacker_manager.alert_system.recent_tower_placements.size()
	rival_hacker_manager._on_player_tower_placed(Vector2i(5, 5), "powerful")
	
	# Should have notified alert system
	assert_gt(rival_hacker_manager.alert_system.recent_tower_placements.size(), initial_alert_count, "Should notify alert system of powerful tower placement")

func test_on_alert_triggered():
	# Test alert response
	rival_hacker_manager.initialize(grid_manager, currency_manager, tower_manager, wave_manager, game_manager)
	
	# Test that alert triggers activation
	rival_hacker_manager._on_alert_triggered("TOWERS_TOO_CLOSE_TO_EXIT", 0.5)
	assert_true(rival_hacker_manager.is_active, "Should activate on alert")

func test_respond_to_exit_proximity_alert():
	# Test exit proximity alert response
	rival_hacker_manager.placement_interval = 3.0
	rival_hacker_manager.placement_timer = Timer.new()
	rival_hacker_manager.placement_timer.wait_time = 3.0
	
	rival_hacker_manager.respond_to_exit_proximity_alert(0.5)
	assert_lt(rival_hacker_manager.placement_timer.wait_time, 3.0, "Should reduce placement interval")

func test_respond_to_burst_placement_alert():
	# Test burst placement alert response
	rival_hacker_manager.placement_interval = 3.0
	rival_hacker_manager.placement_timer = Timer.new()
	rival_hacker_manager.placement_timer.wait_time = 3.0
	
	rival_hacker_manager.respond_to_burst_placement_alert(0.5)
	assert_lt(rival_hacker_manager.placement_timer.wait_time, 3.0, "Should reduce placement interval")

func test_respond_to_powerful_tower_alert():
	# Test powerful tower alert response
	rival_hacker_manager.max_enemy_towers = 10
	rival_hacker_manager.placement_interval = 3.0
	rival_hacker_manager.placement_timer = Timer.new()
	rival_hacker_manager.placement_timer.wait_time = 3.0
	
	rival_hacker_manager.respond_to_powerful_tower_alert(0.5)
	assert_gt(rival_hacker_manager.max_enemy_towers, 10, "Should increase max enemy towers")
	assert_lt(rival_hacker_manager.placement_timer.wait_time, 3.0, "Should reduce placement interval")

func test_setup_detour_points():
	# Test detour points setup
	rival_hacker_manager.grid_manager = grid_manager
	
	rival_hacker_manager.setup_detour_points()
	assert_gt(rival_hacker_manager.detour_points.size(), 0, "Should create detour points")

func test_setup_cell_weights():
	# Test cell weights setup
	rival_hacker_manager.grid_manager = grid_manager
	rival_hacker_manager.tower_manager = tower_manager
	
	# Add a tower to create weights
	var mock_tower = Tower.new()
	add_child_autofree(mock_tower)
	mock_tower.grid_position = Vector2i(3, 3)
	tower_manager.towers_placed = [mock_tower]
	
	rival_hacker_manager.setup_cell_weights()
	assert_gt(rival_hacker_manager.cell_weights.size(), 0, "Should create cell weights")

func test_find_weighted_path():
	# Test weighted pathfinding
	rival_hacker_manager.grid_manager = grid_manager
	
	var path = rival_hacker_manager.find_weighted_path(Vector2i(0, 0), Vector2i(3, 3))
	assert_true(path is Array, "Should return an array")
	assert_gt(path.size(), 0, "Should return a non-empty path")

func test_stop_all_activity():
	# Test stopping all activity
	rival_hacker_manager.is_active = true
	rival_hacker_manager.rival_hackers_active = []
	
	# Add a proper RivalHacker object
	var mock_hacker = RivalHacker.new()
	mock_hacker.is_alive = true
	rival_hacker_manager.rival_hackers_active.append(mock_hacker)
	
	rival_hacker_manager.stop_all_activity()
	assert_false(rival_hacker_manager.is_active, "Should deactivate")
	assert_false(mock_hacker.is_alive, "Should set hacker to dead")

func test_on_enemy_tower_destroyed():
	# Test enemy tower destruction
	var mock_tower = EnemyTower.new()
	rival_hacker_manager.enemy_towers_placed = [mock_tower]
	
	rival_hacker_manager._on_enemy_tower_destroyed(mock_tower)
	assert_eq(rival_hacker_manager.enemy_towers_placed.size(), 0, "Should remove destroyed tower from list")

func test_on_rival_hacker_destroyed():
	# Test rival hacker destruction
	var mock_hacker = RivalHacker.new()
	rival_hacker_manager.rival_hackers_active = [mock_hacker]
	
	rival_hacker_manager._on_rival_hacker_destroyed(mock_hacker)
	assert_eq(rival_hacker_manager.rival_hackers_active.size(), 0, "Should remove destroyed hacker from list")

func test_on_rival_hacker_tower_attacked():
	# Test rival hacker tower attack
	var mock_tower = Tower.new()
	add_child_autofree(mock_tower)
	var initial_health = mock_tower.health
	
	rival_hacker_manager._on_rival_hacker_tower_attacked(mock_tower, 10)
	
	# The method doesn't actually damage the tower, it just logs the attack
	# So we verify the method executed successfully
	assert_eq(mock_tower.health, initial_health, "Method should not modify tower health directly")
	
	# Test with different damage values
	rival_hacker_manager._on_rival_hacker_tower_attacked(mock_tower, 25)
	assert_eq(mock_tower.health, initial_health, "Method should not modify tower health directly")

func test_attempt_strategic_path_block():
	# Test strategic path blocking
	rival_hacker_manager.grid_manager = grid_manager
	
	var result = rival_hacker_manager._attempt_strategic_path_block()
	assert_true(result is bool, "Should return boolean result")
	
	# If successful, should have blocked cells
	if result:
		assert_gt(rival_hacker_manager.blocked_cells_tracker.size(), 0, "Should track blocked cells")

func test_attempt_strategic_non_path_block():
	# Test strategic non-path blocking
	rival_hacker_manager.grid_manager = grid_manager
	
	var result = rival_hacker_manager._attempt_strategic_non_path_block()
	assert_true(result is bool, "Should return boolean result")
	
	# If successful, should have blocked cells
	if result:
		assert_gt(rival_hacker_manager.blocked_cells_tracker.size(), 0, "Should track blocked cells")

func test_attempt_strategic_unblock():
	# Test strategic unblocking
	rival_hacker_manager.grid_manager = grid_manager
	rival_hacker_manager.blocked_cells_tracker = [Vector2i(5, 5)]
	
	var result = rival_hacker_manager._attempt_strategic_unblock()
	assert_true(result is bool, "Should return boolean result")
	
	# If successful, should have unblocked cells
	if result:
		assert_lt(rival_hacker_manager.blocked_cells_tracker.size(), 1, "Should remove unblocked cells")

func test_force_path_recalculation():
	# Test path recalculation
	rival_hacker_manager.grid_manager = grid_manager
	rival_hacker_manager.wave_manager = wave_manager
	
	rival_hacker_manager._force_path_recalculation()
	assert_true(true, "Should not crash when forcing path recalculation")

func test_get_corridor_cells_around_path():
	# Test corridor cells calculation
	rival_hacker_manager.grid_manager = grid_manager
	
	var path: Array[Vector2i] = [Vector2i(5, 5), Vector2i(6, 6)]
	var corridor = rival_hacker_manager.get_corridor_cells_around_path(path, 2)
	assert_true(corridor is Array, "Should return array of corridor cells")
	assert_gt(corridor.size(), 0, "Should return corridor cells")

func test_find_corridor_limited_path():
	# Test corridor-limited pathfinding
	rival_hacker_manager.grid_manager = grid_manager
	
	var allowed_cells: Array[Vector2i] = [Vector2i(1, 1), Vector2i(2, 2), Vector2i(3, 3)]
	var path = rival_hacker_manager.find_corridor_limited_path(Vector2i(0, 0), Vector2i(3, 3), allowed_cells)
	assert_true(path is Array, "Should return array path")
	# Note: Path finding may return empty array if no valid path exists through allowed cells
	# This is expected behavior when start/end points are not in allowed cells

func test_perform_comprehensive_grid_action():
	# Test comprehensive grid action
	rival_hacker_manager.grid_manager = grid_manager
	
	var initial_action_sequence = rival_hacker_manager.action_sequence
	rival_hacker_manager._perform_comprehensive_grid_action()
	
	# Should increment action sequence
	assert_eq(rival_hacker_manager.action_sequence, initial_action_sequence + 1, "Should increment action sequence")

func test_on_grid_action_timer_timeout():
	# Test grid action timer timeout
	rival_hacker_manager.is_active = true
	rival_hacker_manager.game_manager = game_manager
	rival_hacker_manager.grid_manager = grid_manager
	
	var initial_action_sequence = rival_hacker_manager.action_sequence
	rival_hacker_manager._on_grid_action_timer_timeout()
	
	# Should perform grid action when active
	assert_eq(rival_hacker_manager.action_sequence, initial_action_sequence + 1, "Should perform grid action") 
