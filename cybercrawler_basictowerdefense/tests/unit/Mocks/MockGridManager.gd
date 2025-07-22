extends GridManagerInterface
class_name MockGridManager

# Mock GridManager for unit testing
# Implements GridManagerInterface contract

var _grid_data: Array = []
var _blocked_grid_data: Array = []
var _path_positions: Array[Vector2i] = []
var _grid_container: Node2D
var _game_manager: Node
var _initialized: bool = false

# Mock grid constants
const GRID_SIZE = 64
const GRID_WIDTH = 15
const GRID_HEIGHT = 10

func initialize_with_container(container: Node2D, game_mgr = null) -> void:
	_grid_container = container
	_game_manager = game_mgr
	_initialized = true
	_initialize_grid()

func _initialize_grid():
	# Initialize grid data arrays
	_grid_data = []
	_blocked_grid_data = []
	for y in range(GRID_HEIGHT):
		var row = []
		var blocked_row = []
		for x in range(GRID_WIDTH):
			row.append(false)
			blocked_row.append(false)
		_grid_data.append(row)
		_blocked_grid_data.append(blocked_row)

func is_valid_grid_position(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < GRID_WIDTH and grid_pos.y >= 0 and grid_pos.y < GRID_HEIGHT

func is_grid_occupied(grid_pos: Vector2i) -> bool:
	if not is_valid_grid_position(grid_pos):
		return true
	return _grid_data[grid_pos.y][grid_pos.x]

func set_grid_occupied(grid_pos: Vector2i, occupied: bool) -> void:
	if is_valid_grid_position(grid_pos):
		_grid_data[grid_pos.y][grid_pos.x] = occupied

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	var world_x = grid_pos.x * GRID_SIZE + GRID_SIZE / 2.0
	var world_y = grid_pos.y * GRID_SIZE + GRID_SIZE / 2.0
	return Vector2(world_x, world_y)

func world_to_grid(world_pos: Vector2) -> Vector2i:
	var grid_x = int(floor(world_pos.x / GRID_SIZE))
	var grid_y = int(floor(world_pos.y / GRID_SIZE))
	return Vector2i(grid_x, grid_y)

func set_path_positions(positions: Array[Vector2i]) -> void:
	_path_positions = positions

func get_path_positions() -> Array[Vector2i]:
	return _path_positions

func handle_mouse_hover(world_pos: Vector2) -> void:
	# Mock implementation - does nothing
	pass

func get_grid_container() -> Node2D:
	return _grid_container

func get_grid_size() -> Vector2i:
	return Vector2i(GRID_WIDTH, GRID_HEIGHT)

func is_on_enemy_path(grid_pos: Vector2i) -> bool:
	return grid_pos in _path_positions

func is_grid_blocked(grid_pos: Vector2i) -> bool:
	if not is_valid_grid_position(grid_pos):
		return true
	return _blocked_grid_data[grid_pos.y][grid_pos.x]

func set_grid_blocked(grid_pos: Vector2i, blocked: bool) -> void:
	if is_valid_grid_position(grid_pos):
		_blocked_grid_data[grid_pos.y][grid_pos.x] = blocked

# Helper methods for tests
func set_grid_data(data: Array) -> void:
	_grid_data = data

func set_blocked_grid_data(data: Array) -> void:
	_blocked_grid_data = data

func get_grid_data() -> Array:
	return _grid_data

func get_blocked_grid_data() -> Array:
	return _blocked_grid_data

func is_initialized() -> bool:
	return _initialized 