extends Node2D
class_name GridManager

# Grid constants
const GRID_SIZE = 64  # Size of each grid cell in pixels
const GRID_WIDTH = 15  # Number of grid cells horizontally
const GRID_HEIGHT = 10  # Number of grid cells vertically

# Grid data - true means occupied, false means empty
var grid_data: Array = []
var path_grid_positions: Array[Vector2i] = []  # Track which grid positions are on enemy path
var path_visual_elements: Array = []  # Visual indicators for the path
var grid_container: Node2D
var grid_lines: Array = []

# Colors for visualization
const GRID_COLOR = Color(0.8, 0.8, 0.8, 1.0)
const OCCUPIED_COLOR = Color(0.8, 0.2, 0.2, 0.6)
const HOVER_COLOR = Color(0.2, 0.8, 0.2, 0.6)
const PATH_COLOR = Color(0.9, 0.7, 0.3, 0.8)  # Orange/yellow for enemy path

# Current hover position
var hover_grid_pos: Vector2i = Vector2i(-1, -1)

func _ready():
	# GridContainer will be set by MainController during initialization
	initialize_grid()

func initialize_with_container(container: Node2D):
	grid_container = container
	draw_grid()

func initialize_grid():
	# Initialize grid data array
	grid_data = []
	for y in range(GRID_HEIGHT):
		var row = []
		for x in range(GRID_WIDTH):
			row.append(false)  # false = empty, true = occupied
		grid_data.append(row)

func draw_grid():
	# Clear existing grid lines
	for line in grid_lines:
		if line:
			line.queue_free()
	grid_lines.clear()
	
	# Create grid lines
	# Vertical lines
	for x in range(GRID_WIDTH + 1):
		var line = Line2D.new()
		line.add_point(Vector2(x * GRID_SIZE, 0))
		line.add_point(Vector2(x * GRID_SIZE, GRID_HEIGHT * GRID_SIZE))
		line.default_color = GRID_COLOR
		line.width = 2
		line.z_index = 1  # Make sure lines are visible
		grid_container.add_child(line)
		grid_lines.append(line)
	
	# Horizontal lines
	for y in range(GRID_HEIGHT + 1):
		var line = Line2D.new()
		line.add_point(Vector2(0, y * GRID_SIZE))
		line.add_point(Vector2(GRID_WIDTH * GRID_SIZE, y * GRID_SIZE))
		line.default_color = GRID_COLOR
		line.width = 2
		line.z_index = 1  # Make sure lines are visible
		grid_container.add_child(line)
		grid_lines.append(line)

func set_path_positions(positions: Array[Vector2i]):
	path_grid_positions = positions
	draw_enemy_path()

func draw_enemy_path():
	# Clear existing path visuals
	for element in path_visual_elements:
		if element:
			element.queue_free()
	path_visual_elements.clear()
	
	# Create visual indicators for each path tile
	for grid_pos in path_grid_positions:
		var path_tile = ColorRect.new()
		path_tile.size = Vector2(GRID_SIZE, GRID_SIZE)
		path_tile.color = PATH_COLOR
		
		# Position the tile in world coordinates
		var world_pos = grid_to_world(grid_pos)
		path_tile.position = world_pos - Vector2(GRID_SIZE / 2.0, GRID_SIZE / 2.0)
		path_tile.z_index = 0  # Behind towers and other elements
		
		grid_container.add_child(path_tile)
		path_visual_elements.append(path_tile)

func handle_mouse_hover(global_pos: Vector2):
	var new_hover_pos = world_to_grid(global_pos)
	
	if new_hover_pos != hover_grid_pos:
		hover_grid_pos = new_hover_pos
		queue_redraw()

func world_to_grid(world_pos: Vector2) -> Vector2i:
	# Convert world position directly to grid coordinates
	var grid_x = int(floor(world_pos.x / GRID_SIZE))
	var grid_y = int(floor(world_pos.y / GRID_SIZE))
	return Vector2i(grid_x, grid_y)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	var world_x = grid_pos.x * GRID_SIZE + GRID_SIZE / 2.0
	var world_y = grid_pos.y * GRID_SIZE + GRID_SIZE / 2.0
	return Vector2(world_x, world_y)

func is_valid_grid_position(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < GRID_WIDTH and grid_pos.y >= 0 and grid_pos.y < GRID_HEIGHT

func is_grid_occupied(grid_pos: Vector2i) -> bool:
	if not is_valid_grid_position(grid_pos):
		return true
	return grid_data[grid_pos.y][grid_pos.x]

func set_grid_occupied(grid_pos: Vector2i, occupied: bool):
	if is_valid_grid_position(grid_pos):
		grid_data[grid_pos.y][grid_pos.x] = occupied

func is_on_enemy_path(grid_pos: Vector2i) -> bool:
	return grid_pos in path_grid_positions

func get_grid_container() -> Node2D:
	return grid_container

func _draw():
	# Draw hover highlight
	if is_valid_grid_position(hover_grid_pos) and not is_grid_occupied(hover_grid_pos) and not is_on_enemy_path(hover_grid_pos):
		var world_pos = grid_to_world(hover_grid_pos)
		var local_pos = world_pos - global_position
		
		var rect = Rect2(
			local_pos.x - GRID_SIZE / 2.0,
			local_pos.y - GRID_SIZE / 2.0,
			GRID_SIZE,
			GRID_SIZE
		)
		draw_rect(rect, HOVER_COLOR)
	elif is_valid_grid_position(hover_grid_pos) and is_on_enemy_path(hover_grid_pos):
		# Show red highlight for path positions to indicate they can't be used
		var world_pos = grid_to_world(hover_grid_pos)
		var local_pos = world_pos - global_position
		
		var rect = Rect2(
			local_pos.x - GRID_SIZE / 2.0,
			local_pos.y - GRID_SIZE / 2.0,
			GRID_SIZE,
			GRID_SIZE
		)
		draw_rect(rect, Color(0.8, 0.2, 0.2, 0.4))  # Red highlight for invalid positions 