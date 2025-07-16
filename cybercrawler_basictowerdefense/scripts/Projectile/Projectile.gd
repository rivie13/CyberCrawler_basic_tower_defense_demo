extends Node2D
class_name Projectile

# Constants
const HIT_THRESHOLD: float = 10.0  # Distance threshold for projectile hits

# Projectile properties
var target: Node  # Can be Enemy or Tower (any Node with take_damage method)
var damage: int
var speed: float
var start_position: Vector2

func _ready():
	# Create simple projectile visual (small yellow circle)
	var circle = ColorRect.new()
	circle.size = Vector2(6, 6)
	circle.position = Vector2(-3, -3)
	circle.color = Color(1.0, 1.0, 0.2, 0.9)  # Yellow color
	add_child(circle)

func setup(start_pos: Vector2, target_enemy: Enemy, projectile_damage: int, projectile_speed: float):
	global_position = start_pos
	start_position = start_pos
	target = target_enemy
	damage = projectile_damage
	speed = projectile_speed

func setup_for_tower_target(start_pos: Vector2, target_tower: Node, projectile_damage: int, projectile_speed: float):
	global_position = start_pos
	start_position = start_pos
	target = target_tower
	damage = projectile_damage
	speed = projectile_speed

func setup_for_rival_hacker(start_pos: Vector2, target_hacker: RivalHacker, projectile_damage: int, projectile_speed: float):
	global_position = start_pos
	start_position = start_pos
	target = target_hacker
	damage = projectile_damage
	speed = projectile_speed

func _process(delta):
	if not target or not is_instance_valid(target):
		queue_free()
		return
	
	# Check if game is over (projectiles should stop when game ends)
	var main_controller = get_main_controller()
	if main_controller and main_controller.game_manager and main_controller.game_manager.is_game_over():
		queue_free()
		return
	
	# Move towards target
	var direction = (target.global_position - global_position).normalized()
	global_position += direction * speed * delta
	
	# Check if we hit the target
	if global_position.distance_to(target.global_position) < HIT_THRESHOLD:
		hit_target()

func hit_target():
	if target and is_instance_valid(target):
		target.take_damage(damage)
	queue_free()

func get_main_controller():
	return get_tree().get_first_node_in_group("main_controller") 