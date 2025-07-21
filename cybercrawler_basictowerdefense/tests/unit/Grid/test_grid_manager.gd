extends GutTest

# Comprehensive tests for GridManager
# Tests grid initialization, coordinate conversion, path management, A* pathfinding, and grid state

var grid_manager: GridManager
var mock_container: Node2D
var mock_game_manager: GameManager

func before_each():
	# Create fresh GridManager for each test
	grid_manager = GridManager.new()
	mock_container = Node2D.new()
	mock_game_manager = GameManager.new()
	
	# Add to scene for proper cleanup
	add_child_autofree(grid_manager)
	add_child_autofree(mock_container)
	add_child_autofree(mock_game_manager)

func test_grid_manager_initialization():
	# Test that GridManager initializes with correct constants and data structures
	
	# Verify constants
	assert_eq(GridManager.GRID_SIZE, 64, "Grid size should be 64 pixels")
	assert_eq(GridManager.GRID_WIDTH, 15, "Grid width should be 15 cells")
	assert_eq(GridManager.GRID_HEIGHT, 10, "Grid height should be 10 cells")
	
	# Verify grid data structures are initialized
	assert_not_null(grid_manager.grid_data, "Grid data should be initialized")
	assert_not_null(grid_manager.blocked_grid_data, "Blocked grid data should be initialized")
	assert_not_null(grid_manager.path_grid_positions, "Path grid positions should be initialized")
	assert_not_null(grid_manager.previous_path_grid_positions, "Previous path positions should be initialized")
	assert_not_null(grid_manager.path_visual_elements, "Path visual elements should be initialized")
	assert_not_null(grid_manager.grid_lines, "Grid lines should be initialized")

func test_grid_data_initialization():
	# Test that grid data arrays are properly sized and initialized
	
	# Verify grid dimensions
	assert_eq(grid_manager.grid_data.size(), GridManager.GRID_HEIGHT, "Grid data should have correct height")
	assert_eq(grid_manager.blocked_grid_data.size(), GridManager.GRID_HEIGHT, "Blocked grid data should have correct height")
	
	# Verify each row has correct width
	for y in range(GridManager.GRID_HEIGHT):
		assert_eq(grid_manager.grid_data[y].size(), GridManager.GRID_WIDTH, "Grid data row %d should have correct width" % y)
		assert_eq(grid_manager.blocked_grid_data[y].size(), GridManager.GRID_WIDTH, "Blocked grid data row %d should have correct width" % y)
		
		# Verify all cells start as unoccupied and unblocked
		for x in range(GridManager.GRID_WIDTH):
			assert_false(grid_manager.grid_data[y][x], "Grid cell (%d, %d) should start unoccupied" % [x, y])
			assert_false(grid_manager.blocked_grid_data[y][x], "Blocked grid cell (%d, %d) should start unblocked" % [x, y])

func test_coordinate_conversion_world_to_grid():
	# Test world to grid coordinate conversion
	
	# Test basic conversion
	var world_pos = Vector2(64, 64)  # Center of first grid cell
	var grid_pos = grid_manager.world_to_grid(world_pos)
	assert_eq(grid_pos, Vector2i(1, 1), "World position (64, 64) should convert to grid (1, 1)")
	
	# Test edge cases
	var edge_pos = Vector2(0, 0)
	var edge_grid = grid_manager.world_to_grid(edge_pos)
	assert_eq(edge_grid, Vector2i(0, 0), "World position (0, 0) should convert to grid (0, 0)")
	
	# Test fractional positions
	var fractional_pos = Vector2(32, 32)  # Halfway into first cell
	var fractional_grid = grid_manager.world_to_grid(fractional_pos)
	assert_eq(fractional_grid, Vector2i(0, 0), "Fractional world position should floor to correct grid")
	
	# Test negative positions
	var negative_pos = Vector2(-32, -32)
	var negative_grid = grid_manager.world_to_grid(negative_pos)
	assert_eq(negative_grid, Vector2i(-1, -1), "Negative world position should convert correctly")

func test_coordinate_conversion_grid_to_world():
	# Test grid to world coordinate conversion
	
	# Test basic conversion
	var grid_pos = Vector2i(1, 1)
	var world_pos = grid_manager.grid_to_world(grid_pos)
	var expected_pos = Vector2(64 + 32, 64 + 32)  # Center of grid cell (1,1)
	assert_eq(world_pos, expected_pos, "Grid position (1, 1) should convert to correct world position")
	
	# Test origin
	var origin_grid = Vector2i(0, 0)
	var origin_world = grid_manager.grid_to_world(origin_grid)
	var expected_origin = Vector2(32, 32)  # Center of grid cell (0,0)
	assert_eq(origin_world, expected_origin, "Grid origin should convert to correct world position")
	
	# Test edge of grid
	var edge_grid = Vector2i(14, 9)  # Last valid grid position
	var edge_world = grid_manager.grid_to_world(edge_grid)
	var expected_edge = Vector2(14 * 64 + 32, 9 * 64 + 32)
	assert_eq(edge_world, expected_edge, "Edge grid position should convert correctly")

func test_grid_position_validation():
	# Test grid position bounds checking
	
	# Test valid positions
	assert_true(grid_manager.is_valid_grid_position(Vector2i(0, 0)), "Origin should be valid")
	assert_true(grid_manager.is_valid_grid_position(Vector2i(7, 5)), "Middle position should be valid")
	assert_true(grid_manager.is_valid_grid_position(Vector2i(14, 9)), "Last valid position should be valid")
	
	# Test invalid positions
	assert_false(grid_manager.is_valid_grid_position(Vector2i(-1, 0)), "Negative X should be invalid")
	assert_false(grid_manager.is_valid_grid_position(Vector2i(0, -1)), "Negative Y should be invalid")
	assert_false(grid_manager.is_valid_grid_position(Vector2i(15, 0)), "X beyond width should be invalid")
	assert_false(grid_manager.is_valid_grid_position(Vector2i(0, 10)), "Y beyond height should be invalid")
	assert_false(grid_manager.is_valid_grid_position(Vector2i(15, 10)), "Both beyond bounds should be invalid")

func test_grid_occupation_management():
	# Test grid occupation state management
	
	var test_pos = Vector2i(5, 5)
	
	# Test initial state
	assert_false(grid_manager.is_grid_occupied(test_pos), "Grid should start unoccupied")
	
	# Test setting occupation
	grid_manager.set_grid_occupied(test_pos, true)
	assert_true(grid_manager.is_grid_occupied(test_pos), "Grid should be occupied after setting")
	
	# Test unsetting occupation
	grid_manager.set_grid_occupied(test_pos, false)
	assert_false(grid_manager.is_grid_occupied(test_pos), "Grid should be unoccupied after unsetting")
	
	# Test invalid position handling
	var invalid_pos = Vector2i(-1, -1)
	# Invalid positions should be considered occupied by default
	assert_true(grid_manager.is_grid_occupied(invalid_pos), "Invalid position should be considered occupied")
	# Setting invalid position should not change the state
	grid_manager.set_grid_occupied(invalid_pos, true)
	assert_true(grid_manager.is_grid_occupied(invalid_pos), "Invalid position should remain occupied after setting")

func test_grid_blocking_management():
	# Test grid blocking state management
	
	var test_pos = Vector2i(3, 3)
	
	# Test initial state
	assert_false(grid_manager.is_grid_blocked(test_pos), "Grid should start unblocked")
	
	# Test setting blocked state
	grid_manager.set_grid_blocked(test_pos, true)
	assert_true(grid_manager.is_grid_blocked(test_pos), "Grid should be blocked after setting")
	
	# Test unsetting blocked state
	grid_manager.set_grid_blocked(test_pos, false)
	assert_false(grid_manager.is_grid_blocked(test_pos), "Grid should be unblocked after unsetting")
	
	# Test invalid position handling
	var invalid_pos = Vector2i(-1, -1)
	assert_true(grid_manager.is_grid_blocked(invalid_pos), "Invalid position should be considered blocked")

func test_path_position_management():
	# Test enemy path position management
	
	var test_path: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 1), Vector2i(2, 2)]
	
	# Test setting path positions
	grid_manager.set_path_positions(test_path)
	assert_eq(grid_manager.path_grid_positions, test_path, "Path positions should be set correctly")
	
	# Test path detection
	assert_true(grid_manager.is_on_enemy_path(Vector2i(1, 1)), "Position on path should be detected")
	assert_false(grid_manager.is_on_enemy_path(Vector2i(5, 5)), "Position off path should not be detected")
	
	# Test path reroute detection
	var new_path: Array[Vector2i] = [Vector2i(0, 0), Vector2i(3, 3), Vector2i(4, 4)]
	grid_manager.set_path_positions(new_path)
	assert_true(grid_manager.reroute_occurred, "Reroute should be detected when path changes")

func test_path_solvability_ensurance():
	# Test path solvability checking and adjustment
	
	# Set up a simple path
	var simple_path: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
	grid_manager.set_path_positions(simple_path)
	
	# Test blocking a non-path position (should succeed)
	var result = grid_manager.ensure_path_solvability(Vector2i(1, 1), true)
	assert_true(result, "Blocking non-path position should maintain path solvability")
	
	# Test blocking a path position - the function should find an alternative path
	# The ensure_path_solvability function is designed to maintain path solvability
	var path_result = grid_manager.ensure_path_solvability(Vector2i(1, 0), true)
	# The function should return true because it finds an alternative path using A* pathfinding
	assert_true(path_result, "Blocking path position should succeed by finding alternative path")
	
	# Verify that the position remains blocked since the operation succeeded
	# The function should have found an alternative path while keeping the position blocked
	assert_true(grid_manager.is_grid_blocked(Vector2i(1, 0)), "Path position should remain blocked after successful solvability check")

func test_astar_pathfinding():
	# Test A* pathfinding algorithm
	
	# Set up a simple grid with some obstacles
	grid_manager.set_grid_blocked(Vector2i(1, 1), true)
	grid_manager.set_grid_blocked(Vector2i(2, 1), true)
	
	# Test simple path (should find direct path)
	var simple_path = grid_manager.find_path_astar(Vector2i(0, 0), Vector2i(3, 0))
	assert_gt(simple_path.size(), 0, "Simple path should be found")
	assert_eq(simple_path[0], Vector2i(0, 0), "Path should start at start position")
	assert_eq(simple_path[-1], Vector2i(3, 0), "Path should end at end position")
	
	# Test path around obstacles
	var obstacle_path = grid_manager.find_path_astar(Vector2i(0, 0), Vector2i(3, 2))
	assert_gt(obstacle_path.size(), 0, "Path around obstacles should be found")
	
	# Test invalid start/end positions
	var invalid_path = grid_manager.find_path_astar(Vector2i(-1, -1), Vector2i(3, 3))
	assert_eq(invalid_path.size(), 0, "Invalid start position should return empty path")
	
	var blocked_path = grid_manager.find_path_astar(Vector2i(1, 1), Vector2i(3, 3))
	assert_eq(blocked_path.size(), 0, "Blocked start position should return empty path")

func test_neighbor_generation():
	# Test neighbor position generation for pathfinding
	
	var center_pos = Vector2i(5, 5)
	var neighbors = grid_manager.get_neighbors(center_pos)
	
	# Should have 4 neighbors (up, down, left, right)
	assert_eq(neighbors.size(), 4, "Center position should have 4 neighbors")
	
	# Verify all neighbors are valid positions
	for neighbor in neighbors:
		assert_true(grid_manager.is_valid_grid_position(neighbor), "All neighbors should be valid positions")
	
	# Test edge position (should have fewer neighbors)
	var edge_pos = Vector2i(0, 0)
	var edge_neighbors = grid_manager.get_neighbors(edge_pos)
	assert_lt(edge_neighbors.size(), 4, "Edge position should have fewer than 4 neighbors")
	
	# Test corner position
	var corner_pos = Vector2i(14, 9)
	var corner_neighbors = grid_manager.get_neighbors(corner_pos)
	assert_lt(corner_neighbors.size(), 4, "Corner position should have fewer than 4 neighbors")

func test_grid_container_management():
	# Test grid container initialization and access
	
	# Test initial state
	assert_null(grid_manager.get_grid_container(), "Grid container should be null initially")
	
	# Test setting container
	grid_manager.initialize_with_container(mock_container, mock_game_manager)
	assert_eq(grid_manager.get_grid_container(), mock_container, "Grid container should be set correctly")
	assert_eq(grid_manager.game_manager, mock_game_manager, "Game manager should be set correctly")

func test_grid_size_access():
	# Test grid size getter
	
	var grid_size = grid_manager.get_grid_size()
	assert_eq(grid_size, Vector2i(GridManager.GRID_WIDTH, GridManager.GRID_HEIGHT), "Grid size should return correct dimensions")

func test_signal_emission():
	# Test grid blocked signal emission
	
	# Set up a path first so ensure_path_solvability doesn't fail
	var test_path: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
	grid_manager.set_path_positions(test_path)
	
	watch_signals(grid_manager)
	
	# Test signal emission when blocking grid
	grid_manager.set_grid_blocked(Vector2i(5, 5), true)
	assert_signal_emitted(grid_manager, "grid_blocked_changed")
	
	# Test signal parameters
	var signal_data = get_signal_parameters(grid_manager, "grid_blocked_changed", 0)
	assert_eq(signal_data[0], Vector2i(5, 5), "Signal should emit correct grid position")
	assert_true(signal_data[1], "Signal should emit correct blocked state")

func test_mouse_hover_handling():
	# Test mouse hover position tracking
	
	# Test initial hover state
	assert_eq(grid_manager.hover_grid_pos, Vector2i(-1, -1), "Initial hover position should be invalid")
	
	# Test hover position update
	var world_pos = Vector2(64, 64)  # Center of grid cell (1,1)
	grid_manager.handle_mouse_hover(world_pos)
	assert_eq(grid_manager.hover_grid_pos, Vector2i(1, 1), "Hover position should update correctly")
	
	# Test hover position change
	var new_world_pos = Vector2(128, 128)  # Center of grid cell (2,2)
	grid_manager.handle_mouse_hover(new_world_pos)
	assert_eq(grid_manager.hover_grid_pos, Vector2i(2, 2), "Hover position should change correctly")
	
	# Test same position (should not trigger update)
	grid_manager.handle_mouse_hover(new_world_pos)
	assert_eq(grid_manager.hover_grid_pos, Vector2i(2, 2), "Same position should not change hover")

func test_reroute_flag_management():
	# Test reroute flag reset functionality
	
	# Set initial path
	var initial_path: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 1)]
	grid_manager.set_path_positions(initial_path)
	
	# Set new path to trigger reroute
	var new_path: Array[Vector2i] = [Vector2i(0, 0), Vector2i(2, 2)]
	grid_manager.set_path_positions(new_path)
	
	# Verify reroute flag is set
	assert_true(grid_manager.reroute_occurred, "Reroute flag should be set when path changes")
	
	# Test flag reset
	grid_manager._reset_reroute_flag()
	assert_false(grid_manager.reroute_occurred, "Reroute flag should be reset")

func test_game_over_state_handling():
	# Test behavior when game is over
	
	# Set up game manager with game over state
	mock_game_manager.game_over = true
	grid_manager.game_manager = mock_game_manager
	
	# Test that operations are blocked when game is over
	var test_pos = Vector2i(5, 5)
	grid_manager.set_grid_occupied(test_pos, true)
	assert_false(grid_manager.is_grid_occupied(test_pos), "Grid operations should be blocked when game is over")
	
	grid_manager.set_grid_blocked(test_pos, true)
	assert_false(grid_manager.is_grid_blocked(test_pos), "Blocking operations should be blocked when game is over")

func test_path_visualization_cleanup():
	# Test path visualization element cleanup
	
	# Set up a path to create visual elements
	var test_path: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 1)]
	grid_manager.set_path_positions(test_path)
	
	# During testing, grid_container is null, so no visual elements are created
	# This is the expected behavior - visual elements are only created when grid_container is available
	assert_eq(grid_manager.path_visual_elements.size(), 0, "No visual elements should be created when grid_container is null")
	
	# Test cleanup by setting new path (should still work even without visual elements)
	var new_path: Array[Vector2i] = [Vector2i(2, 2), Vector2i(3, 3)]
	grid_manager.set_path_positions(new_path)
	
	# Verify path positions are updated correctly
	assert_eq(grid_manager.path_grid_positions, new_path, "Path positions should be updated correctly")

func test_grid_drawing_skip_conditions():
	# Test that grid drawing is skipped when container is not available
	
	# Test draw_grid with null container (should not crash)
	grid_manager.draw_grid()
	assert_true(true, "Draw grid should not crash with null container")
	
	# Test draw_enemy_path with null container (should not crash)
	grid_manager.draw_enemy_path()
	assert_true(true, "Draw enemy path should not crash with null container")

func test_complex_pathfinding_scenarios():
	# Test more complex pathfinding scenarios
	
	# Create a maze-like pattern
	grid_manager.set_grid_blocked(Vector2i(1, 0), true)
	grid_manager.set_grid_blocked(Vector2i(1, 1), true)
	grid_manager.set_grid_blocked(Vector2i(1, 2), true)
	grid_manager.set_grid_blocked(Vector2i(3, 1), true)
	grid_manager.set_grid_blocked(Vector2i(3, 2), true)
	grid_manager.set_grid_blocked(Vector2i(3, 3), true)
	
	# Test pathfinding through maze
	var maze_path = grid_manager.find_path_astar(Vector2i(0, 1), Vector2i(4, 1))
	assert_gt(maze_path.size(), 0, "Path through maze should be found")
	
	# Verify path doesn't go through blocked cells
	for pos in maze_path:
		assert_false(grid_manager.is_grid_blocked(pos), "Path should not go through blocked cells")

func test_edge_case_coordinate_conversions():
	# Test edge cases in coordinate conversions
	
	# Test very large world coordinates
	var large_world = Vector2(10000, 10000)
	var large_grid = grid_manager.world_to_grid(large_world)
	assert_gt(large_grid.x, 0, "Large world coordinates should convert to positive grid coordinates")
	assert_gt(large_grid.y, 0, "Large world coordinates should convert to positive grid coordinates")
	
	# Test very small world coordinates
	var small_world = Vector2(-10000, -10000)
	var small_grid = grid_manager.world_to_grid(small_world)
	assert_lt(small_grid.x, 0, "Small world coordinates should convert to negative grid coordinates")
	assert_lt(small_grid.y, 0, "Small world coordinates should convert to negative grid coordinates")
	
	# Test grid to world with edge grid positions
	var edge_grid_pos = Vector2i(14, 9)
	var edge_world_pos = grid_manager.grid_to_world(edge_grid_pos)
	assert_gt(edge_world_pos.x, 0, "Edge grid position should convert to positive world coordinates")
	assert_gt(edge_world_pos.y, 0, "Edge grid position should convert to positive world coordinates") 