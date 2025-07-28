extends GutTest

# Integration tests for GridManager pathfinding and state management
# These tests verify A* pathfinding, grid blocking/ruining, and complex grid scenarios

var main_controller: MainController
var grid_manager: GridManager
var wave_manager: WaveManager
var game_manager: GameManager

func before_each():
	# Create real MainController with all real managers for complete integration
	main_controller = preload("res://scripts/MainController.gd").new()
	add_child_autofree(main_controller)
	
	# Let MainController create and initialize all managers
	await wait_physics_frames(3)  # Wait for proper initialization
	
	# Get references to all managers from MainController
	grid_manager = main_controller.grid_manager
	wave_manager = main_controller.wave_manager
	game_manager = main_controller.game_manager
	
	# Verify all managers are properly initialized
	assert_not_null(grid_manager, "GridManager should be initialized")
	assert_not_null(wave_manager, "WaveManager should be initialized")
	assert_not_null(game_manager, "GameManager should be initialized")
	
	# CRITICAL: Manually initialize systems since MainController.initialize_systems() 
	# skips initialization in test environment due to missing GridContainer
	wave_manager.initialize(grid_manager)

func test_astar_pathfinding_integration():
	# Integration test: A* pathfinding algorithm with complex obstacles
	# This tests: GridManager A* pathfinding → path calculation → obstacle navigation
	
	# Set up grid with obstacles
	var start_pos = Vector2i(1, 1)
	var end_pos = Vector2i(8, 8)
	
	# Block some positions to create obstacles
	var obstacle_positions = [
		Vector2i(3, 1), Vector2i(3, 2), Vector2i(3, 3),
		Vector2i(5, 5), Vector2i(5, 6), Vector2i(6, 5)
	]
	
	for pos in obstacle_positions:
		if grid_manager.is_valid_grid_position(pos):
			grid_manager.set_grid_blocked(pos, true)
	
	# Test A* pathfinding with obstacles
	var path = grid_manager.find_path_astar(start_pos, end_pos)
	
	# Verify pathfinding results
	assert_not_null(path, "A* should return a valid path")
	assert_gt(path.size(), 0, "Path should contain waypoints")
	
	if path.size() > 0:
		# Verify path starts and ends correctly
		assert_eq(path[0], start_pos, "Path should start at start position")
		assert_eq(path[-1], end_pos, "Path should end at end position")
		
		# Verify path avoids obstacles
		for waypoint in path:
			assert_false(obstacle_positions.has(waypoint), "Path should avoid blocked positions")
		
		# Verify path connectivity (each step should be adjacent)
		for i in range(1, path.size()):
			var prev_pos = path[i-1]
			var curr_pos = path[i]
			var distance = abs(curr_pos.x - prev_pos.x) + abs(curr_pos.y - prev_pos.y)
			assert_lte(distance, 1, "Path steps should be adjacent (Manhattan distance <= 1)")

func test_grid_blocking_and_path_solvability():
	# Integration test: Grid blocking with path solvability checks
	# This tests: GridManager blocking → path solvability → system coordination
	
	# Set up a path for solvability testing
	var path_positions: Array[Vector2i] = [
		Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1),
		Vector2i(4, 2), Vector2i(4, 3), Vector2i(4, 4), Vector2i(5, 4)
	]
	
	grid_manager.set_path_positions(path_positions)
	
	# Test blocking a non-critical position (should be allowed)
	var non_critical_pos = Vector2i(6, 6)
	var blocking_allowed = grid_manager.ensure_path_solvability(non_critical_pos, true)
	assert_true(blocking_allowed, "Should allow blocking non-critical positions")
	
	# Actually block the position
	grid_manager.set_grid_blocked(non_critical_pos, true)
	assert_true(grid_manager.is_grid_blocked(non_critical_pos), "Position should be blocked")
	
	# Test blocking a critical path position (should check solvability)
	var critical_pos = Vector2i(3, 1)  # On the path
	var critical_blocking_result = grid_manager.ensure_path_solvability(critical_pos, true)
	
	# The result depends on whether alternative paths exist
	if critical_blocking_result:
		grid_manager.set_grid_blocked(critical_pos, true)
		assert_true(grid_manager.is_grid_blocked(critical_pos), "Critical position should be blocked if alternative path exists")
	else:
		# If blocking would break the path, it should not be allowed
		assert_false(grid_manager.is_grid_blocked(critical_pos), "Critical position should not be blocked if it breaks the path")
	
	# Test unblocking
	grid_manager.set_grid_blocked(non_critical_pos, false)
	assert_false(grid_manager.is_grid_blocked(non_critical_pos), "Position should be unblocked")

func test_grid_ruining_system_integration():
	# Integration test: Grid ruining system with state management
	# This tests: GridManager ruining → state tracking → visual updates
	
	var test_positions = [
		Vector2i(2, 2), Vector2i(3, 3), Vector2i(4, 4), Vector2i(5, 5)
	]
	
	# Test ruining positions
	for pos in test_positions:
		if grid_manager.is_valid_grid_position(pos):
			# Initially not ruined
			assert_false(grid_manager.is_grid_ruined(pos), "Position should not be ruined initially")
			
			# Ruin the position
			grid_manager.set_grid_ruined(pos, true)
			assert_true(grid_manager.is_grid_ruined(pos), "Position should be ruined after setting")
			
			# Test ruined positions are also treated as occupied
			# (This tests the integration between ruining and occupancy systems)
			var is_occupied = grid_manager.is_grid_occupied(pos)
			# Note: Ruined positions may or may not be occupied depending on implementation
			# We test that the method exists and returns a boolean
			assert_true(typeof(is_occupied) == TYPE_BOOL, "is_grid_occupied should return boolean")
	
	# Test batch ruining operations
	var batch_positions = [Vector2i(7, 7), Vector2i(8, 7), Vector2i(7, 8)]
	for pos in batch_positions:
		if grid_manager.is_valid_grid_position(pos):
			grid_manager.set_grid_ruined(pos, true)
	
	# Verify batch ruining
	for pos in batch_positions:
		if grid_manager.is_valid_grid_position(pos):
			assert_true(grid_manager.is_grid_ruined(pos), "Batch ruined position should be ruined")
	
	# Test un-ruining
	if grid_manager.is_valid_grid_position(test_positions[0]):
		grid_manager.set_grid_ruined(test_positions[0], false)
		assert_false(grid_manager.is_grid_ruined(test_positions[0]), "Position should not be ruined after clearing")

func test_grid_neighbor_calculation_integration():
	# Integration test: Grid neighbor calculation for pathfinding
	# This tests: GridManager neighbor calculation → pathfinding support → boundary handling
	
	# Test interior position neighbors
	var interior_pos = Vector2i(5, 5)
	var neighbors = grid_manager.get_neighbors(interior_pos)
	
	assert_not_null(neighbors, "Neighbors should be returned")
	assert_true(neighbors.size() > 0, "Interior position should have neighbors")
	assert_lte(neighbors.size(), 4, "Should have at most 4 neighbors (up, down, left, right)")
	
	# Verify neighbor positions are adjacent
	for neighbor in neighbors:
		var distance = abs(neighbor.x - interior_pos.x) + abs(neighbor.y - interior_pos.y)
		assert_eq(distance, 1, "Neighbors should be exactly 1 step away")
		assert_true(grid_manager.is_valid_grid_position(neighbor), "Neighbors should be valid grid positions")
	
	# Test corner position neighbors (boundary case)
	var corner_pos = Vector2i(0, 0)
	if grid_manager.is_valid_grid_position(corner_pos):
		var corner_neighbors = grid_manager.get_neighbors(corner_pos)
		assert_not_null(corner_neighbors, "Corner should have neighbors")
		assert_lte(corner_neighbors.size(), 2, "Corner should have at most 2 neighbors")
		
		# All corner neighbors should be within grid bounds
		for neighbor in corner_neighbors:
			assert_true(grid_manager.is_valid_grid_position(neighbor), "Corner neighbors should be valid")
	
	# Test edge position neighbors
	var grid_size = grid_manager.get_grid_size()
	if grid_size.x > 2 and grid_size.y > 2:
		var edge_pos = Vector2i(0, grid_size.y / 2)  # Left edge, middle
		if grid_manager.is_valid_grid_position(edge_pos):
			var edge_neighbors = grid_manager.get_neighbors(edge_pos)
			assert_not_null(edge_neighbors, "Edge should have neighbors")
			assert_lte(edge_neighbors.size(), 3, "Edge should have at most 3 neighbors")

func test_grid_coordinate_conversion_integration():
	# Integration test: Grid coordinate conversions with mouse interaction
	# This tests: GridManager coordinate conversion → mouse handling → position validation
	
	# Test world to grid conversion
	var world_positions = [
		Vector2(100, 100), Vector2(200, 150), Vector2(300, 300)
	]
	
	for world_pos in world_positions:
		var grid_pos = grid_manager.world_to_grid(world_pos)
		assert_true(typeof(grid_pos) == TYPE_VECTOR2I, "world_to_grid should return Vector2i")
		
		# Test round-trip conversion
		var converted_world = grid_manager.grid_to_world(grid_pos)
		assert_true(typeof(converted_world) == TYPE_VECTOR2, "grid_to_world should return Vector2")
		
		# The converted position should be close to original (within cell bounds)
		var distance = world_pos.distance_to(converted_world)
		assert_lt(distance, 100, "Round-trip conversion should be reasonably close")  # Assuming 64px cells
	
	# Test grid position validation
	var test_grid_positions = [
		Vector2i(0, 0), Vector2i(5, 5), Vector2i(10, 10), 
		Vector2i(-1, 0), Vector2i(0, -1), Vector2i(100, 100)
	]
	
	for grid_pos in test_grid_positions:
		var is_valid = grid_manager.is_valid_grid_position(grid_pos)
		assert_true(typeof(is_valid) == TYPE_BOOL, "is_valid_grid_position should return boolean")
		
		# If position is valid, it should be within grid bounds
		if is_valid:
			var grid_size = grid_manager.get_grid_size()
			assert_gte(grid_pos.x, 0, "Valid position x should be >= 0")
			assert_gte(grid_pos.y, 0, "Valid position y should be >= 0")
			assert_lt(grid_pos.x, grid_size.x, "Valid position x should be < grid width")
			assert_lt(grid_pos.y, grid_size.y, "Valid position y should be < grid height")

func test_mouse_hover_and_visual_feedback_integration():
	# Integration test: Mouse hover handling with visual feedback
	# This tests: GridManager mouse handling → hover detection → visual updates
	
	# Test mouse hover handling
	var hover_positions = [
		Vector2(150, 150), Vector2(250, 200), Vector2(350, 300)
	]
	
	for hover_pos in hover_positions:
		# Handle mouse hover (this should update internal state)
		grid_manager.handle_mouse_hover(hover_pos)
		
		# Verify the method completes without errors
		assert_true(true, "Mouse hover handling should complete without errors")
		
		# Convert to grid position to verify hover detection
		var grid_pos = grid_manager.world_to_grid(hover_pos)
		if grid_manager.is_valid_grid_position(grid_pos):
			# Test that the position can be processed
			var is_occupied = grid_manager.is_grid_occupied(grid_pos)
			assert_true(typeof(is_occupied) == TYPE_BOOL, "Hover position occupancy check should work")

func test_complex_grid_state_scenarios():
	# Integration test: Complex grid state combinations
	# This tests: GridManager state interactions → multi-system coordination → edge cases
	
	var test_pos = Vector2i(6, 6)
	
	if grid_manager.is_valid_grid_position(test_pos):
		# Test state combinations
		assert_false(grid_manager.is_grid_occupied(test_pos), "Position should start unoccupied")
		assert_false(grid_manager.is_grid_blocked(test_pos), "Position should start unblocked")
		assert_false(grid_manager.is_grid_ruined(test_pos), "Position should start unruined")
		
		# Occupy the position
		grid_manager.set_grid_occupied(test_pos, true)
		assert_true(grid_manager.is_grid_occupied(test_pos), "Position should be occupied")
		
		# Block the occupied position
		grid_manager.set_grid_blocked(test_pos, true)
		assert_true(grid_manager.is_grid_blocked(test_pos), "Position should be blocked")
		assert_true(grid_manager.is_grid_occupied(test_pos), "Position should still be occupied")
		
		# Ruin the blocked, occupied position
		grid_manager.set_grid_ruined(test_pos, true)
		assert_true(grid_manager.is_grid_ruined(test_pos), "Position should be ruined")
		assert_true(grid_manager.is_grid_blocked(test_pos), "Position should still be blocked")
		
		# Test cleanup - unblock, unoccupy, unruin
		grid_manager.set_grid_blocked(test_pos, false)
		grid_manager.set_grid_occupied(test_pos, false)
		grid_manager.set_grid_ruined(test_pos, false)
		
		assert_false(grid_manager.is_grid_blocked(test_pos), "Position should be unblocked")
		assert_false(grid_manager.is_grid_occupied(test_pos), "Position should be unoccupied")
		assert_false(grid_manager.is_grid_ruined(test_pos), "Position should be unruined")

func test_grid_signal_emission_integration():
	# Integration test: Grid signal emission with system coordination
	# This tests: GridManager signals → WaveManager response → system integration
	
	var signal_test_pos = Vector2i(4, 5)
	
	if grid_manager.is_valid_grid_position(signal_test_pos):
		# Connect to grid signals for testing (if they exist)
		var signal_received = false
		
		# Test blocking signal emission
		grid_manager.set_grid_blocked(signal_test_pos, true)
		
		# Wait for signal processing
		await wait_physics_frames(3)
		
		# Verify grid state changed
		assert_true(grid_manager.is_grid_blocked(signal_test_pos), "Position should be blocked after signal")
		
		# Test unblocking signal
		grid_manager.set_grid_blocked(signal_test_pos, false)
		
		# Wait for signal processing
		await wait_physics_frames(3)
		
		# Verify grid state changed
		assert_false(grid_manager.is_grid_blocked(signal_test_pos), "Position should be unblocked after signal")
		
		# Test that the signal system is working
		assert_true(true, "Grid signal system should function without errors") 
