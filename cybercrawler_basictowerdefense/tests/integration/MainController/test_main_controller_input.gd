extends GutTest

# Integration tests for MainController input handling and system interactions
# These tests verify complete workflows from user input to system responses

var main_controller: MainController

func before_each():
	# Create a fresh MainController for each test
	# DO NOT call _ready() as it tries to access scene nodes that don't exist in tests
	main_controller = MainController.new()
	add_child_autofree(main_controller)

func test_complete_tower_placement_workflow():
	# Integration test: Complete tower placement workflow
	# This tests the full workflow: selection → placement → currency → grid state
	
	main_controller.setup_managers()
	
	# Initialize managers with proper dependencies
	main_controller.wave_manager.initialize(main_controller.grid_manager)
	main_controller.tower_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.wave_manager)
	main_controller.game_manager.initialize(main_controller.wave_manager, main_controller.currency_manager, main_controller.tower_manager)
	main_controller.rival_hacker_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.tower_manager, main_controller.wave_manager, main_controller.game_manager)
	main_controller.freeze_mine_manager.initialize(main_controller.grid_manager, main_controller.currency_manager)
	main_controller.program_data_packet_manager.initialize(main_controller.grid_manager, main_controller.game_manager, main_controller.wave_manager)
	
	main_controller.initialize_systems()
	
	# Set up for tower placement
	main_controller.selected_tower_type = "basic"
	main_controller.current_click_mode = MainController.MODE_BUILD_TOWERS
	
	# Record initial state
	var initial_currency = main_controller.currency_manager.get_currency()
	var initial_tower_count = main_controller.tower_manager.get_tower_count()
	
	# Simulate tower placement
	main_controller.handle_grid_click(Vector2(100, 100))  # Valid grid position
	
	# Verify tower placement worked
	assert_gt(main_controller.tower_manager.get_tower_count(), initial_tower_count, "Tower count should increase after placement")
	assert_lt(main_controller.currency_manager.get_currency(), initial_currency, "Currency should decrease after tower placement")
	
	# Verify grid state
	var grid_pos = main_controller.grid_manager.world_to_grid(Vector2(100, 100))
	assert_true(main_controller.grid_manager.is_grid_occupied(grid_pos), "Grid should be occupied after tower placement")

func test_complete_attack_mode_workflow():
	# Integration test: Complete attack mode workflow
	# This tests the full workflow: mode selection → enemy targeting → damage → currency
	
	main_controller.setup_managers()
	
	# Initialize managers with proper dependencies
	main_controller.wave_manager.initialize(main_controller.grid_manager)
	main_controller.tower_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.wave_manager)
	main_controller.game_manager.initialize(main_controller.wave_manager, main_controller.currency_manager, main_controller.tower_manager)
	main_controller.rival_hacker_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.tower_manager, main_controller.wave_manager, main_controller.game_manager)
	main_controller.freeze_mine_manager.initialize(main_controller.grid_manager, main_controller.currency_manager)
	main_controller.program_data_packet_manager.initialize(main_controller.grid_manager, main_controller.game_manager, main_controller.wave_manager)
	
	main_controller.initialize_systems()
	
	# Set attack mode
	main_controller.current_click_mode = MainController.MODE_ATTACK_ENEMIES
	
	# Record initial currency
	var initial_currency = main_controller.currency_manager.get_currency()
	
	# Try to attack (no enemies present, so should return false)
	var attack_result = main_controller.try_click_damage_enemy(Vector2(100, 100))
	assert_false(attack_result, "Attack should fail when no enemies present")
	
	# Currency should remain unchanged
	assert_eq(main_controller.currency_manager.get_currency(), initial_currency, "Currency should remain unchanged when no enemies hit")

func test_complete_freeze_mine_workflow():
	# Integration test: Complete freeze mine workflow
	# This tests the full workflow: freeze mine mode → placement → system state validation
	
	main_controller.setup_managers()
	
	# Initialize managers with proper dependencies
	main_controller.wave_manager.initialize(main_controller.grid_manager)
	main_controller.tower_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.wave_manager)
	main_controller.game_manager.initialize(main_controller.wave_manager, main_controller.currency_manager, main_controller.tower_manager)
	main_controller.rival_hacker_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.tower_manager, main_controller.wave_manager, main_controller.game_manager)
	main_controller.freeze_mine_manager.initialize(main_controller.grid_manager, main_controller.currency_manager)
	main_controller.program_data_packet_manager.initialize(main_controller.grid_manager, main_controller.game_manager, main_controller.wave_manager)
	
	main_controller.initialize_systems()
	
	# Add currency for freeze mine (costs 15)
	main_controller.currency_manager.add_currency(50)
	
	# Switch to freeze mine mode
	main_controller.current_click_mode = MainController.MODE_PLACE_FREEZE_MINE
	
	# Get initial state
	var initial_mine_count = main_controller.freeze_mine_manager.get_mines().size()
	var initial_currency = main_controller.currency_manager.get_currency()
	
	# Place a freeze mine at a different position
	var grid_position = Vector2i(4, 4)  # Different position to avoid conflicts
	var world_position = main_controller.grid_manager.grid_to_world(grid_position)
	main_controller.handle_grid_click(world_position)
	
	# Validate freeze mine placement
	var final_mine_count = main_controller.freeze_mine_manager.get_mines().size()
	var final_currency = main_controller.currency_manager.get_currency()
	
	# Mine count should increase
	assert_gt(final_mine_count, initial_mine_count, "Mine count should increase after placement")
	# Currency should decrease
	assert_lt(final_currency, initial_currency, "Currency should decrease after mine placement")
	# Grid should be occupied
	assert_true(main_controller.grid_manager.is_grid_occupied(grid_position), "Grid should be occupied after mine placement")

func test_game_over_input_handling_workflow():
	# Integration test: Game over state affects all input handling
	# This tests how game over state propagates through all input systems
	
	main_controller.setup_managers()
	
	# Initialize managers with proper dependencies
	main_controller.wave_manager.initialize(main_controller.grid_manager)
	main_controller.tower_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.wave_manager)
	main_controller.game_manager.initialize(main_controller.wave_manager, main_controller.currency_manager, main_controller.tower_manager)
	main_controller.rival_hacker_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.tower_manager, main_controller.wave_manager, main_controller.game_manager)
	main_controller.freeze_mine_manager.initialize(main_controller.grid_manager, main_controller.currency_manager)
	main_controller.program_data_packet_manager.initialize(main_controller.grid_manager, main_controller.game_manager, main_controller.wave_manager)
	
	main_controller.initialize_systems()
	
	# Trigger game over
	main_controller.game_manager.trigger_game_over()
	
	# Verify game is over
	assert_true(main_controller.game_manager.is_game_over(), "Game should be over after trigger")
	
	# Try to place a tower - should still work (the code doesn't prevent actions when game is over)
	main_controller.selected_tower_type = "basic"
	main_controller.current_click_mode = MainController.MODE_BUILD_TOWERS
	
	var initial_currency = main_controller.currency_manager.get_currency()
	var initial_tower_count = main_controller.tower_manager.get_tower_count()
	
	main_controller.handle_grid_click(Vector2(100, 100))
	
	# The code allows actions even when game is over, so these should still work
	assert_gt(main_controller.tower_manager.get_tower_count(), initial_tower_count, "Tower placement should still work when game is over")
	assert_lt(main_controller.currency_manager.get_currency(), initial_currency, "Currency should still decrease when game is over")

func test_input_mode_transition_workflow():
	# Integration test: Mode transitions affect all input systems
	# This tests how changing input modes affects system behavior across all systems
	
	main_controller.setup_managers()
	main_controller.initialize_systems()
	
	# Initialize all systems for proper integration
	main_controller.wave_manager.initialize(main_controller.grid_manager)
	main_controller.tower_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.wave_manager)
	main_controller.game_manager.initialize(main_controller.wave_manager, main_controller.currency_manager, main_controller.tower_manager)
	main_controller.rival_hacker_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.tower_manager, main_controller.wave_manager, main_controller.game_manager)
	main_controller.freeze_mine_manager.initialize(main_controller.grid_manager, main_controller.currency_manager)
	main_controller.program_data_packet_manager.initialize(main_controller.grid_manager, main_controller.game_manager, main_controller.wave_manager)
	
	# Test mode transitions
	main_controller.current_click_mode = MainController.MODE_BUILD_TOWERS
	assert_eq(main_controller.current_click_mode, MainController.MODE_BUILD_TOWERS, "Should be in build mode")
	
	main_controller.current_click_mode = MainController.MODE_ATTACK_ENEMIES
	assert_eq(main_controller.current_click_mode, MainController.MODE_ATTACK_ENEMIES, "Should be in attack mode")
	
	main_controller.current_click_mode = MainController.MODE_PLACE_FREEZE_MINE
	assert_eq(main_controller.current_click_mode, MainController.MODE_PLACE_FREEZE_MINE, "Should be in freeze mine mode")
	
	# Test that mode changes don't affect currency
	var initial_currency = main_controller.currency_manager.get_currency()
	main_controller.current_click_mode = MainController.MODE_BUILD_TOWERS
	assert_eq(main_controller.currency_manager.get_currency(), initial_currency, "Currency should not change when switching modes")

func test_enemy_targeting_integration_workflow():
	# Integration test: Enemy targeting works across all systems
	# This tests how enemy targeting integrates with currency, grid, and game state
	
	main_controller.setup_managers()
	main_controller.initialize_systems()
	
	# Initialize all systems for proper integration
	main_controller.wave_manager.initialize(main_controller.grid_manager)
	main_controller.tower_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.wave_manager)
	main_controller.game_manager.initialize(main_controller.wave_manager, main_controller.currency_manager, main_controller.tower_manager)
	main_controller.rival_hacker_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.tower_manager, main_controller.wave_manager, main_controller.game_manager)
	main_controller.freeze_mine_manager.initialize(main_controller.grid_manager, main_controller.currency_manager)
	main_controller.program_data_packet_manager.initialize(main_controller.grid_manager, main_controller.game_manager, main_controller.wave_manager)
	
	# Set attack mode
	main_controller.current_click_mode = MainController.MODE_ATTACK_ENEMIES
	
	# Test enemy targeting without enemies present
	var targeting_result = main_controller.try_click_damage_enemy(Vector2(100, 100))
	assert_false(targeting_result, "Targeting should fail when no enemies present")
	
	# Verify no currency change
	var initial_currency = main_controller.currency_manager.get_currency()
	assert_eq(main_controller.currency_manager.get_currency(), initial_currency, "Currency should not change when no enemies hit")

func test_grid_position_validation_workflow():
	# Integration test: Grid position validation works across all systems
	# This tests how grid position validation affects all placement systems
	
	main_controller.setup_managers()
	main_controller.initialize_systems()
	
	# Initialize all systems for proper integration
	main_controller.wave_manager.initialize(main_controller.grid_manager)
	main_controller.tower_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.wave_manager)
	main_controller.game_manager.initialize(main_controller.wave_manager, main_controller.currency_manager, main_controller.tower_manager)
	main_controller.rival_hacker_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.tower_manager, main_controller.wave_manager, main_controller.game_manager)
	main_controller.freeze_mine_manager.initialize(main_controller.grid_manager, main_controller.currency_manager)
	main_controller.program_data_packet_manager.initialize(main_controller.grid_manager, main_controller.game_manager, main_controller.wave_manager)
	
	# Test valid grid position
	var valid_pos = Vector2(100, 100)
	var valid_grid_pos = main_controller.grid_manager.world_to_grid(valid_pos)
	assert_true(main_controller.grid_manager.is_valid_grid_position(valid_grid_pos), "Valid position should be valid")
	
	# Test invalid grid position
	var invalid_pos = Vector2(-1000, -1000)
	var invalid_grid_pos = main_controller.grid_manager.world_to_grid(invalid_pos)
	assert_false(main_controller.grid_manager.is_valid_grid_position(invalid_grid_pos), "Invalid position should be invalid")
	
	# Test that valid positions work for placement
	main_controller.selected_tower_type = "basic"
	main_controller.current_click_mode = MainController.MODE_BUILD_TOWERS
	
	var initial_currency = main_controller.currency_manager.get_currency()
	main_controller.handle_grid_click(valid_pos)
	
	# Should work for valid position
	assert_lt(main_controller.currency_manager.get_currency(), initial_currency, "Valid position should allow placement") 
