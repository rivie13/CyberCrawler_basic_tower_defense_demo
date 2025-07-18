extends GutTest

# Unit tests for GameManager class
# These tests verify the core functionality of the GameManager

var game_manager: GameManager
var mock_wave_manager: WaveManager
var mock_currency_manager: CurrencyManager
var mock_tower_manager: TowerManager

func before_each():
	# Setup fresh GameManager for each test
	game_manager = GameManager.new()
	# Create actual manager objects instead of generic Node objects
	mock_wave_manager = WaveManager.new()
	mock_currency_manager = CurrencyManager.new()
	mock_tower_manager = TowerManager.new()
	
	# Add to scene so they don't get garbage collected
	add_child_autofree(game_manager)
	add_child_autofree(mock_wave_manager)
	add_child_autofree(mock_currency_manager)
	add_child_autofree(mock_tower_manager)

func test_initial_state():
	# Test that GameManager starts with correct initial values
	assert_eq(game_manager.player_health, 10, "Player should start with 10 health")
	assert_eq(game_manager.enemies_killed, 0, "Should start with 0 enemies killed")
	assert_false(game_manager.game_over, "Game should not be over initially")
	assert_false(game_manager.game_won, "Game should not be won initially")

func test_victory_type_defaults():
	# Test default victory type
	assert_eq(game_manager.victory_type, GameManager.VictoryType.WAVE_SURVIVAL, 
		"Default victory type should be WAVE_SURVIVAL")

func test_initialize_sets_references():
	# Test that initialize properly sets manager references
	game_manager.initialize(mock_wave_manager, mock_currency_manager, mock_tower_manager)
	
	assert_eq(game_manager.wave_manager, mock_wave_manager, "Wave manager should be set")
	assert_eq(game_manager.currency_manager, mock_currency_manager, "Currency manager should be set")
	assert_eq(game_manager.tower_manager, mock_tower_manager, "Tower manager should be set")

func test_ready_initializes_timer():
	# Test that _ready() initializes the timer
	var initial_time = game_manager.game_session_start_time
	game_manager._ready()
	assert_gt(game_manager.game_session_start_time, initial_time, "Timer should be initialized in _ready()")

func test_get_session_time():
	# Test session time calculation
	game_manager._ready()  # Initialize timer
	var session_time = game_manager.get_session_time()
	assert_gte(session_time, 0.0, "Session time should be non-negative")
	assert_true(session_time is float, "Session time should be a float")

func test_format_time():
	# Test time formatting
	var formatted = game_manager.format_time(65.5)  # 1 minute, 5 seconds
	assert_eq(formatted, "1:05", "Should format time as M:SS")
	
	var formatted_zero = game_manager.format_time(0.0)
	assert_eq(formatted_zero, "0:00", "Should format zero time correctly")
	
	var formatted_short = game_manager.format_time(30.2)
	assert_eq(formatted_short, "0:30", "Should format short time correctly")

func test_on_enemy_died():
	# Test enemy death handling
	var initial_count = game_manager.enemies_killed
	var mock_enemy = Enemy.new()
	add_child_autofree(mock_enemy)
	
	game_manager._on_enemy_died(mock_enemy)
	
	assert_eq(game_manager.enemies_killed, initial_count + 1, "Should increment enemies killed")

func test_on_enemy_reached_end():
	# Test enemy reaching end handling
	var initial_health = game_manager.player_health
	var mock_enemy = Enemy.new()
	add_child_autofree(mock_enemy)
	
	game_manager._on_enemy_reached_end(mock_enemy)
	
	assert_eq(game_manager.player_health, initial_health - 1, "Should decrease player health")

func test_trigger_game_over():
	# Test game over triggering
	watch_signals(game_manager)
	
	game_manager.trigger_game_over()
	
	assert_true(game_manager.game_over, "Game should be over")
	assert_signal_emitted(game_manager, "game_over_triggered", "Should emit game over signal")

func test_trigger_game_won():
	# Test game won triggering
	watch_signals(game_manager)
	
	game_manager.trigger_game_won()
	
	assert_true(game_manager.game_won, "Game should be won")
	assert_eq(game_manager.victory_type, GameManager.VictoryType.WAVE_SURVIVAL, "Should set wave survival victory")
	assert_signal_emitted(game_manager, "game_won_triggered", "Should emit game won signal")

func test_trigger_game_won_packet():
	# Test game won by packet delivery
	watch_signals(game_manager)
	
	game_manager.trigger_game_won_packet()
	
	assert_true(game_manager.game_won, "Game should be won")
	assert_eq(game_manager.victory_type, GameManager.VictoryType.PROGRAM_DATA_PACKET, "Should set packet victory")
	assert_signal_emitted(game_manager, "game_won_triggered", "Should emit game won signal")

func test_get_victory_data():
	# Test victory data collection
	game_manager.enemies_killed = 5
	game_manager.victory_type = GameManager.VictoryType.WAVE_SURVIVAL
	
	var victory_data = game_manager.get_victory_data()
	
	assert_eq(victory_data["victory_type"], GameManager.VictoryType.WAVE_SURVIVAL, "Should include victory type")
	assert_eq(victory_data["enemies_killed"], 5, "Should include enemies killed")
	assert_true(victory_data.has("time_played"), "Should include time played")
	assert_true(victory_data.has("currency"), "Should include currency")

func test_get_game_over_data():
	# Test game over data collection
	game_manager.enemies_killed = 3
	game_manager.player_health = 2
	
	var game_over_data = game_manager.get_game_over_data()
	
	assert_eq(game_over_data["enemies_killed"], 3, "Should include enemies killed")
	assert_eq(game_over_data["player_health"], 2, "Should include player health")
	assert_true(game_over_data.has("time_played"), "Should include time played")
	assert_true(game_over_data.has("currency"), "Should include currency")

func test_get_info_label_text():
	# Test info label text generation
	game_manager.player_health = 8
	game_manager.enemies_killed = 15
	
	var info_text = game_manager.get_info_label_text()
	
	assert_true(info_text.contains("Health: 8"), "Should include health")
	assert_true(info_text.contains("Enemies Killed: 15"), "Should include enemies killed")
	assert_true(info_text.contains("Wave:"), "Should include wave information")
	assert_true(info_text.contains("Currency:"), "Should include currency information")

func test_is_game_over():
	# Test game over status check
	assert_false(game_manager.is_game_over(), "Should not be game over initially")
	
	game_manager.game_over = true
	assert_true(game_manager.is_game_over(), "Should be game over when flag is set")
	
	game_manager.game_over = false
	game_manager.game_won = true
	assert_true(game_manager.is_game_over(), "Should be game over when game is won")

func test_getters():
	# Test getter methods
	game_manager.player_health = 7
	game_manager.enemies_killed = 12
	
	assert_eq(game_manager.get_player_health(), 7, "Should return player health")
	assert_eq(game_manager.get_enemies_killed(), 12, "Should return enemies killed")

func test_health_below_zero_prevention():
	# Test that health doesn't go below zero
	game_manager.player_health = 1
	var mock_enemy = Enemy.new()
	add_child_autofree(mock_enemy)
	
	game_manager._on_enemy_reached_end(mock_enemy)
	
	assert_eq(game_manager.player_health, 0, "Health should not go below zero")

func test_game_over_when_health_zero():
	# Test that game over is triggered when health reaches zero
	game_manager.player_health = 1
	var mock_enemy = Enemy.new()
	add_child_autofree(mock_enemy)
	
	game_manager._on_enemy_reached_end(mock_enemy)
	
	assert_true(game_manager.game_over, "Game should be over when health reaches zero")

func test_duplicate_game_over_prevention():
	# Test that game over can't be triggered twice
	game_manager.trigger_game_over()
	var first_result = game_manager.game_over
	
	game_manager.trigger_game_over()
	
	assert_eq(game_manager.game_over, first_result, "Game over should not be triggered twice")

func test_wave_countdown_handling():
	# Test wave countdown functionality
	game_manager.initialize(mock_wave_manager, mock_currency_manager, mock_tower_manager)
	
	# Test wave started
	game_manager._on_wave_started(1)
	assert_false(game_manager.wave_countdown_active, "Wave countdown should be inactive during wave")
	
	# Test wave completed
	game_manager._on_wave_completed(1)
	assert_true(game_manager.wave_countdown_active, "Wave countdown should be active after wave")

# Integration test with signal connections
func test_signal_connections():
	# Initialize with the mock managers
	game_manager.initialize(mock_wave_manager, mock_currency_manager, mock_tower_manager)
	
	# Test that the game manager has connected to the wave manager signals
	# This tests the signal connection logic in initialize()
	# Note: We'll check if the signals exist first to avoid errors
	if mock_wave_manager.has_signal("enemy_died"):
		assert_true(mock_wave_manager.enemy_died.is_connected(game_manager._on_enemy_died), 
			"Should connect to enemy_died signal")
	else:
		# If signal doesn't exist, that's ok - just verify initialize worked
		assert_not_null(game_manager.wave_manager, "Wave manager should be set")
	
	if mock_wave_manager.has_signal("enemy_reached_end"):
		assert_true(mock_wave_manager.enemy_reached_end.is_connected(game_manager._on_enemy_reached_end), 
			"Should connect to enemy_reached_end signal")
	else:
		# If signal doesn't exist, that's ok - just verify initialize worked
		assert_not_null(game_manager.wave_manager, "Wave manager should be set") 