extends Node2D
class_name Tower

# Tower properties
@export var damage: int = 1
@export var tower_range: float = 150.0
@export var attack_rate: float = 1.0  # Attacks per second
@export var projectile_speed: float = 300.0

# State
var attack_timer: Timer
var current_target: Enemy = null
var grid_position: Vector2i
var show_range_indicator: bool = false

# Visual components
var range_circle: Node2D
var tower_body: ColorRect

# Projectile scene
const PROJECTILE_SCENE = preload("res://scenes/Projectile.tscn")

func _ready():
	create_tower_visual()
	setup_attack_timer()

func create_tower_visual():
	# Create tower body (blue rectangle)
	tower_body = ColorRect.new()
	tower_body.size = Vector2(60, 60)
	tower_body.position = Vector2(-30, -30)
	tower_body.color = Color(0.2, 0.6, 0.8, 0.8)
	add_child(tower_body)
	
	# Create range indicator (visible when selected)
	range_circle = Node2D.new()
	add_child(range_circle)

func setup_attack_timer():
	attack_timer = Timer.new()
	attack_timer.wait_time = 1.0 / attack_rate
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)
	attack_timer.start()

func _on_attack_timer_timeout():
	# Check if game is over (get from MainController)
	var main_controller = get_main_controller()
	if main_controller and main_controller.game_manager and main_controller.game_manager.is_game_over():
		return
		
	find_target()
	if current_target and is_instance_valid(current_target):
		attack_target()

func find_target():
	# Clear invalid target
	if current_target and not is_instance_valid(current_target):
		current_target = null
	
	# If we have a valid target in range, keep it
	if current_target and is_target_in_range(current_target):
		return
	
	# Find new target
	current_target = null
	var closest_distance = tower_range
	
	# Get all enemies from parent
	var enemies = get_enemies_from_parent()
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		if distance <= tower_range and distance < closest_distance:
			current_target = enemy
			closest_distance = distance

func get_main_controller():
	# Navigate up the tree to find MainController
	var current_node = self
	while current_node:
		if current_node is MainController:
			return current_node
		current_node = current_node.get_parent()
	return null

func get_enemies_from_parent() -> Array[Enemy]:
	var enemies: Array[Enemy] = []
	
	# Get enemies from the WaveManager via MainController
	var main_controller = get_main_controller()
	if main_controller and main_controller.wave_manager:
		return main_controller.wave_manager.get_enemies()
	
	# Fallback: Search through scene for enemies
	var root = get_tree().get_current_scene()
	if root:
		_search_for_enemies_recursive(root, enemies)
	
	return enemies

func _search_for_enemies_recursive(node: Node, enemies: Array[Enemy]):
	if node is Enemy:
		enemies.append(node)
	for child in node.get_children():
		_search_for_enemies_recursive(child, enemies)

func is_target_in_range(target: Enemy) -> bool:
	if not is_instance_valid(target):
		return false
	var distance_to_target = global_position.distance_to(target.global_position)
	return distance_to_target <= tower_range

func attack_target():
	if not current_target or not is_instance_valid(current_target):
		return
	
	# Create projectile
	var projectile = PROJECTILE_SCENE.instantiate()
	projectile.setup(global_position, current_target, damage, projectile_speed)
	get_parent().add_child(projectile)
	
	# Visual feedback - rotate tower towards target
	var direction = (current_target.global_position - global_position).normalized()
	rotation = direction.angle()

func set_grid_position(grid_pos: Vector2i):
	grid_position = grid_pos

func show_range():
	show_range_indicator = true
	queue_redraw()

func hide_range():
	show_range_indicator = false
	queue_redraw()

func _draw():
	# Draw range circle when selected
	if show_range_indicator:
		var range_color = Color(0.8, 0.2, 0.2, 0.3)  # Semi-transparent red
		draw_circle(Vector2.ZERO, tower_range, range_color)

# For debugging
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		var mouse_pos = get_global_mouse_position()
		if global_position.distance_to(mouse_pos) < 32:
			show_range_debug()

func show_range_debug():
	print("Tower at ", grid_position, " - Range: ", tower_range, " - Current Target: ", current_target)
	# Toggle range visualization for debugging
	if show_range_indicator:
		hide_range()
	else:
		show_range()

func stop_attacking():
	# Stop all tower activity for game over
	attack_timer.stop()
	current_target = null