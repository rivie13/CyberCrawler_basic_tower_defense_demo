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

func _ready():
	setup_enemy_spawning()

func initialize(grid_ref: Node):
	grid_manager = grid_ref
	grid_layout = GridLayout.new(grid_manager)
	create_enemy_path()

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
	if not grid_layout:
		push_error("WaveManager: grid_layout not set!")
		return
	
	# Use GridLayout to create the enemy path
	enemy_path = grid_layout.create_path()

func get_path_grid_positions() -> Array[Vector2i]:
	if not grid_layout:
		return []
	
	# Use GridLayout to get path grid positions
	return grid_layout.get_path_grid_positions()

func start_wave():
	if wave_active or current_wave > max_waves:
		return
	
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
