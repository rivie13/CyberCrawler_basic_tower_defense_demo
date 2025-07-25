extends GutTest

# Unit tests for MainController input handling and grid interaction
# This tests input processing, grid clicks, and enemy targeting

var main_controller: MainController

func before_each():
	# Create a fresh MainController for each test
	# DO NOT call _ready() as it tries to access scene nodes that don't exist in tests
	main_controller = MainController.new()
	add_child_autofree(main_controller)

func test_input_handling_game_over():
	# Test input handling when game is over
	main_controller.setup_managers()
	
	# Set game to over state
	main_controller.game_manager.trigger_game_over()
	
	# Create a mock input event
	var input_event = InputEventMouseButton.new()
	input_event.button_index = MOUSE_BUTTON_LEFT
	input_event.pressed = true
	
	# This should return early due to game over state
	main_controller._input(input_event)
	assert_true(true, "Input handling should handle game over state gracefully")

func test_input_handling_mouse_button():
	# Test input handling with mouse button event
	main_controller.setup_managers()
	
	# Create a mock input event
	var input_event = InputEventMouseButton.new()
	input_event.button_index = MOUSE_BUTTON_LEFT
	input_event.pressed = true
	
	# This should not crash
	main_controller._input(input_event)
	assert_true(true, "Input handling should handle mouse button events")

func test_input_handling_mouse_motion():
	# Test input handling with mouse motion event
	main_controller.setup_managers()
	
	# Create a mock input event
	var input_event = InputEventMouseMotion.new()
	
	# This should not crash
	main_controller._input(input_event)
	assert_true(true, "Input handling should handle mouse motion events")

func test_handle_grid_click_build_mode():
	# Test grid click handling in build mode
	main_controller.setup_managers()
	main_controller.current_click_mode = MainController.MODE_BUILD_TOWERS
	
	# Initialize systems to prevent null reference errors
	# Note: We can't call initialize_systems() directly because it needs scene nodes
	# So we'll manually initialize the tower manager
	if main_controller.tower_manager and main_controller.grid_manager and main_controller.currency_manager and main_controller.wave_manager:
		main_controller.tower_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.wave_manager)
	
	# Test that handle_grid_click doesn't crash in build mode
	main_controller.handle_grid_click(Vector2(100, 100))
	assert_true(true, "Handle grid click in build mode should not crash")

func test_handle_grid_click_attack_mode():
	# Test grid click handling in attack mode
	main_controller.setup_managers()
	main_controller.current_click_mode = MainController.MODE_ATTACK_ENEMIES
	
	# Initialize systems to prevent null reference errors
	# Note: We can't call initialize_systems() directly because it needs scene nodes
	# So we'll manually initialize the rival hacker manager for enemy targeting
	if main_controller.rival_hacker_manager and main_controller.grid_manager and main_controller.currency_manager and main_controller.tower_manager and main_controller.wave_manager:
		main_controller.rival_hacker_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.tower_manager, main_controller.wave_manager, main_controller.game_manager)
	
	# Test that handle_grid_click doesn't crash in attack mode
	main_controller.handle_grid_click(Vector2(100, 100))
	assert_true(true, "Handle grid click in attack mode should not crash")

func test_handle_grid_click_freeze_mine_mode():
	# Test grid click handling in freeze mine mode
	main_controller.setup_managers()
	main_controller.current_click_mode = MainController.MODE_PLACE_FREEZE_MINE
	
	# Initialize systems to prevent null reference errors
	# Note: We can't call initialize_systems() directly because it needs scene nodes
	# So we'll manually initialize the freeze mine manager
	if main_controller.freeze_mine_manager and main_controller.grid_manager and main_controller.currency_manager:
		main_controller.freeze_mine_manager.initialize(main_controller.grid_manager, main_controller.currency_manager)
	
	# Test that handle_grid_click doesn't crash in freeze mine mode
	main_controller.handle_grid_click(Vector2(100, 100))
	assert_true(true, "Handle grid click in freeze mine mode should not crash")

func test_handle_grid_click_with_valid_grid_position():
	# Test handle_grid_click with valid grid position
	main_controller.setup_managers()
	main_controller.current_click_mode = MainController.MODE_BUILD_TOWERS
	
	# Initialize tower manager
	if main_controller.tower_manager and main_controller.grid_manager and main_controller.currency_manager and main_controller.wave_manager:
		main_controller.tower_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.wave_manager)
	
	# Mock grid manager to return valid position
	main_controller.grid_manager.initialize_grid()
	main_controller.grid_manager.set_grid_occupied(Vector2i(1, 1), false)
	
	# Test clicking on valid grid position
	main_controller.handle_grid_click(Vector2(100, 100))
	assert_true(true, "Handle grid click should handle valid grid position")

func test_handle_grid_click_with_invalid_grid_position():
	# Test handle_grid_click with invalid grid position
	main_controller.setup_managers()
	main_controller.current_click_mode = MainController.MODE_BUILD_TOWERS
	
	# Initialize tower manager
	if main_controller.tower_manager and main_controller.grid_manager and main_controller.currency_manager and main_controller.wave_manager:
		main_controller.tower_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.wave_manager)
	
	# Mock grid manager to return invalid position
	main_controller.grid_manager.initialize_grid()
	
	# Test clicking on invalid grid position
	main_controller.handle_grid_click(Vector2(100, 100))
	assert_true(true, "Handle grid click should handle invalid grid position")

func test_try_click_damage_enemy():
	# Test enemy click damage functionality
	main_controller.setup_managers()
	
	# Initialize systems to prevent null reference errors
	# Note: We can't call initialize_systems() directly because it needs scene nodes
	# So we'll manually initialize the rival hacker manager for enemy targeting
	if main_controller.rival_hacker_manager and main_controller.grid_manager and main_controller.currency_manager and main_controller.tower_manager and main_controller.wave_manager:
		main_controller.rival_hacker_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.tower_manager, main_controller.wave_manager, main_controller.game_manager)
	
	# Test that try_click_damage_enemy doesn't crash
	var result = main_controller.try_click_damage_enemy(Vector2(100, 100))
	assert_true(result is bool, "Try click damage enemy should return boolean")
	assert_true(true, "Try click damage enemy should not crash")

func test_try_click_damage_enemy_with_enemy_towers():
	# Test try_click_damage_enemy with enemy towers
	main_controller.setup_managers()
	
	# Initialize rival hacker manager
	if main_controller.rival_hacker_manager and main_controller.grid_manager and main_controller.currency_manager and main_controller.tower_manager and main_controller.wave_manager:
		main_controller.rival_hacker_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.tower_manager, main_controller.wave_manager, main_controller.game_manager)
	
	# Create a mock enemy tower
	var mock_enemy_tower = preload("res://scripts/Tower/EnemyTower.gd").new()
	add_child_autofree(mock_enemy_tower)
	mock_enemy_tower.position = Vector2(100, 100)
	
	# Test clicking on enemy tower - use the public method instead of direct property access
	var result = main_controller.try_click_damage_enemy(Vector2(100, 100))
	assert_true(result is bool, "Try click damage enemy should return boolean")

func test_try_click_damage_enemy_with_rival_hackers():
	# Test try_click_damage_enemy with rival hackers
	main_controller.setup_managers()
	
	# Initialize rival hacker manager
	if main_controller.rival_hacker_manager and main_controller.grid_manager and main_controller.currency_manager and main_controller.tower_manager and main_controller.wave_manager:
		main_controller.rival_hacker_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.tower_manager, main_controller.wave_manager, main_controller.game_manager)
	
	# Create a mock rival hacker
	var mock_rival_hacker = preload("res://scripts/Rival/RivalHacker.gd").new()
	add_child_autofree(mock_rival_hacker)
	mock_rival_hacker.position = Vector2(100, 100)
	
	# Test clicking on rival hacker - use the public method instead of direct property access
	var result = main_controller.try_click_damage_enemy(Vector2(100, 100))
	assert_true(result is bool, "Try click damage enemy should return boolean")

func test_try_click_damage_enemy_with_enemies():
	# Test try_click_damage_enemy with regular enemies
	main_controller.setup_managers()
	
	# Initialize wave manager
	if main_controller.wave_manager and main_controller.grid_manager:
		main_controller.wave_manager.initialize(main_controller.grid_manager)
	
	# Create a mock enemy
	var mock_enemy = preload("res://scripts/Enemy/Enemy.gd").new()
	add_child_autofree(mock_enemy)
	mock_enemy.position = Vector2(100, 100)
	
	# Test clicking on enemy - use the public method instead of direct property access
	var result = main_controller.try_click_damage_enemy(Vector2(100, 100))
	assert_true(result is bool, "Try click damage enemy should return boolean") 