extends GutTest

# Test script for GameManagerInterface
# This tests that the interface contract is properly defined and testable

var mock_game_manager: MockGameManager

func before_each():
	mock_game_manager = MockGameManager.new()
	add_child_autofree(mock_game_manager)

func test_interface_contract():
	"""Test that GameManagerInterface defines the expected contract"""
	assert_not_null(mock_game_manager, "MockGameManager should be created")
	assert_true(mock_game_manager is GameManagerInterface, "MockGameManager should implement GameManagerInterface")

func test_initial_state():
	"""Test initial state of mock game manager"""
	assert_false(mock_game_manager.is_game_over(), "Should not be game over initially")
	assert_eq(mock_game_manager.get_player_health(), 10, "Should start with 10 health")
	assert_eq(mock_game_manager.get_enemies_killed(), 0, "Should start with 0 enemies killed")
	assert_false(mock_game_manager.game_over_triggered_called, "Game over signal should not be triggered initially")
	assert_false(mock_game_manager.game_won_triggered_called, "Game won signal should not be triggered initially")

func test_trigger_game_over():
	"""Test triggering game over state"""
	mock_game_manager.trigger_game_over()
	
	assert_true(mock_game_manager.is_game_over(), "Should be game over after trigger")
	assert_true(mock_game_manager.game_over_triggered_called, "Game over signal should be triggered")
	assert_false(mock_game_manager.game_won_triggered_called, "Game won signal should not be triggered")

func test_trigger_game_won():
	"""Test triggering game won state (wave survival)"""
	mock_game_manager.trigger_game_won()
	
	assert_true(mock_game_manager.is_game_over(), "Should be game over after win")
	assert_true(mock_game_manager.game_won_triggered_called, "Game won signal should be triggered")
	assert_false(mock_game_manager.game_over_triggered_called, "Game over signal should not be triggered")
	assert_eq(mock_game_manager.mock_victory_type, GameManagerInterface.VictoryType.WAVE_SURVIVAL, "Should set wave survival victory type")

func test_trigger_game_won_packet():
	"""Test triggering game won state (program data packet)"""
	mock_game_manager.trigger_game_won_packet()
	
	assert_true(mock_game_manager.is_game_over(), "Should be game over after win")
	assert_true(mock_game_manager.game_won_triggered_called, "Game won signal should be triggered")
	assert_false(mock_game_manager.game_over_triggered_called, "Game over signal should not be triggered")
	assert_eq(mock_game_manager.mock_victory_type, GameManagerInterface.VictoryType.PROGRAM_DATA_PACKET, "Should set program data packet victory type")

func test_get_victory_data():
	"""Test getting victory data"""
	var victory_data = mock_game_manager.get_victory_data()
	
	assert_eq(victory_data["victory_type"], GameManagerInterface.VictoryType.WAVE_SURVIVAL, "Should include victory type")
	assert_eq(victory_data["max_waves"], 10, "Should include max waves")
	assert_eq(victory_data["current_wave"], 10, "Should include current wave")
	assert_eq(victory_data["enemies_killed"], 0, "Should include enemies killed")
	assert_eq(victory_data["currency"], 100, "Should include currency")
	assert_eq(victory_data["time_played"], "1:30", "Should include time played")

func test_get_game_over_data():
	"""Test getting game over data"""
	var game_over_data = mock_game_manager.get_game_over_data()
	
	assert_eq(game_over_data["waves_survived"], 5, "Should include waves survived")
	assert_eq(game_over_data["current_wave"], 6, "Should include current wave")
	assert_eq(game_over_data["enemies_killed"], 0, "Should include enemies killed")
	assert_eq(game_over_data["currency"], 50, "Should include currency")
	assert_eq(game_over_data["time_played"], "0:45", "Should include time played")
	assert_eq(game_over_data["player_health"], 10, "Should include player health")

func test_get_info_label_text():
	"""Test getting info label text"""
	var info_text = mock_game_manager.get_info_label_text()
	
	assert_string_contains(info_text, "Wave: 1", "Should include wave number")
	assert_string_contains(info_text, "Health: 10", "Should include player health")
	assert_string_contains(info_text, "Currency: 100", "Should include currency")
	assert_string_contains(info_text, "Enemies Killed: 0", "Should include enemies killed")
	assert_string_contains(info_text, "Cost: 50", "Should include tower cost")

func test_format_time():
	"""Test time formatting"""
	assert_eq(mock_game_manager.format_time(0), "0:00", "Should format 0 seconds correctly")
	assert_eq(mock_game_manager.format_time(30), "0:30", "Should format 30 seconds correctly")
	assert_eq(mock_game_manager.format_time(60), "1:00", "Should format 1 minute correctly")
	assert_eq(mock_game_manager.format_time(90), "1:30", "Should format 1 minute 30 seconds correctly")
	assert_eq(mock_game_manager.format_time(125), "2:05", "Should format 2 minutes 5 seconds correctly")

func test_mock_utility_methods():
	"""Test mock utility methods for setting state"""
	mock_game_manager.set_mock_player_health(5)
	assert_eq(mock_game_manager.get_player_health(), 5, "Should update player health")
	
	mock_game_manager.set_mock_enemies_killed(15)
	assert_eq(mock_game_manager.get_enemies_killed(), 15, "Should update enemies killed")
	
	mock_game_manager.set_mock_session_time(120.5)
	assert_eq(mock_game_manager.get_session_time(), 120.5, "Should update session time")
	
	mock_game_manager.set_mock_game_over(true)
	assert_true(mock_game_manager.is_game_over(), "Should update game over state")
	
	mock_game_manager.set_mock_game_won(true)
	assert_true(mock_game_manager.is_game_over(), "Should update game won state")

func test_signal_tracking_reset():
	"""Test signal tracking reset functionality"""
	mock_game_manager.trigger_game_over()
	mock_game_manager.trigger_game_won()
	
	assert_true(mock_game_manager.game_over_triggered_called, "Game over should be tracked")
	assert_true(mock_game_manager.game_won_triggered_called, "Game won should be tracked")
	
	mock_game_manager.reset_signal_tracking()
	
	assert_false(mock_game_manager.game_over_triggered_called, "Game over tracking should be reset")
	assert_false(mock_game_manager.game_won_triggered_called, "Game won tracking should be reset")

func test_victory_type_enum():
	"""Test that VictoryType enum is accessible"""
	assert_eq(GameManagerInterface.VictoryType.WAVE_SURVIVAL, 0, "WAVE_SURVIVAL should be 0")
	assert_eq(GameManagerInterface.VictoryType.PROGRAM_DATA_PACKET, 1, "PROGRAM_DATA_PACKET should be 1")

func test_interface_methods_exist():
	"""Test that all required interface methods exist"""
	assert_not_null(mock_game_manager.get_method_list().filter(func(m): return m.name == "is_game_over"), "is_game_over method should exist")
	assert_not_null(mock_game_manager.get_method_list().filter(func(m): return m.name == "get_player_health"), "get_player_health method should exist")
	assert_not_null(mock_game_manager.get_method_list().filter(func(m): return m.name == "get_enemies_killed"), "get_enemies_killed method should exist")
	assert_not_null(mock_game_manager.get_method_list().filter(func(m): return m.name == "trigger_game_over"), "trigger_game_over method should exist")
	assert_not_null(mock_game_manager.get_method_list().filter(func(m): return m.name == "trigger_game_won"), "trigger_game_won method should exist")
	assert_not_null(mock_game_manager.get_method_list().filter(func(m): return m.name == "trigger_game_won_packet"), "trigger_game_won_packet method should exist")
	assert_not_null(mock_game_manager.get_method_list().filter(func(m): return m.name == "get_victory_data"), "get_victory_data method should exist")
	assert_not_null(mock_game_manager.get_method_list().filter(func(m): return m.name == "get_game_over_data"), "get_game_over_data method should exist")
	assert_not_null(mock_game_manager.get_method_list().filter(func(m): return m.name == "get_info_label_text"), "get_info_label_text method should exist")
	assert_not_null(mock_game_manager.get_method_list().filter(func(m): return m.name == "get_session_time"), "get_session_time method should exist")
	assert_not_null(mock_game_manager.get_method_list().filter(func(m): return m.name == "format_time"), "format_time method should exist")
	assert_not_null(mock_game_manager.get_method_list().filter(func(m): return m.name == "cleanup_projectiles"), "cleanup_projectiles method should exist")
	assert_not_null(mock_game_manager.get_method_list().filter(func(m): return m.name == "_on_play_again_pressed"), "_on_play_again_pressed method should exist")
	assert_not_null(mock_game_manager.get_method_list().filter(func(m): return m.name == "_on_exit_game_pressed"), "_on_exit_game_pressed method should exist") 