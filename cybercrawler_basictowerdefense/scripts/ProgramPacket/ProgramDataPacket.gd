extends Node2D
class_name ProgramDataPacket

# Constants for magic numbers (addressing Copilot review)
const COLLISION_THRESHOLD: float = 40.0
const TARGET_REACH_THRESHOLD: float = 10.0

# Debug mode flag for conditional logging
const DEBUG_MODE := true

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
	if DEBUG_MODE:
		print("[DEBUG][set_path] Called. Old path size: %d, New path size: %d, is_active: %s, is_alive: %s" % [path_points.size(), new_path.size(), str(is_active), str(is_alive)])
	"""Set the path for the program data packet to follow, keeping percent progress if possible. Robustly handles short paths and edge cases."""
	if DEBUG_MODE:
		print("[ProgramDataPacket] set_path called. Old path size: %d, New path size: %d" % [path_points.size(), new_path.size()])
	if new_path.size() < 2:
		if DEBUG_MODE:
			print("[ProgramDataPacket] ERROR: New path is too short. Destroying packet.")
		is_alive = false
		queue_free()
		return

	if path_points.size() > 1 and is_active:
		# Calculate percent progress along old path
		var old_path = path_points
		var old_total = _path_total_length(old_path)
		var idx = clamp(current_path_index, 0, old_path.size() - 2)
		var old_traveled = _path_distance_traveled(old_path, idx, global_position)
		var percent = 0.0
		if old_total > 0.0:
			percent = clamp(old_traveled / old_total, 0.0, 1.0)
		if DEBUG_MODE:
			print("[ProgramDataPacket] Old path total: %.2f, traveled: %.2f, percent: %.2f" % [old_total, old_traveled, percent])

		# Find position on new path at same percent
		var new_total = _path_total_length(new_path)
		var new_target_pos = new_path[0]
		var new_index = 0
		if new_total > 0.0:
			var target_dist = percent * new_total
			var accum = 0.0
			var found = false
			for i in range(new_path.size() - 1):
				var seg_len = new_path[i].distance_to(new_path[i+1])
				if accum + seg_len >= target_dist:
					var seg_percent = (target_dist - accum) / seg_len
					new_target_pos = new_path[i].lerp(new_path[i+1], seg_percent)
					new_index = i
					if DEBUG_MODE:
						print("[ProgramDataPacket] Teleporting to segment %d, seg_percent: %.2f, pos: %s" % [i, seg_percent, str(new_target_pos)])
					found = true
					break
				accum += seg_len
			# If target_dist is at end, snap to last point
			if not found or target_dist >= new_total:
				# If path is very short, move to first segment, not all the way to start
				if new_path.size() <= 2:
					new_target_pos = new_path[1]
					new_index = 0
					if DEBUG_MODE:
						print("[ProgramDataPacket] Path very short, moving to first segment instead of start.")
				else:
					new_target_pos = new_path[-2]
					new_index = new_path.size() - 2
					if DEBUG_MODE:
						print("[ProgramDataPacket] Teleporting to near end of new path.")

		path_points = new_path
		current_path_index = new_index
		global_position = new_target_pos
		# Set target_position to the next point, unless at end
		if current_path_index < path_points.size() - 1:
			target_position = path_points[current_path_index + 1]
		else:
			target_position = path_points[current_path_index]
		if DEBUG_MODE:
			print("[ProgramDataPacket] set_path complete. New index: %d, New pos: %s, Target: %s" % [new_index, str(new_target_pos), str(target_position)])
		pause_for_path_change(5.0)
	else:
		# If not active or no old path, just snap to start
		path_points = new_path
		current_path_index = 0
		if path_points.size() > 0:
			global_position = path_points[0]
			target_position = path_points[1] if path_points.size() > 1 else path_points[0]
			if DEBUG_MODE:
				print("[ProgramDataPacket] set_path: Snapped to start of new path.")
	if DEBUG_MODE:
		print("[DEBUG][set_path] After assignment: current_path_index=%d, global_position=%s, target_position=%s, path_points.size()=%d" % [current_path_index, str(global_position), str(target_position), path_points.size()])

# Helper: total length of a path
func _path_total_length(path: Array[Vector2]) -> float:
	var total = 0.0
	for i in range(path.size() - 1):
		total += path[i].distance_to(path[i+1])
	return total

# Helper: distance traveled along path up to current position
func _path_distance_traveled(path: Array[Vector2], idx: int, pos: Vector2) -> float:
	var dist = 0.0
	for i in range(idx):
		dist += path[i].distance_to(path[i+1])
	if idx < path.size():
		dist += path[idx].distance_to(pos)
	return dist

# Pauses the packet for a duration (in seconds) before resuming movement
var _path_pause_timer: Timer = null
var _was_active_before_pause: bool = false

func pause_for_path_change(duration: float):
	if DEBUG_MODE:
		print("[DEBUG][pause_for_path_change] Called. duration=%.2f, is_active=%s, is_alive=%s" % [duration, str(is_active), str(is_alive)])
	
	# Store current state
	_was_active_before_pause = is_active
	
	# Clean up existing timer properly
	if _path_pause_timer != null:
		if _path_pause_timer.timeout.is_connected(_on_path_pause_timeout):
			_path_pause_timer.timeout.disconnect(_on_path_pause_timeout)
		_path_pause_timer.stop()
		_path_pause_timer.queue_free()
	
	# Create new timer
	_path_pause_timer = Timer.new()
	_path_pause_timer.one_shot = true
	_path_pause_timer.wait_time = duration
	_path_pause_timer.timeout.connect(_on_path_pause_timeout)
	add_child(_path_pause_timer)
	
	# Pause movement
	is_active = false
	_path_pause_timer.start()
	
	if DEBUG_MODE:
		print("[DEBUG][pause_for_path_change] Timer started. is_active set to false. _was_active_before_pause=%s" % str(_was_active_before_pause))

func _on_path_pause_timeout():
	if DEBUG_MODE:
		print("[DEBUG][_on_path_pause_timeout] Timer fired. _was_active_before_pause=%s" % str(_was_active_before_pause))
	if _was_active_before_pause:
		is_active = true
		if DEBUG_MODE:
			print("[DEBUG][_on_path_pause_timeout] is_active now: %s" % str(is_active))
	else:
		if DEBUG_MODE:
			print("[DEBUG][_on_path_pause_timeout] Not resuming, was not active before pause.")

func activate():
	"""Activate the program data packet to start moving"""
	is_active = true
	if DEBUG_MODE:
		print("Program data packet activated!")

func _physics_process(delta):
	if DEBUG_MODE:
		print("[DEBUG][_physics_process] Moving. current_path_index=%d, global_position=%s, target_position=%s" % [current_path_index, str(global_position), str(target_position)])
	# Changed back to _physics_process for consistent movement with fixed timestep (Copilot review fix)
	if not is_alive or not is_active or path_points.size() == 0:
		if DEBUG_MODE:
			print("[DEBUG][_physics_process] Skipping. is_alive=%s, is_active=%s, path_points.size()=%d" % [str(is_alive), str(is_active), path_points.size()])
		return
	
	# Check if game is over (get from MainController)
	var main_controller = get_main_controller()
	if main_controller and main_controller.game_manager and main_controller.game_manager.is_game_over():
		return
	
	move_along_path(delta)

func get_main_controller():
	return get_tree().get_first_node_in_group("main_controller")

func move_along_path(delta):
	var direction = (target_position - global_position).normalized()
	var distance_to_target = global_position.distance_to(target_position)
	
	# Move towards target using simple position movement (no physics collision)
	var movement = direction * speed * delta
	global_position += movement
	
	# Check for collisions with enemies and take damage
	check_enemy_collisions()
	
	# Check if reached current target
	if distance_to_target < TARGET_REACH_THRESHOLD:
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
	
	if DEBUG_MODE:
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
	if DEBUG_MODE:
		print("Program data packet destroyed!")
	program_packet_destroyed.emit(self)
	queue_free()

func reach_end():
	if DEBUG_MODE:
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
		if distance < COLLISION_THRESHOLD:  # Use constant instead of magic number
			take_damage(1)
			if DEBUG_MODE:
				print("Program data packet hit enemy at distance ", distance, "! Taking damage...")
			break  # Only take damage from one enemy per frame to avoid rapid damage

func get_enemies_in_scene() -> Array:
	"""Get all enemies currently in the scene"""
	var enemies = []
	var main_controller = get_main_controller()
	if main_controller and main_controller.wave_manager:
		enemies = main_controller.wave_manager.enemies_alive
	return enemies 