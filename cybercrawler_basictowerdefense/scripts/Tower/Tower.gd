extends Node2D
class_name Tower

# Tower properties
@export var damage: int = 1
@export var tower_range: float = 150.0
@export var attack_rate: float = 1.0  # Attacks per second
@export var projectile_speed: float = 300.0
@export var max_health: int = 4  # Player towers slightly more durable than enemy towers
@export var health: int = 4

# State
var attack_timer: Timer
var current_target: Node = null  # Can target Enemy or EnemyTower
var grid_position: Vector2i
var show_range_indicator: bool = false
var is_alive: bool = true

# Visual components
var range_circle: Node2D
var tower_body: ColorRect
var health_bar: ColorRect
var health_bar_bg: ColorRect

# Projectile scene
const PROJECTILE_SCENE = preload("res://scenes/Projectile.tscn")

# Signals
signal tower_destroyed(tower: Tower)

func _ready():
	create_tower_visual()
	setup_attack_timer()
	update_health_bar()

func create_tower_visual():
	# Create tower body (blue rectangle)
	tower_body = ColorRect.new()
	tower_body.size = Vector2(60, 60)
	tower_body.position = Vector2(-30, -30)
	tower_body.color = Color(0.2, 0.6, 0.8, 0.8)
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
	health_bar.color = Color(0.2, 0.8, 0.2, 0.8)  # Green health bar
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
	
	# Find new target - prioritize RivalHackers > enemies > enemy towers
	current_target = null
	var closest_distance = tower_range
	
	# First, look for RivalHackers (highest priority - they attack our towers!)
	var rival_hackers = get_rival_hackers()
	for hacker in rival_hackers:
		if not is_instance_valid(hacker):
			continue
		
		var distance = global_position.distance_to(hacker.global_position)
		if distance <= tower_range and distance < closest_distance:
			current_target = hacker
			closest_distance = distance
	
	# If no RivalHackers found, look for regular enemies
	if not current_target:
		var enemies = get_enemies_from_parent()
		for enemy in enemies:
			if not is_instance_valid(enemy):
				continue
			
			var distance = global_position.distance_to(enemy.global_position)
			if distance <= tower_range and distance < closest_distance:
				current_target = enemy
				closest_distance = distance
	
	# If no enemies found, look for enemy towers
	if not current_target:
		var enemy_towers = get_enemy_towers()
		for enemy_tower in enemy_towers:
			if not is_instance_valid(enemy_tower):
				continue
			
			var distance = global_position.distance_to(enemy_tower.global_position)
			if distance <= tower_range and distance < closest_distance:
				current_target = enemy_tower
				closest_distance = distance

func get_main_controller():
	return get_tree().get_first_node_in_group("main_controller")

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

func get_rival_hackers() -> Array[RivalHacker]:
	var rival_hackers: Array[RivalHacker] = []
	
	# Get RivalHackers from RivalHackerManager via MainController
	var main_controller = get_main_controller()
	if main_controller and main_controller.rival_hacker_manager:
		# Check if RivalHackerManager has a method to get rival hackers
		if main_controller.rival_hacker_manager.has_method("get_rival_hackers"):
			var hackers_array = main_controller.rival_hacker_manager.get_rival_hackers()
			for hacker in hackers_array:
				if hacker is RivalHacker:
					rival_hackers.append(hacker)
	
	# Fallback: Search through scene for RivalHackers
	if rival_hackers.is_empty():
		var root = get_tree().get_current_scene()
		if root:
			_search_for_rival_hackers_recursive(root, rival_hackers)
	
	return rival_hackers

func get_enemy_towers() -> Array[EnemyTower]:
	var enemy_towers: Array[EnemyTower] = []
	
	# Get enemy towers from RivalHackerManager via MainController
	var main_controller = get_main_controller()
	if main_controller and main_controller.rival_hacker_manager:
		# Note: RivalHackerManager.get_enemy_towers() returns Array, need to cast
		var towers_array = main_controller.rival_hacker_manager.get_enemy_towers()
		for tower in towers_array:
			if tower is EnemyTower:
				enemy_towers.append(tower)
	
	return enemy_towers

func _search_for_enemies_recursive(node: Node, enemies: Array[Enemy]):
	if node is Enemy:
		enemies.append(node)
	for child in node.get_children():
		_search_for_enemies_recursive(child, enemies)

func _search_for_rival_hackers_recursive(node: Node, rival_hackers: Array[RivalHacker]):
	if node is RivalHacker:
		rival_hackers.append(node)
	for child in node.get_children():
		_search_for_rival_hackers_recursive(child, rival_hackers)

func is_target_in_range(target: Node) -> bool:
	if not is_instance_valid(target):
		return false
	# Check if target has global_position property (Node2D and subclasses)
	if not "global_position" in target:
		return false
	var distance_to_target = global_position.distance_to(target.global_position)
	return distance_to_target <= tower_range

func attack_target():
	if not current_target or not is_instance_valid(current_target):
		return
	
	# Create projectile
	var projectile = PROJECTILE_SCENE.instantiate()
	
	# Handle different target types
	if current_target is RivalHacker:
		projectile.setup_for_rival_hacker(global_position, current_target, damage, projectile_speed)
	elif current_target is Enemy:
		projectile.setup(global_position, current_target, damage, projectile_speed)
	elif current_target is EnemyTower:
		projectile.setup_for_tower_target(global_position, current_target, damage, projectile_speed)
	elif current_target.has_method("take_damage"):
		# Fallback for any other Node with take_damage method
		projectile.setup(global_position, current_target, damage, projectile_speed)
	else:
		# Log an error for unexpected target types
		print("Error: Unexpected target type passed to attack_target: ", current_target)
		projectile.queue_free()  # Clean up the projectile
		return
	
	get_parent().add_child(projectile)
	
	# Visual feedback - rotate tower towards target
	var direction = (current_target.global_position - global_position).normalized()
	rotation = direction.angle()

func set_grid_position(grid_pos: Vector2i):
	grid_position = grid_pos

func get_grid_position() -> Vector2i:
	return grid_position

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
func show_range_debug():
	print("Tower at ", grid_position, " - Range: ", tower_range, " - Current Target: ", current_target)
	# Toggle range visualization for debugging
	if show_range_indicator:
		hide_range()
	else:
		show_range()

func take_damage(damage_amount: int):
	if not is_alive:
		return
	
	health -= damage_amount
	health = max(0, health)
	update_health_bar()
	
	print("Player Tower at ", grid_position, " took ", damage_amount, " damage. Health: ", health, "/", max_health)
	
	if health <= 0:
		destroy_tower()

func update_health_bar():
	if health_bar:
		var health_percentage = float(health) / float(max_health)
		health_bar.size.x = 60 * health_percentage
		
		# Change color based on health
		if health_percentage > 0.6:
			health_bar.color = Color(0.2, 0.8, 0.2, 0.8)  # Green
		elif health_percentage > 0.3:
			health_bar.color = Color(0.8, 0.8, 0.2, 0.8)  # Yellow
		else:
			health_bar.color = Color(0.8, 0.2, 0.2, 0.8)  # Red

func destroy_tower():
	is_alive = false
	attack_timer.stop()
	
	# Free up grid position
	var main_controller = get_main_controller()
	if main_controller and main_controller.grid_manager:
		main_controller.grid_manager.set_grid_occupied(grid_position, false)
	
	# Remove from tower manager's tracking
	if main_controller and main_controller.tower_manager:
		var towers = main_controller.tower_manager.get_towers()
		towers.erase(self)
	
	# Notify destruction
	tower_destroyed.emit(self)
	
	print("Player Tower at ", grid_position, " destroyed!")
	queue_free()

func stop_attacking():
	# Stop all tower activity for game over
	attack_timer.stop()
	current_target = null