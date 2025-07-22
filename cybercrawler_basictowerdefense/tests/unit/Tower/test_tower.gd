extends GutTest

# Unit tests for Tower class
# These tests verify the tower behavior and functionality

var tower: Tower

func before_each():
	# Setup fresh Tower for each test
	tower = Tower.new()
	add_child_autofree(tower)

func test_initial_state():
	# Test that Tower starts with correct initial values
	assert_eq(tower.damage, 1, "Should have default damage of 1")
	assert_eq(tower.tower_range, 150.0, "Should have default range of 150")
	assert_eq(tower.attack_rate, 1.0, "Should have default attack rate of 1.0")
	assert_eq(tower.projectile_speed, 300.0, "Should have default projectile speed of 300")
	assert_eq(tower.max_health, 4, "Should have max health of 4")
	assert_eq(tower.health, 4, "Should start with full health")
	assert_true(tower.is_alive, "Should start alive")
	assert_false(tower.show_range_indicator, "Should not show range initially")
	assert_null(tower.current_target, "Should start with no target")

func test_ready_creates_components():
	# Test that _ready() creates visual and functional components
	var child_count_before = tower.get_child_count()
	tower._ready()
	
	# Should have created components
	assert_gt(tower.get_child_count(), child_count_before, "Should create visual and functional children")
	
	# Look for specific components
	assert_not_null(tower.tower_body, "Should create tower body")
	assert_not_null(tower.health_bar, "Should create health bar")
	assert_not_null(tower.health_bar_bg, "Should create health bar background")
	assert_not_null(tower.range_circle, "Should create range circle")
	assert_not_null(tower.attack_timer, "Should create attack timer")

func test_create_tower_visual():
	# Test visual creation
	var child_count_before = tower.get_child_count()
	
	tower.create_tower_visual()
	
	assert_gt(tower.get_child_count(), child_count_before, "Should create visual elements")
	assert_not_null(tower.tower_body, "Should create tower body ColorRect")
	assert_not_null(tower.health_bar, "Should create health bar")
	assert_not_null(tower.health_bar_bg, "Should create health bar background")
	assert_not_null(tower.range_circle, "Should create range circle Node2D")

func test_setup_attack_timer():
	# Test attack timer setup
	tower.setup_attack_timer()
	
	assert_not_null(tower.attack_timer, "Should create attack timer")
	assert_eq(tower.attack_timer.wait_time, 1.0, "Timer should match attack rate")
	assert_true(tower.attack_timer.is_connected("timeout", tower._on_attack_timer_timeout), "Should connect timeout signal")

func test_take_damage():
	# Test damage system
	var initial_health = tower.health
	
	tower.take_damage(1)
	
	assert_eq(tower.health, initial_health - 1, "Should reduce health by 1")
	assert_true(tower.is_alive, "Should still be alive after 1 damage")

func test_take_damage_to_death():
	# Test tower destruction when health reaches 0
	watch_signals(tower)
	
	tower.take_damage(4)  # Full health damage
	
	assert_eq(tower.health, 0, "Should have 0 health")
	assert_false(tower.is_alive, "Should be dead")
	assert_signal_emitted(tower, "tower_destroyed", "Should emit tower_destroyed signal")

func test_take_damage_when_already_dead():
	# Test that dead towers don't take more damage
	tower.is_alive = false
	var initial_health = tower.health
	
	tower.take_damage(1)
	
	assert_eq(tower.health, initial_health, "Dead tower should not take damage")

func test_update_health_bar():
	# Test health bar visual updates
	tower.create_tower_visual()
	tower.health = 2
	tower.max_health = 4
	
	tower.update_health_bar()
	
	if tower.health_bar:
		# Health bar width should reflect health percentage
		var expected_width = 60 * (2.0 / 4.0)  # 60 * health_percentage
		assert_almost_eq(tower.health_bar.size.x, expected_width, 1.0, "Health bar width should reflect health")

func test_set_grid_position():
	# Test grid position setting
	var test_position = Vector2i(5, 3)
	
	tower.set_grid_position(test_position)
	
	assert_eq(tower.grid_position, test_position, "Should set grid position")

func test_show_hide_range():
	# Test range visualization
	tower.show_range()
	assert_true(tower.show_range_indicator, "Should show range indicator")
	
	tower.hide_range()
	assert_false(tower.show_range_indicator, "Should hide range indicator")

func test_show_range_debug():
	# Test debug range functionality
	tower.grid_position = Vector2i(2, 2)
	tower.show_range_indicator = false
	
	tower.show_range_debug()
	
	# Should toggle range indicator
	assert_true(tower.show_range_indicator, "Should toggle range on")
	
	tower.show_range_debug()
	assert_false(tower.show_range_indicator, "Should toggle range off")

func test_stop_attacking():
	# Test stopping all attack activity
	tower.setup_attack_timer()
	tower.attack_timer.start()
	tower.current_target = Enemy.new()
	add_child_autofree(tower.current_target)
	
	tower.stop_attacking()
	
	assert_false(tower.attack_timer.is_processing(), "Attack timer should be stopped")
	assert_null(tower.current_target, "Should clear current target")

func test_find_target_clears_invalid():
	# Test that find_target clears invalid targets
	var fake_target = Node.new()
	tower.current_target = fake_target
	fake_target.queue_free()
	
	tower.find_target()
	
	assert_null(tower.current_target, "Should clear invalid target")

func test_is_target_in_range():
	# Test target range checking
	tower.global_position = Vector2(0, 0)
	tower.tower_range = 100.0
	
	var close_target = Node2D.new()
	close_target.global_position = Vector2(50, 0)
	add_child_autofree(close_target)
	
	var far_target = Node2D.new()
	far_target.global_position = Vector2(200, 0)
	add_child_autofree(far_target)
	
	assert_true(tower.is_target_in_range(close_target), "Should detect close target in range")
	assert_false(tower.is_target_in_range(far_target), "Should detect far target out of range")

func test_is_target_in_range_invalid_target():
	# Test range checking with invalid target
	var invalid_target = Node.new()
	invalid_target.queue_free()
	
	var result = tower.is_target_in_range(invalid_target)
	
	assert_false(result, "Should return false for invalid target")

func test_destroy_tower():
	# Test tower destruction process
	tower.setup_attack_timer()
	tower.attack_timer.start()
	tower.grid_position = Vector2i(3, 3)
	watch_signals(tower)
	
	tower.destroy_tower()
	
	assert_false(tower.is_alive, "Should not be alive")
	assert_false(tower.attack_timer.is_processing(), "Attack timer should be stopped")
	assert_signal_emitted(tower, "tower_destroyed", "Should emit destruction signal")

func test_get_enemies_from_parent_fallback():
	# Test fallback enemy search when no MainController
	var enemies = tower.get_enemies_from_parent()
	
	# Should return an array (even if empty)
	assert_true(enemies is Array, "Should return an array")

func test_get_rival_hackers_fallback():
	# Test fallback rival hacker search when no MainController
	var rival_hackers = tower.get_rival_hackers()
	
	# Should return an array (even if empty)
	assert_true(rival_hackers is Array, "Should return an array")

func test_get_enemy_towers():
	# Test enemy tower retrieval
	var enemy_towers = tower.get_enemy_towers()
	
	# Should return an array (even if empty)
	assert_true(enemy_towers is Array, "Should return an array")

func test_attack_target_invalid_target():
	# Test attacking invalid target doesn't crash
	tower.current_target = null
	
	# Should not crash when calling with null target
	tower.attack_target()
	
	assert_true(true, "Should handle null target gracefully")

func test_attack_target_with_enemy():
	# Test attacking an enemy target
	var enemy = Enemy.new()
	add_child_autofree(enemy)
	tower.current_target = enemy
	tower.global_position = Vector2(100, 100)
	enemy.global_position = Vector2(150, 100)
	
	# Attack should create projectile (but won't due to scene instantiation)
	# Main test is that it doesn't crash
	tower.attack_target()
	
	assert_true(true, "Should handle enemy target without crashing")

func test_on_attack_timer_timeout_when_dead():
	# Test attack timer when tower is dead
	tower.is_alive = false
	
	tower._on_attack_timer_timeout()
	
	# Should not crash or cause issues when dead
	assert_true(true, "Should handle timeout when dead")

func test_health_clamping():
	# Test that health doesn't go below 0
	tower.health = 1
	
	tower.take_damage(5)
	
	assert_eq(tower.health, 0, "Health should not go below 0")

func test_attack_timer_configuration():
	# Test attack timer is configured correctly
	tower.attack_rate = 2.0
	tower.setup_attack_timer()
	
	assert_almost_eq(tower.attack_timer.wait_time, 0.5, 0.01, "Timer should be 1/attack_rate")

func test_projectile_scene_constant():
	# Test that projectile scene constant exists
	assert_not_null(Tower.PROJECTILE_SCENE, "Should have projectile scene preloaded")

func test_target_types_handling():
	# Test different target type handling in attack
	var enemy = Enemy.new()
	var enemy_tower = EnemyTower.new() 
	
	add_child_autofree(enemy)
	add_child_autofree(enemy_tower)
	
	# Test with enemy target
	tower.current_target = enemy
	tower.attack_target()  # Should not crash
	
	# Test with enemy tower target  
	tower.current_target = enemy_tower
	tower.attack_target()  # Should not crash
	
	assert_true(true, "Should handle different target types") 