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
	_pause_enemies()
	_show_recalculating_message()
	var enemies_to_recycle = _identify_enemies_to_recycle()
	_remove_enemies(enemies_to_recycle)
	_spawn_replacement_enemies(enemies_to_recycle.size())
	_reposition_remaining_enemies()
	_stagger_resume_enemies()

func _pause_enemies():
	for enemy in enemies_alive:
		if is_instance_valid(enemy):
			enemy.pause()

func _show_recalculating_message():
	var main_controller = get_tree().get_first_node_in_group("main_controller")
	if main_controller:
		main_controller.show_temp_message("Path changed! Enemies recalculating...", 1.5)

func _identify_enemies_to_recycle() -> Array:
	var enemies_to_recycle = []
	for enemy in enemies_alive.duplicate():
		if is_instance_valid(enemy):
			for path_point in enemy_path:
				if enemy.global_position.distance_to(path_point) < grid_manager.GRID_SIZE * 0.5:
					enemies_to_recycle.append(enemy)
					break
	return enemies_to_recycle

func _remove_enemies(enemies_to_recycle: Array):
	for enemy in enemies_to_recycle:
		if is_instance_valid(enemy):
			enemies_alive.erase(enemy)
			enemy.queue_free()

func _spawn_replacement_enemies(num_to_spawn: int):
	var spacing = 32.0
	if enemy_path.size() > 1:
		var start = enemy_path[0]
		var next = enemy_path[1]
		var direction = (next - start).normalized()
		var offscreen_offset = 5 * grid_manager.GRID_SIZE * (enemies_alive.size() + num_to_spawn)
		for i in range(num_to_spawn):
			var enemy = ENEMY_SCENE.instantiate()
			enemy.set_path(enemy_path)
			var pos = start - direction * (offscreen_offset + i * spacing)
			enemy.global_position = pos
			enemy.current_path_index = 0
			enemy.target_position = enemy_path[0]
			# Connect enemy signals
			enemy.enemy_died.connect(_on_enemy_died)
			enemy.enemy_reached_end.connect(_on_enemy_reached_end)
			enemies_alive.append(enemy)
			add_child(enemy)

func _reposition_remaining_enemies():
	var enemies_count = enemies_alive.size()
	var spacing = 32.0
	if enemy_path.size() > 1:
		var start = enemy_path[0]
		var next = enemy_path[1]
		var direction = (next - start).normalized()
		var offscreen_offset = 5 * grid_manager.GRID_SIZE * enemies_count
		for i in range(enemies_count):
			var enemy = enemies_alive[i]
			if is_instance_valid(enemy):
				var pos = start - direction * (offscreen_offset + i * spacing)
				enemy.global_position = pos
				enemy.current_path_index = 0
				enemy.target_position = enemy_path[0]
				enemy.set_path(enemy_path)

func _stagger_resume_enemies():
	var enemies_count = enemies_alive.size()
	var resume_delay = 0.1
	for i in range(enemies_count):
		var enemy = enemies_alive[i]
		if is_instance_valid(enemy):
			var current_enemy = enemy  # Local copy for closure
			var timer = Timer.new()
			timer.wait_time = 0.5 + i * resume_delay
			timer.one_shot = true
			timer.timeout.connect(func():
				if is_instance_valid(current_enemy):
					current_enemy.resume()
				timer.queue_free()
			)
			add_child(timer)

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
	
	# Every 3 waves, randomly select a new layout type for strategic variety
	if current_wave % 3 == 0 and current_wave > 1:
		var layout_types = [
			GridLayout.LayoutType.STRAIGHT_LINE,
			GridLayout.LayoutType.L_SHAPED,
			GridLayout.LayoutType.S_CURVED,
			GridLayout.LayoutType.ZIGZAG
		]
		var new_layout_type = layout_types[randi() % layout_types.size()]
		if new_layout_type != selected_layout_type:
			selected_layout_type = new_layout_type
			print("WaveManager: Changing to new layout type for wave ", current_wave, ": ", selected_layout_type)
			create_enemy_path()  # Update path with new layout
	
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
	enemy.global_position = enemy_path[0]
	
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
