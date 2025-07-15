extends Node2D
class_name ProgramDataPacket

# Program data packet properties
@export var speed: float = 80.0  # Slightly slower than enemies
@export var health: int = 30  # Increased to survive multiple enemy towers
@export var max_health: int = 30
@export var damage_immunity_duration: float = 0.5  # 0.5 seconds of immunity after taking damage

# Path following (travels opposite direction from enemies)
var path_points: Array[Vector2] = []
var current_path_index: int = 0
var target_position: Vector2

# State
var is_alive: bool = true
var is_active: bool = false  # Only active when player releases it
var damage_immunity_timer: Timer
var is_immune_to_damage: bool = false

# Signals
signal program_packet_destroyed(packet: ProgramDataPacket)
signal program_packet_reached_end(packet: ProgramDataPacket)

func _ready():
	# Create program data packet visual (green/cyan circle)
	create_packet_visual()
	
	# Setup damage immunity timer
	setup_damage_immunity_timer()
	
	# Start following path if available
	if path_points.size() > 0:
		target_position = path_points[0]

func create_packet_visual():
	# Create a glowing green/cyan circle representing the program data packet
	var circle = ColorRect.new()
	circle.size = Vector2(24, 24)
	circle.position = Vector2(-12, -12)
	circle.color = Color(0.2, 0.8, 0.6, 0.9)  # Cyan/green color
	add_child(circle)
	
	# Add a subtle glow effect
	var glow = ColorRect.new()
	glow.size = Vector2(32, 32)
	glow.position = Vector2(-16, -16)
	glow.color = Color(0.2, 0.8, 0.6, 0.3)  # Soft glow
	add_child(glow)
	
	# Add health bar
	create_health_bar()

func setup_damage_immunity_timer():
	damage_immunity_timer = Timer.new()
	damage_immunity_timer.wait_time = damage_immunity_duration
	damage_immunity_timer.one_shot = true
	damage_immunity_timer.timeout.connect(_on_damage_immunity_timeout)
	add_child(damage_immunity_timer)

func _on_damage_immunity_timeout():
	is_immune_to_damage = false
	# Reset visual opacity to normal
	modulate.a = 1.0
	print("Program data packet damage immunity ended")

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
	health_bar.color = Color(0.2, 0.8, 0.6, 0.8)  # Match packet color
	add_child(health_bar)

func set_path(new_path: Array[Vector2]):
	"""Set the path for the program data packet to follow"""
	path_points = new_path
	current_path_index = 0
	if path_points.size() > 0:
		target_position = path_points[0]

func activate():
	"""Activate the program data packet to start moving"""
	is_active = true
	print("Program data packet activated!")

func _process(delta):
	# Changed from _physics_process to _process since we're no longer using physics
	if not is_alive or not is_active or path_points.size() == 0:
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

func move_along_path(delta):
	var direction = (target_position - global_position).normalized()
	var distance_to_target = global_position.distance_to(target_position)
	
	# Move towards target using simple position movement (no physics collision)
	var movement = direction * speed * delta
	global_position += movement
	
	# Check for collisions with enemies and take damage
	check_enemy_collisions()
	
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
	if not is_alive or is_immune_to_damage:
		return
	
	health -= damage
	update_health_bar()
	
	# Start damage immunity to prevent rapid damage
	is_immune_to_damage = true
	damage_immunity_timer.start()
	
	# Visual feedback: make packet semi-transparent during immunity
	modulate.a = 0.6
	
	print("Program data packet took ", damage, " damage. Health: ", health, "/", max_health, " (immune for ", damage_immunity_duration, "s)")
	
	if health <= 0:
		die()

func update_health_bar():
	var health_bar = get_node("HealthBar")
	if health_bar:
		var health_percentage = float(health) / float(max_health)
		health_bar.size.x = 32 * health_percentage
		
		# Change color based on health
		if health_percentage > 0.6:
			health_bar.color = Color(0.2, 0.8, 0.6, 0.8)  # Cyan/green
		elif health_percentage > 0.3:
			health_bar.color = Color(0.8, 0.8, 0.2, 0.8)  # Yellow
		else:
			health_bar.color = Color(0.8, 0.2, 0.2, 0.8)  # Red

func die():
	is_alive = false
	print("Program data packet destroyed!")
	program_packet_destroyed.emit(self)
	queue_free()

func reach_end():
	print("Program data packet reached enemy network! Player wins!")
	program_packet_reached_end.emit(self)
	queue_free()

# Click damage detection using Clickable interface
func is_clicked_at(world_pos: Vector2) -> bool:
	"""Check if a world position click hits this program data packet"""
	return Clickable.is_clicked_at(global_position, world_pos, Clickable.ENEMY_CONFIG)

func handle_click_damage():
	"""Handle damage from player click"""
	return Clickable.handle_click_damage(self, Clickable.ENEMY_CONFIG, "ProgramDataPacket")

func get_health_info() -> String:
	"""Get health information for logging"""
	return " Health: " + str(health) + "/" + str(max_health)

func check_enemy_collisions():
	"""Check for collisions with enemies and take damage"""
	# CRITICAL: Only check collisions when packet is active
	# This prevents interference with enemy behavior when packet is inactive
	if not is_alive or is_immune_to_damage or not is_active:
		return
	
	# Get all enemies in the scene
	var enemies = get_enemies_in_scene()
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		# If packet is close enough to enemy, take damage
		if distance < 40.0:  # Increased collision threshold
			take_damage(1)
			print("Program data packet hit enemy at distance ", distance, "! Taking damage...")
			break  # Only take damage from one enemy per frame to avoid rapid damage

func get_enemies_in_scene() -> Array:
	"""Get all enemies currently in the scene"""
	var enemies = []
	var main_controller = get_main_controller()
	if main_controller and main_controller.wave_manager:
		enemies = main_controller.wave_manager.enemies_alive
	return enemies 