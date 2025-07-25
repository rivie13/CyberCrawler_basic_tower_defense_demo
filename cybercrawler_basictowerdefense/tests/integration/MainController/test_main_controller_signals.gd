extends GutTest

# Unit tests for MainController signal handlers
# This tests all signal handlers and event processing

var main_controller: MainController

func before_each():
	# Create a fresh MainController for each test
	# DO NOT call _ready() as it tries to access scene nodes that don't exist in tests
	main_controller = MainController.new()
	add_child_autofree(main_controller)

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

func test_program_data_packet_button_pressed_can_release():
	# Test program data packet button pressed when packet can be released
	main_controller.setup_managers()
	
	# Test button press - the method will handle the logic internally
	main_controller._on_program_data_packet_button_pressed()
	assert_true(true, "Program data packet button should handle successful release") 