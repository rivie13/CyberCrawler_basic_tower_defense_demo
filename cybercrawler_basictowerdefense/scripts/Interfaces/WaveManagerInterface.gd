class_name WaveManagerInterface
extends Node

"""
Interface for wave management systems.
Defines the contract that all wave managers must implement.
"""

# Signals for communication with other managers
signal enemy_died(enemy: Enemy)
signal enemy_reached_end(enemy: Enemy)
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_completed()

# Abstract methods that must be implemented
func initialize(grid_ref: Node) -> void:
	push_error("WaveManagerInterface.initialize() must be overridden")

func create_enemy_path() -> void:
	push_error("WaveManagerInterface.create_enemy_path() must be overridden")

func get_path_grid_positions() -> Array[Vector2i]:
	push_error("WaveManagerInterface.get_path_grid_positions() must be overridden")
	return []

func start_wave() -> void:
	push_error("WaveManagerInterface.start_wave() must be overridden")

func spawn_enemy() -> void:
	push_error("WaveManagerInterface.spawn_enemy() must be overridden")

func get_enemies() -> Array[Enemy]:
	push_error("WaveManagerInterface.get_enemies() must be overridden")
	return []

func get_current_wave() -> int:
	push_error("WaveManagerInterface.get_current_wave() must be overridden")
	return 1

func get_max_waves() -> int:
	push_error("WaveManagerInterface.get_max_waves() must be overridden")
	return 10

func is_wave_active() -> bool:
	push_error("WaveManagerInterface.is_wave_active() must be overridden")
	return false

func are_enemies_alive() -> bool:
	push_error("WaveManagerInterface.are_enemies_alive() must be overridden")
	return false

func get_wave_timer_time_left() -> float:
	push_error("WaveManagerInterface.get_wave_timer_time_left() must be overridden")
	return 0.0

func stop_all_timers() -> void:
	push_error("WaveManagerInterface.stop_all_timers() must be overridden")

func cleanup_all_enemies() -> void:
	push_error("WaveManagerInterface.cleanup_all_enemies() must be overridden")

func get_enemy_path() -> Array[Vector2]:
	push_error("WaveManagerInterface.get_enemy_path() must be overridden")
	return [] 