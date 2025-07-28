extends Node2D
class_name MockEnemy

# Mock Enemy for unit testing
# Provides essential properties and methods that tests need

# Core properties
var speed: float = 100.0
var health: int = 3
var max_health: int = 3
var is_alive: bool = true
var paused: bool = false

# Path following properties
var path_points: Array[Vector2] = []
var current_path_index: int = 0
var target_position: Vector2

# Mock state tracking
var damage_taken: int = 0
var times_damaged: int = 0
var times_paused: int = 0
var times_resumed: int = 0
var times_died: int = 0
var times_reached_end: int = 0

# Signals (same as real Enemy)
signal enemy_died(enemy: MockEnemy)
signal enemy_reached_end(enemy: MockEnemy)

func _ready():
	# Mock implementation - no visual creation needed for unit tests
	pass

func set_path(new_path: Array[Vector2]):
	path_points = new_path
	current_path_index = 0
	if path_points.size() > 0:
		target_position = path_points[0]

func pause():
	paused = true
	times_paused += 1

func resume():
	paused = false
	times_resumed += 1

func take_damage(damage: int):
	if not is_alive:
		return
	
	health -= damage
	damage_taken += damage
	times_damaged += 1
	
	if health <= 0:
		die()

func die():
	is_alive = false
	times_died += 1
	enemy_died.emit(self)

func reach_end():
	times_reached_end += 1
	enemy_reached_end.emit(self)

func move_along_path(_delta):
	# Mock implementation - just track that it was called
	pass

# Helper methods for tests
func set_health(new_health: int):
	health = new_health
	max_health = max(max_health, new_health)

func set_alive(alive: bool):
	is_alive = alive

func set_paused(pause_state: bool):
	paused = pause_state

func reset_mock_state():
	damage_taken = 0
	times_damaged = 0
	times_paused = 0
	times_resumed = 0
	times_died = 0
	times_reached_end = 0

func get_damage_taken() -> int:
	return damage_taken

func get_times_damaged() -> int:
	return times_damaged

func get_times_paused() -> int:
	return times_paused

func get_times_resumed() -> int:
	return times_resumed

func get_times_died() -> int:
	return times_died

func get_times_reached_end() -> int:
	return times_reached_end 