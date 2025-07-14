extends Node2D
class_name EnemyTower

# Enemy tower properties
@export var damage: int = 1
@export var tower_range: float = 120.0  # Slightly shorter range than player towers
@export var attack_rate: float = 0.8  # Slightly slower than player towers
@export var projectile_speed: float = 250.0
@export var max_health: int = 3
@export var health: int = 3

# State
var attack_timer: Timer
var current_target: Tower = null  # Targets player towers instead of enemies
var grid_position: Vector2i
var show_range_indicator: bool = false
var is_alive: bool = true

# Visual components
var range_circle: Node2D
var tower_body: ColorRect
var health_bar: ColorRect
var health_bar_bg: ColorRect

# Projectile scene - reuse the same projectile system
const PROJECTILE_SCENE = preload("res://scenes/Projectile.tscn")

# Signals
signal enemy_tower_destroyed(enemy_tower: EnemyTower)

func _ready():
	create_enemy_tower_visual()
	setup_attack_timer()
	update_health_bar()

func create_enemy_tower_visual():
	# Create enemy tower body (red rectangle to distinguish from player towers)
	tower_body = ColorRect.new()
	tower_body.size = Vector2(60, 60)
	tower_body.position = Vector2(-30, -30)
	tower_body.color = Color(0.8, 0.2, 0.2, 0.8)  # Red color for enemy
	add_child(tower_body)
	
	# Create health bar background
	health_bar_bg = ColorRect.new()
	health_bar_bg.size = Vector2(64, 8)
	health_bar_bg.position = Vector2(-32, -44)
	health_bar_bg.color = Color(0.3, 0.3, 0.3, 0.8)
	add_child(health_bar_bg)
	
	# Create health bar
	health_bar = ColorRect.new()
	health_bar.size = Vector2(60, 6)
	health_bar.position = Vector2(-30, -43)
	health_bar.color = Color(0.8, 0.2, 0.2, 0.8)  # Red health bar
	add_child(health_bar)
	
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
	if not is_alive:
		return
	
	# Check if game is over
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
	
	# Find new target (player towers)
	current_target = null
	var closest_distance = tower_range
	
	# Get all player towers
	var player_towers = get_player_towers()
	
	for tower in player_towers:
		if not is_instance_valid(tower):
			continue
		
		var distance = global_position.distance_to(tower.global_position)
		if distance <= tower_range and distance < closest_distance:
			current_target = tower
			closest_distance = distance

func get_main_controller():
	# Navigate up the tree to find MainController
	var current_node = self
	while current_node:
		if current_node is MainController:
			return current_node
		current_node = current_node.get_parent()
	return null

func get_player_towers() -> Array[Tower]:
	var towers: Array[Tower] = []
	
	# Get player towers from TowerManager via MainController
	var main_controller = get_main_controller()
	if main_controller and main_controller.tower_manager:
		return main_controller.tower_manager.get_towers()
	
	return towers

func is_target_in_range(target: Tower) -> bool:
	if not is_instance_valid(target):
		return false
	var distance_to_target = global_position.distance_to(target.global_position)
	return distance_to_target <= tower_range

func attack_target():
	if not current_target or not is_instance_valid(current_target):
		return
	
	# Create projectile - we'll need to modify projectile to handle tower targets
	var projectile = PROJECTILE_SCENE.instantiate()
	# For now, use existing projectile setup - will modify projectile system later
	projectile.setup_for_tower_target(global_position, current_target, damage, projectile_speed)
	get_parent().add_child(projectile)
	
	# Visual feedback - rotate tower towards target
	var direction = (current_target.global_position - global_position).normalized()
	rotation = direction.angle()

func take_damage(damage_amount: int):
	if not is_alive:
		return
	
	health -= damage_amount
	health = max(0, health)
	update_health_bar()
	
	print("EnemyTower at ", grid_position, " took ", damage_amount, " damage. Health: ", health, "/", max_health)
	
	if health <= 0:
		destroy_tower()

func update_health_bar():
	if health_bar:
		var health_percentage = float(health) / float(max_health)
		health_bar.size.x = 60 * health_percentage
		
		# Change color based on health
		if health_percentage > 0.6:
			health_bar.color = Color(0.8, 0.2, 0.2, 0.8)  # Red
		elif health_percentage > 0.3:
			health_bar.color = Color(0.8, 0.6, 0.2, 0.8)  # Orange
		else:
			health_bar.color = Color(0.6, 0.1, 0.1, 0.8)  # Dark red

func destroy_tower():
	is_alive = false
	attack_timer.stop()
	
	# Free up grid position
	var main_controller = get_main_controller()
	if main_controller and main_controller.grid_manager:
		main_controller.grid_manager.set_grid_occupied(grid_position, false)
	
	# Notify rival hacker manager
	enemy_tower_destroyed.emit(self)
	
	print("EnemyTower at ", grid_position, " destroyed!")
	queue_free()

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

func stop_attacking():
	# Stop all tower activity for game over
	if attack_timer:
		attack_timer.stop()
	current_target = null

# For debugging
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		var mouse_pos = get_global_mouse_position()
		if global_position.distance_to(mouse_pos) < 32:
			show_range_debug()

func show_range_debug():
	print("EnemyTower at ", grid_position, " - Range: ", tower_range, " - Current Target: ", current_target, " - Health: ", health, "/", max_health)
	# Toggle range visualization for debugging
	if show_range_indicator:
		hide_range()
	else:
		show_range() 