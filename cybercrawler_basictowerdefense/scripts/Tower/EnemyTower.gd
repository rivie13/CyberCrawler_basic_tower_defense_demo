extends Node2D
class_name EnemyTower

# Tower properties
@export var tower_range: float = 120.0
@export var damage: int = 1
@export var attack_speed: float = 2.0  # Attacks per second
@export var health: int = 5
@export var max_health: int = 5

# Cost (for removal reward)
@export var removal_reward: int = 5

# Click damage properties handled by Clickable interface
# EnemyTower uses ENEMY_TOWER_CONFIG for medium-sized click area

# State
var attack_timer: Timer
var current_target: Node = null  # Can target player towers or program data packet
var grid_position: Vector2i
var show_range_indicator: bool = false
var is_alive: bool = true

# Freeze effect state
var is_frozen: bool = false
var freeze_timer: Timer
var freeze_visual: ColorRect

# Signals
signal enemy_tower_destroyed(tower: EnemyTower)

func _ready():
	# Create tower visual
	create_enemy_tower_visual()
	
	# Setup attack timer
	setup_attack_timer()
	
	# Setup damage immunity timer
	setup_damage_immunity_timer()
	
	# Setup freeze timer
	setup_freeze_timer()
	
	# Start attacking immediately
	start_attacking()

func create_enemy_tower_visual():
	# Create red square for enemy tower
	var square = ColorRect.new()
	square.size = Vector2(32, 32)
	square.position = Vector2(-16, -16)
	square.color = Color(0.8, 0.2, 0.2, 0.8)  # Red color
	add_child(square)
	
	# Add a darker outline
	var outline = ColorRect.new()
	outline.size = Vector2(36, 36)
	outline.position = Vector2(-18, -18)
	outline.color = Color(0.6, 0.1, 0.1, 0.6)  # Darker red
	add_child(outline)
	move_child(outline, 0)  # Send to back
	
	# Add health bar
	create_health_bar()

func setup_attack_timer():
	attack_timer = Timer.new()
	attack_timer.wait_time = 1.0 / attack_speed
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)

func setup_damage_immunity_timer():
	damage_immunity_timer = Timer.new()
	damage_immunity_timer.wait_time = damage_immunity_duration
	damage_immunity_timer.one_shot = true
	damage_immunity_timer.timeout.connect(_on_damage_immunity_timeout)
	add_child(damage_immunity_timer)

func setup_freeze_timer():
	freeze_timer = Timer.new()
	freeze_timer.one_shot = true
	freeze_timer.timeout.connect(_on_freeze_timer_timeout)
	add_child(freeze_timer)

func _on_attack_timer_timeout():
	if not is_alive or is_frozen:
		return
		
	find_target()
	
	if current_target:
		attack_target()

func _on_freeze_timer_timeout():
	# Remove freeze effect
	is_frozen = false
	remove_freeze_visual()
	print("EnemyTower at ", grid_position, " is no longer frozen")

func apply_freeze_effect(duration: float):
	if not is_alive:
		return
		
	is_frozen = true
	freeze_timer.wait_time = duration
	freeze_timer.start()
	
	# Add freeze visual effect
	add_freeze_visual()
	
	print("EnemyTower at ", grid_position, " has been frozen for ", duration, " seconds")

func add_freeze_visual():
	if freeze_visual:
		freeze_visual.queue_free()
	
	# Create freeze effect visual (light blue overlay)
	freeze_visual = ColorRect.new()
	freeze_visual.size = Vector2(40, 40)
	freeze_visual.position = Vector2(-20, -20)
	freeze_visual.color = Color(0.7, 0.9, 1.0, 0.6)  # Light blue semi-transparent
	add_child(freeze_visual)

func remove_freeze_visual():
	if freeze_visual:
		freeze_visual.queue_free()
		freeze_visual = null

func find_target():
	# Check if current target is still valid and in range
	if current_target and is_instance_valid(current_target) and is_target_in_range(current_target):
		return
	
	# Find new target - prioritize program data packet > player towers
	current_target = null
	var closest_distance = tower_range
	
	# First priority: Program data packet (if active and alive)
	var program_packet = get_program_data_packet()
	if program_packet and is_instance_valid(program_packet) and program_packet.is_alive and program_packet.is_active:
		var distance = global_position.distance_to(program_packet.global_position)
		if distance <= tower_range:
			current_target = program_packet
			return
	
	# Second priority: Player towers
	var player_towers = get_player_towers()
	for tower in player_towers:
		if not is_instance_valid(tower) or not tower.is_alive:
			continue
		
		var distance = global_position.distance_to(tower.global_position)
		if distance <= tower_range and distance < closest_distance:
			current_target = tower
			closest_distance = distance

func get_main_controller():
	return get_tree().get_first_node_in_group("main_controller")

func get_player_towers() -> Array[Tower]:
	var towers: Array[Tower] = []
	var main_controller = get_main_controller()
	if main_controller and main_controller.has_method("get_tower_manager"):
		var tower_manager = main_controller.get_tower_manager()
		if tower_manager:
			towers = tower_manager.get_towers()
	return towers

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
	
	# Deal damage to target
	current_target.take_damage(damage)
	
	# Create projectile visual effect
	create_projectile_to_target(current_target)
	
	print("EnemyTower at ", grid_position, " attacked target for ", damage, " damage!")
	
	# Check if target was destroyed
	if (current_target is Tower and not current_target.is_alive) or (current_target is ProgramDataPacket and not current_target.is_alive):
		current_target = null

func create_projectile_to_target(target: Node):
	# Safety check for freed target
	if not target or not is_instance_valid(target):
		return
		
	# Create a simple projectile visual effect
	var projectile = ColorRect.new()
	projectile.size = Vector2(6, 6)
	projectile.position = Vector2(-3, -3)
	projectile.color = Color(0.8, 0.8, 0.2, 0.9)  # Yellow projectile
	add_child(projectile)
	
	# Animate projectile to target
	var tween = create_tween()
	var target_pos = target.global_position - global_position
	tween.tween_property(projectile, "position", target_pos, 0.3)
	tween.tween_callback(func(): projectile.queue_free())

func start_attacking():
	if not is_alive:
		return
	find_target()
	attack_timer.start()

func stop_attacking():
	attack_timer.stop()

func set_grid_position(pos: Vector2i):
	grid_position = pos

func get_grid_position() -> Vector2i:
	return grid_position

# Damage immunity system - reduced duration for less tankiness
var damage_immunity_timer: Timer
var damage_immunity_duration: float = 0.1  # Reduced from 0.3 to 0.1 seconds
var is_immune_to_damage: bool = false

func _on_damage_immunity_timeout():
	is_immune_to_damage = false
	# Reset visual opacity to normal
	modulate.a = 1.0

func create_health_bar():
	var health_bar_bg = ColorRect.new()
	health_bar_bg.size = Vector2(36, 6)
	health_bar_bg.position = Vector2(-18, -40)
	health_bar_bg.color = Color(0.3, 0.3, 0.3, 0.8)
	add_child(health_bar_bg)
	
	var health_bar = ColorRect.new()
	health_bar.name = "HealthBar"
	health_bar.size = Vector2(32, 4)
	health_bar.position = Vector2(-16, -39)
	health_bar.color = Color(0.8, 0.2, 0.2, 0.8)  # Red to match tower
	add_child(health_bar)

func take_damage(damage_amount: int):
	if not is_alive or is_immune_to_damage:
		return
	
	health -= damage_amount
	update_health_bar()
	
	# Start damage immunity to prevent rapid damage
	is_immune_to_damage = true
	damage_immunity_timer.start()
	
	# Visual feedback: make tower semi-transparent during immunity
	modulate.a = 0.6
	
	print("EnemyTower at ", grid_position, " took ", damage_amount, " damage. Health: ", health, "/", max_health)
	
	if health <= 0:
		die()

func update_health_bar():
	var health_bar = get_node("HealthBar")
	if health_bar:
		var health_percentage = float(health) / float(max_health)
		health_bar.size.x = 32 * health_percentage
		
		# Change color based on health
		if health_percentage > 0.6:
			health_bar.color = Color(0.8, 0.2, 0.2, 0.8)  # Red
		elif health_percentage > 0.3:
			health_bar.color = Color(0.8, 0.8, 0.2, 0.8)  # Yellow
		else:
			health_bar.color = Color(0.8, 0.4, 0.2, 0.8)  # Orange

func die():
	is_alive = false
	stop_attacking()
	enemy_tower_destroyed.emit(self)
	print("EnemyTower at ", grid_position, " destroyed!")
	queue_free()

# Click damage detection using Clickable interface
func is_clicked_at(world_pos: Vector2) -> bool:
	"""Check if a world position click hits this enemy tower"""
	return Clickable.is_clicked_at(global_position, world_pos, Clickable.ENEMY_TOWER_CONFIG)

func handle_click_damage():
	"""Handle damage from player click"""
	return Clickable.handle_click_damage(self, Clickable.ENEMY_TOWER_CONFIG, "EnemyTower")

func get_health_info() -> String:
	"""Get health information for logging"""
	return " Health: " + str(health) + "/" + str(max_health)

func get_program_data_packet() -> ProgramDataPacket:
	"""Get the program data packet from the main controller"""
	var main_controller = get_main_controller()
	if main_controller and main_controller.has_method("get_program_data_packet_manager"):
		var pdp_manager = main_controller.get_program_data_packet_manager()
		if pdp_manager and pdp_manager.has_method("get_program_data_packet"):
			var packet = pdp_manager.get_program_data_packet()
			# Check if the packet is valid and not freed
			if packet and is_instance_valid(packet):
				return packet
	return null

# Debug method for range visualization (can be called from console)
func show_range_debug():
	print("EnemyTower at ", grid_position, " - Range: ", tower_range, " - Current Target: ", current_target, " - Health: ", health, "/", max_health) 
