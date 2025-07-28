extends GridManagerInterface
class_name MockGridManager

# Mock GridManager for unit testing
# Implements GridManagerInterface contract

# Signal for grid block changes (matches real GridManager)
signal grid_blocked_changed(grid_pos: Vector2i, blocked: bool)

var _grid_data: Array = []
var _blocked_grid_data: Array = []
var _ruined_grid_data: Array = []
var _path_positions: Array[Vector2i] = []
var _grid_container: Node2D
var _game_manager: Node
var _initialized: bool = false

# Mock properties for test control
var is_valid_position: bool = true
var is_occupied: bool = false
var is_on_path: bool = false
var world_position: Vector2 = Vector2.ZERO
var unblocked_positions: Array = []
var occupied_positions: Array = []

# Mock function properties for testing
var mock_set_grid_ruined_func: Callable
var mock_is_grid_ruined_func: Callable

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
	_ruined_grid_data = []
	for y in range(GRID_HEIGHT):
		var row = []
		var blocked_row = []
		var ruined_row = []
		for x in range(GRID_WIDTH):
			row.append(false)
			blocked_row.append(false)
			ruined_row.append(false)
		_grid_data.append(row)
		_blocked_grid_data.append(blocked_row)
		_ruined_grid_data.append(ruined_row)

func is_valid_grid_position(grid_pos: Vector2i) -> bool:
	# Use mock property for test control
	if not is_valid_position:
		return false
	return grid_pos.x >= 0 and grid_pos.x < GRID_WIDTH and grid_pos.y >= 0 and grid_pos.y < GRID_HEIGHT

func is_grid_occupied(grid_pos: Vector2i) -> bool:
	# Use mock property for test control
	if is_occupied:
		return true
	if not is_valid_grid_position(grid_pos):
		return true
	# Ensure arrays are initialized
	if _grid_data.size() <= grid_pos.y or _grid_data[grid_pos.y].size() <= grid_pos.x:
		return false
	return _grid_data[grid_pos.y][grid_pos.x]

func set_grid_occupied(grid_pos: Vector2i, occupied: bool) -> void:
	if is_valid_grid_position(grid_pos):
		# Ensure arrays are initialized
		while _grid_data.size() <= grid_pos.y:
			_grid_data.append([])
		while _grid_data[grid_pos.y].size() <= grid_pos.x:
			_grid_data[grid_pos.y].append(false)
		_grid_data[grid_pos.y][grid_pos.x] = occupied
		
		# Track positions for tests
		if occupied:
			if not grid_pos in occupied_positions:
				occupied_positions.append(grid_pos)
		else:
			occupied_positions.erase(grid_pos)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	# Use mock property for test control
	if world_position != Vector2.ZERO:
		return world_position
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

# Add property to match real GridManager interface
var path_grid_positions: Array[Vector2i]:
	get: return _path_positions
	set(value): _path_positions = value

func handle_mouse_hover(world_pos: Vector2) -> void:
	# Mock implementation - does nothing
	pass

func get_grid_container() -> Node2D:
	return _grid_container

func get_grid_size() -> Vector2i:
	return Vector2i(GRID_WIDTH, GRID_HEIGHT)

func set_grid_size(size: Vector2i) -> void:
	# Mock implementation - update the grid dimensions
	# Note: This is for testing purposes only
	# In a real implementation, this would require reinitializing the grid
	pass

func is_on_enemy_path(grid_pos: Vector2i) -> bool:
	# Use mock property for test control
	if is_on_path:
		return true
	return grid_pos in _path_positions

func is_grid_blocked(grid_pos: Vector2i) -> bool:
	if not is_valid_grid_position(grid_pos):
		return true
	# Ensure arrays are initialized
	if _blocked_grid_data.size() <= grid_pos.y or _blocked_grid_data[grid_pos.y].size() <= grid_pos.x:
		return false
	return _blocked_grid_data[grid_pos.y][grid_pos.x]

func set_grid_blocked(grid_pos: Vector2i, blocked: bool) -> void:
	if is_valid_grid_position(grid_pos):
		# Ensure arrays are initialized
		while _blocked_grid_data.size() <= grid_pos.y:
			_blocked_grid_data.append([])
		while _blocked_grid_data[grid_pos.y].size() <= grid_pos.x:
			_blocked_grid_data[grid_pos.y].append(false)
		_blocked_grid_data[grid_pos.y][grid_pos.x] = blocked
		
		# Track positions for tests
		if not blocked:
			if not grid_pos in unblocked_positions:
				unblocked_positions.append(grid_pos)
		else:
			unblocked_positions.erase(grid_pos)

# NEW: Ruined grid methods
func is_grid_ruined(grid_pos: Vector2i) -> bool:
	# Use mock function if available
	if mock_is_grid_ruined_func.is_valid():
		return mock_is_grid_ruined_func.call(grid_pos)
	
	if not is_valid_grid_position(grid_pos):
		return true
	# Ensure arrays are initialized
	if _ruined_grid_data.size() <= grid_pos.y or _ruined_grid_data[grid_pos.y].size() <= grid_pos.x:
		return false
	return _ruined_grid_data[grid_pos.y][grid_pos.x]

func set_grid_ruined(grid_pos: Vector2i, ruined: bool) -> void:
	# Use mock function if available
	if mock_set_grid_ruined_func.is_valid():
		mock_set_grid_ruined_func.call(grid_pos, ruined)
		return
	
	if is_valid_grid_position(grid_pos):
		# Ensure arrays are initialized
		while _ruined_grid_data.size() <= grid_pos.y:
			_ruined_grid_data.append([])
		while _ruined_grid_data[grid_pos.y].size() <= grid_pos.x:
			_ruined_grid_data[grid_pos.y].append(false)
		_ruined_grid_data[grid_pos.y][grid_pos.x] = ruined

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

# Additional helper methods for tests
func set_unblocked_positions(positions: Array) -> void:
	unblocked_positions = positions

func get_unblocked_positions() -> Array:
	return unblocked_positions

func set_occupied_positions(positions: Array) -> void:
	occupied_positions = positions

func get_occupied_positions() -> Array:
	return occupied_positions

# Add missing methods that RivalHackerManager expects
func find_path_astar(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	# Mock implementation - return a simple path if start and end are valid
	if is_valid_grid_position(start) and is_valid_grid_position(end):
		return [start, end]
	return [] as Array[Vector2i]

func get_neighbors(pos: Vector2i) -> Array[Vector2i]:
	# Mock implementation - return adjacent positions
	var neighbors: Array[Vector2i] = []
	var directions = [Vector2i(0, 1), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0)]
	for dir in directions:
		var neighbor = pos + dir
		if is_valid_grid_position(neighbor):
			neighbors.append(neighbor)
	return neighbors 