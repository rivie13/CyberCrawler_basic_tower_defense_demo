extends Node2D
class_name WaveManager

# Signals for communication with other managers
signal enemy_died(enemy: Enemy)
signal enemy_reached_end(enemy: Enemy)
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_completed()

# Enemy spawning
const ENEMY_SCENE = preload("res://scenes/Enemy.tscn")
var enemy_spawn_timer: Timer
var wave_timer: Timer
var enemies_alive: Array[Enemy] = []
var enemy_path: Array[Vector2] = []

# Wave system
var current_wave: int = 1
var enemies_per_wave: int = 5
var enemies_spawned_this_wave: int = 0
var wave_active: bool = false
var time_between_enemies: float = 1.0
var time_between_waves: float = 3.0
var max_waves: int = 10  # Win condition: survive 10 waves

# Grid reference for positioning
var grid_manager: Node
var grid_layout: GridLayout
var selected_layout_type: Variant = null  # FIXED: Initialize to null so randomization works

# Replace Vector2i.ZERO sentinels with nullable variables
var path_start: Variant = null  # Start grid position for path, null if unset
var path_end: Variant = null    # End grid position for path, null if unset

func _ready():
	setup_enemy_spawning()
	# Add MainController to the group
	add_to_group("main_controller")

func initialize(grid_ref: Node):
	grid_manager = grid_ref
	grid_layout = GridLayout.new(grid_manager)
	# Only randomize layout type once, if not already set
	if selected_layout_type == null:
		var layout_types = [
			GridLayout.LayoutType.STRAIGHT_LINE,
			GridLayout.LayoutType.L_SHAPED,
			GridLayout.LayoutType.S_CURVED,
			GridLayout.LayoutType.ZIGZAG
		]
		selected_layout_type = layout_types[randi() % layout_types.size()]
		print("WaveManager: Selected random layout type: ", selected_layout_type)
	create_enemy_path()
	# NEW: Listen for grid block changes
	if grid_manager.has_signal("grid_blocked_changed"):
		grid_manager.grid_blocked_changed.connect(_on_grid_blocked_changed)

# NEW: Handle grid block changes
func _on_grid_blocked_changed(grid_pos: Vector2i, blocked: bool):
	create_enemy_path()
	# Enhanced: Pause, reposition, and resume enemies on path change
	_handle_enemies_on_path_change()
	# Update all active enemies with the new path
	for enemy in enemies_alive:
		if is_instance_valid(enemy):
			enemy.set_path(enemy_path)

# NEW: Enhanced path change handling
func _handle_enemies_on_path_change():
	# SIMPLIFIED: Just pause, update paths, and resume enemies without complex repositioning
	_pause_enemies()
	_show_recalculating_message()
	_update_enemy_paths_simple()
	_resume_enemies_simple()

func _pause_enemies():
	for enemy in enemies_alive:
		if is_instance_valid(enemy):
			enemy.pause()

func _show_recalculating_message():
	var main_controller = get_tree().get_first_node_in_group("main_controller")
	if main_controller:
		main_controller.show_temp_message("Path changed! Enemies recalculating...", 1.5)

# SIMPLIFIED: Just update paths and let enemies naturally follow the new route
func _update_enemy_paths_simple():
	for enemy in enemies_alive:
		if is_instance_valid(enemy):
			enemy.set_path(enemy_path)
			# Find the closest path point and set it as the new target
			var closest_distance = INF
			var closest_index = 0
			for i in range(enemy_path.size()):
				var distance = enemy.global_position.distance_to(enemy_path[i])
				if distance < closest_distance:
					closest_distance = distance
					closest_index = i
			
			# Set the enemy to head toward the closest path point
			enemy.current_path_index = closest_index
			enemy.target_position = enemy_path[closest_index]

# SIMPLIFIED: Resume all enemies at once to maintain formation
func _resume_enemies_simple():
	# Small delay to let path visualization update
	var timer = Timer.new()
	timer.wait_time = 0.2
	timer.one_shot = true
	timer.timeout.connect(func():
		for enemy in enemies_alive:
			if is_instance_valid(enemy):
				enemy.resume()
		timer.queue_free()
	)
	add_child(timer)

# DEPRECATED: These functions are replaced by the simplified system above
func _identify_enemies_to_recycle() -> Array:
	# This function is no longer used - keeping for compatibility
	return []

func _remove_enemies(enemies_to_recycle: Array):
	# This function is no longer used - keeping for compatibility
	pass

func _spawn_replacement_enemies(num_to_spawn: int):
	# This function is no longer used - keeping for compatibility
	pass

func _reposition_remaining_enemies():
	# This function is no longer used - keeping for compatibility
	pass

func _stagger_resume_enemies():
	# This function is no longer used - keeping for compatibility
	pass

func setup_enemy_spawning():
	# Create enemy spawn timer
	enemy_spawn_timer = Timer.new()
	enemy_spawn_timer.wait_time = time_between_enemies
	enemy_spawn_timer.timeout.connect(_on_enemy_spawn_timer_timeout)
	add_child(enemy_spawn_timer)
	
	# Create wave timer
	wave_timer = Timer.new()
	wave_timer.wait_time = time_between_waves
	wave_timer.one_shot = true
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	add_child(wave_timer)

func create_enemy_path():
	if not grid_layout or not grid_manager:
		push_error("WaveManager: grid_layout or grid_manager not set!")
		return

	var grid_path = []
	
	# Always try to use the selected layout type first (for strategic variety)
	grid_path = grid_layout.get_path_grid_positions(selected_layout_type)
	
	if grid_path.size() == 0:
		push_error("WaveManager: No grid path available for layout type: ", selected_layout_type)
		return
		
	# Store start and end for potential A* fallback
	path_start = grid_path[0]
	path_end = grid_path[grid_path.size() - 1]
	
	# Check if the selected layout path is blocked by validating each step
	var path_blocked = false
	for i in range(grid_path.size() - 1):
		var current_pos = grid_path[i]
		var next_pos = grid_path[i + 1]
		
		# Check if current position is blocked (except start and end)
		if i > 0 and i < grid_path.size() - 1 and grid_manager.is_grid_blocked(current_pos):
			path_blocked = true
			break
	
	# If the strategic layout is blocked, fall back to A* but preserve strategic endpoints
	if path_blocked:
		print("WaveManager: Strategic layout blocked, using A* pathfinding...")
		grid_path = grid_manager.find_path_astar(path_start, path_end)
		if grid_path.size() == 0:
			push_error("WaveManager: No valid A* path available!")
			return

	# Convert grid path to world positions for enemy movement
	enemy_path = []
	for grid_pos in grid_path:
		enemy_path.append(grid_manager.grid_to_world(grid_pos))

	# Update grid visualization to match the actual path
	grid_manager.set_path_positions(grid_path)

func get_path_grid_positions() -> Array[Vector2i]:
	if not grid_layout:
		return []
	
	# Use the same selected layout type for consistency
	return grid_layout.get_path_grid_positions(selected_layout_type)

func start_wave():
	if wave_active or current_wave > max_waves:
		return
	
	# DISABLED: Layout changes now handled by RivalHackerManager only
	# Every 3 waves, randomly select a new layout type for strategic variety
	# if current_wave % 3 == 0 and current_wave > 1:
	#	var layout_types = [
	#		GridLayout.LayoutType.STRAIGHT_LINE,
	#		GridLayout.LayoutType.L_SHAPED,
	#		GridLayout.LayoutType.S_CURVED,
	#		GridLayout.LayoutType.ZIGZAG
	#	]
	#	var new_layout_type = layout_types[randi() % layout_types.size()]
	#	if new_layout_type != selected_layout_type:
	#		selected_layout_type = new_layout_type
	#		print("WaveManager: Changing to new layout type for wave ", current_wave, ": ", selected_layout_type)
	#		create_enemy_path()  # Update path with new layout
	
	wave_active = true
	enemies_spawned_this_wave = 0
	enemy_spawn_timer.start()
	
	wave_started.emit(current_wave)
	print("Wave ", current_wave, " started!")

func _on_enemy_spawn_timer_timeout():
	if enemies_spawned_this_wave >= enemies_per_wave:
		enemy_spawn_timer.stop()
		wave_active = false
		
		# Start countdown for next wave
		wave_timer.start()
		wave_completed.emit(current_wave)
		return
	
	spawn_enemy()
	enemies_spawned_this_wave += 1

func _on_wave_timer_timeout():
	# Check if we've completed all waves
	if current_wave >= max_waves:
		all_waves_completed.emit()
		return
	
	# Start next wave
	current_wave += 1
	enemies_per_wave += 2  # Increase difficulty
	start_wave()

func spawn_enemy():
	var enemy = ENEMY_SCENE.instantiate()
	enemy.set_path(enemy_path)
	
	# FIXED: Spawn enemies with proper spacing to prevent stacking
	var spacing = 48.0  # Distance between enemies
	var spawn_position = enemy_path[0]
	
	# Calculate spawn position based on number of enemies already spawned this wave
	if enemy_path.size() > 1 and enemies_spawned_this_wave > 0:
		var direction = (enemy_path[0] - enemy_path[1]).normalized()
		var offset = direction * spacing * enemies_spawned_this_wave
		spawn_position = enemy_path[0] + offset
	
	enemy.global_position = spawn_position
	
	# Connect enemy signals
	enemy.enemy_died.connect(_on_enemy_died)
	enemy.enemy_reached_end.connect(_on_enemy_reached_end)
	
	enemies_alive.append(enemy)
	add_child(enemy)

func _on_enemy_died(enemy: Enemy):
	enemies_alive.erase(enemy)
	enemy_died.emit(enemy)

func _on_enemy_reached_end(enemy: Enemy):
	enemies_alive.erase(enemy)
	enemy_reached_end.emit(enemy)

func get_enemies() -> Array[Enemy]:
	return enemies_alive

func get_current_wave() -> int:
	return current_wave

func get_max_waves() -> int:
	return max_waves

func is_wave_active() -> bool:
	return wave_active

func are_enemies_alive() -> bool:
	return not enemies_alive.is_empty()

func get_wave_timer_time_left() -> float:
	if wave_timer:
		return wave_timer.time_left
	return 0.0

func stop_all_timers():
	if enemy_spawn_timer:
		enemy_spawn_timer.stop()
	if wave_timer:
		wave_timer.stop()
	wave_active = false

func cleanup_all_enemies():
	for enemy in enemies_alive.duplicate():
		if is_instance_valid(enemy):
			enemy.queue_free()
	enemies_alive.clear()

func get_enemy_path() -> Array[Vector2]:
	"""Get the current enemy path for other systems to use"""
	return enemy_path 
