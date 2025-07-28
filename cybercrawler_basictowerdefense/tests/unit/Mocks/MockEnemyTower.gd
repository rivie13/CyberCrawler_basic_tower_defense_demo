extends Node2D
class_name MockEnemyTower

# Mock EnemyTower for unit testing
# Provides essential properties and methods that tests need

# Core properties
var tower_range: float = 120.0
var damage: int = 1
var attack_speed: float = 2.0
var health: int = 5
var max_health: int = 5
var removal_reward: int = 5

# State properties
var is_alive: bool = true
var is_frozen: bool = false
var grid_position: Vector2i
var current_target: Node = null
var show_range_indicator: bool = false

# Mock state tracking
var damage_taken: int = 0
var times_damaged: int = 0
var times_frozen: int = 0
var times_unfrozen: int = 0
var times_destroyed: int = 0
var times_attacked: int = 0
var times_targeted: int = 0

# Signals (same as real EnemyTower)
signal enemy_tower_destroyed(tower: MockEnemyTower)

func _ready():
	# Mock implementation - no visual creation needed for unit tests
	pass

func take_damage(damage_amount: int):
	if not is_alive:
		return
	
	health -= damage_amount
	damage_taken += damage_amount
	times_damaged += 1
	
	if health <= 0:
		destroy()

func destroy():
	is_alive = false
	times_destroyed += 1
	enemy_tower_destroyed.emit(self)

func apply_freeze_effect(duration: float):
	is_frozen = true
	times_frozen += 1

func remove_freeze_effect():
	is_frozen = false
	times_unfrozen += 1

func find_target():
	times_targeted += 1
	# Mock implementation - just track that it was called

func attack_target():
	times_attacked += 1
	# Mock implementation - just track that it was called

func start_attacking():
	# Mock implementation - just track that it was called
	pass

func stop_attacking():
	# Mock implementation - just track that it was called
	pass

func remove_freeze_visual():
	# Mock implementation - just track that it was called
	pass

# Helper methods for tests
func set_health(new_health: int):
	health = new_health
	max_health = max(max_health, new_health)

func set_alive(alive: bool):
	is_alive = alive

func set_frozen(frozen: bool):
	is_frozen = frozen

func set_grid_position(pos: Vector2i):
	grid_position = pos

func set_current_target(target: Node):
	current_target = target

func reset_mock_state():
	damage_taken = 0
	times_damaged = 0
	times_frozen = 0
	times_unfrozen = 0
	times_destroyed = 0
	times_attacked = 0
	times_targeted = 0

func get_damage_taken() -> int:
	return damage_taken

func get_times_damaged() -> int:
	return times_damaged

func get_times_frozen() -> int:
	return times_frozen

func get_times_unfrozen() -> int:
	return times_unfrozen

func get_times_destroyed() -> int:
	return times_destroyed

func get_times_attacked() -> int:
	return times_attacked

func get_times_targeted() -> int:
	return times_targeted 