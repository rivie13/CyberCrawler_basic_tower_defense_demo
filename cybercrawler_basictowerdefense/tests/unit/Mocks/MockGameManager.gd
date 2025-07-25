extends GameManagerInterface
class_name MockGameManager

# Mock state
var mock_game_over: bool = false
var mock_game_won: bool = false
var mock_player_health: int = 10
var mock_enemies_killed: int = 0
var mock_victory_type: VictoryType = VictoryType.WAVE_SURVIVAL
var mock_session_time: float = 0.0

func _ready():
	# Mock implementation - initialize session time
	mock_session_time = 0.0

# Signal tracking
var game_over_triggered_called: bool = false
var game_won_triggered_called: bool = false

# Core game state methods
func is_game_over() -> bool:
	return mock_game_over or mock_game_won

func get_player_health() -> int:
	return mock_player_health

func get_enemies_killed() -> int:
	return mock_enemies_killed

# Game state trigger methods
func trigger_game_over() -> void:
	mock_game_over = true
	game_over_triggered_called = true
	game_over_triggered.emit()

func trigger_game_won() -> void:
	mock_game_won = true
	mock_victory_type = VictoryType.WAVE_SURVIVAL
	game_won_triggered_called = true
	game_won_triggered.emit()

func trigger_game_won_packet() -> void:
	mock_game_won = true
	mock_victory_type = VictoryType.PROGRAM_DATA_PACKET
	game_won_triggered_called = true
	game_won_triggered.emit()

# Data retrieval methods
func get_victory_data() -> Dictionary:
	return {
		"victory_type": mock_victory_type,
		"max_waves": 10,
		"current_wave": 10,
		"enemies_killed": mock_enemies_killed,
		"currency": 100,
		"time_played": "1:30"
	}

func get_game_over_data() -> Dictionary:
	return {
		"waves_survived": 5,
		"current_wave": 6,
		"enemies_killed": mock_enemies_killed,
		"currency": 50,
		"time_played": "0:45",
		"player_health": mock_player_health
	}

func get_info_label_text() -> String:
	return "Wave: 1 | Health: %d | Currency: 100 | Enemies Killed: %d | Time: 0:00\nClick on grid to place towers (Cost: 50)" % [mock_player_health, mock_enemies_killed]

# Time and session methods
func get_session_time() -> float:
	return mock_session_time

func format_time(seconds: float) -> String:
	var total_seconds = int(seconds)
	var minutes = total_seconds / 60
	var secs = total_seconds % 60
	return "%d:%02d" % [minutes, secs]

# Cleanup methods
func cleanup_projectiles() -> void:
	# Mock implementation - does nothing
	pass

# UI interaction methods
func _on_play_again_pressed() -> void:
	# Mock implementation - does nothing
	pass

func _on_exit_game_pressed() -> void:
	# Mock implementation - does nothing
	pass

# Mock utility methods for testing
func set_mock_game_over(value: bool) -> void:
	mock_game_over = value

func set_mock_game_won(value: bool) -> void:
	mock_game_won = value

func set_mock_player_health(value: int) -> void:
	mock_player_health = value

func set_mock_enemies_killed(value: int) -> void:
	mock_enemies_killed = value

func set_mock_session_time(value: float) -> void:
	mock_session_time = value

func reset_signal_tracking() -> void:
	game_over_triggered_called = false
	game_won_triggered_called = false 