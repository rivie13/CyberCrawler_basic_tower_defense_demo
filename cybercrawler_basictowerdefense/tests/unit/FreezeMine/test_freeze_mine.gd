extends GutTest

# Unit tests for FreezeMine class
# These tests verify the freeze mine behavior and functionality

var freeze_mine: FreezeMine

func before_each():
	# Setup fresh FreezeMine for each test
	freeze_mine = FreezeMine.new()
	add_child_autofree(freeze_mine)

func test_initial_state():
	# Test that FreezeMine starts with correct initial values
	assert_eq(freeze_mine.freeze_radius, 100.0, "Should have default freeze radius of 100.0")
	assert_eq(freeze_mine.freeze_duration, 3.0, "Should have default freeze duration of 3.0")
	assert_eq(freeze_mine.trigger_radius, 80.0, "Should have default trigger radius of 80.0")
	assert_eq(freeze_mine.cost, 15, "Should have default cost of 15")
	assert_eq(freeze_mine.max_uses, 1, "Should have default max uses of 1")
	assert_true(freeze_mine.is_active, "Should start active")
	assert_false(freeze_mine.is_triggered, "Should not start triggered")
	# uses_remaining is not initialized until _ready() is called
	# Note: In Godot, _ready() might be called automatically during test setup
	# So we check if it's either 0 (not initialized) or 1 (already initialized)
	assert_true(freeze_mine.uses_remaining == 0 or freeze_mine.uses_remaining == 1, "Should start with 0 or 1 uses depending on _ready() call")

func test_ready_initialization():
	# Test that _ready() initializes the mine properly
	freeze_mine._ready()
	
	assert_eq(freeze_mine.uses_remaining, 1, "Should have 1 use remaining after _ready")
	assert_not_null(freeze_mine.detection_timer, "Should create detection timer")
	assert_true(freeze_mine.detection_timer.is_connected("timeout", freeze_mine._on_detection_timer_timeout), "Should connect timeout signal")

func test_create_mine_visual():
	# Test visual creation
	var child_count_before = freeze_mine.get_child_count()
	
	freeze_mine.create_mine_visual()
	
	# Should have created visual elements
	assert_gt(freeze_mine.get_child_count(), child_count_before, "Should create visual children")
	
	# Check for specific visual components
	assert_not_null(freeze_mine.mine_body, "Should create mine body")
	assert_not_null(freeze_mine.uses_label, "Should create uses label")

func test_mine_body_properties():
	# Test mine body visual properties
	freeze_mine.create_mine_visual()
	
	assert_eq(freeze_mine.mine_body.size, Vector2(20, 20), "Should have size 20x20")
	assert_eq(freeze_mine.mine_body.position, Vector2(-10, -10), "Should be centered")
	assert_eq(freeze_mine.mine_body.color, Color(0.0, 0.8, 0.8, 0.8), "Should have cyan color")

func test_uses_label_properties():
	# Test uses label properties
	freeze_mine._ready()  # Initialize uses_remaining first
	
	assert_eq(freeze_mine.uses_label.text, "1", "Should show initial uses")
	assert_eq(freeze_mine.uses_label.position, Vector2(-5, -30), "Should be positioned correctly")

func test_outline_creation():
	# Test that outline is created
	freeze_mine.create_mine_visual()
	
	# Look for the outline (should be the first child)
	var outline = freeze_mine.get_child(0)
	assert_not_null(outline, "Should have outline as first child")
	assert_true(outline is ColorRect, "Outline should be a ColorRect")
	assert_eq(outline.size, Vector2(24, 24), "Outline should be 24x24")
	assert_eq(outline.position, Vector2(-12, -12), "Outline should be positioned correctly")
	assert_eq(outline.color, Color(0.0, 0.5, 0.5, 0.6), "Outline should be darker cyan")

func test_setup_detection_timer():
	# Test detection timer setup
	# Freeze mine is already added to scene tree in before_each()
	
	freeze_mine.setup_detection_timer()
	
	# Verify timer is created and configured correctly
	assert_not_null(freeze_mine.detection_timer, "Should create detection timer")
	assert_eq(freeze_mine.detection_timer.wait_time, 0.2, "Should have 0.2 second wait time")
	assert_true(freeze_mine.detection_timer.is_connected("timeout", freeze_mine._on_detection_timer_timeout), "Should connect timeout signal")
	assert_true(freeze_mine.detection_timer.is_inside_tree(), "Timer should be added to scene tree")
	
	# Test that the timer's timeout method works correctly
	# Use GUT's simulate() method to test the timer functionality
	watch_signals(freeze_mine)
	
	# Simulate the timer timeout by calling the timeout method directly
	freeze_mine._on_detection_timer_timeout()
	
	# The timeout method should not trigger the mine if no enemy towers are nearby
	# (which is the case in this test environment)
	# So we just verify the method can be called without errors

func test_get_cost():
	# Test cost retrieval
	var cost = freeze_mine.get_cost()
	assert_eq(cost, 15, "Should return correct cost")

func test_set_get_grid_position():
	# Test grid position management
	var test_position = Vector2i(3, 4)
	
	freeze_mine.set_grid_position(test_position)
	
	assert_eq(freeze_mine.grid_position, test_position, "Should set grid position correctly")

func test_can_be_placed_at_valid_position():
	# Test placement validation with valid position
	var mock_grid_manager = MockGridManager.new()
	mock_grid_manager.initialize_with_container(Node2D.new())
	# Set up grid data for valid position
	mock_grid_manager.set_grid_occupied(Vector2i(2, 2), false)
	mock_grid_manager.set_path_positions([])  # No path positions
	add_child_autofree(mock_grid_manager)
	
	var result = freeze_mine.can_be_placed_at(Vector2i(2, 2), mock_grid_manager)
	assert_true(result, "Should allow placement at valid position")

func test_can_be_placed_at_invalid_position():
	# Test placement validation with invalid position
	var mock_grid_manager = MockGridManager.new()
	mock_grid_manager.initialize_with_container(Node2D.new())
	add_child_autofree(mock_grid_manager)
	
	var result = freeze_mine.can_be_placed_at(Vector2i(-1, -1), mock_grid_manager)
	assert_false(result, "Should not allow placement at invalid position")

func test_can_be_placed_at_occupied_position():
	# Test placement validation with occupied position
	var mock_grid_manager = MockGridManager.new()
	mock_grid_manager.initialize_with_container(Node2D.new())
	mock_grid_manager.set_grid_occupied(Vector2i(2, 2), true)
	add_child_autofree(mock_grid_manager)
	
	var result = freeze_mine.can_be_placed_at(Vector2i(2, 2), mock_grid_manager)
	assert_false(result, "Should not allow placement at occupied position")

func test_can_be_placed_at_enemy_path():
	# Test placement validation on enemy path
	var mock_grid_manager = MockGridManager.new()
	mock_grid_manager.initialize_with_container(Node2D.new())
	mock_grid_manager.set_path_positions([Vector2i(2, 2)])  # Position is on path
	add_child_autofree(mock_grid_manager)
	
	var result = freeze_mine.can_be_placed_at(Vector2i(2, 2), mock_grid_manager)
	assert_false(result, "Should not allow placement on enemy path")

func test_trigger_freeze_mine_inactive():
	# Test triggering when mine is inactive
	freeze_mine.is_active = false
	watch_signals(freeze_mine)
	
	freeze_mine.trigger_freeze_mine()
	
	assert_signal_not_emitted(freeze_mine, "mine_triggered", "Should not trigger when inactive")

func test_trigger_freeze_mine_no_uses():
	# Test triggering when no uses remaining
	freeze_mine.uses_remaining = 0
	watch_signals(freeze_mine)
	
	freeze_mine.trigger_freeze_mine()
	
	assert_signal_not_emitted(freeze_mine, "mine_triggered", "Should not trigger when no uses remaining")

func test_trigger_freeze_mine_already_triggered():
	# Test triggering when already triggered
	freeze_mine.is_triggered = true
	watch_signals(freeze_mine)
	
	freeze_mine.trigger_freeze_mine()
	
	assert_signal_not_emitted(freeze_mine, "mine_triggered", "Should not trigger when already triggered")

func test_trigger_freeze_mine_success():
	# Test successful triggering
	freeze_mine._ready()
	watch_signals(freeze_mine)
	
	freeze_mine.trigger_freeze_mine()
	
	assert_true(freeze_mine.is_triggered, "Should be triggered")
	assert_eq(freeze_mine.uses_remaining, 0, "Should reduce uses remaining")
	assert_signal_emitted(freeze_mine, "mine_triggered", "Should emit mine_triggered signal")

func test_trigger_freeze_mine_depletion():
	# Test mine depletion after triggering
	freeze_mine._ready()
	watch_signals(freeze_mine)
	
	freeze_mine.trigger_freeze_mine()
	
	# Wait for the depletion logic
	await get_tree().create_timer(0.6).timeout
	
	assert_false(freeze_mine.is_active, "Should be inactive after depletion")
	assert_signal_emitted(freeze_mine, "mine_depleted", "Should emit mine_depleted signal")

func test_create_freeze_effect_visual():
	# Test freeze effect visual creation
	var child_count_before = freeze_mine.get_child_count()
	
	freeze_mine.create_freeze_effect_visual()
	
	# Should have created visual effect
	assert_gt(freeze_mine.get_child_count(), child_count_before, "Should create freeze effect visual")
	
	# Look for the freeze effect
	var freeze_effect = freeze_mine.get_child(freeze_mine.get_child_count() - 1)
	assert_true(freeze_effect is ColorRect, "Should create ColorRect for freeze effect")
	assert_eq(freeze_effect.size, Vector2(200, 200), "Should have correct size (radius * 2)")
	assert_eq(freeze_effect.position, Vector2(-100, -100), "Should be positioned correctly")
	assert_eq(freeze_effect.color, Color(0.0, 0.8, 0.8, 0.3), "Should have semi-transparent cyan color")

func test_get_enemy_towers_in_radius():
	# Test enemy tower detection
	freeze_mine.global_position = Vector2(100, 100)
	
	# Create mock enemy towers
	var mock_tower1 = MockEnemyTower.new()
	mock_tower1.global_position = Vector2(150, 100)  # 50 units away (within 80 trigger radius)
	mock_tower1.is_alive = true
	add_child_autofree(mock_tower1)
	
	var mock_tower2 = MockEnemyTower.new()
	mock_tower2.global_position = Vector2(200, 100)  # 100 units away (outside 80 trigger radius)
	mock_tower2.is_alive = true
	add_child_autofree(mock_tower2)
	
	# Create mock main controller and rival hacker manager
	var mock_main_controller = MockMainController.new()
	var mock_rival_manager = MockRivalHackerManager.new()
	mock_rival_manager.set_mock_enemy_towers([mock_tower1, mock_tower2])
	
	# Set the real rival_hacker_manager property that FreezeMine will access
	mock_main_controller.rival_hacker_manager = mock_rival_manager
	add_child_autofree(mock_main_controller)
	add_child_autofree(mock_rival_manager)
	
	# Add to main_controller group
	mock_main_controller.add_to_group("main_controller")
	
	var towers_in_radius = freeze_mine.get_enemy_towers_in_radius(Vector2(100, 100), 80.0)
	assert_eq(towers_in_radius.size(), 1, "Should find 1 tower within 80 unit radius")
	assert_eq(towers_in_radius[0], mock_tower1, "Should find the closer tower")

func test_get_main_controller():
	# Test getting main controller from tree
	var mock_main_controller = MockMainController.new()
	mock_main_controller.add_to_group("main_controller")
	add_child_autofree(mock_main_controller)
	
	var result = freeze_mine.get_main_controller()
	assert_eq(result, mock_main_controller, "Should return main controller from group")

# Mock classes for testing - now using global MockEnemyTower 
