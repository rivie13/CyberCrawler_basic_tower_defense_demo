extends WaveManagerInterface
class_name WaveManager

# Signals are now inherited from WaveManagerInterface

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
	print("WaveManager: grid_blocked_changed signal received at position: ", grid_pos, " blocked: ", blocked)
	create_enemy_path()
	print("WaveManager: Updated enemy path with ", enemy_path.size(), " points")
	# Enhanced: Pause, reposition, and resume enemies on path change
	_handle_enemies_on_path_change()
	# Update all active enemies with the new path
	for enemy in enemies_alive:
		if is_instance_valid(enemy):
			enemy.set_path(enemy_path)

# NEW: Enhanced path change handling
func _handle_enemies_on_path_change():
	# RESTORED: Use the working enemy recycling system that removes and re-queues enemies
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
	if main_controller and is_instance_valid(main_controller) and main_controller.has_method("show_temp_message"):
		main_controller.show_temp_message("Path changed! Enemies recalculating...", 1.5)
	# Silently skip if main controller not available (e.g., during unit testing)

# RESTORED: Identify enemies that need to be recycled when path changes
func _identify_enemies_to_recycle() -> Array:
	# FIXED: When path changes, recycle ALL enemies to prevent confusion
	var enemies_to_recycle = []
	for enemy in enemies_alive.duplicate():
		if is_instance_valid(enemy):
			enemies_to_recycle.append(enemy)
	return enemies_to_recycle

# RESTORED: Remove enemies that are in problematic positions
func _remove_enemies(enemies_to_recycle: Array):
	for enemy in enemies_to_recycle:
		if is_instance_valid(enemy):
			enemies_alive.erase(enemy)
			enemy.queue_free()

# RESTORED: Spawn replacement enemies at the back of the queue
func _spawn_replacement_enemies(num_to_spawn: int):
	# CRITICAL: Validate enemy_path before spawning replacement enemies
	if enemy_path.size() == 0:
		push_error("WaveManager: Cannot spawn replacement enemies - enemy_path is empty!")
		return
	
	var spacing = 80.0  # Improved spacing to match spawn_enemy
	if enemy_path.size() > 1:
		var start = enemy_path[0]
		var next = enemy_path[1]
		var direction = (next - start).normalized()
		# FIXED: Position enemies at START of path with proper spacing
		for i in range(num_to_spawn):
			var enemy = ENEMY_SCENE.instantiate()
			enemy.set_path(enemy_path)
			# Position behind the start position with proper spacing
			var pos = start - direction * spacing * (i + 1)
			enemy.global_position = pos
			# ALWAYS start from the beginning of the path
			enemy.current_path_index = 0
			enemy.target_position = enemy_path[0]
			# Connect enemy signals
			enemy.enemy_died.connect(_on_enemy_died)
			enemy.enemy_reached_end.connect(_on_enemy_reached_end)
			enemies_alive.append(enemy)
			add_child(enemy)

# RESTORED: Reposition remaining enemies to maintain proper formation
func _reposition_remaining_enemies():
	# CRITICAL: Validate enemy_path before repositioning enemies
	if enemy_path.size() == 0:
		push_error("WaveManager: Cannot reposition enemies - enemy_path is empty!")
		return
	
	var enemies_count = enemies_alive.size()
	var spacing = 80.0  # Improved spacing to match spawn_enemy
	if enemy_path.size() > 1:
		var start = enemy_path[0]
		var next = enemy_path[1]
		var direction = (next - start).normalized()
		# FIXED: Position ALL enemies at START of path with proper spacing
		for i in range(enemies_count):
			var enemy = enemies_alive[i]
			if is_instance_valid(enemy):
				# Position behind the start position with proper spacing
				var pos = start - direction * spacing * (i + 1)
				enemy.global_position = pos
				# ALWAYS start from the beginning of the path
				enemy.current_path_index = 0
				enemy.target_position = enemy_path[0]
				enemy.set_path(enemy_path)

# RESTORED: Stagger enemy resume to prevent all enemies moving at once
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
		# CRITICAL: Stop any active wave spawning if path creation fails
		if enemy_spawn_timer and enemy_spawn_timer.timeout.is_connected(_on_enemy_spawn_timer_timeout):
			enemy_spawn_timer.stop()
		return

	var grid_path = []
	
	# Always try to use the selected layout type first (for strategic variety)
	grid_path = grid_layout.get_path_grid_positions(selected_layout_type)
	
	if grid_path.size() == 0:
		push_error("WaveManager: No grid path available for layout type: ", selected_layout_type)
		# CRITICAL: Stop any active wave spawning if path creation fails
		if enemy_spawn_timer and enemy_spawn_timer.timeout.is_connected(_on_enemy_spawn_timer_timeout):
			enemy_spawn_timer.stop()
		return
		
	# Store start and end for potential A* fallback
	path_start = grid_path[0]
	path_end = grid_path[grid_path.size() - 1]
	
	# Check if the selected layout path is blocked by validating each step
	var path_blocked = false
	for i in range(grid_path.size() - 1):
		var current_pos = grid_path[i]
		# Removed unused variable assignment for next_pos
		
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
			# CRITICAL: Stop any active wave spawning if path creation fails
			if enemy_spawn_timer and enemy_spawn_timer.timeout.is_connected(_on_enemy_spawn_timer_timeout):
				enemy_spawn_timer.stop()
			return

	# Convert grid path to world positions for enemy movement
	enemy_path = []
	for grid_pos in grid_path:
		enemy_path.append(grid_manager.grid_to_world(grid_pos))

	# Update grid visualization to match the actual path
	grid_manager.set_path_positions(grid_path)
	
	print("WaveManager: Successfully created enemy path with ", enemy_path.size(), " points")

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
	# CRITICAL: Validate enemy_path before spawning
	if enemy_path.size() == 0:
		push_error("WaveManager: Cannot spawn enemy - enemy_path is empty!")
		return
	
	var enemy = ENEMY_SCENE.instantiate()
	enemy.set_path(enemy_path)
	
	# IMPROVED: Better spawn positioning to prevent crowding and stacking
	var base_spacing = 80.0  # Increased spacing to prevent crowding
	var spawn_position = enemy_path[0]
	
	# Calculate spawn position with proper spacing from ALL enemies (alive + spawned)
	if enemy_path.size() > 1:
		var direction = (enemy_path[0] - enemy_path[1]).normalized()
		# Use total enemies (existing + current) for proper sequential spacing
		var total_enemy_count = enemies_alive.size() + enemies_spawned_this_wave
		var offset = direction * base_spacing * total_enemy_count
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
