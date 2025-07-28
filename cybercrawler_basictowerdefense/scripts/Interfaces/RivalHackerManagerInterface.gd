class_name RivalHackerManagerInterface
extends Node

"""
Interface for rival hacker AI management systems.
Defines the contract that all rival hacker managers must implement.
"""

# Signals
signal enemy_tower_placed(grid_pos: Vector2i)
signal rival_hacker_activated()

# Abstract methods that must be implemented
func initialize(grid_mgr: GridManagerInterface, currency_mgr: CurrencyManagerInterface, tower_mgr: TowerManagerInterface, wave_mgr: WaveManagerInterface, gm: Node = null) -> void:
	push_error("RivalHackerManagerInterface.initialize() must be overridden")

func activate() -> void:
	push_error("RivalHackerManagerInterface.activate() must be overridden")

func deactivate() -> void:
	push_error("RivalHackerManagerInterface.deactivate() must be overridden")

func get_enemy_towers() -> Array:
	push_error("RivalHackerManagerInterface.get_enemy_towers() must be overridden")
	return []

func get_rival_hackers() -> Array[RivalHacker]:
	push_error("RivalHackerManagerInterface.get_rival_hackers() must be overridden")
	return []

func stop_all_activity() -> void:
	push_error("RivalHackerManagerInterface.stop_all_activity() must be overridden") 