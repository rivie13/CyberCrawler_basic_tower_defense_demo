extends GutTest

# Unit tests for GridLayout class
# These tests verify the grid layout functionality and path generation

var grid_layout: GridLayout
var mock_grid_manager: GridManager

func before_each():
	# Setup fresh GridLayout for each test
	mock_grid_manager = GridManager.new()
	grid_layout = GridLayout.new(mock_grid_manager)
	add_child_autofree(grid_layout)
	add_child_autofree(mock_grid_manager)

func test_initial_state():
	# Test that GridLayout starts with correct initial values
	assert_eq(grid_layout.grid_manager, mock_grid_manager, "Should have grid manager reference")

func test_create_path_without_grid_manager():
	# Test path creation when grid manager is null
	var null_layout = GridLayout.new(null)
	add_child_autofree(null_layout)
	
	var path = null_layout.create_path(GridLayout.LayoutType.STRAIGHT_LINE)
	assert_eq(path.size(), 0, "Should return empty path when grid manager is null")

func test_create_straight_line_path():
	# Test straight line path creation
	var path = grid_layout.create_straight_line_path()
	
	assert_gt(path.size(), 0, "Should create non-empty path")
	assert_eq(path[0].x, -32.0, "Should start at left edge")
	assert_eq(path[0].y, 352.0, "Should be at middle height")  # 10/2 * 64 + 32 = 352
	assert_eq(path[path.size() - 1].x, 992.0, "Should end at right edge")  # (15+1) * 64 + 32 = 992

func test_get_straight_line_grid_positions():
	# Test straight line grid positions
	var grid_positions = grid_layout.get_straight_line_grid_positions()
	
	assert_gt(grid_positions.size(), 0, "Should have grid positions")
	assert_eq(grid_positions[0], Vector2i(0, 5), "Should start at grid position (0, 5)")
	assert_eq(grid_positions[grid_positions.size() - 1], Vector2i(14, 5), "Should end at grid position (14, 5)")  # GRID_WIDTH = 15, so 0-14

func test_create_l_shaped_path():
	# Test L-shaped path creation
	var path = grid_layout.create_l_shaped_path()
	
	assert_gt(path.size(), 0, "Should create non-empty path")
	# L-shaped path should have more points than straight line
	assert_gt(path.size(), 22, "L-shaped path should have more points than straight line")

func test_get_l_shaped_grid_positions():
	# Test L-shaped grid positions
	var grid_positions = grid_layout.get_l_shaped_grid_positions()
	
	assert_gt(grid_positions.size(), 0, "Should have grid positions")
	# L-shaped should have more grid positions than straight line
	assert_gt(grid_positions.size(), 20, "L-shaped should have more grid positions than straight line")

func test_create_s_curved_path():
	# Test S-curved path creation
	var path = grid_layout.create_s_curved_path()
	
	assert_gt(path.size(), 0, "Should create non-empty path")
	assert_eq(path.size(), 21, "Should have 21 segments (0 to 20)")
	
	# S-curve should have varying Y positions
	var y_positions = []
	for point in path:
		y_positions.append(point.y)
	
	# Should have different Y positions (not all the same)
	var unique_y_count = 0
	for i in range(y_positions.size() - 1):
		if abs(y_positions[i] - y_positions[i + 1]) > 1.0:
			unique_y_count += 1
	
	assert_gt(unique_y_count, 0, "S-curve should have varying Y positions")

func test_get_s_curved_grid_positions():
	# Test S-curved grid positions
	var grid_positions = grid_layout.get_s_curved_grid_positions()
	
	assert_gt(grid_positions.size(), 0, "Should have grid positions")
	assert_eq(grid_positions.size(), 15, "Should have 15 grid positions (0 to 14)")  # GRID_WIDTH = 15
	
	# S-curve should have varying Y positions in grid coordinates
	var y_positions = []
	for pos in grid_positions:
		y_positions.append(pos.y)
	
	# Should have different Y positions (not all the same)
	var unique_y_count = 0
	for i in range(y_positions.size() - 1):
		if y_positions[i] != y_positions[i + 1]:
			unique_y_count += 1
	
	assert_gt(unique_y_count, 0, "S-curve should have varying Y grid positions")

func test_create_zigzag_path():
	# Test zigzag path creation
	var path = grid_layout.create_zigzag_path()
	
	assert_gt(path.size(), 0, "Should create non-empty path")
	# Zigzag should have more points than straight line due to transitions
	assert_gt(path.size(), 22, "Zigzag path should have more points than straight line")

func test_get_zigzag_grid_positions():
	# Test zigzag grid positions
	var grid_positions = grid_layout.get_zigzag_grid_positions()
	
	assert_gt(grid_positions.size(), 0, "Should have grid positions")
	# Zigzag should have more grid positions than straight line
	assert_gt(grid_positions.size(), 20, "Zigzag should have more grid positions than straight line")

func test_create_path_with_layout_types():
	# Test create_path with different layout types
	var straight_path = grid_layout.create_path(GridLayout.LayoutType.STRAIGHT_LINE)
	var l_shaped_path = grid_layout.create_path(GridLayout.LayoutType.L_SHAPED)
	var s_curved_path = grid_layout.create_path(GridLayout.LayoutType.S_CURVED)
	var zigzag_path = grid_layout.create_path(GridLayout.LayoutType.ZIGZAG)
	
	assert_gt(straight_path.size(), 0, "Straight line path should not be empty")
	assert_gt(l_shaped_path.size(), 0, "L-shaped path should not be empty")
	assert_gt(s_curved_path.size(), 0, "S-curved path should not be empty")
	assert_gt(zigzag_path.size(), 0, "Zigzag path should not be empty")
	
	# Different layouts should have different path lengths
	assert_ne(straight_path.size(), l_shaped_path.size(), "Different layouts should have different path lengths")

func test_get_path_grid_positions_with_layout_types():
	# Test get_path_grid_positions with different layout types
	var straight_positions = grid_layout.get_path_grid_positions(GridLayout.LayoutType.STRAIGHT_LINE)
	var l_shaped_positions = grid_layout.get_path_grid_positions(GridLayout.LayoutType.L_SHAPED)
	var s_curved_positions = grid_layout.get_path_grid_positions(GridLayout.LayoutType.S_CURVED)
	var zigzag_positions = grid_layout.get_path_grid_positions(GridLayout.LayoutType.ZIGZAG)
	
	assert_gt(straight_positions.size(), 0, "Straight line positions should not be empty")
	assert_gt(l_shaped_positions.size(), 0, "L-shaped positions should not be empty")
	assert_gt(s_curved_positions.size(), 0, "S-curved positions should not be empty")
	assert_gt(zigzag_positions.size(), 0, "Zigzag positions should not be empty")

func test_create_path_default_layout():
	# Test create_path with default layout (should be L-shaped)
	var default_path = grid_layout.create_path()
	var l_shaped_path = grid_layout.create_path(GridLayout.LayoutType.L_SHAPED)
	
	assert_eq(default_path.size(), l_shaped_path.size(), "Default layout should be L-shaped")

func test_get_path_grid_positions_default_layout():
	# Test get_path_grid_positions with default layout (should be L-shaped)
	var default_positions = grid_layout.get_path_grid_positions()
	var l_shaped_positions = grid_layout.get_path_grid_positions(GridLayout.LayoutType.L_SHAPED)
	
	assert_eq(default_positions.size(), l_shaped_positions.size(), "Default layout should be L-shaped")

func test_create_path_invalid_layout():
	# Test create_path with invalid layout type (should default to L-shaped)
	var invalid_path = grid_layout.create_path(999)  # Invalid enum value
	var l_shaped_path = grid_layout.create_path(GridLayout.LayoutType.L_SHAPED)
	
	assert_eq(invalid_path.size(), l_shaped_path.size(), "Invalid layout should default to L-shaped")

func test_get_path_grid_positions_invalid_layout():
	# Test get_path_grid_positions with invalid layout type (should default to L-shaped)
	var invalid_positions = grid_layout.get_path_grid_positions(999)  # Invalid enum value
	var l_shaped_positions = grid_layout.get_path_grid_positions(GridLayout.LayoutType.L_SHAPED)
	
	assert_eq(invalid_positions.size(), l_shaped_positions.size(), "Invalid layout should default to L-shaped")

func test_path_continuity():
	# Test that paths are continuous (no large gaps)
	var path = grid_layout.create_l_shaped_path()
	
	for i in range(path.size() - 1):
		var current = path[i]
		var next = path[i + 1]
		var distance = current.distance_to(next)
		
		# Points should be reasonably close together (within 2 grid cells)
		assert_lte(distance, 128.0, "Path points should be continuous")

func test_grid_positions_validity():
	# Test that grid positions are within valid grid bounds
	var grid_positions = grid_layout.get_l_shaped_grid_positions()
	
	for pos in grid_positions:
		assert_gte(pos.x, 0, "Grid X should be non-negative")
		assert_lt(pos.x, 20, "Grid X should be less than grid width")
		assert_gte(pos.y, 0, "Grid Y should be non-negative")
		assert_lt(pos.y, 10, "Grid Y should be less than grid height")

func test_path_world_positions():
	# Test that world positions are calculated correctly
	var path = grid_layout.create_straight_line_path()
	
	# Check that world positions are properly spaced
	for i in range(1, path.size()):
		var current = path[i]
		var previous = path[i - 1]
		var x_diff = current.x - previous.x
		
		# Should be spaced by grid size (64 pixels)
		assert_almost_eq(x_diff, 64.0, 1.0, "World positions should be spaced by grid size")

func test_layout_type_enum():
	# Test that layout type enum values are correct
	assert_eq(GridLayout.LayoutType.STRAIGHT_LINE, 0, "STRAIGHT_LINE should be 0")
	assert_eq(GridLayout.LayoutType.L_SHAPED, 1, "L_SHAPED should be 1")
	assert_eq(GridLayout.LayoutType.S_CURVED, 2, "S_CURVED should be 2")
	assert_eq(GridLayout.LayoutType.ZIGZAG, 3, "ZIGZAG should be 3")

func test_s_curve_mathematical_properties():
	# Test S-curve mathematical properties
	var path = grid_layout.create_s_curved_path()
	
	# S-curve should start and end at similar Y positions (smooth curve)
	var start_y = path[0].y
	var end_y = path[path.size() - 1].y
	var y_diff = abs(start_y - end_y)
	
	assert_lte(y_diff, 100.0, "S-curve should start and end at similar Y positions")

func test_zigzag_alternating_pattern():
	# Test zigzag alternating pattern
	var grid_positions = grid_layout.get_zigzag_grid_positions()
	
	# Check that Y positions alternate between high and low
	var y_positions = []
	for pos in grid_positions:
		y_positions.append(pos.y)
	
	# Should have both high and low Y positions
	var high_count = 0
	var low_count = 0
	for y in y_positions:
		if y < 5:  # Low position
			low_count += 1
		else:  # High position
			high_count += 1
	
	assert_gt(high_count, 0, "Zigzag should have high Y positions")
	assert_gt(low_count, 0, "Zigzag should have low Y positions")

# No mock classes needed - using real GridManager 