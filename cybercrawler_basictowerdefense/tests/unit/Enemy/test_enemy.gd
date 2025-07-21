extends GutTest

# Unit tests for Enemy class
# These tests verify the enemy behavior and functionality

var enemy: Enemy

func before_each():
	# Setup fresh Enemy for each test
	enemy = Enemy.new()
	add_child_autofree(enemy)

func test_initial_state():
	# Test that Enemy starts with correct initial values
	assert_eq(enemy.speed, 100.0, "Should have default speed of 100")
	assert_eq(enemy.health, 3, "Should start with 3 health")
	assert_eq(enemy.max_health, 3, "Should have max health of 3")
	assert_true(enemy.is_alive, "Should start alive")
	assert_false(enemy.paused, "Should not start paused")
	assert_eq(enemy.current_path_index, 0, "Should start at path index 0")
	assert_eq(enemy.path_points.size(), 0, "Should start with no path points")

func test_ready_creates_visual():
	# Test that _ready() creates the visual components
	var child_count_before = enemy.get_child_count()
	enemy._ready()
	
	# Should have created visual elements
	assert_gt(enemy.get_child_count(), child_count_before, "Should create visual children")
	
	# Look for health bar
	var health_bar = enemy.get_node("HealthBar")
	assert_not_null(health_bar, "Should create health bar")

func test_set_path():
	# Test path setting functionality
	var test_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0), Vector2(100, 100)]
	
	enemy.set_path(test_path)
	
	assert_eq(enemy.path_points, test_path, "Should set the path points")
	assert_eq(enemy.current_path_index, 0, "Should start at beginning of path")
	assert_eq(enemy.target_position, test_path[0], "Should target first point")

func test_pause_resume():
	# Test pause and resume functionality
	enemy.pause()
	assert_true(enemy.paused, "Should be paused after pause()")
	
	enemy.resume()
	assert_false(enemy.paused, "Should not be paused after resume()")

func test_take_damage():
	# Test damage system
	watch_signals(enemy)
	var initial_health = enemy.health
	
	enemy.take_damage(1)
	
	assert_eq(enemy.health, initial_health - 1, "Should reduce health by 1")
	assert_true(enemy.is_alive, "Should still be alive after 1 damage")

func test_take_damage_to_death():
	# Test that enemy dies when health reaches 0
	watch_signals(enemy)
	
	enemy.take_damage(3)  # Full health damage
	
	assert_eq(enemy.health, 0, "Should have 0 health")
	assert_false(enemy.is_alive, "Should be dead")
	assert_signal_emitted(enemy, "enemy_died", "Should emit enemy_died signal")

func test_take_damage_when_already_dead():
	# Test that dead enemies don't take more damage
	enemy.is_alive = false
	var initial_health = enemy.health
	
	enemy.take_damage(1)
	
	assert_eq(enemy.health, initial_health, "Dead enemy should not take damage")

func test_die_method():
	# Test the die() method directly
	watch_signals(enemy)
	
	enemy.die()
	
	assert_false(enemy.is_alive, "Should not be alive after die()")
	assert_signal_emitted(enemy, "enemy_died", "Should emit enemy_died signal")

func test_reach_end():
	# Test the reach_end() method
	watch_signals(enemy)
	
	enemy.reach_end()
	
	assert_signal_emitted(enemy, "enemy_reached_end", "Should emit enemy_reached_end signal")

func test_is_clicked_at():
	# Test click detection
	enemy.global_position = Vector2(100, 100)
	
	# Test click within range
	var click_within = enemy.is_clicked_at(Vector2(110, 110))
	assert_true(click_within, "Should detect click within range")
	
	# Test click outside range
	var click_outside = enemy.is_clicked_at(Vector2(200, 200))
	assert_false(click_outside, "Should not detect click outside range")

func test_handle_click_damage():
	# Test click damage handling
	var initial_health = enemy.health
	
	var result = enemy.handle_click_damage()
	
	# Should return true if damage was applied
	assert_true(result is bool, "Should return boolean result")
	
	# If damage was applied, health should be reduced
	if result:
		assert_lt(enemy.health, initial_health, "Health should be reduced if damage applied")

func test_get_health_info():
	# Test health info string
	enemy.health = 2
	enemy.max_health = 3
	
	var health_info = enemy.get_health_info()
	
	assert_true(health_info.contains("2"), "Should contain current health")
	assert_true(health_info.contains("3"), "Should contain max health")
	assert_true(health_info.contains("Health:"), "Should contain 'Health:' label")

func test_physics_process_when_paused():
	# Test that paused enemies don't move
	enemy.paused = true
	enemy.path_points = [Vector2(0, 0), Vector2(100, 0)]
	var initial_pos = enemy.global_position
	
	# Call _physics_process with small delta
	enemy._physics_process(0.016)
	
	# Position should not change when paused
	assert_eq(enemy.global_position, initial_pos, "Should not move when paused")

func test_physics_process_without_path():
	# Test that enemies without path don't move
	enemy.path_points = []
	var initial_pos = enemy.global_position
	
	enemy._physics_process(0.016)
	
	assert_eq(enemy.global_position, initial_pos, "Should not move without path")

func test_physics_process_when_dead():
	# Test that dead enemies don't move
	enemy.is_alive = false
	enemy.path_points = [Vector2(0, 0), Vector2(100, 0)]
	var initial_pos = enemy.global_position
	
	enemy._physics_process(0.016)
	
	assert_eq(enemy.global_position, initial_pos, "Should not move when dead")

func test_update_health_bar():
	# Test health bar visual updates
	enemy._ready()  # Create visual components
	enemy.health = 2
	enemy.max_health = 3
	
	enemy.update_health_bar()
	
	var health_bar = enemy.get_node("HealthBar")
	if health_bar:
		# Health bar width should reflect health percentage
		var expected_width = 32 * (2.0 / 3.0)  # 32 * health_percentage
		assert_almost_eq(health_bar.size.x, expected_width, 1.0, "Health bar width should reflect health")

func test_move_along_path_basic():
	# Test basic path following (without actual movement to avoid complex setup)
	enemy.path_points = [Vector2(0, 0), Vector2(100, 0), Vector2(100, 100)]
	enemy.current_path_index = 0
	enemy.target_position = enemy.path_points[0]
	enemy.global_position = Vector2(0, 0)
	
	# This mainly tests that the method doesn't crash with valid setup
	enemy.move_along_path(0.016)
	
	# Should still be alive and on valid path index
	assert_true(enemy.is_alive, "Should remain alive during path movement")
	assert_gte(enemy.current_path_index, 0, "Path index should remain valid")

func test_path_completion():
	# Test what happens when enemy completes path
	enemy.path_points = [Vector2(0, 0), Vector2(100, 0)]
	enemy.current_path_index = 2  # Beyond path length
	enemy.global_position = Vector2(100, 0)
	watch_signals(enemy)
	
	enemy.move_along_path(0.016)
	
	assert_signal_emitted(enemy, "enemy_reached_end", "Should emit reached_end when path complete")

func test_create_enemy_visual():
	# Test visual creation
	var child_count_before = enemy.get_child_count()
	
	enemy.create_enemy_visual()
	
	assert_gt(enemy.get_child_count(), child_count_before, "Should create visual elements")

func test_create_health_bar():
	# Test health bar creation
	var child_count_before = enemy.get_child_count()
	
	enemy.create_health_bar()
	
	assert_gt(enemy.get_child_count(), child_count_before, "Should create health bar elements")
	
	# Look for the health bar specifically
	var health_bar = enemy.get_node_or_null("HealthBar")
	assert_not_null(health_bar, "Should create HealthBar node") 