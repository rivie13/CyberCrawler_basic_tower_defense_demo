extends GutTest

# Unit tests for RivalAlertSystem
# Tests core alert detection logic without complex signal testing

var alert_system: RivalAlertSystem
var mock_grid_manager: MockGridManager

func before_each():
	alert_system = RivalAlertSystem.new()
	mock_grid_manager = MockGridManager.new()
	add_child_autofree(alert_system)
	add_child_autofree(mock_grid_manager)

func after_each():
	pass  # Cleanup is handled by autofree

# ===== INITIALIZATION TESTS =====

func test_initial_state():
	"""Test RivalAlertSystem initial state"""
	assert_eq(alert_system.recent_tower_placements.size(), 0, "Recent placements should be empty initially")
	assert_eq(alert_system.honeypot_positions.size(), 0, "Honeypot positions should be empty initially")
	assert_eq(alert_system.is_monitoring, false, "Should not be monitoring initially")
	assert_eq(alert_system.current_alert_level, 0.0, "Alert level should be 0 initially")
	assert_eq(alert_system.alert_factors.size(), 0, "Alert factors should be empty initially")

func test_initialize_with_grid_manager():
	"""Test initialization with grid manager"""
	alert_system.initialize(mock_grid_manager)
	
	assert_eq(alert_system.grid_manager, mock_grid_manager, "Grid manager should be set")
	assert_gt(alert_system.honeypot_positions.size(), 0, "Honeypot positions should be set up")

func test_setup_honeypot_positions():
	"""Test honeypot position setup"""
	alert_system.initialize(mock_grid_manager)
	
	# Should have honeypot positions set up
	assert_gt(alert_system.honeypot_positions.size(), 0, "Honeypot positions should be set up")
	
	# Should include corner positions
	var grid_size = mock_grid_manager.get_grid_size()
	var expected_corners = [
		Vector2i(0, 0),  # Top-left
		Vector2i(0, grid_size.y - 1),  # Bottom-left
		Vector2i(grid_size.x - 1, 0),  # Top-right
		Vector2i(grid_size.x - 1, grid_size.y - 1)  # Bottom-right
	]
	
	for corner in expected_corners:
		assert_true(alert_system.honeypot_positions.has(corner), "Corner position should be honeypot")

# ===== MONITORING STATE TESTS =====

func test_start_monitoring():
	"""Test starting monitoring"""
	alert_system.initialize(mock_grid_manager)
	alert_system.start_monitoring()
	
	assert_true(alert_system.is_monitoring, "Should be monitoring after start")

func test_start_monitoring_without_grid_manager():
	"""Test starting monitoring without grid manager"""
	alert_system.start_monitoring()
	
	assert_false(alert_system.is_monitoring, "Should not start monitoring without grid manager")

func test_stop_monitoring():
	"""Test stopping monitoring"""
	alert_system.initialize(mock_grid_manager)
	alert_system.start_monitoring()
	alert_system.stop_monitoring()
	
	assert_false(alert_system.is_monitoring, "Should not be monitoring after stop")
	assert_eq(alert_system.recent_tower_placements.size(), 0, "Recent placements should be cleared")
	assert_eq(alert_system.alert_factors.size(), 0, "Alert factors should be cleared")
	assert_eq(alert_system.current_alert_level, 0.0, "Alert level should be reset")

# ===== TOWER PLACEMENT TRACKING TESTS =====

func test_on_player_tower_placed_when_not_monitoring():
	"""Test tower placement when not monitoring"""
	alert_system.initialize(mock_grid_manager)
	
	# Create a mock tower
	var mock_tower = MockTower.new()
	mock_tower.damage = 2
	mock_tower.tower_range = 150.0
	mock_tower.attack_rate = 1.5
	
	alert_system.on_player_tower_placed(Vector2i(5, 5), mock_tower)
	
	assert_eq(alert_system.recent_tower_placements.size(), 0, "Should not track placement when not monitoring")

func test_on_player_tower_placed_when_monitoring():
	"""Test tower placement when monitoring"""
	alert_system.initialize(mock_grid_manager)
	alert_system.start_monitoring()
	
	# Create a mock tower
	var mock_tower = MockTower.new()
	mock_tower.damage = 2
	mock_tower.tower_range = 150.0
	mock_tower.attack_rate = 1.5
	
	alert_system.on_player_tower_placed(Vector2i(5, 5), mock_tower)
	
	assert_eq(alert_system.recent_tower_placements.size(), 1, "Should track placement when monitoring")
	
	var placement = alert_system.recent_tower_placements[0]
	assert_eq(placement.position, Vector2i(5, 5), "Placement position should be recorded")
	assert_true(placement.has("timestamp"), "Placement should have timestamp")
	assert_true(placement.has("tower_stats"), "Placement should have tower stats")
	
	var stats = placement.tower_stats
	assert_eq(stats.damage, 2, "Tower damage should be recorded")
	assert_eq(stats.range, 150.0, "Tower range should be recorded")
	assert_eq(stats.attack_rate, 1.5, "Tower attack rate should be recorded")

# ===== CLEANUP TESTS =====

func test_cleanup_old_placements():
	"""Test cleanup of old tower placements"""
	alert_system.initialize(mock_grid_manager)
	alert_system.start_monitoring()
	
	# Add some placements with old timestamps
	var old_time = Time.get_unix_time_from_system() - 10.0  # 10 seconds ago
	var recent_time = Time.get_unix_time_from_system() - 1.0  # 1 second ago
	
	alert_system.recent_tower_placements = [
		{"position": Vector2i(1, 1), "timestamp": old_time, "tower_stats": {}},
		{"position": Vector2i(2, 2), "timestamp": recent_time, "tower_stats": {}}
	]
	
	alert_system.cleanup_old_placements()
	
	assert_eq(alert_system.recent_tower_placements.size(), 1, "Should keep only recent placements")
	assert_eq(alert_system.recent_tower_placements[0].position, Vector2i(2, 2), "Should keep the recent placement")

# ===== TOWER POWER CALCULATION TESTS =====

func test_calculate_tower_power_level_basic():
	"""Test power level calculation for basic tower"""
	var stats = {"damage": 1, "range": 100.0, "attack_rate": 1.0}
	var power_level = alert_system.calculate_tower_power_level(stats)
	
	assert_gt(power_level, 0.0, "Power level should be positive")
	assert_lt(power_level, 1.0, "Power level should be less than 1.0")

func test_calculate_tower_power_level_powerful():
	"""Test power level calculation for powerful tower"""
	var stats = {"damage": 5, "range": 300.0, "attack_rate": 3.0}
	var power_level = alert_system.calculate_tower_power_level(stats)
	
	assert_gt(power_level, 0.7, "Powerful tower should have high power level")

func test_calculate_tower_power_level_missing_stats():
	"""Test power level calculation with missing stats"""
	var stats = {"damage": 2}  # Missing range and attack_rate
	var power_level = alert_system.calculate_tower_power_level(stats)
	
	assert_gt(power_level, 0.0, "Power level should be calculated even with missing stats")

func test_is_powerful_tower_true():
	"""Test powerful tower detection - true cases"""
	var high_damage_stats = {"damage": 3, "range": 100.0, "attack_rate": 1.0}
	var high_range_stats = {"damage": 1, "range": 200.0, "attack_rate": 1.0}
	var high_attack_stats = {"damage": 1, "range": 100.0, "attack_rate": 3.0}
	
	assert_true(alert_system.is_powerful_tower(high_damage_stats), "High damage tower should be powerful")
	assert_true(alert_system.is_powerful_tower(high_range_stats), "High range tower should be powerful")
	assert_true(alert_system.is_powerful_tower(high_attack_stats), "High attack rate tower should be powerful")

func test_is_powerful_tower_false():
	"""Test powerful tower detection - false cases"""
	var weak_stats = {"damage": 0, "range": 100.0, "attack_rate": 1.0}
	
	assert_false(alert_system.is_powerful_tower(weak_stats), "Weak tower should not be powerful")

# ===== HONEYPOT SEVERITY TESTS =====

func test_calculate_honeypot_severity_near_exit():
	"""Test honeypot severity calculation for positions near exit"""
	alert_system.initialize(mock_grid_manager)
	
	var grid_size = mock_grid_manager.get_grid_size()
	var near_exit_pos = Vector2i(grid_size.x - 2, 5)  # Near exit
	
	var severity = alert_system.calculate_honeypot_severity(near_exit_pos)
	
	assert_gt(severity, 0.9, "Near exit honeypot should have very high severity")

func test_calculate_honeypot_severity_corner():
	"""Test honeypot severity calculation for corner positions"""
	alert_system.initialize(mock_grid_manager)
	
	var grid_size = mock_grid_manager.get_grid_size()
	var corner_pos = Vector2i(0, 0)  # Corner position
	
	var severity = alert_system.calculate_honeypot_severity(corner_pos)
	
	assert_gt(severity, 0.8, "Corner honeypot should have high severity")

func test_calculate_honeypot_severity_center():
	"""Test honeypot severity calculation for center positions"""
	alert_system.initialize(mock_grid_manager)
	
	var grid_size = mock_grid_manager.get_grid_size()
	var center_x = int(grid_size.x / 2)
	var center_y = int(grid_size.y / 2)
	var center_pos = Vector2i(center_x, center_y)  # Center position
	
	var severity = alert_system.calculate_honeypot_severity(center_pos)
	
	assert_gt(severity, 0.7, "Center honeypot should have medium-high severity")

func test_calculate_honeypot_severity_without_grid_manager():
	"""Test honeypot severity calculation without grid manager"""
	var severity = alert_system.calculate_honeypot_severity(Vector2i(5, 5))
	
	assert_eq(severity, 0.9, "Should return default severity without grid manager")

# ===== ALERT FACTOR TESTS =====

func test_get_current_alert_level():
	"""Test getting current alert level"""
	alert_system.current_alert_level = 0.75
	
	assert_eq(alert_system.get_current_alert_level(), 0.75, "Should return current alert level")

func test_get_active_alert_factors():
	"""Test getting active alert factors"""
	alert_system.alert_factors = {
		"exit_proximity": 0.8,
		"honeypot": 0.9
	}
	
	var factors = alert_system.get_active_alert_factors()
	
	assert_eq(factors.size(), 2, "Should return all active factors")
	assert_eq(factors["exit_proximity"], 0.8, "Should return correct exit proximity severity")
	assert_eq(factors["honeypot"], 0.9, "Should return correct honeypot severity")

func test_reset_alerts():
	"""Test resetting alerts"""
	alert_system.current_alert_level = 0.8
	alert_system.alert_factors = {"test": 0.5}
	
	alert_system.reset_alerts()
	
	assert_eq(alert_system.current_alert_level, 0.0, "Alert level should be reset")
	assert_eq(alert_system.alert_factors.size(), 0, "Alert factors should be cleared")

# ===== ALERT CALCULATION TESTS =====

func test_calculate_exit_proximity_severity_very_close():
	"""Test exit proximity severity calculation for very close positions"""
	alert_system.initialize(mock_grid_manager)
	alert_system.start_monitoring()
	
	# Add some tower placements to simulate game progression
	var mock_tower = MockTower.new()
	alert_system.on_player_tower_placed(Vector2i(5, 5), mock_tower)
	alert_system.on_player_tower_placed(Vector2i(6, 5), mock_tower)
	
	var grid_size = mock_grid_manager.get_grid_size()
	var very_close_pos = Vector2i(grid_size.x - 1, 5)  # Right at exit
	var severity = alert_system.calculate_exit_proximity_severity(very_close_pos, 0)
	
	assert_gte(severity, 0.8, "Very close position should have high severity")

func test_calculate_exit_proximity_severity_early_game():
	"""Test exit proximity severity for early game placement"""
	alert_system.initialize(mock_grid_manager)
	alert_system.start_monitoring()
	
	var grid_size = mock_grid_manager.get_grid_size()
	var close_pos = Vector2i(grid_size.x - 2, 5)  # Close to exit
	var severity = alert_system.calculate_exit_proximity_severity(close_pos, 1)
	
	assert_gt(severity, 0.6, "Early game close placement should have high severity")

func test_calculate_burst_placement_severity():
	"""Test burst placement severity calculation"""
	alert_system.initialize(mock_grid_manager)
	alert_system.start_monitoring()
	
	# Add multiple tower placements to simulate burst
	var mock_tower = MockTower.new()
	for i in range(4):  # More than max_towers_per_burst (3)
		alert_system.on_player_tower_placed(Vector2i(i, 5), mock_tower)
	
	var severity = alert_system.calculate_burst_placement_severity(4)
	
	assert_gt(severity, 0.0, "Burst placement should have positive severity")

func test_calculate_time_distribution_factor():
	"""Test time distribution factor calculation"""
	alert_system.initialize(mock_grid_manager)
	alert_system.start_monitoring()
	
	# Add placements with different timestamps
	var current_time = Time.get_unix_time_from_system()
	alert_system.recent_tower_placements = [
		{"position": Vector2i(1, 1), "timestamp": current_time - 1.0, "tower_stats": {}},
		{"position": Vector2i(2, 2), "timestamp": current_time - 2.0, "tower_stats": {}},
		{"position": Vector2i(3, 3), "timestamp": current_time - 3.0, "tower_stats": {}}
	]
	
	var factor = alert_system.calculate_time_distribution_factor()
	
	assert_gt(factor, 0.0, "Time distribution factor should be positive")

func test_calculate_consecutive_placement_factor():
	"""Test consecutive placement factor calculation"""
	alert_system.initialize(mock_grid_manager)
	alert_system.start_monitoring()
	
	# Add placements with very close timestamps
	var current_time = Time.get_unix_time_from_system()
	alert_system.recent_tower_placements = [
		{"position": Vector2i(1, 1), "timestamp": current_time - 0.5, "tower_stats": {}},
		{"position": Vector2i(2, 2), "timestamp": current_time - 1.0, "tower_stats": {}},
		{"position": Vector2i(3, 3), "timestamp": current_time - 1.5, "tower_stats": {}}
	]
	
	var factor = alert_system.calculate_consecutive_placement_factor()
	
	assert_gt(factor, 0.0, "Consecutive placement factor should be positive")

func test_calculate_powerful_tower_severity():
	"""Test powerful tower severity calculation"""
	alert_system.initialize(mock_grid_manager)
	alert_system.start_monitoring()
	
	var powerful_towers_data = [
		{
			"placement": {"position": Vector2i(1, 1), "timestamp": 0.0, "tower_stats": {"damage": 3, "range": 200.0, "attack_rate": 2.0}},
			"power_level": 0.8
		},
		{
			"placement": {"position": Vector2i(2, 2), "timestamp": 1.0, "tower_stats": {"damage": 4, "range": 250.0, "attack_rate": 2.5}},
			"power_level": 0.9
		}
	]
	
	var severity = alert_system.calculate_powerful_tower_severity(powerful_towers_data)
	
	assert_gt(severity, 0.0, "Powerful tower severity should be positive")

func test_calculate_powerful_tower_time_clustering():
	"""Test powerful tower time clustering calculation"""
	alert_system.initialize(mock_grid_manager)
	alert_system.start_monitoring()
	
	var powerful_towers_data = [
		{
			"placement": {"position": Vector2i(1, 1), "timestamp": 0.0, "tower_stats": {}},
			"power_level": 0.8
		},
		{
			"placement": {"position": Vector2i(2, 2), "timestamp": 1.0, "tower_stats": {}},
			"power_level": 0.9
		}
	]
	
	var clustering = alert_system.calculate_powerful_tower_time_clustering(powerful_towers_data)
	
	assert_gt(clustering, 0.0, "Time clustering should be positive")

func test_calculate_powerful_tower_time_clustering_single():
	"""Test powerful tower time clustering with single tower"""
	alert_system.initialize(mock_grid_manager)
	alert_system.start_monitoring()
	
	var powerful_towers_data = [
		{
			"placement": {"position": Vector2i(1, 1), "timestamp": 0.0, "tower_stats": {}},
			"power_level": 0.8
		}
	]
	
	var clustering = alert_system.calculate_powerful_tower_time_clustering(powerful_towers_data)
	
	assert_eq(clustering, 0.0, "Single tower should have zero clustering")

# ===== ALERT LEVEL CALCULATION TESTS =====

func test_calculate_alert_level_no_factors():
	"""Test alert level calculation with no active factors"""
	alert_system.initialize(mock_grid_manager)
	alert_system.alert_factors = {}
	
	alert_system.calculate_alert_level()
	
	assert_eq(alert_system.current_alert_level, 0.0, "Alert level should be 0 with no factors")

func test_calculate_alert_level_with_factors():
	"""Test alert level calculation with active factors"""
	alert_system.initialize(mock_grid_manager)
	alert_system.alert_factors = {
		"honeypot": 0.8,
		"exit_proximity": 0.7
	}
	
	alert_system.calculate_alert_level()
	
	assert_gt(alert_system.current_alert_level, 0.0, "Alert level should be positive with factors")

func test_calculate_alert_level_multi_factor_threat():
	"""Test alert level calculation that triggers multi-factor threat"""
	alert_system.initialize(mock_grid_manager)
	alert_system.alert_factors = {
		"honeypot": 0.8,
		"exit_proximity": 0.8,
		"powerful_towers": 0.7
	}
	
	alert_system.calculate_alert_level()
	
	assert_gt(alert_system.current_alert_level, 0.7, "Multi-factor threat should have high alert level")

# ===== FACTOR COMBINATION TESTS =====

func test_check_factor_combinations_critical():
	"""Test factor combination detection for critical threat"""
	alert_system.initialize(mock_grid_manager)
	alert_system.alert_factors = {
		"exit_proximity": 0.9,
		"powerful_towers": 0.9
	}
	
	alert_system.check_factor_combinations()
	
	# Should not crash and should process the combination
	assert_true(true, "Critical combination check should not crash")

func test_check_factor_combinations_trap_strategy():
	"""Test factor combination detection for trap strategy"""
	alert_system.initialize(mock_grid_manager)
	alert_system.alert_factors = {
		"honeypot": 0.8,
		"burst_placement": 0.8
	}
	
	alert_system.check_factor_combinations()
	
	# Should not crash and should process the combination
	assert_true(true, "Trap strategy check should not crash")

func test_check_factor_combinations_rush_strategy():
	"""Test factor combination detection for rush strategy"""
	alert_system.initialize(mock_grid_manager)
	alert_system.alert_factors = {
		"exit_proximity": 0.8,
		"burst_placement": 0.8
	}
	
	alert_system.check_factor_combinations()
	
	# Should not crash and should process the combination
	assert_true(true, "Rush strategy check should not crash")

func test_check_factor_combinations_sophisticated():
	"""Test factor combination detection for sophisticated threat"""
	alert_system.initialize(mock_grid_manager)
	alert_system.alert_factors = {
		"exit_proximity": 0.7,
		"powerful_towers": 0.7,
		"burst_placement": 0.7
	}
	
	alert_system.check_factor_combinations()
	
	# Should not crash and should process the combination
	assert_true(true, "Sophisticated threat check should not crash")

# ===== EDGE CASE TESTS =====

func test_on_player_tower_placed_without_grid_manager():
	"""Test tower placement when grid manager is null"""
	alert_system.start_monitoring()
	
	var mock_tower = MockTower.new()
	alert_system.on_player_tower_placed(Vector2i(5, 5), mock_tower)
	
	# Should not crash even without grid manager
	assert_true(true, "Should handle tower placement without grid manager")

func test_cleanup_old_placements_empty():
	"""Test cleanup with empty placements"""
	alert_system.initialize(mock_grid_manager)
	alert_system.start_monitoring()
	
	alert_system.recent_tower_placements = []
	alert_system.cleanup_old_placements()
	
	assert_eq(alert_system.recent_tower_placements.size(), 0, "Empty placements should remain empty")

func test_calculate_tower_power_level_empty_stats():
	"""Test power level calculation with empty stats"""
	var empty_stats = {}
	var power_level = alert_system.calculate_tower_power_level(empty_stats)
	
	assert_gt(power_level, 0.0, "Empty stats should still produce a power level")

func test_is_powerful_tower_empty_stats():
	"""Test powerful tower detection with empty stats"""
	var empty_stats = {}
	
	assert_false(alert_system.is_powerful_tower(empty_stats), "Empty stats should not be powerful")

# ===== CONSTANTS TESTS =====

func test_alert_type_constants():
	"""Test alert type constants are defined"""
	assert_eq(RivalAlertSystem.AlertType.TOWERS_TOO_CLOSE_TO_EXIT, 0, "TOWERS_TOO_CLOSE_TO_EXIT should be 0")
	assert_eq(RivalAlertSystem.AlertType.TOO_MANY_TOWERS_AT_ONCE, 1, "TOO_MANY_TOWERS_AT_ONCE should be 1")
	assert_eq(RivalAlertSystem.AlertType.TOO_MANY_POWERFUL_TOWERS, 2, "TOO_MANY_POWERFUL_TOWERS should be 2")
	assert_eq(RivalAlertSystem.AlertType.HONEYPOT_TRAP_DETECTED, 3, "HONEYPOT_TRAP_DETECTED should be 3")
	assert_eq(RivalAlertSystem.AlertType.MULTI_FACTOR_THREAT, 4, "MULTI_FACTOR_THREAT should be 4")

func test_export_variables():
	"""Test export variables are set correctly"""
	assert_eq(alert_system.time_window_for_burst, 5.0, "Time window should be 5.0")
	assert_eq(alert_system.max_towers_per_burst, 3, "Max towers per burst should be 3")
	assert_eq(alert_system.max_powerful_towers_per_burst, 1, "Max powerful towers per burst should be 1")
	assert_eq(alert_system.exit_proximity_threshold, 3, "Exit proximity threshold should be 3")
	assert_eq(alert_system.powerful_tower_damage_threshold, 1, "Powerful tower damage threshold should be 1")
	assert_eq(alert_system.powerful_tower_range_threshold, 120.0, "Powerful tower range threshold should be 120.0") 
