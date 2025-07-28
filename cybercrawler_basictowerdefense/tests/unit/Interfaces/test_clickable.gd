extends GutTest

# Unit tests for Clickable interface
# These tests verify the static methods and configuration classes

func test_click_config_initialization():
	# Test that ClickConfig can be initialized with default values
	var config = Clickable.ClickConfig.new()
	
	assert_eq(config.damage_taken, 1, "Default damage should be 1")
	assert_eq(config.click_radius, 20.0, "Default click radius should be 20.0")
	assert_eq(config.feedback_color, Color.WHITE, "Default feedback color should be WHITE")
	assert_eq(config.feedback_font_size, 14, "Default font size should be 14")
	assert_eq(config.feedback_offset, Vector2(-10, -35), "Default offset should be (-10, -35)")
	assert_eq(config.feedback_move_distance, -25.0, "Default move distance should be -25.0")
	assert_eq(config.feedback_duration, 0.8, "Default duration should be 0.8")

func test_click_config_custom_initialization():
	# Test ClickConfig with custom values
	var config = Clickable.ClickConfig.new(2, 30.0, Color.RED, 16, Vector2(-5, -20), -15.0, 1.0)
	
	assert_eq(config.damage_taken, 2, "Custom damage should be 2")
	assert_eq(config.click_radius, 30.0, "Custom click radius should be 30.0")
	assert_eq(config.feedback_color, Color.RED, "Custom feedback color should be RED")
	assert_eq(config.feedback_font_size, 16, "Custom font size should be 16")
	assert_eq(config.feedback_offset, Vector2(-5, -20), "Custom offset should be (-5, -20)")
	assert_eq(config.feedback_move_distance, -15.0, "Custom move distance should be -15.0")
	assert_eq(config.feedback_duration, 1.0, "Custom duration should be 1.0")

func test_static_config_constants():
	# Test that static configuration constants are properly defined
	assert_not_null(Clickable.ENEMY_CONFIG, "ENEMY_CONFIG should be defined")
	assert_not_null(Clickable.ENEMY_TOWER_CONFIG, "ENEMY_TOWER_CONFIG should be defined")
	assert_not_null(Clickable.RIVAL_HACKER_CONFIG, "RIVAL_HACKER_CONFIG should be defined")
	
	# Test ENEMY_CONFIG values
	assert_eq(Clickable.ENEMY_CONFIG.damage_taken, 1, "Enemy config damage should be 1")
	assert_eq(Clickable.ENEMY_CONFIG.click_radius, 20.0, "Enemy config radius should be 20.0")
	assert_eq(Clickable.ENEMY_CONFIG.feedback_color, Color.ORANGE, "Enemy config color should be ORANGE")
	
	# Test ENEMY_TOWER_CONFIG values
	assert_eq(Clickable.ENEMY_TOWER_CONFIG.damage_taken, 1, "Enemy tower config damage should be 1")
	assert_eq(Clickable.ENEMY_TOWER_CONFIG.click_radius, 35.0, "Enemy tower config radius should be 35.0")
	assert_eq(Clickable.ENEMY_TOWER_CONFIG.feedback_color, Color.YELLOW, "Enemy tower config color should be YELLOW")
	
	# Test RIVAL_HACKER_CONFIG values
	assert_eq(Clickable.RIVAL_HACKER_CONFIG.damage_taken, 2, "Rival hacker config damage should be 2")
	assert_eq(Clickable.RIVAL_HACKER_CONFIG.click_radius, 25.0, "Rival hacker config radius should be 25.0")
	assert_eq(Clickable.RIVAL_HACKER_CONFIG.feedback_color, Color.RED, "Rival hacker config color should be RED")

func test_is_clicked_at_within_radius():
	# Test is_clicked_at when click is within radius
	var config = Clickable.ClickConfig.new(1, 20.0)
	var entity_pos = Vector2(100, 100)
	var click_pos = Vector2(110, 110)  # Distance = ~14.14, within radius of 20
	
	var result = Clickable.is_clicked_at(entity_pos, click_pos, config)
	assert_true(result, "Should detect click within radius")

func test_is_clicked_at_outside_radius():
	# Test is_clicked_at when click is outside radius
	var config = Clickable.ClickConfig.new(1, 20.0)
	var entity_pos = Vector2(100, 100)
	var click_pos = Vector2(130, 130)  # Distance = ~42.43, outside radius of 20
	
	var result = Clickable.is_clicked_at(entity_pos, click_pos, config)
	assert_false(result, "Should not detect click outside radius")

func test_is_clicked_at_exact_radius():
	# Test is_clicked_at when click is exactly at radius
	var config = Clickable.ClickConfig.new(1, 20.0)
	var entity_pos = Vector2(100, 100)
	var click_pos = Vector2(120, 100)  # Distance = exactly 20
	
	var result = Clickable.is_clicked_at(entity_pos, click_pos, config)
	assert_true(result, "Should detect click at exact radius")

func test_is_clicked_at_same_position():
	# Test is_clicked_at when click is at same position
	var config = Clickable.ClickConfig.new(1, 20.0)
	var entity_pos = Vector2(100, 100)
	var click_pos = Vector2(100, 100)  # Distance = 0
	
	var result = Clickable.is_clicked_at(entity_pos, click_pos, config)
	assert_true(result, "Should detect click at same position")

func test_handle_click_damage_with_valid_entity():
	# Test handle_click_damage with a valid entity
	var config = Clickable.ClickConfig.new(2, 20.0)
	var entity = MockClickableEntity.new()
	add_child_autofree(entity)
	
	var result = Clickable.handle_click_damage(entity, config, "TestEntity")
	assert_true(result, "Should successfully handle click damage")
	assert_eq(entity.damage_taken_amount, 2, "Should take correct amount of damage")

func test_handle_click_damage_with_dead_entity():
	# Test handle_click_damage with a dead entity
	var config = Clickable.ClickConfig.new(1, 20.0)
	var entity = MockClickableEntity.new()
	entity.is_alive = false
	add_child_autofree(entity)
	
	var result = Clickable.handle_click_damage(entity, config, "DeadEntity")
	assert_false(result, "Should not handle click damage for dead entity")
	assert_eq(entity.damage_taken_amount, 0, "Should not take damage when dead")

func test_handle_click_damage_without_take_damage_method():
	# Test handle_click_damage with entity that doesn't have take_damage method
	var config = Clickable.ClickConfig.new(1, 20.0)
	var entity = MockInvalidEntity.new()
	add_child_autofree(entity)
	
	var result = Clickable.handle_click_damage(entity, config, "InvalidEntity")
	assert_false(result, "Should fail for entity without take_damage method")

func test_create_click_feedback():
	# Test create_click_feedback creates visual feedback
	var config = Clickable.ClickConfig.new(3, 20.0, Color.GREEN, 18, Vector2(-15, -30), -20.0, 0.5)
	var entity = MockClickableEntity.new()
	add_child_autofree(entity)
	
	var initial_child_count = entity.get_child_count()
	Clickable.create_click_feedback(entity, config)
	
	# Should have added a child (the damage label)
	assert_eq(entity.get_child_count(), initial_child_count + 1, "Should add damage label as child")
	
	# Check that the label has the correct properties
	var damage_label = entity.get_child(entity.get_child_count() - 1)
	assert_eq(damage_label.text, "-3", "Damage label should show damage amount")
	assert_eq(damage_label.position, Vector2(-15, -30), "Damage label should be at correct position")

func test_different_config_damage_values():
	# Test that different config damage values work correctly
	var config_low = Clickable.ClickConfig.new(1, 20.0)
	var config_high = Clickable.ClickConfig.new(5, 20.0)
	
	var entity1 = MockClickableEntity.new()
	var entity2 = MockClickableEntity.new()
	add_child_autofree(entity1)
	add_child_autofree(entity2)
	
	Clickable.handle_click_damage(entity1, config_low, "Entity1")
	Clickable.handle_click_damage(entity2, config_high, "Entity2")
	
	assert_eq(entity1.damage_taken_amount, 1, "Entity1 should take 1 damage")
	assert_eq(entity2.damage_taken_amount, 5, "Entity2 should take 5 damage")

func test_different_config_radius_values():
	# Test that different config radius values work correctly
	var config_small = Clickable.ClickConfig.new(1, 10.0)
	var config_large = Clickable.ClickConfig.new(1, 50.0)
	
	var entity_pos = Vector2(100, 100)
	var click_pos = Vector2(130, 100)  # Distance = 30
	
	var result_small = Clickable.is_clicked_at(entity_pos, click_pos, config_small)
	var result_large = Clickable.is_clicked_at(entity_pos, click_pos, config_large)
	
	assert_false(result_small, "Small radius should not detect distant click")
	assert_true(result_large, "Large radius should detect distant click")

# Mock entity for testing - now using global MockClickableEntity

# Mock entity without take_damage method
class MockInvalidEntity extends Node2D:
	var is_alive: bool = true 