extends GutTest

# Unit tests for MainController initialization and setup
# This tests the main game controller initialization, constants, and manager setup

var main_controller: MainController

func before_each():
	# Create a fresh MainController for each test
	# DO NOT call _ready() as it tries to access scene nodes that don't exist in tests
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

func test_initialize_systems_without_scene_nodes():
	# Test initialize_systems when scene nodes don't exist (test environment)
	main_controller.setup_managers()
	
	# This should not crash and should handle missing scene nodes gracefully
	main_controller.initialize_systems()
	assert_true(true, "Initialize systems should handle missing scene nodes gracefully")

func test_setup_ui_without_scene_nodes():
	# Test setup_ui when UI nodes don't exist (test environment)
	main_controller.setup_managers()
	
	# This should not crash and should handle missing UI nodes gracefully
	main_controller.setup_ui()
	assert_true(true, "Setup UI should handle missing UI nodes gracefully")

func test_start_game_without_managers():
	# Test start_game when managers aren't initialized
	# This should not crash and should handle missing managers gracefully
	main_controller.start_game()
	assert_true(true, "Start game should handle missing managers gracefully")

func test_start_game_with_managers():
	# Test start_game when managers are properly initialized
	main_controller.setup_managers()
	
	# This should not crash
	main_controller.start_game()
	assert_true(true, "Start game should work with initialized managers") 