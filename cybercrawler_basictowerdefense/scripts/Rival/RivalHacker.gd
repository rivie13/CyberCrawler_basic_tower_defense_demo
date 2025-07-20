extends Node2D
class_name RivalHacker

# RivalHacker movement and targeting properties
@export var movement_speed: float = 100.0
@export var detection_range: float = 100.0
@export var attack_damage: int = 3
@export var attack_rate: float = 1.5  # Attacks per second
@export var health: int = 8
@export var max_health: int = 8

# Click damage properties handled by Clickable interface (between enemy and tower sizes)

# Targeting and movement
var current_target: Node = null  # Can target Tower or ProgramDataPacket
var target_position: Vector2
var is_seeking_target: bool = true

# Attack system
var attack_timer: Timer

# State
var is_alive: bool = true
var grid_position: Vector2i

# Signals
signal rival_hacker_destroyed(rival_hacker: RivalHacker)
signal tower_attacked(tower: Tower, damage: int)

func _ready():
	# Create rival hacker visual
	create_rival_hacker_visual()
	
	# Setup attack timer
	setup_attack_timer()
	
	# Set initial position
	target_position = global_position

func create_rival_hacker_visual():
	# Create a diamond-shaped rival hacker (rotated square)
	var diamond = ColorRect.new()
	diamond.size = Vector2(24, 24)
	diamond.position = Vector2(-12, -12)
	diamond.color = Color(0.8, 0.4, 0.8, 0.9)  # Purple color
	diamond.rotation = deg_to_rad(45)  # Rotate 45 degrees to make diamond shape
	add_child(diamond)
	
	# Add glow effect
	var glow = ColorRect.new()
	glow.size = Vector2(28, 28)
	glow.position = Vector2(-14, -14)
	glow.color = Color(0.8, 0.4, 0.8, 0.4)  # Purple glow
	glow.rotation = deg_to_rad(45)
	add_child(glow)
	move_child(glow, 0)  # Send to back
	
	# Add health bar
	create_health_bar()

func setup_attack_timer():
	attack_timer = Timer.new()
	attack_timer.wait_time = 1.0 / attack_rate
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)

func _on_attack_timer_timeout():
	if not is_alive:
		return
	
	# Check if we have a target and are in range
	if current_target and is_target_in_range(current_target):
		attack_target()
	else:
		# No target in range, stop attacking
		attack_timer.stop()

func _process(delta):
	if not is_alive:
		return
	
	# Check if game is over
	var main_controller = get_main_controller()
	if main_controller and main_controller.game_manager and main_controller.game_manager.is_game_over():
		return
	
	# Find target if we don't have one
	if not current_target:
		find_nearest_tower()
	
	# Move towards target or seek
	if current_target:
		move_towards_target(delta)
	else:
		seek_movement(delta)

func find_nearest_tower():
	# Clear invalid target
	if current_target and not is_instance_valid(current_target):
		current_target = null
	
	# If we have a valid target in range, keep it
	if current_target and is_target_in_range(current_target):
		return
	
	# Use the new TargetingUtil to find the best target
	var main_controller = get_main_controller()
	if not main_controller:
		return
	
	current_target = TargetingUtil.find_best_target(global_position, detection_range, main_controller)

func is_target_in_range(target: Node) -> bool:
	return TargetingUtil.is_target_in_range(global_position, target, detection_range)

func move_towards_target(delta):
	if not current_target or not is_instance_valid(current_target):
		return
	
	# Calculate direction to target
	var direction = (current_target.global_position - global_position).normalized()
	
	# Move towards target but stop at attack range (slightly closer than detection range)
	var distance_to_target = global_position.distance_to(current_target.global_position)
	var attack_range = detection_range * 0.8  # Attack at 80% of detection range
	
	if distance_to_target > attack_range:
		# Move towards target
		global_position += direction * movement_speed * delta
	else:
		# In attack range, start attacking if not already
		if attack_timer.is_stopped():
			attack_timer.start()

func seek_movement(delta):
	# Random seeking movement when no target
	if is_seeking_target:
		# Move towards target position
		var direction = (target_position - global_position).normalized()
		var distance_to_target = global_position.distance_to(target_position)
		
		if distance_to_target > 5.0:
			global_position += direction * movement_speed * delta
		else:
			# Reached target position, pick a new one
			pick_new_seek_position()

func pick_new_seek_position():
	# Pick a random position within a reasonable range
	var random_offset = Vector2(
		randf_range(-100, 100),
		randf_range(-100, 100)
	)
	target_position = global_position + random_offset
	
	# Ensure position is within reasonable bounds (you might want to adjust this)
	target_position.x = clamp(target_position.x, 50, 750)
	target_position.y = clamp(target_position.y, 50, 550)

func attack_target():
	if not current_target or not is_instance_valid(current_target):
		return
	
	# Deal damage to the target
	current_target.take_damage(attack_damage)
	
	# Emit appropriate signal and print message based on target type
	if current_target is Tower:
		tower_attacked.emit(current_target, attack_damage)
		print("RivalHacker attacked tower at ", current_target.grid_position, " for ", attack_damage, " damage!")
	elif current_target is ProgramDataPacket:
		print("RivalHacker attacked program data packet for ", attack_damage, " damage!")
	else:
		print("RivalHacker attacked target for ", attack_damage, " damage!")
	
	# Check if target was destroyed
	if (current_target is Tower and not current_target.is_alive) or (current_target is ProgramDataPacket and not current_target.is_alive):
		current_target = null
		attack_timer.stop()

func get_main_controller():
	return get_tree().get_first_node_in_group("main_controller")

func create_health_bar():
	var health_bar_bg = ColorRect.new()
	health_bar_bg.size = Vector2(30, 6)
	health_bar_bg.position = Vector2(-15, -25)
	health_bar_bg.color = Color(0.3, 0.3, 0.3, 0.8)
	add_child(health_bar_bg)
	
	var health_bar = ColorRect.new()
	health_bar.name = "HealthBar"
	health_bar.size = Vector2(26, 4)
	health_bar.position = Vector2(-13, -24)
	health_bar.color = Color(0.8, 0.4, 0.8, 0.8)  # Purple to match rival hacker
	add_child(health_bar)

func take_damage(damage_amount: int):
	if not is_alive:
		return
	
	health -= damage_amount
	update_health_bar()
	
	print("RivalHacker took ", damage_amount, " damage. Health: ", health, "/", max_health)
	
	if health <= 0:
		die()

func update_health_bar():
	var health_bar = get_node("HealthBar")
	if health_bar:
		var health_percentage = float(health) / float(max_health)
		health_bar.size.x = 26 * health_percentage
		
		# Change color based on health
		if health_percentage > 0.6:
			health_bar.color = Color(0.8, 0.4, 0.8, 0.8)  # Purple
		elif health_percentage > 0.3:
			health_bar.color = Color(0.8, 0.8, 0.2, 0.8)  # Yellow
		else:
			health_bar.color = Color(0.8, 0.2, 0.2, 0.8)  # Red

func die():
	is_alive = false
	attack_timer.stop()
	rival_hacker_destroyed.emit(self)
	print("RivalHacker destroyed!")
	queue_free()

func set_grid_position(pos: Vector2i):
	grid_position = pos

func get_grid_position() -> Vector2i:
	return grid_position

# Click damage detection using Clickable interface
func is_clicked_at(world_pos: Vector2) -> bool:
	"""Check if a world position click hits this rival hacker"""
	return Clickable.is_clicked_at(global_position, world_pos, Clickable.RIVAL_HACKER_CONFIG)

func handle_click_damage():
	"""Handle damage from player click"""
	return Clickable.handle_click_damage(self, Clickable.RIVAL_HACKER_CONFIG, "RivalHacker")

func get_health_info() -> String:
	"""Get health information for logging"""
	return " Health: " + str(health) + "/" + str(max_health)

# Debug method
func show_debug_info():
	print("RivalHacker - Health: ", health, "/", max_health, " - Current Target: ", current_target, " - Position: ", global_position) 
