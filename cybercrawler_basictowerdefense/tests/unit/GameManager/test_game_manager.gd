extends GutTest

# Unit test for GameManager.gd (real implementation, mocks for dependencies)
var game_manager: GameManager
var mock_wave_manager: MockWaveManager
var mock_currency_manager: MockCurrencyManager
var mock_tower_manager: BaseMockTowerManager

func before_each():
	game_manager = GameManager.new()
	mock_wave_manager = MockWaveManager.new()
	mock_currency_manager = MockCurrencyManager.new()
	mock_tower_manager = BaseMockTowerManager.new()
	add_child_autofree(game_manager)
	add_child_autofree(mock_wave_manager)
	add_child_autofree(mock_currency_manager)
	add_child_autofree(mock_tower_manager)
	game_manager.initialize(mock_wave_manager, mock_currency_manager, mock_tower_manager)
	await wait_physics_frames(1) # Yield for a frame to ensure signal delivery works

func test_initial_state():
	assert_eq(game_manager.player_health, 10, "Initial player health should be 10")
	assert_eq(game_manager.enemies_killed, 0, "Initial enemies killed should be 0")
	assert_false(game_manager.game_over, "Game should not be over initially")
	assert_false(game_manager.game_won, "Game should not be won initially")
	assert_eq(game_manager.victory_type, GameManager.VictoryType.WAVE_SURVIVAL, "Victory type should default to WAVE_SURVIVAL")

func test_get_victory_data_returns_expected_dict():
	var data = game_manager.get_victory_data()
	assert_eq(data["victory_type"], GameManager.VictoryType.WAVE_SURVIVAL, "Victory type should match")
	assert_eq(data["enemies_killed"], 0, "Enemies killed should match")
	assert_eq(data["max_waves"], mock_wave_manager.max_waves, "Max waves should match mock")
	assert_eq(data["current_wave"], mock_wave_manager.get_current_wave(), "Current wave should match mock")
	assert_eq(data["currency"], mock_currency_manager.get_currency(), "Currency should match mock")
	assert_string_contains(data["time_played"], ":", "Time played should be formatted")

func test_get_game_over_data_returns_expected_dict():
	var data = game_manager.get_game_over_data()
	assert_eq(data["waves_survived"], mock_wave_manager.current_wave - 1, "Waves survived should match mock")
	assert_eq(data["current_wave"], mock_wave_manager.current_wave, "Current wave should match mock")
	assert_eq(data["enemies_killed"], 0, "Enemies killed should match")
	assert_eq(data["currency"], mock_currency_manager.get_currency(), "Currency should match mock")
	assert_string_contains(data["time_played"], ":", "Time played should be formatted")
	assert_eq(data["player_health"], 10, "Player health should match initial")

func test_get_info_label_text_includes_expected_fields():
	var text = game_manager.get_info_label_text()
	assert_string_contains(text, "Wave: ", "Should include wave number")
	assert_string_contains(text, "Health: ", "Should include health")
	assert_string_contains(text, "Currency: ", "Should include currency")
	assert_string_contains(text, "Enemies Killed: ", "Should include enemies killed")
	assert_string_contains(text, "Cost: ", "Should include tower cost")

func test_format_time_formats_seconds():
	assert_eq(game_manager.format_time(0), "0:00", "0 seconds should be formatted as 0:00")
	assert_eq(game_manager.format_time(30), "0:30", "30 seconds should be formatted as 0:30")
	assert_eq(game_manager.format_time(90), "1:30", "90 seconds should be formatted as 1:30")

func test_is_game_over_true_when_game_over_or_won():
	game_manager.game_over = true
	assert_true(game_manager.is_game_over(), "Should be true if game_over is true")
	game_manager.game_over = false
	game_manager.game_won = true
	assert_true(game_manager.is_game_over(), "Should be true if game_won is true")
	game_manager.game_over = false
	game_manager.game_won = false
	assert_false(game_manager.is_game_over(), "Should be false if neither is true")

func test_get_player_health_and_enemies_killed():
	game_manager.player_health = 7
	game_manager.enemies_killed = 3
	assert_eq(game_manager.get_player_health(), 7, "Should return correct player health")
	assert_eq(game_manager.get_enemies_killed(), 3, "Should return correct enemies killed") 
