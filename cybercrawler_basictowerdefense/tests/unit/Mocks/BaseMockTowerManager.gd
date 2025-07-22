extends TowerManagerInterface

# Shared base mock for TowerManagerInterface for use in unit tests
class_name BaseMockTowerManager

var _towers: Array = []
var _enemies: Array = []
var _initialized: bool = false
var _grid_manager: Node
var _currency_manager: CurrencyManagerInterface
var _wave_manager: Node

func initialize(grid_mgr: Node, currency_mgr: CurrencyManagerInterface, wave_mgr: Node) -> void:
	_grid_manager = grid_mgr
	_currency_manager = currency_mgr
	_wave_manager = wave_mgr
	_initialized = true

func attempt_tower_placement(grid_pos: Vector2i, tower_type: String = BASIC_TOWER) -> bool:
	if not _initialized:
		return false
	return place_tower(grid_pos, tower_type)

func attempt_basic_tower_placement(grid_pos: Vector2i) -> bool:
	return attempt_tower_placement(grid_pos, BASIC_TOWER)

func place_tower(grid_pos: Vector2i, tower_type: String = BASIC_TOWER) -> bool:
	if not _initialized:
		return false
	# Create a mock tower node
	var mock_tower = Node.new()
	mock_tower.set_meta("grid_pos", grid_pos)
	mock_tower.set_meta("tower_type", tower_type)
	_towers.append(mock_tower)
	tower_placed.emit(grid_pos, tower_type)
	return true

func get_enemies_for_towers() -> Array:
	return _enemies

func get_towers() -> Array:
	return _towers

func stop_all_towers() -> void:
	for tower in _towers:
		tower.set_meta("stopped", true)

func cleanup_all_towers() -> void:
	_towers.clear()

func get_tower_count() -> int:
	return _towers.size()

func get_tower_count_by_type(tower_type: String) -> int:
	var count = 0
	for tower in _towers:
		if tower.get_meta("tower_type") == tower_type:
			count += 1
	return count

func remove_tower(tower: Node) -> void:
	if tower in _towers:
		_towers.erase(tower)

func get_total_power_level() -> float:
	return float(_towers.size()) * 1.5  # Mock power calculation

# Helper methods for tests
func set_towers(towers: Array) -> void:
	_towers = towers

func add_enemy(enemy: Node):
	_enemies.append(enemy)

func clear_enemies():
	_enemies.clear() 