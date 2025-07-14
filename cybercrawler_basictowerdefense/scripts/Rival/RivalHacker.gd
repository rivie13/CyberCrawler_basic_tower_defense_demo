extends CharacterBody2D
class_name RivalHacker

# RivalHacker properties - more powerful than regular enemies
@export var speed: float = 120.0  # Slightly faster than regular enemies
@export var health: int = 8  # Much more health than regular enemies (3)
@export var max_health: int = 8
@export var attack_damage: int = 3  # High damage to player towers
@export var detection_range: float = 400.0  # Range to detect player towers

# Click damage properties
# Click damage properties handled by Clickable interface (between enemy and tower sizes)

# Targeting and movement
var current_target: Tower = null
var target_position: Vector2
var is_seeking_target: bool = true

# State
var is_alive: bool = true
var attack_timer: Timer

# Visual components
var hacker_body: ColorRect
var health_bar: ColorRect
var health_bar_bg: ColorRect

# Signals
signal hacker_destroyed(hacker: RivalHacker)
signal tower_attacked(tower: Tower, damage: int)

func _ready():
	create_hacker_visual()
	setup_attack_timer()
	update_health_bar()

func create_hacker_visual():
	# Create hacker body (distinct purple/magenta color to differentiate from enemies and towers)
	hacker_body = ColorRect.new()
	hacker_body.size = Vector2(40, 40)
	hacker_body.position = Vector2(-20, -20)
	hacker_body.color = Color(0.8, 0.2, 0.8, 0.9)  # Purple/magenta - distinctive hacker color
	add_child(hacker_body)
	
	# Create health bar background
	health_bar_bg = ColorRect.new()
	health_bar_bg.size = Vector2(44, 8)
	health_bar_bg.position = Vector2(-22, -34)
	health_bar_bg.color = Color(0.3, 0.3, 0.3, 0.8)
	add_child(health_bar_bg)
	
	# Create health bar
	health_bar = ColorRect.new()
	health_bar.size = Vector2(40, 6)
	health_bar.position = Vector2(-20, -33)
	health_bar.color = Color(0.8, 0.2, 0.8, 0.8)  # Purple health bar to match theme
	add_child(health_bar)

func setup_attack_timer():
	attack_timer = Timer.new()
	attack_timer.wait_time = 0.1  # Fast attack rate when in contact
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)

func _physics_process(delta):
	if not is_alive:
		return
	
	# Check if game is over
	var main_controller = get_main_controller()
	if main_controller and main_controller.game_manager and main_controller.game_manager.is_game_over():
		return
	
	# Update targeting and movement
	if is_seeking_target:
		find_nearest_tower()
		move_toward_target(delta)

func get_main_controller():
	# Navigate up the tree to find MainController
	var current_node = self
	while current_node:
		if current_node is MainController:
			return current_node
		current_node = current_node.get_parent()
	return null

func find_nearest_tower():
	# Clear invalid target
	if current_target and not is_instance_valid(current_target):
		current_target = null
	
	# If we have a valid target still in range, keep it
	if current_target and is_target_in_range(current_target):
		return
	
	# Find nearest player tower
	current_target = null
	var closest_distance = detection_range
	
	var main_controller = get_main_controller()
	if main_controller and main_controller.tower_manager:
		var towers = main_controller.tower_manager.get_towers()
		for tower in towers:
			if not is_instance_valid(tower) or not tower.is_alive:
				continue
			
			var distance = global_position.distance_to(tower.global_position)
			if distance < closest_distance:
				current_target = tower
				closest_distance = distance

func is_target_in_range(target: Tower) -> bool:
	if not is_instance_valid(target) or not target.is_alive:
		return false
	var distance_to_target = global_position.distance_to(target.global_position)
	return distance_to_target <= detection_range

func move_toward_target(_delta):
	if not current_target or not is_instance_valid(current_target):
		# No target - move randomly or patrol
		wander()
		return
	
	# Move directly toward the target (homing missile behavior)
	var direction = (current_target.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	# Check if we're close enough to attack
	var distance_to_target = global_position.distance_to(current_target.global_position)
	if distance_to_target < 50.0:  # Close enough to attack
		if not attack_timer.time_left > 0:
			attack_timer.start()

func wander():
	# Simple wandering behavior when no target is found
	# Move toward center of the grid or random movement
	var main_controller = get_main_controller()
	if main_controller and main_controller.grid_manager:
		var grid_center = main_controller.grid_manager.grid_to_world(Vector2i(7, 5))  # Approximate center
		var direction = (grid_center - global_position).normalized()
		velocity = direction * (speed * 0.5)  # Slower when wandering
		move_and_slide()

func _on_attack_timer_timeout():
	if current_target and is_instance_valid(current_target) and current_target.is_alive:
		# Check if still in attack range
		var distance_to_target = global_position.distance_to(current_target.global_position)
		if distance_to_target < 50.0:
			attack_target()
		else:
			attack_timer.stop()

func attack_target():
	if not current_target or not is_instance_valid(current_target):
		return
	
	# Deal damage to the tower
	current_target.take_damage(attack_damage)
	tower_attacked.emit(current_target, attack_damage)
	
	print("RivalHacker attacked tower at ", current_target.grid_position, " for ", attack_damage, " damage!")
	
	# Check if tower was destroyed
	if not current_target.is_alive:
		current_target = null
		attack_timer.stop()

func take_damage(damage: int):
	if not is_alive:
		return
	
	health -= damage
	health = max(0, health)
	update_health_bar()
	
	print("RivalHacker took ", damage, " damage. Health: ", health, "/", max_health)
	
	if health <= 0:
		die()

func update_health_bar():
	if health_bar:
		var health_percentage = float(health) / float(max_health)
		health_bar.size.x = 40 * health_percentage
		
		# Change color based on health
		if health_percentage > 0.6:
			health_bar.color = Color(0.8, 0.2, 0.8, 0.8)  # Purple
		elif health_percentage > 0.3:
			health_bar.color = Color(0.8, 0.8, 0.2, 0.8)  # Yellow
		else:
			health_bar.color = Color(0.8, 0.2, 0.2, 0.8)  # Red

func die():
	is_alive = false
	is_seeking_target = false
	attack_timer.stop()
	hacker_destroyed.emit(self)
	print("RivalHacker destroyed!")
	queue_free()

# Click damage detection using Clickable interface
func is_clicked_at(world_pos: Vector2) -> bool:
	"""Check if a world position click hits this RivalHacker"""
	return Clickable.is_clicked_at(global_position, world_pos, Clickable.RIVAL_HACKER_CONFIG)

func handle_click_damage():
	"""Handle damage from player click"""
	return Clickable.handle_click_damage(self, Clickable.RIVAL_HACKER_CONFIG, "RivalHacker")

func get_health_info() -> String:
	"""Get health information for logging"""
	return " Health: " + str(health) + "/" + str(max_health)

func stop_activity():
	# Stop all hacker activity for game over
	attack_timer.stop()
	is_seeking_target = false
	current_target = null 