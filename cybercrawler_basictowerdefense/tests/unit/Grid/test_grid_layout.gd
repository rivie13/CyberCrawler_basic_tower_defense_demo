extends GutTest

# Unit tests for GridLayout
# Tests path generation for different layout types

var grid_layout: GridLayout
var mock_grid_manager: MockGridManager

func before_each():
	mock_grid_manager = MockGridManager.new()
	add_child_autofree(mock_grid_manager)
	grid_layout = GridLayout.new(mock_grid_manager)
	add_child_autofree(grid_layout)

func test_initialization():
	# Test that GridLayout is properly initialized
	assert_not_null(grid_layout, "GridLayout should be created")
	assert_not_null(grid_layout.grid_manager, "Grid manager should be set")

func test_create_path_with_null_grid_manager():
	# Test error handling when grid_manager is null
	var null_layout = GridLayout.new(null)
	add_child_autofree(null_layout)
	
	var path = null_layout.create_path()
	assert_eq(path.size(), 0, "Should return empty path when grid_manager is null")

func test_create_straight_line_path():
	# Test straight line path creation
	var path = grid_layout.create_path(GridLayout.LayoutType.STRAIGHT_LINE)
	
	assert_not_null(path, "Path should not be null")
	assert_gt(path.size(), 0, "Path should have points")
	
	# Check that path goes from left to right
	var first_point = path[0]
	var last_point = path[path.size() - 1]
	assert_lt(first_point.x, last_point.x, "Path should go from left to right")
	
	# Check that all points have the same Y coordinate (straight line)
	var expected_y = first_point.y
	for point in path:
		assert_eq(point.y, expected_y, "All points should have same Y coordinate")

func test_get_straight_line_grid_positions():
	# Test straight line grid positions
	var grid_positions = grid_layout.get_path_grid_positions(GridLayout.LayoutType.STRAIGHT_LINE)
	
	assert_not_null(grid_positions, "Grid positions should not be null")
	assert_gt(grid_positions.size(), 0, "Should have grid positions")
	
	# Check that positions are within grid bounds
	for pos in grid_positions:
		assert_true(mock_grid_manager.is_valid_grid_position(pos), "All positions should be valid")
	
	# Check that positions form a horizontal line
	var expected_y = grid_positions[0].y
	for pos in grid_positions:
		assert_eq(pos.y, expected_y, "All positions should have same Y coordinate")

func test_create_l_shaped_path():
	# Test L-shaped path creation
	var path = grid_layout.create_path(GridLayout.LayoutType.L_SHAPED)
	
	assert_not_null(path, "Path should not be null")
	assert_gt(path.size(), 0, "Path should have points")
	
	# Check that path has both horizontal and vertical segments
	var has_horizontal = false
	var has_vertical = false
	var prev_point = path[0]
	
	for i in range(1, path.size()):
		var current_point = path[i]
		if abs(current_point.x - prev_point.x) > 0.1:  # Horizontal movement
			has_horizontal = true
		if abs(current_point.y - prev_point.y) > 0.1:  # Vertical movement
			has_vertical = true
		prev_point = current_point
	
	assert_true(has_horizontal, "L-shaped path should have horizontal segment")
	assert_true(has_vertical, "L-shaped path should have vertical segment")

func test_get_l_shaped_grid_positions():
	# Test L-shaped grid positions
	var grid_positions = grid_layout.get_path_grid_positions(GridLayout.LayoutType.L_SHAPED)
	
	assert_not_null(grid_positions, "Grid positions should not be null")
	assert_gt(grid_positions.size(), 0, "Should have grid positions")
	
	# Check that positions are within grid bounds
	for pos in grid_positions:
		assert_true(mock_grid_manager.is_valid_grid_position(pos), "All positions should be valid")

func test_create_s_curved_path():
	# Test S-curved path creation
	var path = grid_layout.create_path(GridLayout.LayoutType.S_CURVED)
	
	assert_not_null(path, "Path should not be null")
	assert_gt(path.size(), 0, "Path should have points")
	
	# Check that path goes from left to right
	var first_point = path[0]
	var last_point = path[path.size() - 1]
	assert_lt(first_point.x, last_point.x, "Path should go from left to right")
	
	# Check that Y coordinates vary (not a straight line)
	var y_values = []
	for point in path:
		y_values.append(point.y)
	
	var min_y = y_values.min()
	var max_y = y_values.max()
	assert_gt(max_y - min_y, 10.0, "S-curved path should have varying Y coordinates")

func test_get_s_curved_grid_positions():
	# Test S-curved grid positions
	var grid_positions = grid_layout.get_path_grid_positions(GridLayout.LayoutType.S_CURVED)
	
	assert_not_null(grid_positions, "Grid positions should not be null")
	assert_gt(grid_positions.size(), 0, "Should have grid positions")
	
	# Check that positions are within grid bounds
	for pos in grid_positions:
		assert_true(mock_grid_manager.is_valid_grid_position(pos), "All positions should be valid")

func test_create_zigzag_path():
	# Test zigzag path creation
	var path = grid_layout.create_path(GridLayout.LayoutType.ZIGZAG)
	
	assert_not_null(path, "Path should not be null")
	assert_gt(path.size(), 0, "Path should have points")
	
	# Check that path goes from left to right
	var first_point = path[0]
	var last_point = path[path.size() - 1]
	assert_lt(first_point.x, last_point.x, "Path should go from left to right")
	
	# Check that Y coordinates alternate (zigzag pattern)
	var y_values = []
	for point in path:
		y_values.append(point.y)
	
	var min_y = y_values.min()
	var max_y = y_values.max()
	assert_gt(max_y - min_y, 10.0, "Zigzag path should have varying Y coordinates")

func test_get_zigzag_grid_positions():
	# Test zigzag grid positions
	var grid_positions = grid_layout.get_path_grid_positions(GridLayout.LayoutType.ZIGZAG)
	
	assert_not_null(grid_positions, "Grid positions should not be null")
	assert_gt(grid_positions.size(), 0, "Should have grid positions")
	
	# Check that positions are within grid bounds
	for pos in grid_positions:
		assert_true(mock_grid_manager.is_valid_grid_position(pos), "All positions should be valid")

func test_default_layout_type():
	# Test that default layout type works
	var path = grid_layout.create_path()
	
	assert_not_null(path, "Default path should not be null")
	assert_gt(path.size(), 0, "Default path should have points")

func test_invalid_layout_type():
	# Test handling of invalid layout type
	var path = grid_layout.create_path(999)  # Invalid enum value
	
	assert_not_null(path, "Invalid layout should return default path")
	assert_gt(path.size(), 0, "Invalid layout should have points")

func test_path_consistency():
	# Test that create_path and get_path_grid_positions are consistent
	var world_path = grid_layout.create_path(GridLayout.LayoutType.STRAIGHT_LINE)
	var grid_path = grid_layout.get_path_grid_positions(GridLayout.LayoutType.STRAIGHT_LINE)
	
	assert_eq(world_path.size(), grid_path.size() + 2, "World path should have 2 extra points (start/end)")
	
	# Check that grid positions correspond to world positions
	for i in range(grid_path.size()):
		var grid_pos = grid_path[i]
		var world_pos = mock_grid_manager.grid_to_world(grid_pos)
		var expected_world_pos = world_path[i + 1]  # Skip first world point
		assert_eq(world_pos, expected_world_pos, "Grid and world positions should match")

func test_all_layout_types():
	# Test all layout types work
	var layout_types = [
		GridLayout.LayoutType.STRAIGHT_LINE,
		GridLayout.LayoutType.L_SHAPED,
		GridLayout.LayoutType.S_CURVED,
		GridLayout.LayoutType.ZIGZAG
	]
	
	for layout_type in layout_types:
		var path = grid_layout.create_path(layout_type)
		var grid_positions = grid_layout.get_path_grid_positions(layout_type)
		
		assert_not_null(path, "Path for layout type " + str(layout_type) + " should not be null")
		assert_gt(path.size(), 0, "Path for layout type " + str(layout_type) + " should have points")
		assert_not_null(grid_positions, "Grid positions for layout type " + str(layout_type) + " should not be null")
		assert_gt(grid_positions.size(), 0, "Grid positions for layout type " + str(layout_type) + " should have positions")

func test_grid_manager_dependency():
	# Test that GridLayout properly uses the grid manager
	var path = grid_layout.create_path(GridLayout.LayoutType.STRAIGHT_LINE)
	
	# Path should be created based on grid manager's grid size
	assert_gt(path.size(), 0, "Path should be created based on grid manager")
	
	# Check that path uses the grid manager's dimensions
	var grid_size = mock_grid_manager.get_grid_size()
	assert_gt(path.size(), grid_size.x, "Path should be longer than grid width")
	
	# Verify that the path uses the grid manager for coordinate conversion
	var grid_positions = grid_layout.get_path_grid_positions(GridLayout.LayoutType.STRAIGHT_LINE)
	assert_gt(grid_positions.size(), 0, "Grid positions should be generated")
	
	# Check that grid positions are within the grid manager's bounds
	for pos in grid_positions:
		assert_true(mock_grid_manager.is_valid_grid_position(pos), "All grid positions should be valid")

func test_path_validation():
	# Test that generated paths are valid
	var layout_types = [
		GridLayout.LayoutType.STRAIGHT_LINE,
		GridLayout.LayoutType.L_SHAPED,
		GridLayout.LayoutType.S_CURVED,
		GridLayout.LayoutType.ZIGZAG
	]
	
	for layout_type in layout_types:
		var path = grid_layout.create_path(layout_type)
		
		# Check that path has valid points
		for point in path:
			assert_not_null(point, "Path point should not be null")
			assert_true(point is Vector2, "Path point should be Vector2")
		
		# Check that path has reasonable length
		assert_gt(path.size(), 0, "Path should have at least one point")
		assert_lt(path.size(), 100, "Path should not be excessively long")

func test_grid_positions_validation():
	# Test that generated grid positions are valid
	var layout_types = [
		GridLayout.LayoutType.STRAIGHT_LINE,
		GridLayout.LayoutType.L_SHAPED,
		GridLayout.LayoutType.S_CURVED,
		GridLayout.LayoutType.ZIGZAG
	]
	
	for layout_type in layout_types:
		var grid_positions = grid_layout.get_path_grid_positions(layout_type)
		
		# Check that all positions are valid
		for pos in grid_positions:
			assert_not_null(pos, "Grid position should not be null")
			assert_true(pos is Vector2i, "Grid position should be Vector2i")
			assert_true(mock_grid_manager.is_valid_grid_position(pos), "Grid position should be valid")
		
		# Check that positions are unique
		var unique_positions = []
		for pos in grid_positions:
			if not pos in unique_positions:
				unique_positions.append(pos)
		assert_eq(unique_positions.size(), grid_positions.size(), "Grid positions should be unique") 
