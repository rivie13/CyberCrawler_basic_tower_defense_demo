extends Node
class_name GameManagerInterface

# Signals for game state changes
signal game_over_triggered()
signal game_won_triggered()

# Victory types
enum VictoryType {
	WAVE_SURVIVAL,
	PROGRAM_DATA_PACKET
}

# Core game state methods
func is_game_over() -> bool:
	"""Check if the game is over (either won or lost)"""
	push_error("is_game_over() must be implemented by subclass")
	return false

func get_player_health() -> int:
	"""Get current player health"""
	push_error("get_player_health() must be implemented by subclass")
	return 0

func get_enemies_killed() -> int:
	"""Get total number of enemies killed"""
	push_error("get_enemies_killed() must be implemented by subclass")
	return 0

# Game state trigger methods
func trigger_game_over() -> void:
	"""Trigger game over state"""
	push_error("trigger_game_over() must be implemented by subclass")

func trigger_game_won() -> void:
	"""Trigger game won state (wave survival)"""
	push_error("trigger_game_won() must be implemented by subclass")

func trigger_game_won_packet() -> void:
	"""Trigger game won state (program data packet)"""
	push_error("trigger_game_won_packet() must be implemented by subclass")

# Data retrieval methods
func get_victory_data() -> Dictionary:
	"""Get data for victory screen"""
	push_error("get_victory_data() must be implemented by subclass")
	return {}

func get_game_over_data() -> Dictionary:
	"""Get data for game over screen"""
	push_error("get_game_over_data() must be implemented by subclass")
	return {}

func get_info_label_text() -> String:
	"""Get formatted text for info label"""
	push_error("get_info_label_text() must be implemented by subclass")
	return ""

# Time and session methods
func get_session_time() -> float:
	"""Get current session time in seconds"""
	push_error("get_session_time() must be implemented by subclass")
	return 0.0

func format_time(seconds: float) -> String:
	"""Format time in MM:SS format"""
	push_error("format_time() must be implemented by subclass")
	return ""

# Cleanup methods
func cleanup_projectiles() -> void:
	"""Clean up all projectiles in the scene"""
	push_error("cleanup_projectiles() must be implemented by subclass")

# UI interaction methods
func _on_play_again_pressed() -> void:
	"""Handle play again button press"""
	push_error("_on_play_again_pressed() must be implemented by subclass")

func _on_exit_game_pressed() -> void:
	"""Handle exit game button press"""
	push_error("_on_exit_game_pressed() must be implemented by subclass") 