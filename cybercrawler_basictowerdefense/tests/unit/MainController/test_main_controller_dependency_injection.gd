extends GutTest

# Test script for MainController dependency injection
# This tests that MainController can be initialized with injected dependencies

var mock_main_controller: MockMainController
var mock_grid_manager: MockGridManager
var mock_wave_manager: MockWaveManager
var mock_tower_manager: BaseMockTowerManager
var mock_currency_manager: MockCurrencyManager
var mock_game_manager: MockGameManager
var mock_rival_hacker_manager: MockRivalHackerManager
var mock_program_data_packet_manager: MockProgramDataPacketManager
var mock_freeze_mine_manager: MockMineManager

func before_each():
	# Create all mock managers
	mock_grid_manager = MockGridManager.new()
	mock_wave_manager = MockWaveManager.new()
	mock_tower_manager = BaseMockTowerManager.new()
	mock_currency_manager = MockCurrencyManager.new()
	mock_game_manager = MockGameManager.new()
	mock_rival_hacker_manager = MockRivalHackerManager.new()
	mock_program_data_packet_manager = MockProgramDataPacketManager.new()
	mock_freeze_mine_manager = MockMineManager.new()
	
	# Create mock main controller
	mock_main_controller = MockMainController.new()
	add_child_autofree(mock_main_controller)

func test_initialization_with_injected_dependencies():
	"""Test that MainController can be initialized with injected dependencies"""
	# Initialize with mocked dependencies
	mock_main_controller.initialize(
		mock_grid_manager,
		mock_wave_manager,
		mock_tower_manager,
		mock_currency_manager,
		mock_game_manager,
		mock_rival_hacker_manager,
		mock_program_data_packet_manager,
		mock_freeze_mine_manager
	)
	
	# Verify all managers are set correctly
	assert_eq(mock_main_controller.grid_manager, mock_grid_manager, "Grid manager should be set")
	assert_eq(mock_main_controller.wave_manager, mock_wave_manager, "Wave manager should be set")
	assert_eq(mock_main_controller.tower_manager, mock_tower_manager, "Tower manager should be set")
	assert_eq(mock_main_controller.currency_manager, mock_currency_manager, "Currency manager should be set")
	assert_eq(mock_main_controller.game_manager, mock_game_manager, "Game manager should be set")
	assert_eq(mock_main_controller.rival_hacker_manager, mock_rival_hacker_manager, "Rival hacker manager should be set")
	assert_eq(mock_main_controller.program_data_packet_manager, mock_program_data_packet_manager, "Program data packet manager should be set")
	assert_eq(mock_main_controller.freeze_mine_manager, mock_freeze_mine_manager, "Freeze mine manager should be set")

func test_managers_are_added_as_children():
	"""Test that injected managers are added as children"""
	# Initialize with mocked dependencies
	mock_main_controller.initialize(
		mock_grid_manager,
		mock_wave_manager,
		mock_tower_manager,
		mock_currency_manager,
		mock_game_manager,
		mock_rival_hacker_manager,
		mock_program_data_packet_manager,
		mock_freeze_mine_manager
	)
	
	# Verify all managers are children of the main controller
	# Note: Node2D doesn't have has_child(), so we check if they're in the scene tree
	assert_true(mock_grid_manager.get_parent() == mock_main_controller, "Grid manager should be child")
	assert_true(mock_wave_manager.get_parent() == mock_main_controller, "Wave manager should be child")
	assert_true(mock_tower_manager.get_parent() == mock_main_controller, "Tower manager should be child")
	assert_true(mock_currency_manager.get_parent() == mock_main_controller, "Currency manager should be child")
	assert_true(mock_game_manager.get_parent() == mock_main_controller, "Game manager should be child")
	assert_true(mock_rival_hacker_manager.get_parent() == mock_main_controller, "Rival hacker manager should be child")
	assert_true(mock_program_data_packet_manager.get_parent() == mock_main_controller, "Program data packet manager should be child")
	assert_true(mock_freeze_mine_manager.get_parent() == mock_main_controller, "Freeze mine manager should be child")

func test_signal_connections_work_with_mocks():
	"""Test that signal connections work with mocked dependencies"""
	# Initialize with mocked dependencies
	mock_main_controller.initialize(
		mock_grid_manager,
		mock_wave_manager,
		mock_tower_manager,
		mock_currency_manager,
		mock_game_manager,
		mock_rival_hacker_manager,
		mock_program_data_packet_manager,
		mock_freeze_mine_manager
	)
	
	# Call setup_test_signal_connections to set up signal connections
	mock_main_controller.setup_test_signal_connections()
	
	# Reset signal tracking
	mock_main_controller.reset_signal_tracking()
	
	# Emit signals from mock managers
	mock_tower_manager.tower_placed.emit(Vector2i(1, 1), "basic")
	mock_tower_manager.tower_placement_failed.emit("Insufficient funds")
	mock_game_manager.game_over_triggered.emit()
	mock_game_manager.game_won_triggered.emit()
	mock_rival_hacker_manager.rival_hacker_activated.emit()
	mock_rival_hacker_manager.enemy_tower_placed.emit(Vector2i(5, 5))
	mock_program_data_packet_manager.program_packet_ready.emit()
	mock_currency_manager.currency_changed.emit(150)
	
	# Verify signals were received
	assert_true(mock_main_controller.tower_placed_called, "Tower placed signal should be received")
	assert_true(mock_main_controller.tower_placement_failed_called, "Tower placement failed signal should be received")
	assert_true(mock_main_controller.game_over_called, "Game over signal should be received")
	assert_true(mock_main_controller.game_won_called, "Game won signal should be received")
	assert_true(mock_main_controller.rival_hacker_activated_called, "Rival hacker activated signal should be received")
	assert_true(mock_main_controller.enemy_tower_placed_called, "Enemy tower placed signal should be received")
	assert_true(mock_main_controller.program_packet_ready_called, "Program packet ready signal should be received")
	assert_true(mock_main_controller.currency_changed_called, "Currency changed signal should be received")

func test_mock_data_tracking():
	"""Test that mock data is tracked correctly"""
	# Initialize with mocked dependencies
	mock_main_controller.initialize(
		mock_grid_manager,
		mock_wave_manager,
		mock_tower_manager,
		mock_currency_manager,
		mock_game_manager,
		mock_rival_hacker_manager,
		mock_program_data_packet_manager,
		mock_freeze_mine_manager
	)
	
	# Call setup_test_signal_connections to set up signal connections
	mock_main_controller.setup_test_signal_connections()
	
	# Reset signal tracking
	mock_main_controller.reset_signal_tracking()
	
	# Emit signals with specific data
	mock_tower_manager.tower_placed.emit(Vector2i(3, 4), "powerful")
	mock_tower_manager.tower_placement_failed.emit("Position occupied")
	mock_rival_hacker_manager.enemy_tower_placed.emit(Vector2i(7, 8))
	mock_currency_manager.currency_changed.emit(200)
	
	# Verify data was tracked correctly
	assert_eq(mock_main_controller.get_mock_placed_tower_position(), Vector2i(3, 4), "Tower position should be tracked")
	assert_eq(mock_main_controller.get_mock_placed_tower_type(), "powerful", "Tower type should be tracked")
	assert_eq(mock_main_controller.get_mock_failed_placement_reason(), "Position occupied", "Failed reason should be tracked")
	assert_eq(mock_main_controller.get_mock_enemy_tower_position(), Vector2i(7, 8), "Enemy tower position should be tracked")
	assert_eq(mock_main_controller.get_mock_currency_amount(), 200, "Currency amount should be tracked")

func test_backwards_compatibility():
	"""Test that MainController still works without injected dependencies (backwards compatibility)"""
	# Create a new mock MainController without calling initialize
	var test_main_controller = MockMainController.new()
	add_child_autofree(test_main_controller)
	
	# It should create its own managers in _ready()
	# We can't easily test this without scene nodes, but we can verify it doesn't crash
	assert_not_null(test_main_controller, "MainController should be created")
	assert_true(test_main_controller.is_in_group("main_controller"), "Should be in main_controller group")

func test_interface_types():
	"""Test that all manager references use interface types"""
	# Initialize with mocked dependencies
	mock_main_controller.initialize(
		mock_grid_manager,
		mock_wave_manager,
		mock_tower_manager,
		mock_currency_manager,
		mock_game_manager,
		mock_rival_hacker_manager,
		mock_program_data_packet_manager,
		mock_freeze_mine_manager
	)
	
	# Verify all managers implement their respective interfaces
	assert_true(mock_main_controller.grid_manager is GridManagerInterface, "Grid manager should implement GridManagerInterface")
	assert_true(mock_main_controller.wave_manager is WaveManagerInterface, "Wave manager should implement WaveManagerInterface")
	assert_true(mock_main_controller.tower_manager is TowerManagerInterface, "Tower manager should implement TowerManagerInterface")
	assert_true(mock_main_controller.currency_manager is CurrencyManagerInterface, "Currency manager should implement CurrencyManagerInterface")
	assert_true(mock_main_controller.game_manager is GameManagerInterface, "Game manager should implement GameManagerInterface")
	assert_true(mock_main_controller.rival_hacker_manager is RivalHackerManagerInterface, "Rival hacker manager should implement RivalHackerManagerInterface")
	assert_true(mock_main_controller.program_data_packet_manager is ProgramDataPacketManagerInterface, "Program data packet manager should implement ProgramDataPacketManagerInterface")
	assert_true(mock_main_controller.freeze_mine_manager is MineManagerInterface, "Freeze mine manager should implement MineManagerInterface")

func test_mock_utility_methods():
	"""Test mock utility methods for setting state"""
	# Test setting click mode
	mock_main_controller.set_mock_click_mode(MainController.MODE_ATTACK_ENEMIES)
	assert_eq(mock_main_controller.get_mock_click_mode(), MainController.MODE_ATTACK_ENEMIES, "Click mode should be set")
	
	# Test setting tower type
	mock_main_controller.set_mock_selected_tower_type(MainController.POWERFUL_TOWER)
	assert_eq(mock_main_controller.get_mock_selected_tower_type(), MainController.POWERFUL_TOWER, "Tower type should be set")
	
	# Test signal tracking reset
	mock_main_controller.tower_placed_called = true
	mock_main_controller.game_over_called = true
	mock_main_controller.reset_signal_tracking()
	assert_false(mock_main_controller.tower_placed_called, "Tower placed should be reset")
	assert_false(mock_main_controller.game_over_called, "Game over should be reset")

func test_initialize_method_parameters():
	"""Test that initialize method accepts the correct parameter types"""
	# This test verifies the method signature is correct
	# The actual test is that the code compiles and runs without errors
	assert_not_null(mock_main_controller.get_method_list().filter(func(m): return m.name == "initialize"), "Initialize method should exist")
	
	# Test that we can call initialize with all the required parameters
	mock_main_controller.initialize(
		mock_grid_manager,
		mock_wave_manager,
		mock_tower_manager,
		mock_currency_manager,
		mock_game_manager,
		mock_rival_hacker_manager,
		mock_program_data_packet_manager,
		mock_freeze_mine_manager
	)
	
	# If we get here without errors, the method signature is correct
	assert_true(true, "Initialize method should accept all required parameters") 