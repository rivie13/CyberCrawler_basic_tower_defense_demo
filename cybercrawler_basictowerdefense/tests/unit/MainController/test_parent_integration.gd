# test_parent_integration.gd - Tests for parent repository integration
extends GutTest

# Preload all mock classes to avoid parser errors in editor - FIXED to use existing files only
const MockGridManager = preload("res://tests/unit/Mocks/MockGridManager.gd")
const MockWaveManager = preload("res://tests/unit/Mocks/MockWaveManager.gd")
const BaseMockTowerManager = preload("res://tests/unit/Mocks/BaseMockTowerManager.gd")
const MockCurrencyManager = preload("res://tests/unit/Mocks/MockCurrencyManager.gd")
const MockGameManager = preload("res://tests/unit/Mocks/MockGameManager.gd")
const MockRivalHackerManager = preload("res://tests/unit/Mocks/MockRivalHackerManager.gd")
const MockProgramDataPacketManager = preload("res://tests/unit/Mocks/MockProgramDataPacketManager.gd")
const MockMineManager = preload("res://tests/unit/Mocks/MockMineManager.gd")

# Preload MissionContext to avoid parser errors
const MissionContext = preload("res://scripts/Data/MissionContext.gd")

var main_controller: MainController
var mock_parent_interface: Node
var mock_grid_manager: MockGridManager
var mock_wave_manager: MockWaveManager
var mock_tower_manager: BaseMockTowerManager
var mock_currency_manager: MockCurrencyManager
var mock_game_manager: MockGameManager
var mock_rival_hacker_manager: MockRivalHackerManager
var mock_packet_manager: MockProgramDataPacketManager
var mock_mine_manager: MockMineManager

func before_each():
	# Create MainController
	main_controller = MainController.new()
	
	# Create mock parent interface
	mock_parent_interface = Node.new()
	mock_parent_interface.name = "MockParentInterface"
	
	# Create all mock managers
	mock_grid_manager = MockGridManager.new()
	mock_wave_manager = MockWaveManager.new()
	mock_tower_manager = BaseMockTowerManager.new()
	mock_currency_manager = MockCurrencyManager.new()
	mock_game_manager = MockGameManager.new()
	mock_rival_hacker_manager = MockRivalHackerManager.new()
	mock_packet_manager = MockProgramDataPacketManager.new()
	mock_mine_manager = MockMineManager.new()

func after_each():
	if is_instance_valid(main_controller):
		main_controller.queue_free()
	if is_instance_valid(mock_parent_interface):
		mock_parent_interface.queue_free()

func test_parent_communication_signals_exist():
	"""Test that parent integration signals are properly defined"""
	# Check signals exist
	assert_true(main_controller.has_signal("td_session_completed"))
	assert_true(main_controller.has_signal("rival_hacker_activated"))
	assert_true(main_controller.has_signal("td_alert_generated"))
	assert_true(main_controller.has_signal("stealth_alert_received"))

func test_background_execution_mode():
	"""Test background execution mode functionality"""
	# Initialize with managers
	main_controller.initialize(mock_grid_manager, mock_wave_manager, mock_tower_manager,
							   mock_currency_manager, mock_game_manager, mock_rival_hacker_manager,
							   mock_packet_manager, mock_mine_manager, mock_parent_interface)
	
	# Should start in foreground mode
	assert_eq(main_controller.execution_mode, MainController.ExecutionMode.FOREGROUND)
	
	# Switch to background mode
	main_controller.set_background_mode(true)
	assert_eq(main_controller.execution_mode, MainController.ExecutionMode.BACKGROUND)
	
	# Switch back to foreground mode
	main_controller.set_background_mode(false)
	assert_eq(main_controller.execution_mode, MainController.ExecutionMode.FOREGROUND)

func test_parent_interface_initialization():
	"""Test parent interface is properly stored during initialization"""
	# Initialize with parent interface
	main_controller.initialize(mock_grid_manager, mock_wave_manager, mock_tower_manager,
							   mock_currency_manager, mock_game_manager, mock_rival_hacker_manager,
							   mock_packet_manager, mock_mine_manager, mock_parent_interface)
	
	# Parent interface should be stored
	assert_eq(main_controller.parent_interface, mock_parent_interface)

func test_mission_context_application():
	"""Test mission context is applied during initialization"""
	# Create mission context
	var mission_context = MissionContext.new("test_mission", 1.5, 800)
	
	# Initialize with mission context
	main_controller.initialize(mock_grid_manager, mock_wave_manager, mock_tower_manager,
							   mock_currency_manager, mock_game_manager, mock_rival_hacker_manager,
							   mock_packet_manager, mock_mine_manager, mock_parent_interface, mission_context)
	
	# Currency should be set to mission context value
	assert_true(mock_currency_manager.set_currency_called)
	assert_eq(mock_currency_manager.last_set_currency_value, 800)

func test_mission_context_without_parent():
	"""Test mission context works even without parent interface"""
	var mission_context = MissionContext.new("test_mission", 1.2, 500)
	
	# Initialize without parent interface but with mission context
	main_controller.initialize(mock_grid_manager, mock_wave_manager, mock_tower_manager,
							   mock_currency_manager, mock_game_manager, mock_rival_hacker_manager,
							   mock_packet_manager, mock_mine_manager, null, mission_context)
	
	# Mission context should still be applied
	assert_true(mock_currency_manager.set_currency_called)
	assert_eq(mock_currency_manager.last_set_currency_value, 500)

func test_session_state_retrieval():
	"""Test getting current session state for parent coordination"""
	# Initialize
	main_controller.initialize(mock_grid_manager, mock_wave_manager, mock_tower_manager,
							   mock_currency_manager, mock_game_manager, mock_rival_hacker_manager,
							   mock_packet_manager, mock_mine_manager, mock_parent_interface)
	
	# Set up mock return values
	mock_currency_manager.set_mock_currency(150)
	mock_game_manager.set_mock_game_over(false)
	
	# Get session state
	var session_state = main_controller.get_session_state()
	
	# Validate session state structure
	assert_true(session_state.has("execution_mode"))
	assert_true(session_state.has("currency"))
	assert_true(session_state.has("game_active"))
	assert_eq(session_state.currency, 150)
	assert_eq(session_state.game_active, true)

func test_rival_hacker_signal_emission():
	"""Test that rival hacker activation emits parent signals"""
	# Set up signal monitoring
	watch_signals(main_controller)
	
	# Initialize with parent interface
	main_controller.initialize(mock_grid_manager, mock_wave_manager, mock_tower_manager,
							   mock_currency_manager, mock_game_manager, mock_rival_hacker_manager,
							   mock_packet_manager, mock_mine_manager, mock_parent_interface)
	
	# Simulate rival hacker activation
	mock_rival_hacker_manager.rival_hacker_activated.emit()
	
	# Should emit parent integration signals
	assert_signal_emitted(main_controller, "rival_hacker_activated")
	assert_signal_emitted(main_controller, "td_alert_generated")

func test_game_completion_signal_emission():
	"""Test that game completion emits parent session completion signal"""
	# Set up signal monitoring
	watch_signals(main_controller)
	
	# Initialize with parent interface
	main_controller.initialize(mock_grid_manager, mock_wave_manager, mock_tower_manager,
							   mock_currency_manager, mock_game_manager, mock_rival_hacker_manager,
							   mock_packet_manager, mock_mine_manager, mock_parent_interface)
	
	# Simulate game over
	mock_game_manager.game_over_triggered.emit()
	
	# Should emit session completion signal
	assert_signal_emitted(main_controller, "td_session_completed")

func test_parent_signals_only_connected_with_parent_interface():
	"""Test that parent signals are only connected when parent interface is provided"""
	# Initialize without parent interface
	main_controller.initialize(mock_grid_manager, mock_wave_manager, mock_tower_manager,
							   mock_currency_manager, mock_game_manager, mock_rival_hacker_manager,
							   mock_packet_manager, mock_mine_manager)
	
	# Parent interface should be null
	assert_null(main_controller.parent_interface)
	
	# Watch signals
	watch_signals(main_controller)
	
	# Simulate rival hacker activation
	mock_rival_hacker_manager.rival_hacker_activated.emit()
	
	# Parent signals should NOT be emitted (no parent interface)
	assert_signal_not_emitted(main_controller, "rival_hacker_activated")
	assert_signal_not_emitted(main_controller, "td_alert_generated")

func test_backwards_compatibility():
	"""Test that existing initialization still works without parent parameters"""
	# Initialize with original method signature (without parent parameters)
	main_controller.initialize(mock_grid_manager, mock_wave_manager, mock_tower_manager,
							   mock_currency_manager, mock_game_manager, mock_rival_hacker_manager,
							   mock_packet_manager, mock_mine_manager)
	
	# Should work fine with null parent interface
	assert_null(main_controller.parent_interface)
	assert_eq(main_controller.execution_mode, MainController.ExecutionMode.FOREGROUND)
	
	# All managers should be properly assigned
	assert_eq(main_controller.grid_manager, mock_grid_manager)
	assert_eq(main_controller.currency_manager, mock_currency_manager)

func test_mission_context_resource():
	"""Test MissionContext resource class functionality"""
	var context = MissionContext.new("stealth_mission_01", 2.0, 1000)
	
	assert_eq(context.mission_id, "stealth_mission_01")
	assert_eq(context.difficulty_modifier, 2.0)
	assert_eq(context.starting_currency, 1000)
	assert_eq(context.available_towers, ["basic", "powerful"])
	
	# Test summary
	var summary = context.get_mission_summary()
	assert_true(summary.contains("stealth_mission_01"))
	assert_true(summary.contains("2.0"))
	assert_true(summary.contains("1000"))
