extends GridManagerInterface
class_name GridManager
# Implements GridManagerInterface contract

# Grid constants
const GRID_SIZE = 64  # Size of each grid cell in pixels
const GRID_WIDTH = 15  # Number of grid cells horizontally
const GRID_HEIGHT = 10  # Number of grid cells vertically

# Grid data - true means occupied, false means empty
var grid_data: Array = []
# NEW: Blocked grid data - true means blocked, false means available
var blocked_grid_data: Array = []
# NEW: Ruined grid data - true means ruined, false means available
var ruined_grid_data: Array = []
var path_grid_positions: Array[Vector2i] = []  # Track which grid positions are on enemy path
# NEW: Track previous path positions for visualization
var previous_path_grid_positions: Array[Vector2i] = []
var path_visual_elements: Array = []  # Visual indicators for the path
var grid_lines: Array = []

# Colors for visualization
const GRID_COLOR = Color(0.8, 0.8, 0.8, 1.0)
const OCCUPIED_COLOR = Color(0.8, 0.2, 0.2, 0.6)
const HOVER_COLOR = Color(0.2, 0.8, 0.2, 0.6)
const PATH_COLOR = Color(0.9, 0.7, 0.3, 0.8)  # Orange/yellow for enemy path

# Current hover position
var hover_grid_pos: Vector2i = Vector2i(-1, -1)

# NEW: Track if a reroute has occurred
var reroute_occurred: bool = false

# NEW: Signal for when a grid cell is blocked/unblocked
signal grid_blocked_changed(grid_pos: Vector2i, blocked: bool)

var game_manager: GameManagerInterface = null

func _ready():
	# GridContainer will be set by MainController during initialization
	initialize_grid()

func initialize_with_container(container: Node2D, gm: GameManagerInterface = null):
	grid_container = container
	if gm != null:
		game_manager = gm
	draw_grid()

func initialize_grid():
	# Initialize grid data array
	grid_data = []
	blocked_grid_data = [] # NEW: initialize blocked grid
	ruined_grid_data = [] # NEW: initialize ruined grid
	for y in range(GRID_HEIGHT):
		var row = []
		var blocked_row = [] # NEW: row for blocked cells
		var ruined_row = [] # NEW: row for ruined cells
		for x in range(GRID_WIDTH):
			row.append(false)  # false = empty, true = occupied
			blocked_row.append(false) # false = available, true = blocked
			ruined_row.append(false) # false = available, true = ruined
		grid_data.append(row)
		blocked_grid_data.append(blocked_row) # NEW: add blocked row
		ruined_grid_data.append(ruined_row) # NEW: add ruined row

func draw_grid():
	# Skip grid drawing if grid_container is not available (e.g., during unit testing)
	if not grid_container:
		return
		
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
	if game_manager and game_manager.is_game_over():
		return
	# Check if current path is different from new path
	if path_grid_positions.size() > 0 and path_grid_positions != positions:
		reroute_occurred = true
		# Store the current path as the previous path to be visualized
		previous_path_grid_positions = path_grid_positions.duplicate()
	path_grid_positions = positions
	draw_enemy_path()

func draw_enemy_path():
	# Clear existing path visuals
	for element in path_visual_elements:
		if element:
			element.queue_free()
	path_visual_elements.clear()

	# Skip visual drawing if grid_container is not available (e.g., during unit testing)
	if not grid_container:
		return

	# Only draw previous path if reroute_occurred
	if reroute_occurred:
		for grid_pos in previous_path_grid_positions:
			var prev_tile = ColorRect.new()
			prev_tile.size = Vector2(GRID_SIZE, GRID_SIZE)
			prev_tile.color = Color(0.5, 0.8, 1.0, 0.5)  # Light blue, semi-transparent
			var world_pos = grid_to_world(grid_pos)
			prev_tile.position = world_pos - Vector2(GRID_SIZE / 2.0, GRID_SIZE / 2.0)
			prev_tile.z_index = -1
			grid_container.add_child(prev_tile)
			path_visual_elements.append(prev_tile)

			# Overlay a faded symbol (e.g., 'O') to indicate old path
			var symbol_label = Label.new()
			symbol_label.text = "O"
			symbol_label.modulate = Color(0.2, 0.4, 0.8, 0.6)  # Faded blue
			symbol_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			symbol_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			symbol_label.size = Vector2(GRID_SIZE, GRID_SIZE)
			symbol_label.position = prev_tile.position
			symbol_label.z_index = 0
			grid_container.add_child(symbol_label)
			path_visual_elements.append(symbol_label)

	# Draw current path in yellow/orange
	for grid_pos in path_grid_positions:
		var path_tile = ColorRect.new()
		path_tile.size = Vector2(GRID_SIZE, GRID_SIZE)
		path_tile.color = PATH_COLOR
		var world_pos = grid_to_world(grid_pos)
		path_tile.position = world_pos - Vector2(GRID_SIZE / 2.0, GRID_SIZE / 2.0)
		path_tile.z_index = -1
		grid_container.add_child(path_tile)
		path_visual_elements.append(path_tile)

	# Schedule a reset of the reroute flag after the visualization has been drawn
	if reroute_occurred:
		call_deferred("_reset_reroute_flag")

func _reset_reroute_flag():
	"""Reset the reroute flag after the visualization has been drawn"""
	reroute_occurred = false

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
	if game_manager and game_manager.is_game_over():
		return
	if is_valid_grid_position(grid_pos):
		grid_data[grid_pos.y][grid_pos.x] = occupied

func is_on_enemy_path(grid_pos: Vector2i) -> bool:
	return grid_pos in path_grid_positions

func get_grid_container() -> Node2D:
	return grid_container

func get_grid_size() -> Vector2i:
	return Vector2i(GRID_WIDTH, GRID_HEIGHT)

func is_grid_blocked(grid_pos: Vector2i) -> bool:
	if not is_valid_grid_position(grid_pos):
		return true
	return blocked_grid_data[grid_pos.y][grid_pos.x]

func set_grid_blocked(grid_pos: Vector2i, blocked: bool):
	if game_manager and game_manager.is_game_over():
		return
	if is_valid_grid_position(grid_pos):
		# print("[DEBUG][set_grid_blocked] Blocking cell at %s: %s" % [str(grid_pos), str(blocked)])
		update_blocked_grid_data(grid_pos, blocked)
		if not ensure_path_solvability(grid_pos, blocked):
			return
		emit_grid_blocked_signal(grid_pos, blocked)
		queue_redraw() # Ensure redraw after blocking

func update_blocked_grid_data(grid_pos: Vector2i, blocked: bool):
	blocked_grid_data[grid_pos.y][grid_pos.x] = blocked
	# print("[DEBUG][update_blocked_grid_data] blocked_grid_data[%d][%d] = %s" % [grid_pos.y, grid_pos.x, str(blocked)])

# NEW: Ruined grid methods
func is_grid_ruined(grid_pos: Vector2i) -> bool:
	if not is_valid_grid_position(grid_pos):
		return true
	return ruined_grid_data[grid_pos.y][grid_pos.x]

func set_grid_ruined(grid_pos: Vector2i, ruined: bool):
	if game_manager and game_manager.is_game_over():
		return
	if is_valid_grid_position(grid_pos):
		# print("[DEBUG][set_grid_ruined] Ruining cell at %s: %s" % [str(grid_pos), str(ruined)])
		update_ruined_grid_data(grid_pos, ruined)
		queue_redraw() # Ensure redraw after ruining

func update_ruined_grid_data(grid_pos: Vector2i, ruined: bool):
	ruined_grid_data[grid_pos.y][grid_pos.x] = ruined
	# print("[DEBUG][update_ruined_grid_data] ruined_grid_data[%d][%d] = %s" % [grid_pos.y, grid_pos.x, str(ruined)])

func ensure_path_solvability(grid_pos: Vector2i, blocked: bool) -> bool:
	# If no path is set up, allow the operation (no path to check)
	if path_grid_positions.size() == 0:
		return true
	
	var path_blocked = false
	var candidates = []
	var to_block = null
	for pos in path_grid_positions:
		if blocked_grid_data[pos.y][pos.x]:
			path_blocked = true
			break

	if blocked and not path_blocked:
		for pos in path_grid_positions:
			if not blocked_grid_data[pos.y][pos.x] and pos != path_grid_positions[0] and pos != path_grid_positions[-1]:
				candidates.append(pos)
		if candidates.size() > 0:
			to_block = candidates[randi() % candidates.size()]
			blocked_grid_data[to_block.y][to_block.x] = true

	var start = path_grid_positions[0]
	var end = path_grid_positions[-1]
	var new_path = find_path_astar(start, end)
	if new_path.size() == 0:
		blocked_grid_data[grid_pos.y][grid_pos.x] = false
		if blocked and not path_blocked and candidates.size() > 0 and to_block != null:
			blocked_grid_data[to_block.y][to_block.x] = false
		return false
	return true

func emit_grid_blocked_signal(grid_pos: Vector2i, blocked: bool):
	grid_blocked_changed.emit(grid_pos, blocked)

func _draw():
	# Draw hover highlight
	if is_valid_grid_position(hover_grid_pos) and not is_grid_occupied(hover_grid_pos) and not is_on_enemy_path(hover_grid_pos) and not is_grid_ruined(hover_grid_pos):
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

	# NEW: Draw blocked cell overlays (solid red + bold X, always on top of grid but below entities)
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var grid_pos = Vector2i(x, y)
			if is_grid_blocked(grid_pos):
				var world_pos = grid_to_world(grid_pos)
				var local_pos = world_pos - global_position
				var rect = Rect2(
					local_pos.x - GRID_SIZE / 2.0,
					local_pos.y - GRID_SIZE / 2.0,
					GRID_SIZE,
					GRID_SIZE
				)
				draw_rect(rect, Color(1, 0, 0, 0.85))  # Solid, mostly opaque red
				# Draw a bold X
				var margin = GRID_SIZE * 0.2
				var x1 = local_pos.x - GRID_SIZE / 2.0 + margin
				var y1 = local_pos.y - GRID_SIZE / 2.0 + margin
				var x2 = local_pos.x + GRID_SIZE / 2.0 - margin
				var y2 = local_pos.y + GRID_SIZE / 2.0 - margin
				draw_line(Vector2(x1, y1), Vector2(x2, y2), Color(1, 1, 1, 0.95), 4.0)
				draw_line(Vector2(x1, y2), Vector2(x2, y1), Color(1, 1, 1, 0.95), 4.0)

	# NEW: Draw ruined cell overlays (solid dark gray + skull symbol, always on top of grid but below entities)
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var grid_pos = Vector2i(x, y)
			if is_grid_ruined(grid_pos):
				var world_pos = grid_to_world(grid_pos)
				var local_pos = world_pos - global_position
				var rect = Rect2(
					local_pos.x - GRID_SIZE / 2.0,
					local_pos.y - GRID_SIZE / 2.0,
					GRID_SIZE,
					GRID_SIZE
				)
				draw_rect(rect, Color(0.3, 0.3, 0.3, 0.9))  # Solid, mostly opaque dark gray
				# Draw a skull-like symbol (simplified)
				var margin = GRID_SIZE * 0.25
				var center_x = local_pos.x
				var center_y = local_pos.y
				# Draw eyes
				draw_circle(Vector2(center_x - margin, center_y - margin), 3, Color(1, 1, 1, 0.95))
				draw_circle(Vector2(center_x + margin, center_y - margin), 3, Color(1, 1, 1, 0.95))
				# Draw mouth (simple line)
				draw_line(Vector2(center_x - margin, center_y + margin), Vector2(center_x + margin, center_y + margin), Color(1, 1, 1, 0.95), 3.0)

# NEW: A* pathfinding for dynamic rerouting
func find_path_astar(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	# Returns a list of grid positions from start to end, or [] if no path
	if not is_valid_grid_position(start) or not is_valid_grid_position(end):
		return [] as Array[Vector2i]
	if is_grid_blocked(start) or is_grid_blocked(end) or is_grid_ruined(start) or is_grid_ruined(end):
		return [] as Array[Vector2i]

	var open_set = [start]
	var came_from = {}
	var g_score = {}
	var f_score = {}
	g_score[start] = 0
	f_score[start] = start.distance_to(end)

	while open_set.size() > 0:
		# Find node in open_set with lowest f_score
		open_set.sort_custom(func(a, b): return f_score.get(a, INF) < f_score.get(b, INF))
		var current = open_set[0]
		if current == end:
			# Reconstruct path
			var path: Array[Vector2i] = [current]
			while current in came_from:
				current = came_from[current]
				path.insert(0, current)
			return path

		open_set.remove_at(0)
		for neighbor in get_neighbors(current):
			if is_grid_blocked(neighbor) or is_grid_occupied(neighbor) or is_grid_ruined(neighbor):
				continue
			var tentative_g = g_score.get(current, INF) + 1
			if tentative_g < g_score.get(neighbor, INF):
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + neighbor.distance_to(end)
				if neighbor not in open_set:
					open_set.append(neighbor)
	return [] as Array[Vector2i]

# Helper: Get valid 4-way neighbors
func get_neighbors(pos: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	for offset in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
		var n = pos + offset
		if is_valid_grid_position(n):
			neighbors.append(n)
	return neighbors 
