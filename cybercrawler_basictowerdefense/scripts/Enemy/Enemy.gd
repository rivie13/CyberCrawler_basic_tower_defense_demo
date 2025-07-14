extends CharacterBody2D
class_name Enemy

# Enemy properties
@export var speed: float = 100.0
@export var health: int = 3
@export var max_health: int = 3

# Click damage properties
@export var click_damage_taken: int = 1  # Damage taken per click
@export var click_radius: float = 20.0   # Click detection radius (smaller than towers)

# Path following
var path_points: Array[Vector2] = []
var current_path_index: int = 0
var target_position: Vector2

# State
var is_alive: bool = true

# Signals
signal enemy_died(enemy: Enemy)
signal enemy_reached_end(enemy: Enemy)

func _ready():
	# Create simple enemy visual (red circle)
	create_enemy_visual()
	
	# Start following path if available
	if path_points.size() > 0:
		target_position = path_points[0]

func create_enemy_visual():
	# Create a simple red circle as enemy placeholder
	var circle = ColorRect.new()
	circle.size = Vector2(32, 32)
	circle.position = Vector2(-16, -16)
	circle.color = Color(0.8, 0.2, 0.2, 0.8)  # Red color
	add_child(circle)
	
	# Add health bar
	create_health_bar()

func create_health_bar():
	var health_bar_bg = ColorRect.new()
	health_bar_bg.size = Vector2(36, 6)
	health_bar_bg.position = Vector2(-18, -28)
	health_bar_bg.color = Color(0.3, 0.3, 0.3, 0.8)
	add_child(health_bar_bg)
	
	var health_bar = ColorRect.new()
	health_bar.name = "HealthBar"
	health_bar.size = Vector2(32, 4)
	health_bar.position = Vector2(-16, -27)
	health_bar.color = Color(0.2, 0.8, 0.2, 0.8)
	add_child(health_bar)

func set_path(new_path: Array[Vector2]):
	path_points = new_path
	current_path_index = 0
	if path_points.size() > 0:
		target_position = path_points[0]

func _physics_process(delta):
	if not is_alive or path_points.size() == 0:
		return
	
	# Check if game is over (get from MainController)
	var main_controller = get_main_controller()
	if main_controller and main_controller.game_manager and main_controller.game_manager.is_game_over():
		return
	
	move_along_path(delta)

func get_main_controller():
	# Navigate up the tree to find MainController
	var current_node = self
	while current_node:
		if current_node is MainController:
			return current_node
		current_node = current_node.get_parent()
	return null

func move_along_path(_delta):
	var direction = (target_position - global_position).normalized()
	var distance_to_target = global_position.distance_to(target_position)
	
	# Move towards target
	velocity = direction * speed
	move_and_slide()
	
	# Check if reached current target
	if distance_to_target < 10.0:
		current_path_index += 1
		
		# Check if reached end of path
		if current_path_index >= path_points.size():
			reach_end()
			return
		
		# Move to next path point
		target_position = path_points[current_path_index]

func take_damage(damage: int):
	if not is_alive:
		return
	
	health -= damage
	update_health_bar()
	
	if health <= 0:
		die()

func update_health_bar():
	var health_bar = get_node("HealthBar")
	if health_bar:
		var health_percentage = float(health) / float(max_health)
		health_bar.size.x = 32 * health_percentage
		
		# Change color based on health
		if health_percentage > 0.6:
			health_bar.color = Color(0.2, 0.8, 0.2, 0.8)  # Green
		elif health_percentage > 0.3:
			health_bar.color = Color(0.8, 0.8, 0.2, 0.8)  # Yellow
		else:
			health_bar.color = Color(0.8, 0.2, 0.2, 0.8)  # Red

func die():
	is_alive = false
	enemy_died.emit(self)
	queue_free()

# Click damage detection
func is_clicked_at(world_pos: Vector2) -> bool:
	"""Check if a world position click hits this enemy"""
	return global_position.distance_to(world_pos) <= click_radius

func handle_click_damage():
	"""Handle damage from player click"""
	if not is_alive:
		return false
	
	# Apply click damage
	take_damage(click_damage_taken)
	
	# Create visual feedback
	create_click_feedback()
	
	print("Enemy was clicked! Took ", click_damage_taken, " damage. Health: ", health, "/", max_health)
	return true

func create_click_feedback():
	"""Create visual feedback when enemy is clicked"""
	# Create a temporary damage indicator
	var damage_label = Label.new()
	damage_label.text = "-" + str(click_damage_taken)
	damage_label.position = Vector2(-10, -35)
	damage_label.add_theme_color_override("font_color", Color.ORANGE)
	damage_label.add_theme_font_size_override("font_size", 14)
	add_child(damage_label)
	
	# Animate the damage number
	var tween = create_tween()
	tween.parallel().tween_property(damage_label, "position", damage_label.position + Vector2(0, -25), 0.8)
	tween.parallel().tween_property(damage_label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(damage_label.queue_free)

func reach_end():
	enemy_reached_end.emit(self)
	queue_free() 
