extends CharacterBody2D
class_name Enemy

# Enemy properties
@export var speed: float = 100.0
@export var health: int = 3
@export var max_health: int = 3

# Click damage properties handled by Clickable interface

# Path following
var path_points: Array[Vector2] = []
var current_path_index: int = 0
var target_position: Vector2

# State
var is_alive: bool = true
var paused: bool = false  # NEW: Controls whether enemy is paused

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
	
	# FIXED: ALWAYS start from the beginning of the path - NEVER go backwards
	current_path_index = 0
	if path_points.size() > 0:
		target_position = path_points[0]

func pause():
	paused = true

func resume():
	paused = false

func _physics_process(delta):
	if not is_alive or path_points.size() == 0 or paused:
		return
	
	# Check if game is over (get from MainController)
	var main_controller = get_main_controller()
	if main_controller and main_controller.game_manager and main_controller.game_manager.is_game_over():
		return
	
	# ALWAYS follow the path - never deviate to chase other targets
	move_along_path(delta)

func get_main_controller():
	return get_tree().get_first_node_in_group("main_controller")

func move_along_path(_delta):
	# CRITICAL: Enemies must ALWAYS follow their path to the end to damage the player
	# Do not allow any targeting or deviation from the path
	
	# Validate path and current index
	if current_path_index >= path_points.size():
		reach_end()
		return
	
	var direction = (target_position - global_position).normalized()
	var distance_to_target = global_position.distance_to(target_position)
	
	# IMPROVED: Use larger distance threshold to prevent overshooting and backtracking
	var reach_threshold = 25.0  # Increased from 10.0 to prevent dance/reverse issues
	
	# Move towards target
	velocity = direction * speed
	move_and_slide()
	
	# Check if reached current target
	if distance_to_target < reach_threshold:
		# IMPROVED: Don't snap immediately - let enemy move naturally toward next target
		current_path_index += 1
		
		# Check if reached end of path
		if current_path_index >= path_points.size():
			reach_end()
			return
		
		# IMPROVED: Validate next target exists before setting
		if current_path_index < path_points.size():
			target_position = path_points[current_path_index]
		else:
			# Safety fallback - should not happen but prevents crashes
			reach_end()
			return

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

# Click damage detection using Clickable interface
func is_clicked_at(world_pos: Vector2) -> bool:
	"""Check if a world position click hits this enemy"""
	return Clickable.is_clicked_at(global_position, world_pos, Clickable.ENEMY_CONFIG)

func handle_click_damage():
	"""Handle damage from player click"""
	return Clickable.handle_click_damage(self, Clickable.ENEMY_CONFIG, "Enemy")

func get_health_info() -> String:
	"""Get health information for logging"""
	return " Health: " + str(health) + "/" + str(max_health)

func reach_end():
	# This is critical - enemies must reach the end to damage the player
	# Do not allow any interference with this behavior
	enemy_reached_end.emit(self)
	queue_free()

# NOTE: Enemies do NOT target the program data packet
# They only follow their path to damage the player
# Any collision with the packet is handled by the packet itself 
