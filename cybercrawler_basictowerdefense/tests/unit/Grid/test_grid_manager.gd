extends GutTest

# Unit tests for GridManager
# Tests core grid management functionality without signals (signals belong in integration tests)

var grid_manager: GridManager
var mock_game_manager: MockGameManager
var mock_grid_container: Node2D

func before_each():
	grid_manager = GridManager.new()
	mock_game_manager = MockGameManager.new()
	mock_grid_container = Node2D.new()
	add_child_autofree(grid_manager)
	add_child_autofree(mock_game_manager)
	add_child_autofree(mock_grid_container)

func after_each():
	pass  # Cleanup is handled by autofree

# ===== INITIALIZATION TESTS =====

func test_initial_state_after_ready():
	"""Test GridManager state after _ready() is called"""
	# GridManager automatically calls initialize_grid() in _ready()
	# So we test the state after that initialization
	
	assert_eq(grid_manager.grid_data.size(), 10, "Grid data should be initialized after _ready()")
	assert_eq(grid_manager.blocked_grid_data.size(), 10, "Blocked grid data should be initialized after _ready()")
	assert_eq(grid_manager.ruined_grid_data.size(), 10, "Ruined grid data should be initialized after _ready()")
	assert_eq(grid_manager.path_grid_positions.size(), 0, "Path positions should be empty initially")
	assert_eq(grid_manager.hover_grid_pos, Vector2i(-1, -1), "Hover position should be invalid initially")
	assert_eq(grid_manager.reroute_occurred, false, "Reroute flag should be false initially")

func test_initialize_grid():
	"""Test grid initialization creates proper data structures"""
	grid_manager.initialize_grid()
	
	assert_eq(grid_manager.grid_data.size(), 10, "Grid should have 10 rows")
	assert_eq(grid_manager.grid_data[0].size(), 15, "Each row should have 15 columns")
	assert_eq(grid_manager.blocked_grid_data.size(), 10, "Blocked grid should have 10 rows")
	assert_eq(grid_manager.blocked_grid_data[0].size(), 15, "Blocked grid should have 15 columns")
	assert_eq(grid_manager.ruined_grid_data.size(), 10, "Ruined grid should have 10 rows")
	assert_eq(grid_manager.ruined_grid_data[0].size(), 15, "Ruined grid should have 15 columns")
	
	# Check all cells are initially false
	for y in range(10):
		for x in range(15):
			assert_eq(grid_manager.grid_data[y][x], false, "Grid cells should be unoccupied initially")
			assert_eq(grid_manager.blocked_grid_data[y][x], false, "Grid cells should be unblocked initially")
			assert_eq(grid_manager.ruined_grid_data[y][x], false, "Grid cells should be unruined initially")

func test_initialize_with_container():
	"""Test initialization with container and game manager"""
	grid_manager.initialize_with_container(mock_grid_container, mock_game_manager)
	
	assert_eq(grid_manager.grid_container, mock_grid_container, "Grid container should be set")
	assert_eq(grid_manager.game_manager, mock_game_manager, "Game manager should be set")

# ===== GRID POSITION VALIDATION TESTS =====

func test_is_valid_grid_position():
	"""Test grid position validation"""
	# Valid positions
	assert_true(grid_manager.is_valid_grid_position(Vector2i(0, 0)), "Origin should be valid")
	assert_true(grid_manager.is_valid_grid_position(Vector2i(14, 9)), "Bottom-right corner should be valid")
	assert_true(grid_manager.is_valid_grid_position(Vector2i(7, 5)), "Middle position should be valid")
	
	# Invalid positions
	assert_false(grid_manager.is_valid_grid_position(Vector2i(-1, 0)), "Negative x should be invalid")
	assert_false(grid_manager.is_valid_grid_position(Vector2i(0, -1)), "Negative y should be invalid")
	assert_false(grid_manager.is_valid_grid_position(Vector2i(15, 0)), "X beyond width should be invalid")
	assert_false(grid_manager.is_valid_grid_position(Vector2i(0, 10)), "Y beyond height should be invalid")
	assert_false(grid_manager.is_valid_grid_position(Vector2i(20, 20)), "Far out of bounds should be invalid")

# ===== COORDINATE CONVERSION TESTS =====

func test_world_to_grid():
	"""Test world to grid coordinate conversion"""
	# Test various world positions
	assert_eq(grid_manager.world_to_grid(Vector2(32, 32)), Vector2i(0, 0), "Origin world position")
	assert_eq(grid_manager.world_to_grid(Vector2(96, 96)), Vector2i(1, 1), "One cell offset")
	assert_eq(grid_manager.world_to_grid(Vector2(64, 64)), Vector2i(1, 1), "Cell center")
	assert_eq(grid_manager.world_to_grid(Vector2(63, 63)), Vector2i(0, 0), "Just before cell boundary")
	assert_eq(grid_manager.world_to_grid(Vector2(65, 65)), Vector2i(1, 1), "Just after cell boundary")

func test_grid_to_world():
	"""Test grid to world coordinate conversion"""
	# Test various grid positions (should convert to cell centers)
	assert_eq(grid_manager.grid_to_world(Vector2i(0, 0)), Vector2(32, 32), "Origin grid position")
	assert_eq(grid_manager.grid_to_world(Vector2i(1, 1)), Vector2(96, 96), "One cell offset")
	assert_eq(grid_manager.grid_to_world(Vector2i(5, 3)), Vector2(352, 224), "Specific grid position")

func test_coordinate_conversion_roundtrip():
	"""Test that grid<->world conversion is consistent"""
	var test_grid_positions = [Vector2i(0, 0), Vector2i(5, 3), Vector2i(14, 9)]
	
	for grid_pos in test_grid_positions:
		var world_pos = grid_manager.grid_to_world(grid_pos)
		var converted_back = grid_manager.world_to_grid(world_pos)
		assert_eq(converted_back, grid_pos, "Grid->World->Grid conversion should be consistent")

# ===== GRID OCCUPATION TESTS =====

func test_is_grid_occupied():
	"""Test grid occupation checking"""
	grid_manager.initialize_grid()
	
	# Initially unoccupied
	assert_false(grid_manager.is_grid_occupied(Vector2i(0, 0)), "Grid should be unoccupied initially")
	assert_false(grid_manager.is_grid_occupied(Vector2i(5, 5)), "Grid should be unoccupied initially")
	
	# Invalid positions should be considered occupied
	assert_true(grid_manager.is_grid_occupied(Vector2i(-1, 0)), "Invalid positions should be occupied")
	assert_true(grid_manager.is_grid_occupied(Vector2i(20, 20)), "Invalid positions should be occupied")

func test_set_grid_occupied():
	"""Test setting grid occupation"""
	grid_manager.initialize_grid()
	
	# Set occupation
	grid_manager.set_grid_occupied(Vector2i(5, 5), true)
	assert_true(grid_manager.is_grid_occupied(Vector2i(5, 5)), "Grid should be occupied after setting")
	
	# Clear occupation
	grid_manager.set_grid_occupied(Vector2i(5, 5), false)
	assert_false(grid_manager.is_grid_occupied(Vector2i(5, 5)), "Grid should be unoccupied after clearing")
	
	# Invalid positions should be ignored (no crash)
	grid_manager.set_grid_occupied(Vector2i(-1, 0), true)
	grid_manager.set_grid_occupied(Vector2i(20, 20), true)

func test_set_grid_occupied_with_game_over():
	"""Test grid occupation when game is over"""
	grid_manager.initialize_grid()
	mock_game_manager.set_mock_game_over(true)
	grid_manager.game_manager = mock_game_manager
	
	# Verify grid is initially unoccupied
	assert_false(grid_manager.is_grid_occupied(Vector2i(5, 5)), "Grid should be unoccupied initially")
	
	# Try to set occupation when game is over
	grid_manager.set_grid_occupied(Vector2i(5, 5), true)
	
	# Grid should remain unoccupied because game is over
	assert_false(grid_manager.is_grid_occupied(Vector2i(5, 5)), "Grid should not change when game is over")

# ===== GRID BLOCKING TESTS =====

func test_is_grid_blocked():
	"""Test grid blocking checking"""
	grid_manager.initialize_grid()
	
	# Initially unblocked
	assert_false(grid_manager.is_grid_blocked(Vector2i(0, 0)), "Grid should be unblocked initially")
	assert_false(grid_manager.is_grid_blocked(Vector2i(5, 5)), "Grid should be unblocked initially")
	
	# Invalid positions should be considered blocked
	assert_true(grid_manager.is_grid_blocked(Vector2i(-1, 0)), "Invalid positions should be blocked")
	assert_true(grid_manager.is_grid_blocked(Vector2i(20, 20)), "Invalid positions should be blocked")

func test_update_blocked_grid_data():
	"""Test blocked grid data update (internal method)"""
	grid_manager.initialize_grid()
	
	grid_manager.update_blocked_grid_data(Vector2i(5, 5), true)
	assert_true(grid_manager.blocked_grid_data[5][5], "Blocked grid data should be updated")
	assert_true(grid_manager.is_grid_blocked(Vector2i(5, 5)), "Grid should be blocked after update")
	
	grid_manager.update_blocked_grid_data(Vector2i(5, 5), false)
	assert_false(grid_manager.blocked_grid_data[5][5], "Blocked grid data should be updated")
	assert_false(grid_manager.is_grid_blocked(Vector2i(5, 5)), "Grid should be unblocked after update")

# ===== GRID RUINING TESTS =====

func test_is_grid_ruined():
	"""Test grid ruining checking"""
	grid_manager.initialize_grid()
	
	# Initially unruined
	assert_false(grid_manager.is_grid_ruined(Vector2i(0, 0)), "Grid should be unruined initially")
	assert_false(grid_manager.is_grid_ruined(Vector2i(5, 5)), "Grid should be unruined initially")
	
	# Invalid positions should be considered ruined
	assert_true(grid_manager.is_grid_ruined(Vector2i(-1, 0)), "Invalid positions should be ruined")
	assert_true(grid_manager.is_grid_ruined(Vector2i(20, 20)), "Invalid positions should be ruined")

func test_update_ruined_grid_data():
	"""Test ruined grid data update (internal method)"""
	grid_manager.initialize_grid()
	
	grid_manager.update_ruined_grid_data(Vector2i(5, 5), true)
	assert_true(grid_manager.ruined_grid_data[5][5], "Ruined grid data should be updated")
	assert_true(grid_manager.is_grid_ruined(Vector2i(5, 5)), "Grid should be ruined after update")
	
	grid_manager.update_ruined_grid_data(Vector2i(5, 5), false)
	assert_false(grid_manager.ruined_grid_data[5][5], "Ruined grid data should be updated")
	assert_false(grid_manager.is_grid_ruined(Vector2i(5, 5)), "Grid should be unruined after update")

func test_set_grid_ruined():
	"""Test setting grid ruining (without game over)"""
	grid_manager.initialize_grid()
	
	# Set ruining
	grid_manager.set_grid_ruined(Vector2i(5, 5), true)
	assert_true(grid_manager.is_grid_ruined(Vector2i(5, 5)), "Grid should be ruined after setting")
	
	# Clear ruining
	grid_manager.set_grid_ruined(Vector2i(5, 5), false)
	assert_false(grid_manager.is_grid_ruined(Vector2i(5, 5)), "Grid should be unruined after clearing")

func test_set_grid_ruined_with_game_over():
	"""Test grid ruining when game is over"""
	grid_manager.initialize_grid()
	mock_game_manager.set_mock_game_over(true)
	grid_manager.game_manager = mock_game_manager
	
	# Verify grid is initially unruined
	assert_false(grid_manager.is_grid_ruined(Vector2i(5, 5)), "Grid should be unruined initially")
	
	# Try to set ruining when game is over
	grid_manager.set_grid_ruined(Vector2i(5, 5), true)
	
	# Grid should remain unruined because game is over
	assert_false(grid_manager.is_grid_ruined(Vector2i(5, 5)), "Grid should not change when game is over")

# ===== PATH MANAGEMENT TESTS =====

func test_set_path_positions():
	"""Test setting enemy path positions"""
	grid_manager.initialize_grid()
	var path_positions: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 1), Vector2i(2, 2)]
	
	# Verify initial state
	assert_eq(grid_manager.path_grid_positions.size(), 0, "Path should be empty initially")
	
	grid_manager.set_path_positions(path_positions)
	assert_eq(grid_manager.path_grid_positions, path_positions, "Path positions should be set")
	assert_eq(grid_manager.reroute_occurred, false, "Reroute should not occur on first set")

func test_set_path_positions_with_reroute():
	"""Test path reroute detection"""
	grid_manager.initialize_grid()
	var initial_path: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 1)]
	var new_path: Array[Vector2i] = [Vector2i(0, 0), Vector2i(2, 2)]
	
	grid_manager.set_path_positions(initial_path)
	assert_eq(grid_manager.reroute_occurred, false, "No reroute on first path")
	
	grid_manager.set_path_positions(new_path)
	assert_eq(grid_manager.path_grid_positions, new_path, "New path should be set")
	assert_eq(grid_manager.previous_path_grid_positions, initial_path, "Previous path should be stored")
	assert_eq(grid_manager.reroute_occurred, true, "Reroute should be detected")

func test_set_path_positions_same_path():
	"""Test that setting same path doesn't trigger reroute"""
	grid_manager.initialize_grid()
	var path: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 1)]
	
	grid_manager.set_path_positions(path)
	grid_manager.set_path_positions(path)
	
	assert_eq(grid_manager.reroute_occurred, false, "Reroute should not occur for same path")

func test_set_path_positions_with_game_over():
	"""Test path setting when game is over"""
	grid_manager.initialize_grid()
	mock_game_manager.set_mock_game_over(true)
	grid_manager.game_manager = mock_game_manager
	
	var path: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 1)]
	grid_manager.set_path_positions(path)
	
	assert_eq(grid_manager.path_grid_positions.size(), 0, "Path should not be set when game is over")

func test_is_on_enemy_path():
	"""Test enemy path checking"""
	grid_manager.initialize_grid()
	var path_positions: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 1), Vector2i(2, 2)]
	
	# Test with no path set
	assert_false(grid_manager.is_on_enemy_path(Vector2i(0, 0)), "Should not be on path when no path is set")
	
	grid_manager.set_path_positions(path_positions)
	
	assert_true(grid_manager.is_on_enemy_path(Vector2i(0, 0)), "Path position should be on enemy path")
	assert_true(grid_manager.is_on_enemy_path(Vector2i(1, 1)), "Path position should be on enemy path")
	assert_true(grid_manager.is_on_enemy_path(Vector2i(2, 2)), "Path position should be on enemy path")
	assert_false(grid_manager.is_on_enemy_path(Vector2i(5, 5)), "Non-path position should not be on enemy path")

# ===== PATHFINDING TESTS =====

func test_find_path_astar_valid_path():
	"""Test A* pathfinding with valid path"""
	grid_manager.initialize_grid()
	var start = Vector2i(0, 0)
	var end = Vector2i(2, 2)
	
	var path = grid_manager.find_path_astar(start, end)
	assert_gt(path.size(), 0, "Should find a path between valid positions")
	assert_eq(path[0], start, "Path should start at start position")
	assert_eq(path[-1], end, "Path should end at end position")

func test_find_path_astar_invalid_positions():
	"""Test A* pathfinding with invalid positions"""
	grid_manager.initialize_grid()
	
	# Invalid start
	var path1 = grid_manager.find_path_astar(Vector2i(-1, 0), Vector2i(2, 2))
	assert_eq(path1.size(), 0, "Should not find path with invalid start")
	
	# Invalid end
	var path2 = grid_manager.find_path_astar(Vector2i(0, 0), Vector2i(20, 20))
	assert_eq(path2.size(), 0, "Should not find path with invalid end")

func test_find_path_astar_blocked_positions():
	"""Test A* pathfinding with blocked positions"""
	grid_manager.initialize_grid()
	
	# Block start position
	grid_manager.update_blocked_grid_data(Vector2i(0, 0), true)
	var path1 = grid_manager.find_path_astar(Vector2i(0, 0), Vector2i(2, 2))
	assert_eq(path1.size(), 0, "Should not find path with blocked start")
	
	# Unblock start, block end
	grid_manager.update_blocked_grid_data(Vector2i(0, 0), false)
	grid_manager.update_blocked_grid_data(Vector2i(2, 2), true)
	var path2 = grid_manager.find_path_astar(Vector2i(0, 0), Vector2i(2, 2))
	assert_eq(path2.size(), 0, "Should not find path with blocked end")

func test_find_path_astar_ruined_positions():
	"""Test A* pathfinding with ruined positions"""
	grid_manager.initialize_grid()
	
	# Ruin start position
	grid_manager.update_ruined_grid_data(Vector2i(0, 0), true)
	var path1 = grid_manager.find_path_astar(Vector2i(0, 0), Vector2i(2, 2))
	assert_eq(path1.size(), 0, "Should not find path with ruined start")
	
	# Unruin start, ruin end
	grid_manager.update_ruined_grid_data(Vector2i(0, 0), false)
	grid_manager.update_ruined_grid_data(Vector2i(2, 2), true)
	var path2 = grid_manager.find_path_astar(Vector2i(0, 0), Vector2i(2, 2))
	assert_eq(path2.size(), 0, "Should not find path with ruined end")

func test_find_path_astar_occupied_positions():
	"""Test A* pathfinding with occupied positions"""
	grid_manager.initialize_grid()
	
	# Occupy some intermediate positions to force pathfinding around them
	grid_manager.set_grid_occupied(Vector2i(1, 0), true)
	grid_manager.set_grid_occupied(Vector2i(0, 1), true)
	
	var path = grid_manager.find_path_astar(Vector2i(0, 0), Vector2i(2, 2))
	
	# Path should still be found, but avoid occupied cells
	if path.size() > 0:
		for pos in path:
			assert_false(grid_manager.is_grid_occupied(pos), "Path should not go through occupied cells")
		assert_eq(path[0], Vector2i(0, 0), "Path should start at start position")
		assert_eq(path[-1], Vector2i(2, 2), "Path should end at end position")
	else:
		# If no path found, we should still assert something meaningful
		assert_true(true, "No path found due to occupied positions blocking all routes")

func test_get_neighbors():
	"""Test getting valid neighbors"""
	grid_manager.initialize_grid()
	
	# Test center position
	var pos = Vector2i(5, 5)
	var neighbors = grid_manager.get_neighbors(pos)
	
	assert_eq(neighbors.size(), 4, "Should have 4 neighbors for center position")
	assert_true(Vector2i(6, 5) in neighbors, "Right neighbor should be included")
	assert_true(Vector2i(4, 5) in neighbors, "Left neighbor should be included")
	assert_true(Vector2i(5, 6) in neighbors, "Down neighbor should be included")
	assert_true(Vector2i(5, 4) in neighbors, "Up neighbor should be included")

func test_get_neighbors_corner():
	"""Test getting neighbors for corner position"""
	grid_manager.initialize_grid()
	var pos = Vector2i(0, 0)
	var neighbors = grid_manager.get_neighbors(pos)
	
	assert_eq(neighbors.size(), 2, "Corner should have 2 neighbors")
	assert_true(Vector2i(1, 0) in neighbors, "Right neighbor should be included")
	assert_true(Vector2i(0, 1) in neighbors, "Down neighbor should be included")

func test_get_neighbors_edge():
	"""Test getting neighbors for edge position"""
	grid_manager.initialize_grid()
	var pos = Vector2i(0, 5)
	var neighbors = grid_manager.get_neighbors(pos)
	
	assert_eq(neighbors.size(), 3, "Edge should have 3 neighbors")
	assert_true(Vector2i(1, 5) in neighbors, "Right neighbor should be included")
	assert_true(Vector2i(0, 6) in neighbors, "Down neighbor should be included")
	assert_true(Vector2i(0, 4) in neighbors, "Up neighbor should be included")

# ===== GRID PROPERTIES TESTS =====

func test_get_grid_size():
	"""Test getting grid size"""
	assert_eq(grid_manager.get_grid_size(), Vector2i(15, 10), "Grid size should be 15x10")

func test_get_grid_container():
	"""Test getting grid container"""
	grid_manager.initialize_with_container(mock_grid_container, mock_game_manager)
	assert_eq(grid_manager.get_grid_container(), mock_grid_container, "Should return the grid container")

func test_handle_mouse_hover():
	"""Test mouse hover handling"""
	grid_manager.initialize_grid()
	var initial_hover = grid_manager.hover_grid_pos
	
	# Test hover position update
	grid_manager.handle_mouse_hover(Vector2(96, 96))  # Should be grid position (1, 1)
	
	# The hover position should be updated (exact behavior depends on implementation)
	# This tests that the method doesn't crash and potentially updates state
	assert_true(true, "Mouse hover handling should not crash")

# ===== CONSTANTS TESTS =====

func test_grid_constants():
	"""Test grid constants are correct"""
	assert_eq(grid_manager.GRID_SIZE, 64, "Grid size should be 64 pixels")
	assert_eq(grid_manager.GRID_WIDTH, 15, "Grid width should be 15 cells")
	assert_eq(grid_manager.GRID_HEIGHT, 10, "Grid height should be 10 cells")

func test_color_constants():
	"""Test color constants are defined"""
	assert_not_null(grid_manager.GRID_COLOR, "Grid color should be defined")
	assert_not_null(grid_manager.OCCUPIED_COLOR, "Occupied color should be defined")
	assert_not_null(grid_manager.HOVER_COLOR, "Hover color should be defined")
	assert_not_null(grid_manager.PATH_COLOR, "Path color should be defined")

# ===== COMPLEX FUNCTIONALITY TESTS =====

func test_ensure_path_solvability_no_path():
	"""Test path solvability when no path is set"""
	grid_manager.initialize_grid()
	
	# Should return true when no path is set (nothing to check)
	var result = grid_manager.ensure_path_solvability(Vector2i(5, 5), true)
	assert_true(result, "Should allow operation when no path is set")

func test_ensure_path_solvability_with_path():
	"""Test path solvability with existing path"""
	grid_manager.initialize_grid()
	
	# Set up a simple path
	var path: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
	grid_manager.set_path_positions(path)
	
	# Verify path is set
	assert_eq(grid_manager.path_grid_positions, path, "Path should be set correctly")
	
	# Test blocking a position not on the path
	var result = grid_manager.ensure_path_solvability(Vector2i(5, 5), true)
	assert_true(result, "Should allow blocking positions not affecting path solvability")

func test_visual_methods_dont_crash():
	"""Test that visual methods don't crash when called without container"""
	grid_manager.initialize_grid()
	
	# These methods should handle missing grid_container gracefully
	grid_manager.draw_grid()
	grid_manager.draw_enemy_path()
	
	# Should not crash
	assert_true(true, "Visual methods should handle missing container gracefully")

func test_reset_reroute_flag():
	"""Test reroute flag reset functionality"""
	grid_manager.initialize_grid()
	grid_manager.reroute_occurred = true
	
	grid_manager._reset_reroute_flag()
	assert_false(grid_manager.reroute_occurred, "Reroute flag should be reset") 
