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
const PROJECTILE_SCENE = preload("res://Projectile.tscn")

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

func get_enemies_from_parent() -> Array[Enemy]:
	var enemies: Array[Enemy] = []
	
	# First try to get the GridSystem node (grandparent)
	# Towers are children of grid_container, which is a child of GridSystem
	var grid_system = get_parent().get_parent()
	
	if grid_system and grid_system.has_method("get_enemies"):
		return grid_system.get_enemies()
	
	# Fallback 1: Try direct parent
	var parent = get_parent()
	if parent.has_method("get_enemies"):
		return parent.get_enemies()
	
	# Fallback 2: Search through GridSystem children for enemies
	if grid_system:
		for child in grid_system.get_children():
			if child is Enemy:
				enemies.append(child)
	
	# Fallback 3: Search through direct parent children
	for child in parent.get_children():
		if child is Enemy:
			enemies.append(child)
	
	return enemies

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