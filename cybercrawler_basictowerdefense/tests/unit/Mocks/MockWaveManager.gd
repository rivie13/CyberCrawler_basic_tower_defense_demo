extends WaveManagerInterface
class_name MockWaveManager

# Add public properties to match real WaveManager
enum { DEFAULT_CURRENT_WAVE = 1, DEFAULT_MAX_WAVES = 10 }

var current_wave: int:
	get: return mock_current_wave
	set(value): mock_current_wave = value

var max_waves: int:
	get: return mock_max_waves
	set(value): mock_max_waves = value

var enemy_path: Array[Vector2]:
	get: return mock_enemy_path
	set(value): mock_enemy_path = value

# Mock state
var mock_enemies: Array[Enemy] = []
var mock_enemy_path: Array[Vector2] = []
var mock_current_wave: int = 1
var mock_max_waves: int = 10
var mock_wave_active: bool = false
var mock_enemies_alive: bool = false
var mock_wave_timer_time_left: float = 0.0

# Mock dependencies
var mock_grid_manager: Node = null

# Mock signals
var mock_enemy_died_called: bool = false
var mock_enemy_reached_end_called: bool = false
var mock_wave_started_called: bool = false
var mock_wave_completed_called: bool = false
var mock_all_waves_completed_called: bool = false

func initialize(grid_ref: Node) -> void:
	mock_grid_manager = grid_ref

func create_enemy_path() -> void:
	# Mock implementation - do nothing
	pass

func get_path_grid_positions() -> Array[Vector2i]:
	return []

func start_wave() -> void:
	mock_wave_active = true
	mock_wave_started_called = true
	wave_started.emit(mock_current_wave)

func spawn_enemy() -> void:
	var enemy = Enemy.new()
	mock_enemies.append(enemy)
	mock_enemies_alive = true

func get_enemies() -> Array[Enemy]:
	return mock_enemies

func get_current_wave() -> int:
	return mock_current_wave

func get_max_waves() -> int:
	return mock_max_waves

func is_wave_active() -> bool:
	return mock_wave_active

func are_enemies_alive() -> bool:
	return mock_enemies_alive

func get_wave_timer_time_left() -> float:
	return mock_wave_timer_time_left

func stop_all_timers() -> void:
	mock_wave_active = false

func cleanup_all_enemies() -> void:
	mock_enemies.clear()
	mock_enemies_alive = false

func get_enemy_path() -> Array[Vector2]:
	return mock_enemy_path

# Mock helper methods for testing
func set_mock_current_wave(wave: int):
	mock_current_wave = wave

func set_mock_max_waves(waves: int):
	mock_max_waves = waves

func set_mock_wave_active(active: bool):
	mock_wave_active = active

func set_mock_enemies_alive(alive: bool):
	mock_enemies_alive = alive

func set_mock_wave_timer_time_left(time: float):
	mock_wave_timer_time_left = time

func set_mock_enemy_path(path: Array[Vector2]):
	mock_enemy_path = path

func add_mock_enemy(enemy: Enemy):
	mock_enemies.append(enemy)
	mock_enemies_alive = true

func remove_mock_enemy(enemy: Enemy):
	mock_enemies.erase(enemy)
	mock_enemies_alive = not mock_enemies.is_empty()

func reset_mock_signals():
	mock_enemy_died_called = false
	mock_enemy_reached_end_called = false
	mock_wave_started_called = false
	mock_wave_completed_called = false
	mock_all_waves_completed_called = false 