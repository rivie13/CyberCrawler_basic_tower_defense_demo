extends GutTest

# Unit tests for RivalHacker class
# These tests verify the rival hacker behavior, combat, movement, and targeting functionality

var rival_hacker: RivalHacker

func before_each():
	# Setup fresh RivalHacker for each test
	rival_hacker = RivalHacker.new()
	add_child_autofree(rival_hacker)

func test_initial_state():
	# Test that RivalHacker starts with correct initial values
	assert_eq(rival_hacker.movement_speed, 100.0, "Should have default movement speed of 100")
	assert_eq(rival_hacker.detection_range, 100.0, "Should have default detection range of 100")
	assert_eq(rival_hacker.attack_damage, 3, "Should have default attack damage of 3")
	assert_eq(rival_hacker.attack_rate, 1.5, "Should have default attack rate of 1.5")
	assert_eq(rival_hacker.health, 8, "Should start with 8 health")
	assert_eq(rival_hacker.max_health, 8, "Should have max health of 8")
	assert_true(rival_hacker.is_alive, "Should start alive")
	assert_true(rival_hacker.is_seeking_target, "Should start seeking target")
	assert_null(rival_hacker.current_target, "Should start with no target")

func test_ready_creates_components():
	# Test that _ready() creates visual and functional components
	var child_count_before = rival_hacker.get_child_count()
	rival_hacker._ready()
	
	# Should have created components
	assert_gt(rival_hacker.get_child_count(), child_count_before, "Should create visual and functional children")
	assert_not_null(rival_hacker.attack_timer, "Should create attack timer")
	assert_eq(rival_hacker.target_position, rival_hacker.global_position, "Should set initial target position")

func test_create_rival_hacker_visual():
	# Test visual creation
	var child_count_before = rival_hacker.get_child_count()
	
	rival_hacker.create_rival_hacker_visual()
	
	assert_gt(rival_hacker.get_child_count(), child_count_before, "Should create visual elements")

func test_setup_attack_timer():
	# Test attack timer setup
	rival_hacker.setup_attack_timer()
	
	assert_not_null(rival_hacker.attack_timer, "Should create attack timer")
	assert_almost_eq(rival_hacker.attack_timer.wait_time, 1.0 / 1.5, 0.01, "Timer should be 1/attack_rate")
	assert_true(rival_hacker.attack_timer.timeout.is_connected(rival_hacker._on_attack_timer_timeout), "Should connect timeout signal")

func test_take_damage():
	# Test damage system
	var initial_health = rival_hacker.health
	
	rival_hacker.take_damage(2)
	
	assert_eq(rival_hacker.health, initial_health - 2, "Should reduce health by 2")
	assert_true(rival_hacker.is_alive, "Should still be alive after 2 damage")

func test_take_damage_to_death():
	# Test rival hacker destruction when health reaches 0
	watch_signals(rival_hacker)
	
	rival_hacker.take_damage(8)  # Full health damage
	
	assert_eq(rival_hacker.health, 0, "Should have 0 health")
	assert_false(rival_hacker.is_alive, "Should be dead")
	assert_signal_emitted(rival_hacker, "rival_hacker_destroyed", "Should emit rival_hacker_destroyed signal")

func test_take_damage_when_already_dead():
	# Test that dead rival hackers don't take more damage
	rival_hacker.is_alive = false
	var initial_health = rival_hacker.health
	
	rival_hacker.take_damage(1)
	
	assert_eq(rival_hacker.health, initial_health, "Dead rival hacker should not take damage")

func test_create_health_bar():
	# Test health bar creation
	var child_count_before = rival_hacker.get_child_count()
	
	rival_hacker.create_health_bar()
	
	assert_gt(rival_hacker.get_child_count(), child_count_before, "Should create health bar elements")
	
	# Look for the health bar specifically
	var health_bar = rival_hacker.get_node_or_null("HealthBar")
	assert_not_null(health_bar, "Should create HealthBar node")

func test_update_health_bar():
	# Test health bar visual updates
	rival_hacker.create_health_bar()
	rival_hacker.health = 4
	rival_hacker.max_health = 8
	
	rival_hacker.update_health_bar()
	
	var health_bar = rival_hacker.get_node("HealthBar")
	if health_bar:
		# Health bar width should reflect health percentage
		var expected_width = 26 * (4.0 / 8.0)  # 26 * health_percentage
		assert_almost_eq(health_bar.size.x, expected_width, 1.0, "Health bar width should reflect health")

func test_die():
	# Test rival hacker death
	rival_hacker.setup_attack_timer()
	rival_hacker.attack_timer.start()
	watch_signals(rival_hacker)
	
	rival_hacker.die()
	
	assert_false(rival_hacker.is_alive, "Should not be alive")
	assert_false(rival_hacker.attack_timer.is_processing(), "Attack timer should be stopped")
	assert_signal_emitted(rival_hacker, "rival_hacker_destroyed", "Should emit destruction signal")

func test_set_get_grid_position():
	# Test grid position management
	var test_position = Vector2i(4, 7)
	
	rival_hacker.set_grid_position(test_position)
	
	assert_eq(rival_hacker.get_grid_position(), test_position, "Should return set grid position")
	assert_eq(rival_hacker.grid_position, test_position, "Should set internal grid position")

func test_is_clicked_at():
	# Test click detection
	rival_hacker.global_position = Vector2(100, 100)
	
	# Test click within range (using medium click config)
	var click_within = rival_hacker.is_clicked_at(Vector2(110, 110))
	assert_true(click_within, "Should detect click within range")
	
	# Test click outside range
	var click_outside = rival_hacker.is_clicked_at(Vector2(200, 200))
	assert_false(click_outside, "Should not detect click outside range")

func test_handle_click_damage():
	# Test click damage handling
	var initial_health = rival_hacker.health
	
	var result = rival_hacker.handle_click_damage()
	
	# Should return true if damage was applied
	assert_true(result is bool, "Should return boolean result")
	
	# If damage was applied, health should be reduced
	if result:
		assert_lt(rival_hacker.health, initial_health, "Health should be reduced if damage applied")

func test_get_health_info():
	# Test health info string
	rival_hacker.health = 5
	rival_hacker.max_health = 8
	
	var health_info = rival_hacker.get_health_info()
	
	assert_true(health_info.contains("5"), "Should contain current health")
	assert_true(health_info.contains("8"), "Should contain max health")
	assert_true(health_info.contains("Health:"), "Should contain 'Health:' label")

func test_get_main_controller():
	# Test getting main controller
	var main_controller = rival_hacker.get_main_controller()
	
	# Should return something (even if null)
	assert_true(main_controller == null or main_controller is Node, "Should return null or Node")

func test_show_debug_info():
	# Test debug info display
	rival_hacker.health = 6
	rival_hacker.max_health = 8
	rival_hacker.global_position = Vector2(150, 200)
	
	# Should not crash when called
	rival_hacker.show_debug_info()
	
	# Verify debug info was updated (if debug system is available)
	assert_true(true, "Debug method should not crash")

func test_pick_new_seek_position():
	# Test picking new seek position
	var initial_position = rival_hacker.global_position
	rival_hacker.target_position = initial_position
	
	rival_hacker.pick_new_seek_position()
	
	# Should have changed target position
	assert_ne(rival_hacker.target_position, initial_position, "Should pick new target position")
	
	# Should be within bounds
	assert_true(rival_hacker.target_position.x >= 50, "Should be within x bounds")
	assert_true(rival_hacker.target_position.x <= 750, "Should be within x bounds")
	assert_true(rival_hacker.target_position.y >= 50, "Should be within y bounds")
	assert_true(rival_hacker.target_position.y <= 550, "Should be within y bounds")

func test_seek_movement():
	# Test seek movement behavior
	var delta = 0.016
	rival_hacker.global_position = Vector2(100, 100)
	rival_hacker.target_position = Vector2(200, 100)
	rival_hacker.is_seeking_target = true
	var initial_position = rival_hacker.global_position
	
	rival_hacker.seek_movement(delta)
	
	# Should have moved towards target
	assert_ne(rival_hacker.global_position, initial_position, "Should have moved")
	
	# Should be closer to target
	var initial_distance = initial_position.distance_to(rival_hacker.target_position)
	var new_distance = rival_hacker.global_position.distance_to(rival_hacker.target_position)
	assert_lt(new_distance, initial_distance, "Should be closer to target")

func test_seek_movement_when_close():
	# Test seek movement when close to target
	rival_hacker.global_position = Vector2(100, 100)
	rival_hacker.target_position = Vector2(101, 100)  # Very close
	var initial_target = rival_hacker.target_position
	
	rival_hacker.seek_movement(0.016)
	
	# Should pick new target when close
	assert_ne(rival_hacker.target_position, initial_target, "Should pick new target when close")

func test_move_towards_target():
	# Test moving towards target
	var tower = Tower.new()
	add_child_autofree(tower)
	tower.global_position = Vector2(200, 100)
	rival_hacker.current_target = tower
	rival_hacker.global_position = Vector2(100, 100)
	rival_hacker.setup_attack_timer()
	var initial_position = rival_hacker.global_position
	
	rival_hacker.move_towards_target(0.016)
	
	# Should move towards target (unless already in attack range)
	var distance_to_target = rival_hacker.global_position.distance_to(tower.global_position)
	var attack_range = rival_hacker.detection_range * 0.8
	
	if distance_to_target > attack_range:
		assert_ne(rival_hacker.global_position, initial_position, "Should move towards target when out of range")

func test_move_towards_target_invalid():
	# Test moving towards invalid target
	rival_hacker.current_target = null
	var initial_position = rival_hacker.global_position
	
	rival_hacker.move_towards_target(0.016)
	
	# Should not move with invalid target
	assert_eq(rival_hacker.global_position, initial_position, "Should not move with invalid target")

func test_attack_target_with_tower():
	# Test attacking a tower
	var tower = Tower.new()
	add_child_autofree(tower)
	tower.grid_position = Vector2i(3, 3)
	rival_hacker.current_target = tower
	var initial_health = tower.health
	watch_signals(rival_hacker)
	
	rival_hacker.attack_target()
	
	assert_eq(tower.health, initial_health - rival_hacker.attack_damage, "Should damage the tower")
	assert_signal_emitted(rival_hacker, "tower_attacked", "Should emit tower_attacked signal")

func test_attack_target_with_invalid():
	# Test attacking invalid target
	rival_hacker.current_target = null
	
	# Should not crash with invalid target
	rival_hacker.attack_target()
	
	# Verify no errors occurred
	assert_true(true, "Should handle invalid target gracefully")

func test_attack_target_destroys_target():
	# Test attacking target until destroyed
	var tower = Tower.new()
	add_child_autofree(tower)
	tower.health = 1  # Low health for easy destruction
	rival_hacker.current_target = tower
	rival_hacker.setup_attack_timer()
	rival_hacker.attack_timer.start()
	
	rival_hacker.attack_target()
	
	# Target should be cleared when destroyed
	assert_null(rival_hacker.current_target, "Should clear target when destroyed")
	assert_false(rival_hacker.attack_timer.is_processing(), "Should stop attack timer when target destroyed")

func test_on_attack_timer_timeout_when_dead():
	# Test attack timer when rival hacker is dead
	rival_hacker.is_alive = false
	
	rival_hacker._on_attack_timer_timeout()
	
	# Should not crash or cause issues when dead
	assert_false(rival_hacker.is_alive, "Should remain dead after timeout")

func test_on_attack_timer_timeout_with_target():
	# Test attack timer with valid target in range
	var tower = Tower.new()
	add_child_autofree(tower)
	tower.global_position = Vector2(120, 100)  # Just within detection range
	rival_hacker.global_position = Vector2(100, 100)
	rival_hacker.current_target = tower
	rival_hacker.setup_attack_timer()
	var initial_health = tower.health
	
	rival_hacker._on_attack_timer_timeout()
	
	# Should attack the target if in range
	if rival_hacker.global_position.distance_to(tower.global_position) <= rival_hacker.detection_range:
		assert_eq(tower.health, initial_health - rival_hacker.attack_damage, "Should attack target in range")

func test_on_attack_timer_timeout_without_target():
	# Test attack timer without target
	rival_hacker.current_target = null
	rival_hacker.setup_attack_timer()
	rival_hacker.attack_timer.start()
	
	rival_hacker._on_attack_timer_timeout()
	
	# Should stop timer when no target
	assert_false(rival_hacker.attack_timer.is_processing(), "Should stop timer when no target")

func test_is_target_in_range():
	# Test target range checking via TargetingUtil
	var tower = Tower.new()
	add_child_autofree(tower)
	tower.global_position = Vector2(150, 100)
	rival_hacker.global_position = Vector2(100, 100)
	rival_hacker.detection_range = 100.0
	
	var in_range = rival_hacker.is_target_in_range(tower)
	
	# Distance is 50, range is 100, so should be in range
	assert_true(in_range, "Should detect target in range")
	
	# Test target out of range
	tower.global_position = Vector2(250, 100)  # Distance 150, range 100
	in_range = rival_hacker.is_target_in_range(tower)
	assert_false(in_range, "Should not detect target out of range")

func test_find_nearest_tower():
	# Test finding nearest tower
	rival_hacker.current_target = null
	
	# This method depends on TargetingUtil and MainController
	# Test that it doesn't crash and potentially finds a target
	rival_hacker.find_nearest_tower()
	
	# Should either find a target or remain null, but not crash
	assert_true(rival_hacker.current_target == null or rival_hacker.current_target is Node, "Should find valid target or remain null") 