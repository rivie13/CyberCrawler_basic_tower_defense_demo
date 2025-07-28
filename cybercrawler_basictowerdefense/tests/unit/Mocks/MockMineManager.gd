extends MineManagerInterface
class_name MockMineManager

# Mock state
var mock_mines: Array[Mine] = []
var mock_grid_manager: GridManagerInterface
var mock_currency_manager: CurrencyManagerInterface
var mock_can_place_result: bool = true
var mock_place_result: bool = true
var mock_mine_cost: int = 10

func initialize(grid_mgr: GridManagerInterface, currency_mgr: CurrencyManagerInterface):
	mock_grid_manager = grid_mgr
	mock_currency_manager = currency_mgr

func can_place_mine_at(grid_pos: Vector2i, mine_type: String = "freeze") -> bool:
	return mock_can_place_result

func place_mine(grid_pos: Vector2i, mine_type: String = "freeze") -> bool:
	if mock_place_result:
		var mock_mine = MockMine.new()
		mock_mine.grid_position = grid_pos
		mock_mines.append(mock_mine)
		mine_placed.emit(mock_mine)
	else:
		mine_placement_failed.emit("Mock placement failed")
	return mock_place_result

func create_mine_at_position(grid_pos: Vector2i, mine_type: String = "freeze") -> Mine:
	var mock_mine = MockMine.new()
	mock_mine.grid_position = grid_pos
	return mock_mine

func get_mines() -> Array[Mine]:
	return mock_mines

func get_mine_count() -> int:
	return mock_mines.size()

func clear_all_mines():
	mock_mines.clear()

func get_mine_cost(mine_type: String = "freeze") -> int:
	return mock_mine_cost

# Helper methods for tests
func set_can_place_result(result: bool):
	mock_can_place_result = result

func set_place_result(result: bool):
	mock_place_result = result

func set_mine_cost(cost: int):
	mock_mine_cost = cost

func add_mock_mine(mine: Mine):
	mock_mines.append(mine)

func reset():
	mock_mines.clear()
	mock_can_place_result = true
	mock_place_result = true
	mock_mine_cost = 10

# Mock mine class for testing
class MockMine extends Mine:
	func trigger_mine():
		is_triggered = true
	
	func get_mine_type() -> String:
		return "mock"
	
	func get_mine_name() -> String:
		return "Mock Mine" 