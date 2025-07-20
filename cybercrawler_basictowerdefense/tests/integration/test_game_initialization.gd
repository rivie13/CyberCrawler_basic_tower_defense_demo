extends GutTest

# Small integration test to verify game initialization
# This tests that MainController properly sets up all managers and connects them

var main_controller: MainController

func before_each():
	# Create a fresh MainController for each test
	main_controller = MainController.new()
	add_child_autofree(main_controller)

func test_game_initialization_creates_all_managers():
	# Test that MainController creates all required managers
	# This is the SMALLEST possible integration test
	
	# Call setup_managers to create all the managers
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

func test_default_click_mode_is_build_towers():
	# Test that the default click mode is set correctly
	main_controller.setup_managers()
	
	# Verify default click mode
	assert_eq(main_controller.current_click_mode, MainController.MODE_BUILD_TOWERS, "Default click mode should be build towers")

func test_default_tower_type_is_basic():
	# Test that the default tower type is set correctly
	main_controller.setup_managers()
	
	# Verify default tower type
	assert_eq(main_controller.selected_tower_type, MainController.BASIC_TOWER, "Default tower type should be basic") 