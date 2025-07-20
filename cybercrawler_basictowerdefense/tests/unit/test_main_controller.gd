extends GutTest

# Unit tests for MainController
# This tests the main game controller that orchestrates all systems

var main_controller: MainController

func before_each():
	# Create a fresh MainController for each test
	main_controller = MainController.new()
	add_child_autofree(main_controller)

func test_main_controller_initialization():
	# Test that MainController initializes with correct default values
	assert_eq(main_controller.selected_tower_type, MainController.BASIC_TOWER, "Default tower type should be basic")
	assert_eq(main_controller.current_click_mode, MainController.MODE_BUILD_TOWERS, "Default click mode should be build towers")
	assert_not_null(main_controller, "MainController should be created")

func test_main_controller_constants():
	# Test that all constants are properly defined
	assert_eq(MainController.BASIC_TOWER, "basic", "BASIC_TOWER constant should be 'basic'")
	assert_eq(MainController.POWERFUL_TOWER, "powerful", "POWERFUL_TOWER constant should be 'powerful'")
	assert_eq(MainController.FREEZE_MINE, "freeze_mine", "FREEZE_MINE constant should be 'freeze_mine'")
	assert_eq(MainController.MODE_BUILD_TOWERS, "build_towers", "MODE_BUILD_TOWERS constant should be 'build_towers'")
	assert_eq(MainController.MODE_ATTACK_ENEMIES, "attack_enemies", "MODE_ATTACK_ENEMIES constant should be 'attack_enemies'")
	assert_eq(MainController.MODE_PLACE_FREEZE_MINE, "place_freeze_mine", "MODE_PLACE_FREEZE_MINE constant should be 'place_freeze_mine'")

func test_main_controller_color_constants():
	# Test that color constants are properly defined
	assert_not_null(MainController.VICTORY_COLOR, "VICTORY_COLOR should be defined")
	assert_not_null(MainController.DEFEAT_COLOR, "DEFEAT_COLOR should be defined")
	assert_not_null(MainController.WARNING_COLOR, "WARNING_COLOR should be defined")

func test_setup_managers():
	# Test that setup_managers creates all required managers
	main_controller.setup_managers()
	
	# Verify all managers were created
	assert_not_null(main_controller.grid_manager, "GridManager should be created")
	assert_not_null(main_controller.wave_manager, "WaveManager should be created")
	assert_not_null(main_controller.tower_manager, "TowerManager should be created")
	assert_not_null(main_controller.currency_manager, "CurrencyManager should be created")
	assert_not_null(main_controller.game_manager, "GameManager should be created")
	assert_not_null(main_controller.rival_hacker_manager, "RivalHackerManager should be created")
	assert_not_null(main_controller.program_data_packet_manager, "ProgramDataPacketManager should be created")
	assert_not_null(main_controller.freeze_mine_manager, "FreezeMineManager should be created")

func test_managers_are_added_as_children():
	# Test that managers are properly added to the scene tree
	main_controller.setup_managers()
	
	# Verify managers are children of MainController
	assert_true(main_controller.grid_manager.get_parent() == main_controller, "GridManager should be child of MainController")
	assert_true(main_controller.wave_manager.get_parent() == main_controller, "WaveManager should be child of MainController")
	assert_true(main_controller.tower_manager.get_parent() == main_controller, "TowerManager should be child of MainController")
	assert_true(main_controller.currency_manager.get_parent() == main_controller, "CurrencyManager should be child of MainController")
	assert_true(main_controller.game_manager.get_parent() == main_controller, "GameManager should be child of MainController")
	assert_true(main_controller.rival_hacker_manager.get_parent() == main_controller, "RivalHackerManager should be child of MainController")
	assert_true(main_controller.program_data_packet_manager.get_parent() == main_controller, "ProgramDataPacketManager should be child of MainController")
	assert_true(main_controller.freeze_mine_manager.get_parent() == main_controller, "FreezeMineManager should be child of MainController")

func test_main_controller_joins_main_controller_group():
	# Test that MainController joins the correct group for signal communication
	main_controller.setup_managers()
	
	# Verify MainController is in the main_controller group
	assert_true(main_controller.is_in_group("main_controller"), "MainController should be in main_controller group")

func test_tower_selection_system():
	# Test tower selection functionality
	main_controller.setup_managers()
	
	# Test basic tower selection
	main_controller._on_basic_tower_selected()
	assert_eq(main_controller.selected_tower_type, MainController.BASIC_TOWER, "Should select basic tower")
	
	# Test powerful tower selection
	main_controller._on_powerful_tower_selected()
	assert_eq(main_controller.selected_tower_type, MainController.POWERFUL_TOWER, "Should select powerful tower")

func test_click_mode_toggle():
	# Test click mode toggle functionality
	main_controller.setup_managers()
	
	# Test initial mode
	assert_eq(main_controller.current_click_mode, MainController.MODE_BUILD_TOWERS, "Should start in build towers mode")
	
	# Test toggle to attack mode
	main_controller._on_mode_toggle_pressed()
	assert_eq(main_controller.current_click_mode, MainController.MODE_ATTACK_ENEMIES, "Should switch to attack enemies mode")
	
	# Test toggle back to build mode
	main_controller._on_mode_toggle_pressed()
	assert_eq(main_controller.current_click_mode, MainController.MODE_BUILD_TOWERS, "Should switch back to build towers mode")

func test_freeze_mine_mode_selection():
	# Test freeze mine mode selection
	main_controller.setup_managers()
	
	# Test freeze mine button press
	main_controller._on_freeze_mine_button_pressed()
	assert_eq(main_controller.current_click_mode, MainController.MODE_PLACE_FREEZE_MINE, "Should switch to place freeze mine mode")

func test_backwards_compatibility_tower_selection():
	# Test backwards compatibility method
	main_controller.setup_managers()
	
	# Test that _on_tower_selected calls _on_basic_tower_selected
	main_controller._on_tower_selected()
	assert_eq(main_controller.selected_tower_type, MainController.BASIC_TOWER, "Backwards compatibility should select basic tower")

func test_currency_changed_handler():
	# Test currency changed signal handler
	main_controller.setup_managers()
	
	# Test that currency changed handler doesn't crash
	main_controller._on_currency_changed(100)
	assert_true(true, "Currency changed handler should not crash")

func test_tower_placed_handler():
	# Test tower placed signal handler
	main_controller.setup_managers()
	
	# Test that tower placed handler doesn't crash
	main_controller._on_tower_placed(Vector2i(1, 1), MainController.BASIC_TOWER)
	assert_true(true, "Tower placed handler should not crash")

func test_tower_placement_failed_handler():
	# Test tower placement failed signal handler
	main_controller.setup_managers()
	
	# Test that tower placement failed handler doesn't crash
	main_controller._on_tower_placement_failed("Insufficient funds")
	assert_true(true, "Tower placement failed handler should not crash")

func test_ui_update_timer_timeout():
	# Test UI update timer timeout handler
	main_controller.setup_managers()
	
	# Test that UI update timer timeout handler doesn't crash
	main_controller._on_ui_update_timer_timeout()
	assert_true(true, "UI update timer timeout handler should not crash")

func test_game_over_handler():
	# Test game over signal handler
	main_controller.setup_managers()
	
	# Test that game over handler doesn't crash
	main_controller._on_game_over()
	assert_true(true, "Game over handler should not crash")

func test_game_won_handler():
	# Test game won signal handler
	main_controller.setup_managers()
	
	# Test that game won handler doesn't crash
	main_controller._on_game_won()
	assert_true(true, "Game won handler should not crash")

func test_rival_hacker_activated_handler():
	# Test rival hacker activated signal handler
	main_controller.setup_managers()
	
	# Test that rival hacker activated handler doesn't crash
	main_controller._on_rival_hacker_activated()
	assert_true(true, "Rival hacker activated handler should not crash")

func test_enemy_tower_placed_handler():
	# Test enemy tower placed signal handler
	main_controller.setup_managers()
	
	# Test that enemy tower placed handler doesn't crash
	main_controller._on_enemy_tower_placed(Vector2i(5, 5))
	assert_true(true, "Enemy tower placed handler should not crash")

func test_program_packet_ready_handler():
	# Test program packet ready signal handler
	main_controller.setup_managers()
	
	# Test that program packet ready handler doesn't crash
	main_controller._on_program_packet_ready()
	assert_true(true, "Program packet ready handler should not crash")

func test_program_packet_destroyed_handler():
	# Test program packet destroyed signal handler
	main_controller.setup_managers()
	
	# Create a mock packet for testing
	var mock_packet = preload("res://scripts/ProgramPacket/ProgramDataPacket.gd").new()
	add_child_autofree(mock_packet)
	
	# Test that program packet destroyed handler doesn't crash
	main_controller._on_program_packet_destroyed(mock_packet)
	assert_true(true, "Program packet destroyed handler should not crash")

func test_program_packet_reached_end_handler():
	# Test program packet reached end signal handler
	main_controller.setup_managers()
	
	# Create a mock packet for testing
	var mock_packet = preload("res://scripts/ProgramPacket/ProgramDataPacket.gd").new()
	add_child_autofree(mock_packet)
	
	# Test that program packet reached end handler doesn't crash
	main_controller._on_program_packet_reached_end(mock_packet)
	assert_true(true, "Program packet reached end handler should not crash")

func test_program_data_packet_button_pressed():
	# Test program data packet button pressed handler
	main_controller.setup_managers()
	
	# Test that program data packet button pressed handler doesn't crash
	main_controller._on_program_data_packet_button_pressed()
	assert_true(true, "Program data packet button pressed handler should not crash")

func test_freeze_mine_placed_handler():
	# Test freeze mine placed signal handler
	main_controller.setup_managers()
	
	# Create a mock freeze mine for testing
	var mock_mine = preload("res://scripts/FreezeMine/FreezeMine.gd").new()
	add_child_autofree(mock_mine)
	mock_mine.grid_position = Vector2i(2, 2)
	
	# Test that freeze mine placed handler doesn't crash
	main_controller._on_freeze_mine_placed(mock_mine)
	assert_true(true, "Freeze mine placed handler should not crash")

func test_freeze_mine_placement_failed_handler():
	# Test freeze mine placement failed signal handler
	main_controller.setup_managers()
	
	# Test that freeze mine placement failed handler doesn't crash
	main_controller._on_freeze_mine_placement_failed("Position occupied")
	assert_true(true, "Freeze mine placement failed handler should not crash")

func test_freeze_mine_triggered_handler():
	# Test freeze mine triggered signal handler
	main_controller.setup_managers()
	
	# Create a mock freeze mine for testing
	var mock_mine = preload("res://scripts/FreezeMine/FreezeMine.gd").new()
	add_child_autofree(mock_mine)
	mock_mine.grid_position = Vector2i(3, 3)
	
	# Test that freeze mine triggered handler doesn't crash
	main_controller._on_freeze_mine_triggered(mock_mine)
	assert_true(true, "Freeze mine triggered handler should not crash")

func test_freeze_mine_depleted_handler():
	# Test freeze mine depleted signal handler
	main_controller.setup_managers()
	
	# Create a mock freeze mine for testing
	var mock_mine = preload("res://scripts/FreezeMine/FreezeMine.gd").new()
	add_child_autofree(mock_mine)
	mock_mine.grid_position = Vector2i(4, 4)
	
	# Test that freeze mine depleted handler doesn't crash
	main_controller._on_freeze_mine_depleted(mock_mine)
	assert_true(true, "Freeze mine depleted handler should not crash")

func test_show_temp_message():
	# Test temporary message display functionality
	main_controller.setup_managers()
	
	# Test that show_temp_message doesn't crash
	main_controller.show_temp_message("Test message", 1.0)
	assert_true(true, "Show temp message should not crash")

func test_destroy_all_projectiles():
	# Test projectile destruction functionality
	main_controller.setup_managers()
	
	# Test that destroy_all_projectiles doesn't crash
	main_controller.destroy_all_projectiles()
	assert_true(true, "Destroy all projectiles should not crash")

func test_stop_all_game_activity():
	# Test stop all game activity functionality
	main_controller.setup_managers()
	
	# Test that stop_all_game_activity doesn't crash
	main_controller.stop_all_game_activity()
	assert_true(true, "Stop all game activity should not crash")

func test_show_victory_screen():
	# Test victory screen display functionality
	main_controller.setup_managers()
	
	# Test that show_victory_screen doesn't crash
	main_controller.show_victory_screen()
	assert_true(true, "Show victory screen should not crash")

func test_show_game_over_screen():
	# Test game over screen display functionality
	main_controller.setup_managers()
	
	# Test that show_game_over_screen doesn't crash
	main_controller.show_game_over_screen()
	assert_true(true, "Show game over screen should not crash")

func test_update_packet_ui():
	# Test packet UI update functionality
	main_controller.setup_managers()
	
	# Test that update_packet_ui doesn't crash
	main_controller.update_packet_ui()
	assert_true(true, "Update packet UI should not crash")

func test_update_tower_selection_ui():
	# Test tower selection UI update functionality
	main_controller.setup_managers()
	
	# Test that update_tower_selection_ui doesn't crash
	main_controller.update_tower_selection_ui()
	assert_true(true, "Update tower selection UI should not crash")

func test_update_mode_ui():
	# Test mode UI update functionality
	main_controller.setup_managers()
	
	# Test that update_mode_ui doesn't crash
	main_controller.update_mode_ui()
	assert_true(true, "Update mode UI should not crash")

func test_update_info_label():
	# Test info label update functionality
	main_controller.setup_managers()
	
	# Test that update_info_label doesn't crash
	main_controller.update_info_label()
	assert_true(true, "Update info label should not crash")

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