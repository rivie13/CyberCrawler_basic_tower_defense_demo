class_name TowerManagerInterface
extends Node

# Tower type constants - consistent with TowerManager
const BASIC_TOWER = "basic"
const POWERFUL_TOWER = "powerful"

# Signals
signal tower_placed(grid_pos: Vector2i, tower_type: String)
signal tower_placement_failed(reason: String)

# Abstract methods that must be implemented
func initialize(grid_mgr: GridManagerInterface, currency_mgr: CurrencyManagerInterface, wave_mgr: WaveManagerInterface) -> void:
	push_error("TowerManagerInterface.initialize() must be overridden")

func attempt_tower_placement(grid_pos: Vector2i, tower_type: String = BASIC_TOWER) -> bool:
	push_error("TowerManagerInterface.attempt_tower_placement() must be overridden")
	return false

func attempt_basic_tower_placement(grid_pos: Vector2i) -> bool:
	push_error("TowerManagerInterface.attempt_basic_tower_placement() must be overridden")
	return false

func place_tower(grid_pos: Vector2i, tower_type: String = BASIC_TOWER) -> bool:
	push_error("TowerManagerInterface.place_tower() must be overridden")
	return false

func get_enemies_for_towers() -> Array[Enemy]:
	push_error("TowerManagerInterface.get_enemies_for_towers() must be overridden")
	return []

func get_towers() -> Array[Tower]:
	push_error("TowerManagerInterface.get_towers() must be overridden")
	return []

func stop_all_towers() -> void:
	push_error("TowerManagerInterface.stop_all_towers() must be overridden")

func cleanup_all_towers() -> void:
	push_error("TowerManagerInterface.cleanup_all_towers() must be overridden")

func get_tower_count() -> int:
	push_error("TowerManagerInterface.get_tower_count() must be overridden")
	return 0

func get_tower_count_by_type(tower_type: String) -> int:
	push_error("TowerManagerInterface.get_tower_count_by_type() must be overridden")
	return 0

func remove_tower(tower: Node) -> void:
	push_error("TowerManagerInterface.remove_tower() must be overridden")

func get_total_power_level() -> float:
	push_error("TowerManagerInterface.get_total_power_level() must be overridden")
	return 0.0 