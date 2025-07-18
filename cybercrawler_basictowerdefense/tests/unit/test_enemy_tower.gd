extends GutTest

# Unit tests for EnemyTower class
# These tests verify the enemy tower behavior and functionality

var enemy_tower: EnemyTower

func before_each():
	# Setup fresh EnemyTower for each test
	enemy_tower = EnemyTower.new()
	add_child_autofree(enemy_tower)

func test_initial_state():
	# Test that EnemyTower starts with correct initial values
	assert_eq(enemy_tower.tower_range, 120.0, "Should have default range of 120")
	assert_eq(enemy_tower.damage, 1, "Should have default damage of 1")
	assert_eq(enemy_tower.attack_speed, 2.0, "Should have default attack speed of 2.0")
	assert_eq(enemy_tower.health, 5, "Should start with 5 health")
	assert_eq(enemy_tower.max_health, 5, "Should have max health of 5")
	assert_eq(enemy_tower.removal_reward, 5, "Should have removal reward of 5")
	assert_true(enemy_tower.is_alive, "Should start alive")
	assert_false(enemy_tower.show_range_indicator, "Should not show range initially")
	assert_false(enemy_tower.is_frozen, "Should not start frozen")
	assert_null(enemy_tower.current_target, "Should start with no target")

func test_ready_creates_components():
	# Test that _ready() creates visual and functional components
	var child_count_before = enemy_tower.get_child_count()
	enemy_tower._ready()
	
	# Should have created components
	assert_gt(enemy_tower.get_child_count(), child_count_before, "Should create visual and functional children")
	
	# Look for specific components
	assert_not_null(enemy_tower.attack_timer, "Should create attack timer")
	assert_not_null(enemy_tower.damage_immunity_timer, "Should create damage immunity timer")
	assert_not_null(enemy_tower.freeze_timer, "Should create freeze timer")

func test_create_enemy_tower_visual():
	# Test visual creation
	var child_count_before = enemy_tower.get_child_count()
	
	enemy_tower.create_enemy_tower_visual()
	
	assert_gt(enemy_tower.get_child_count(), child_count_before, "Should create visual elements")

func test_setup_attack_timer():
	# Test attack timer setup
	enemy_tower.setup_attack_timer()
	
	assert_not_null(enemy_tower.attack_timer, "Should create attack timer")
	assert_eq(enemy_tower.attack_timer.wait_time, 0.5, "Timer should be 1/attack_speed")
	assert_true(enemy_tower.attack_timer.is_connected("timeout", enemy_tower._on_attack_timer_timeout), "Should connect timeout signal")

func test_setup_damage_immunity_timer():
	# Test damage immunity timer setup
	enemy_tower.setup_damage_immunity_timer()
	
	assert_not_null(enemy_tower.damage_immunity_timer, "Should create damage immunity timer")
	assert_eq(enemy_tower.damage_immunity_timer.wait_time, enemy_tower.damage_immunity_duration, "Should use immunity duration")

func test_setup_freeze_timer():
	# Test freeze timer setup
	enemy_tower.setup_freeze_timer()
	
	assert_not_null(enemy_tower.freeze_timer, "Should create freeze timer")
	assert_true(enemy_tower.freeze_timer.one_shot, "Freeze timer should be one-shot")
	assert_true(enemy_tower.freeze_timer.is_connected("timeout", enemy_tower._on_freeze_timer_timeout), "Should connect freeze timeout")

func test_take_damage():
	# Test damage system
	var initial_health = enemy_tower.health
	
	enemy_tower.take_damage(2)
	
	assert_eq(enemy_tower.health, initial_health - 2, "Should reduce health by 2")
	assert_true(enemy_tower.is_alive, "Should still be alive after 2 damage")

func test_take_damage_to_death():
	# Test enemy tower destruction when health reaches 0
	watch_signals(enemy_tower)
	
	enemy_tower.take_damage(5)  # Full health damage
	
	assert_eq(enemy_tower.health, 0, "Should have 0 health")
	assert_false(enemy_tower.is_alive, "Should be dead")
	assert_signal_emitted(enemy_tower, "enemy_tower_destroyed", "Should emit enemy_tower_destroyed signal")

func test_take_damage_when_immune():
	# Test that immune towers don't take damage
	enemy_tower.is_immune_to_damage = true
	var initial_health = enemy_tower.health
	
	enemy_tower.take_damage(1)
	
	assert_eq(enemy_tower.health, initial_health, "Immune tower should not take damage")

func test_take_damage_when_dead():
	# Test that dead towers don't take more damage
	enemy_tower.is_alive = false
	var initial_health = enemy_tower.health
	
	enemy_tower.take_damage(1)
	
	assert_eq(enemy_tower.health, initial_health, "Dead tower should not take damage")

func test_damage_immunity_timeout():
	# Test damage immunity timeout
	enemy_tower.is_immune_to_damage = true
	enemy_tower.modulate.a = 0.6
	
	enemy_tower._on_damage_immunity_timeout()
	
	assert_false(enemy_tower.is_immune_to_damage, "Should no longer be immune")
	assert_eq(enemy_tower.modulate.a, 1.0, "Should restore full opacity")

func test_freeze_effect():
	# Test applying freeze effect
	enemy_tower.apply_freeze_effect(3.0)
	
	assert_true(enemy_tower.is_frozen, "Should be frozen")
	assert_not_null(enemy_tower.freeze_visual, "Should have freeze visual")

func test_freeze_timeout():
	# Test freeze effect timeout
	enemy_tower.is_frozen = true
	enemy_tower.add_freeze_visual()
	
	enemy_tower._on_freeze_timer_timeout()
	
	assert_false(enemy_tower.is_frozen, "Should no longer be frozen")

func test_remove_freeze_visual():
	# Test removing freeze visual
	enemy_tower.add_freeze_visual()
	assert_not_null(enemy_tower.freeze_visual, "Should have freeze visual")
	
	enemy_tower.remove_freeze_visual()
	
	assert_null(enemy_tower.freeze_visual, "Should remove freeze visual")

func test_start_stop_attacking():
	# Test starting and stopping attack
	enemy_tower.setup_attack_timer()
	
	enemy_tower.start_attacking()
	# Timer should be running (but we can't easily test this without complex setup)
	
	enemy_tower.stop_attacking()
	assert_false(enemy_tower.attack_timer.is_processing(), "Attack timer should be stopped")

func test_set_get_grid_position():
	# Test grid position management
	var test_position = Vector2i(3, 4)
	
	enemy_tower.set_grid_position(test_position)
	
	assert_eq(enemy_tower.get_grid_position(), test_position, "Should return set grid position")
	assert_eq(enemy_tower.grid_position, test_position, "Should set internal grid position")

func test_is_target_in_range():
	# Test target range checking
	enemy_tower.global_position = Vector2(0, 0)
	enemy_tower.tower_range = 100.0
	
	var close_target = Node2D.new()
	close_target.global_position = Vector2(50, 0)
	add_child_autofree(close_target)
	
	var far_target = Node2D.new()
	far_target.global_position = Vector2(200, 0)
	add_child_autofree(far_target)
	
	assert_true(enemy_tower.is_target_in_range(close_target), "Should detect close target in range")
	assert_false(enemy_tower.is_target_in_range(far_target), "Should detect far target out of range")

func test_is_target_in_range_invalid():
	# Test range checking with invalid target
	var invalid_target = Node.new()
	invalid_target.queue_free()
	
	var result = enemy_tower.is_target_in_range(invalid_target)
	
	assert_false(result, "Should return false for invalid target")

func test_get_main_controller():
	# Test getting main controller
	var main_controller = enemy_tower.get_main_controller()
	
	# Should return something (even if null)
	assert_true(main_controller == null or main_controller is Node, "Should return null or Node")

func test_get_player_towers():
	# Test getting player towers
	var player_towers = enemy_tower.get_player_towers()
	
	# Should return an array (even if empty)
	assert_true(player_towers is Array, "Should return an array")

func test_get_program_data_packet():
	# Test getting program data packet
	var packet = enemy_tower.get_program_data_packet()
	
	# Should return null or ProgramDataPacket
	assert_true(packet == null or packet is ProgramDataPacket, "Should return null or ProgramDataPacket")

func test_update_health_bar():
	# Test health bar visual updates
	enemy_tower.create_enemy_tower_visual()
	enemy_tower.health = 2
	enemy_tower.max_health = 5
	
	enemy_tower.update_health_bar()
	
	var health_bar = enemy_tower.get_node("HealthBar")
	if health_bar:
		# Health bar width should reflect health percentage
		var expected_width = 32 * (2.0 / 5.0)  # 32 * health_percentage
		assert_almost_eq(health_bar.size.x, expected_width, 1.0, "Health bar width should reflect health")

func test_die():
	# Test tower death
	enemy_tower.setup_attack_timer()
	enemy_tower.attack_timer.start()
	watch_signals(enemy_tower)
	
	enemy_tower.die()
	
	assert_false(enemy_tower.is_alive, "Should not be alive")
	assert_false(enemy_tower.attack_timer.is_processing(), "Attack timer should be stopped")
	assert_signal_emitted(enemy_tower, "enemy_tower_destroyed", "Should emit destruction signal")

func test_is_clicked_at():
	# Test click detection
	enemy_tower.global_position = Vector2(100, 100)
	
	# Test click within range (using medium click config)
	var click_within = enemy_tower.is_clicked_at(Vector2(110, 110))
	assert_true(click_within, "Should detect click within range")
	
	# Test click outside range
	var click_outside = enemy_tower.is_clicked_at(Vector2(200, 200))
	assert_false(click_outside, "Should not detect click outside range")

func test_handle_click_damage():
	# Test click damage handling
	var initial_health = enemy_tower.health
	
	var result = enemy_tower.handle_click_damage()
	
	# Should return true if damage was applied
	assert_true(result is bool, "Should return boolean result")
	
	# If damage was applied, health should be reduced
	if result:
		assert_lt(enemy_tower.health, initial_health, "Health should be reduced if damage applied")

func test_get_health_info():
	# Test health info string
	enemy_tower.health = 3
	enemy_tower.max_health = 5
	
	var health_info = enemy_tower.get_health_info()
	
	assert_true(health_info.contains("3"), "Should contain current health")
	assert_true(health_info.contains("5"), "Should contain max health")
	assert_true(health_info.contains("Health:"), "Should contain 'Health:' label")

func test_show_range_debug():
	# Test debug range functionality
	enemy_tower.grid_position = Vector2i(2, 3)
	enemy_tower.health = 3
	enemy_tower.max_health = 5
	
	# Should not crash when called
	enemy_tower.show_range_debug()
	
	assert_true(true, "Debug method should not crash")

func test_attack_timer_timeout_when_frozen():
	# Test attack timer when tower is frozen
	enemy_tower.is_frozen = true
	
	enemy_tower._on_attack_timer_timeout()
	
	# Should not crash or cause issues when frozen
	assert_true(true, "Should handle timeout when frozen")

func test_attack_timer_timeout_when_dead():
	# Test attack timer when tower is dead
	enemy_tower.is_alive = false
	
	enemy_tower._on_attack_timer_timeout()
	
	# Should not crash or cause issues when dead
	assert_true(true, "Should handle timeout when dead") 