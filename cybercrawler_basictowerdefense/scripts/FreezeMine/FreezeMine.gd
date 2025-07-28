extends Mine
class_name FreezeMine

# FreezeMine properties
@export var freeze_radius: float = 100.0
@export var freeze_duration: float = 3.0  # Duration in seconds
@export var trigger_radius: float = 80.0  # Radius to detect enemies for auto-trigger
@export var max_uses: int = 1  # Single use item

# State
var uses_remaining: int
var detection_timer: Timer

# Visual components
var mine_body: ColorRect
var trigger_circle: Node2D
var freeze_circle: Node2D
var uses_label: Label

# Signals
signal mine_triggered(mine: FreezeMine)
signal mine_depleted(mine: FreezeMine)

func _ready():
	uses_remaining = max_uses
	cost = 15  # Set the cost for freeze mines
	create_mine_visual()
	setup_detection_timer()

func create_mine_visual():
	# Create mine body (small cyan square)
	mine_body = ColorRect.new()
	mine_body.size = Vector2(20, 20)
	mine_body.position = Vector2(-10, -10)
	mine_body.color = Color(0.0, 0.8, 0.8, 0.8)  # Cyan color
	add_child(mine_body)
	
	# Add a darker outline
	var outline = ColorRect.new()
	outline.size = Vector2(24, 24)
	outline.position = Vector2(-12, -12)
	outline.color = Color(0.0, 0.5, 0.5, 0.6)  # Darker cyan
	add_child(outline)
	move_child(outline, 0)  # Send to back
	
	# Add uses remaining label
	uses_label = Label.new()
	uses_label.text = str(uses_remaining)
	uses_label.position = Vector2(-5, -30)
	uses_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(uses_label)

func setup_detection_timer():
	detection_timer = Timer.new()
	detection_timer.wait_time = 0.2  # Check every 0.2 seconds
	detection_timer.timeout.connect(_on_detection_timer_timeout)
	add_child(detection_timer)
	
	# Start the timer after it's added to the scene tree
	# Use call_deferred to ensure it happens after the node is properly added
	call_deferred("_start_detection_timer")

func _start_detection_timer():
	if detection_timer and is_inside_tree():
		detection_timer.start()

func _on_detection_timer_timeout():
	if not is_active or uses_remaining <= 0:
		return
		
	# Check for enemy towers in trigger radius
	var enemy_towers = get_enemy_towers_in_radius(global_position, trigger_radius)
	if enemy_towers.size() > 0:
		trigger_freeze_mine()

func get_enemy_towers_in_radius(center: Vector2, radius: float) -> Array:
	var towers_in_radius = []
	var main_controller = get_main_controller()
	if main_controller and main_controller.rival_hacker_manager:
		var all_enemy_towers = main_controller.rival_hacker_manager.get_enemy_towers()
		for tower in all_enemy_towers:
			if is_instance_valid(tower) and tower.is_alive:
				var distance = center.distance_to(tower.global_position)
				if distance <= radius:
					towers_in_radius.append(tower)
	return towers_in_radius

func trigger_freeze_mine():
	if not is_active or uses_remaining <= 0 or is_triggered:
		return
	
	is_triggered = true
	uses_remaining -= 1
	
	# Apply freeze effect to enemy towers in freeze radius
	var enemy_towers = get_enemy_towers_in_radius(global_position, freeze_radius)
	for tower in enemy_towers:
		if is_instance_valid(tower) and tower.has_method("apply_freeze_effect"):
			tower.apply_freeze_effect(freeze_duration)
	
	# Visual effect
	create_freeze_effect_visual()
	
	# Update uses label
	uses_label.text = str(uses_remaining)
	
	# Emit signal
	mine_triggered.emit(self)
	
	print("FreezeMine triggered! Froze ", enemy_towers.size(), " enemy towers for ", freeze_duration, " seconds")
	
	# Reset triggered state after a short delay
	await get_tree().create_timer(0.5).timeout
	is_triggered = false
	
	# If no uses remaining, mark as depleted
	if uses_remaining <= 0:
		is_active = false
		mine_depleted.emit(self)
		# Change visual to indicate depletion
		mine_body.color = Color(0.5, 0.5, 0.5, 0.5)  # Gray out

func create_freeze_effect_visual():
	# Create visual effect for freeze radius
	var freeze_effect = ColorRect.new()
	freeze_effect.size = Vector2(freeze_radius * 2, freeze_radius * 2)
	freeze_effect.position = Vector2(-freeze_radius, -freeze_radius)
	freeze_effect.color = Color(0.0, 0.8, 0.8, 0.3)  # Semi-transparent cyan
	add_child(freeze_effect)
	
	# Animate the effect
	var tween = create_tween()
	tween.tween_property(freeze_effect, "modulate:a", 0.0, 1.0)
	tween.tween_callback(freeze_effect.queue_free)

func get_main_controller():
	return get_tree().get_first_node_in_group("main_controller")

func can_be_placed_at(grid_pos: Vector2i, grid_manager: GridManagerInterface) -> bool:
	# Check if position is valid and not occupied
	if not grid_manager.is_valid_grid_position(grid_pos):
		return false
	if grid_manager.is_grid_occupied(grid_pos):
		return false
	if grid_manager.is_on_enemy_path(grid_pos):
		return false
	return true

func set_grid_position(grid_pos: Vector2i):
	grid_position = grid_pos

func get_mine_type() -> String:
	return "freeze"

func get_mine_name() -> String:
	return "Freeze Mine"

func trigger_mine():
	trigger_freeze_mine()

func get_cost() -> int:
	return cost 