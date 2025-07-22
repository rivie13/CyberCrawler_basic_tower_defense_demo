extends Node
class_name GridLayout

# Layout types for strategic path variety
enum LayoutType {
	STRAIGHT_LINE,
	L_SHAPED,
	S_CURVED,  # Smooth curved path for strategic positioning
	ZIGZAG     # Alternating path for tactical advantage
}

# Grid reference for calculations
var grid_manager: GridManagerInterface

func _init(grid_ref: GridManagerInterface):
	grid_manager = grid_ref

func create_path(layout_type: LayoutType = LayoutType.L_SHAPED) -> Array[Vector2]:
	"""Create a path based on the specified layout type"""
	if not grid_manager:
		push_error("GridLayout: grid_manager not set!")
		return []
	
	match layout_type:
		LayoutType.STRAIGHT_LINE:
			return create_straight_line_path()
		LayoutType.L_SHAPED:
			return create_l_shaped_path()
		LayoutType.S_CURVED:
			return create_s_curved_path()
		LayoutType.ZIGZAG:
			return create_zigzag_path()
		_:
			return create_l_shaped_path()  # Default to L-shaped

func get_path_grid_positions(layout_type: LayoutType = LayoutType.L_SHAPED) -> Array[Vector2i]:
	"""Get grid positions for the path based on layout type"""
	if not grid_manager:
		return []
	
	match layout_type:
		LayoutType.STRAIGHT_LINE:
			return get_straight_line_grid_positions()
		LayoutType.L_SHAPED:
			return get_l_shaped_grid_positions()
		LayoutType.S_CURVED:
			return get_s_curved_grid_positions()
		LayoutType.ZIGZAG:
			return get_zigzag_grid_positions()
		_:
			return get_l_shaped_grid_positions()  # Default to L-shaped

# STRAIGHT LINE PATH (Original implementation)
func create_straight_line_path() -> Array[Vector2]:
	var path: Array[Vector2] = []
	var grid_height = grid_manager.GRID_HEIGHT
	var grid_width = grid_manager.GRID_WIDTH
	var grid_size = grid_manager.GRID_SIZE
	var start_y = grid_height / 2.0
	
	# Path goes from left edge to right edge
	for x in range(grid_width + 2):
		var world_pos = Vector2((x - 1) * grid_size + grid_size / 2.0, start_y * grid_size + grid_size / 2.0)
		path.append(world_pos)
	
	return path

func get_straight_line_grid_positions() -> Array[Vector2i]:
	var path_positions: Array[Vector2i] = []
	var grid_height = grid_manager.GRID_HEIGHT
	var grid_width = grid_manager.GRID_WIDTH
	var start_y = grid_height / 2.0
	var path_grid_y = int(start_y)
	
	# Track grid positions that are part of the path (only those within the grid)
	for x in range(1, grid_width + 1):
		var grid_pos = Vector2i(x - 1, path_grid_y)
		path_positions.append(grid_pos)
	
	return path_positions

# L-SHAPED PATH (New strategic layout)
func create_l_shaped_path() -> Array[Vector2]:
	var path: Array[Vector2] = []
	var grid_height = grid_manager.GRID_HEIGHT
	var grid_width = grid_manager.GRID_WIDTH
	var grid_size = grid_manager.GRID_SIZE
	
	# L-shaped path: Start top, go right, then down, then right again
	var start_y = 2  # Start in upper part of grid
	var middle_x = grid_width / 2  # Turn point
	var end_y = grid_height - 2  # End in lower part of grid
	
	# Part 1: From left edge to middle (horizontal)
	for x in range(-1, middle_x + 1):
		var world_pos = Vector2(x * grid_size + grid_size / 2.0, start_y * grid_size + grid_size / 2.0)
		path.append(world_pos)
	
	# Part 2: Turn down (vertical)
	for y in range(start_y + 1, end_y + 1):
		var world_pos = Vector2(middle_x * grid_size + grid_size / 2.0, y * grid_size + grid_size / 2.0)
		path.append(world_pos)
	
	# Part 3: Go to right edge (horizontal)
	for x in range(middle_x + 1, grid_width + 2):
		var world_pos = Vector2(x * grid_size + grid_size / 2.0, end_y * grid_size + grid_size / 2.0)
		path.append(world_pos)
	
	return path

func get_l_shaped_grid_positions() -> Array[Vector2i]:
	var path_positions: Array[Vector2i] = []
	var grid_height = grid_manager.GRID_HEIGHT
	var grid_width = grid_manager.GRID_WIDTH
	
	var start_y = 2
	var middle_x = grid_width / 2
	var end_y = grid_height - 2
	
	# Part 1: Horizontal line (top)
	for x in range(0, middle_x + 1):
		if x >= 0 and x < grid_width:
			path_positions.append(Vector2i(x, start_y))
	
	# Part 2: Vertical line (down)
	for y in range(start_y + 1, end_y + 1):
		if y >= 0 and y < grid_height:
			path_positions.append(Vector2i(middle_x, y))
	
	# Part 3: Horizontal line (bottom)
	for x in range(middle_x + 1, grid_width):
		if x >= 0 and x < grid_width:
			path_positions.append(Vector2i(x, end_y))
	
	return path_positions

# S-CURVED PATH (Strategic curved layout)
func create_s_curved_path() -> Array[Vector2]:
	var path: Array[Vector2] = []
	var grid_height = grid_manager.GRID_HEIGHT
	var grid_width = grid_manager.GRID_WIDTH
	var grid_size = grid_manager.GRID_SIZE
	
	# S-curved path: Creates a smooth S-shape across the grid
	var segments = 20  # Number of segments for smooth curve
	
	for i in range(segments + 1):
		var t = float(i) / float(segments)  # 0.0 to 1.0
		
		# X position progresses linearly from left to right
		var x = (t * (grid_width + 1) - 0.5) * grid_size + grid_size / 2.0
		
		# Y position follows an S-curve using sine wave
		var y_normalized = 0.5 + 0.3 * sin(t * PI * 2)  # Creates S-shape
		var y = y_normalized * grid_height * grid_size + grid_size / 2.0
		
		path.append(Vector2(x, y))
	
	return path

func get_s_curved_grid_positions() -> Array[Vector2i]:
	var path_positions: Array[Vector2i] = []
	var grid_height = grid_manager.GRID_HEIGHT
	var grid_width = grid_manager.GRID_WIDTH
	
	# Approximate the S-curve with grid positions
	for x in range(0, grid_width):
		var t = float(x) / float(grid_width)
		var y_normalized = 0.5 + 0.3 * sin(t * PI * 2)
		var y = int(y_normalized * grid_height)
		
		# Clamp y to valid grid range
		y = max(0, min(y, grid_height - 1))
		path_positions.append(Vector2i(x, y))
	
	return path_positions

# ZIGZAG PATH (Tactical zigzag layout)
func create_zigzag_path() -> Array[Vector2]:
	var path: Array[Vector2] = []
	var grid_height = grid_manager.GRID_HEIGHT
	var grid_width = grid_manager.GRID_WIDTH
	var grid_size = grid_manager.GRID_SIZE
	
	# Zigzag path: Alternates between top and bottom positions
	var segments_per_zag = 3  # How many x positions per zig/zag
	var top_y = grid_height / 4
	var bottom_y = 3 * grid_height / 4
	
	for x in range(-1, grid_width + 2):
		var segment = int(x / segments_per_zag)
		var is_top = (segment % 2 == 0)
		
		var target_y = top_y if is_top else bottom_y
		var world_pos = Vector2(x * grid_size + grid_size / 2.0, target_y * grid_size + grid_size / 2.0)
		path.append(world_pos)
		
		# Add transition points at the zigzag turns
		if x % segments_per_zag == segments_per_zag - 1 and x < grid_width:
			var next_segment = segment + 1
			var next_is_top = (next_segment % 2 == 0)
			var next_y = top_y if next_is_top else bottom_y
			
			# Add intermediate points for smooth transition
			var transition_x = (x + 1) * grid_size + grid_size / 2.0
			var transition_pos = Vector2(transition_x, next_y * grid_size + grid_size / 2.0)
			path.append(transition_pos)
	
	return path

func get_zigzag_grid_positions() -> Array[Vector2i]:
	var path_positions: Array[Vector2i] = []
	var grid_height = grid_manager.GRID_HEIGHT
	var grid_width = grid_manager.GRID_WIDTH

	var segments_per_zag = 3
	var top_y = int(grid_height / 4)
	var bottom_y = int(3 * grid_height / 4)

	var prev_y = top_y
	for x in range(0, grid_width):
		var segment = int(x / segments_per_zag)
		var is_top = (segment % 2 == 0)
		var y = top_y if is_top else bottom_y

		# If the previous y is different, fill in the vertical step(s) to connect FIRST
		if x > 0 and prev_y != y:
			var step = 1 if y > prev_y else -1
			for fill_y in range(prev_y + step, y, step):
				# Fill in intermediate cells for a staircase effect
				path_positions.append(Vector2i(x, fill_y))

		# Then add the current position (target)
		path_positions.append(Vector2i(x, y))

		prev_y = y

	return path_positions 