extends Node2D
class_name MockClickableEntity

# Mock ClickableEntity for unit testing
# Provides essential properties and methods that the Clickable interface expects

# Core properties
var is_alive: bool = true
var health: int = 10
var max_health: int = 10

# Mock state tracking
var damage_taken_amount: int = 0
var times_damaged: int = 0
var times_clicked: int = 0
var times_died: int = 0

func _ready():
	# Mock implementation - no visual creation needed for unit tests
	pass

func take_damage(amount: int):
	if not is_alive:
		return
	
	damage_taken_amount = amount
	health -= amount
	times_damaged += 1
	times_clicked += 1
	
	if health <= 0:
		die()

func die():
	is_alive = false
	times_died += 1

func get_health_info() -> String:
	return " (Health: " + str(health) + "/" + str(max_health) + ")"

# Helper methods for tests
func set_health(new_health: int):
	health = new_health
	max_health = max(max_health, new_health)

func set_alive(alive: bool):
	is_alive = alive

func set_max_health(new_max_health: int):
	max_health = new_max_health

func reset_mock_state():
	damage_taken_amount = 0
	times_damaged = 0
	times_clicked = 0
	times_died = 0

func get_damage_taken_amount() -> int:
	return damage_taken_amount

func get_times_damaged() -> int:
	return times_damaged

func get_times_clicked() -> int:
	return times_clicked

func get_times_died() -> int:
	return times_died

func get_health() -> int:
	return health

func get_max_health() -> int:
	return max_health 