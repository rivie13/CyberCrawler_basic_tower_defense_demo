extends RivalHackerManagerInterface
class_name MockRivalHackerManager

# Mock state
var mock_enemy_towers: Array = []
var mock_rival_hackers: Array[RivalHacker] = []
var mock_is_active: bool = false

# Mock dependencies
var mock_grid_manager: GridManagerInterface = null
var mock_currency_manager: CurrencyManagerInterface = null
var mock_tower_manager: TowerManagerInterface = null
var mock_wave_manager: WaveManagerInterface = null
var mock_game_manager: Node = null

# Mock signals
var mock_enemy_tower_placed_called: bool = false
var mock_rival_hacker_activated_called: bool = false

func initialize(grid_mgr: GridManagerInterface, currency_mgr: CurrencyManagerInterface, tower_mgr: TowerManagerInterface, wave_mgr: WaveManagerInterface, gm: Node = null) -> void:
	mock_grid_manager = grid_mgr
	mock_currency_manager = currency_mgr
	mock_tower_manager = tower_mgr
	mock_wave_manager = wave_mgr
	mock_game_manager = gm

func activate() -> void:
	mock_is_active = true
	mock_rival_hacker_activated_called = true
	rival_hacker_activated.emit()

func deactivate() -> void:
	mock_is_active = false

func get_enemy_towers() -> Array:
	return mock_enemy_towers

func get_rival_hackers() -> Array[RivalHacker]:
	return mock_rival_hackers

func stop_all_activity() -> void:
	mock_is_active = false
	mock_enemy_towers.clear()
	mock_rival_hackers.clear()

# Mock helper methods for testing
func set_mock_is_active(active: bool):
	mock_is_active = active

func set_mock_enemy_towers(towers: Array):
	mock_enemy_towers = towers

func add_mock_enemy_tower(tower):
	mock_enemy_towers.append(tower)
	mock_enemy_tower_placed_called = true
	enemy_tower_placed.emit(Vector2i(0, 0))  # Default position

func remove_mock_enemy_tower(tower):
	mock_enemy_towers.erase(tower)

func add_mock_rival_hacker(hacker: RivalHacker):
	mock_rival_hackers.append(hacker)

func remove_mock_rival_hacker(hacker: RivalHacker):
	mock_rival_hackers.erase(hacker)

func reset_mock_signals():
	mock_enemy_tower_placed_called = false
	mock_rival_hacker_activated_called = false

# Methods to manually emit signals for testing
func emit_enemy_tower_placed(grid_pos: Vector2i):
	enemy_tower_placed.emit(grid_pos)

func emit_rival_hacker_activated():
	rival_hacker_activated.emit() 