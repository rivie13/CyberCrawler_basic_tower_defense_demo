extends GutTest

# Unit tests for GridManagerInterface
# Tests the interface contract and mock implementation

var mock_grid_manager: MockGridManager

func before_each():
	mock_grid_manager = MockGridManager.new()
	add_child_autofree(mock_grid_manager)

func test_initial_state():
	# Test that mock starts in correct initial state
	assert_not_null(mock_grid_manager, "MockGridManager should be created")
	assert_false(mock_grid_manager.is_initialized(), "Should not be initialized initially")
	assert_eq(mock_grid_manager.get_grid_size(), Vector2i(15, 10), "Grid size should be correct")

func test_initialize_with_container():
	# Test initialization with container
	var mock_container = Node2D.new()
	var mock_game_manager = Node.new()
	
	mock_grid_manager.initialize_with_container(mock_container, mock_game_manager)
	
	assert_true(mock_grid_manager.is_initialized(), "Should be initialized after setup")
	assert_eq(mock_grid_manager.get_grid_container(), mock_container, "Grid container should be set")
	assert_eq(mock_grid_manager.get_grid_data().size(), 10, "Grid data should be initialized")
	assert_eq(mock_grid_manager.get_blocked_grid_data().size(), 10, "Blocked grid data should be initialized")

func test_is_valid_grid_position():
	# Test grid position validation
	assert_true(mock_grid_manager.is_valid_grid_position(Vector2i(0, 0)), "Origin should be valid")
	assert_true(mock_grid_manager.is_valid_grid_position(Vector2i(7, 5)), "Middle position should be valid")
	assert_true(mock_grid_manager.is_valid_grid_position(Vector2i(14, 9)), "Last valid position should be valid")
	
	assert_false(mock_grid_manager.is_valid_grid_position(Vector2i(-1, 0)), "Negative X should be invalid")
	assert_false(mock_grid_manager.is_valid_grid_position(Vector2i(0, -1)), "Negative Y should be invalid")
	assert_false(mock_grid_manager.is_valid_grid_position(Vector2i(15, 0)), "X beyond width should be invalid")
	assert_false(mock_grid_manager.is_valid_grid_position(Vector2i(0, 10)), "Y beyond height should be invalid")

func test_grid_occupation():
	# Test grid occupation functionality
	var test_pos = Vector2i(5, 5)
	
	# Initialize the mock first
	var mock_container = Node2D.new()
	mock_grid_manager.initialize_with_container(mock_container)
	
	assert_false(mock_grid_manager.is_grid_occupied(test_pos), "Grid should start unoccupied")
	
	mock_grid_manager.set_grid_occupied(test_pos, true)
	assert_true(mock_grid_manager.is_grid_occupied(test_pos), "Grid should be occupied after setting")
	
	mock_grid_manager.set_grid_occupied(test_pos, false)
	assert_false(mock_grid_manager.is_grid_occupied(test_pos), "Grid should be unoccupied after unsetting")

func test_grid_blocking():
	# Test grid blocking functionality
	var test_pos = Vector2i(3, 3)
	
	# Initialize the mock first
	var mock_container = Node2D.new()
	mock_grid_manager.initialize_with_container(mock_container)
	
	assert_false(mock_grid_manager.is_grid_blocked(test_pos), "Grid should start unblocked")
	
	mock_grid_manager.set_grid_blocked(test_pos, true)
	assert_true(mock_grid_manager.is_grid_blocked(test_pos), "Grid should be blocked after setting")
	
	mock_grid_manager.set_grid_blocked(test_pos, false)
	assert_false(mock_grid_manager.is_grid_blocked(test_pos), "Grid should be unblocked after unsetting")

func test_coordinate_conversion():
	# Test grid to world and world to grid conversion
	var grid_pos = Vector2i(2, 3)
	var world_pos = mock_grid_manager.grid_to_world(grid_pos)
	var converted_grid = mock_grid_manager.world_to_grid(world_pos)
	
	assert_eq(converted_grid, grid_pos, "Coordinate conversion should be reversible")
	assert_eq(world_pos, Vector2(160, 224), "World position should be calculated correctly")

func test_path_positions():
	# Test path position management
	print("DEBUG: Starting test_path_positions")
	
	# First, let's verify the mock is working
	assert_not_null(mock_grid_manager, "MockGridManager should not be null")
	print("DEBUG: MockGridManager is not null")
	
	var test_path: Array[Vector2i] = [Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)]
	print("DEBUG: Test path created: ", test_path)
	
	# Test basic functionality first
	var initial_path = mock_grid_manager.get_path_positions()
	print("DEBUG: Initial path: ", initial_path)
	assert_eq(initial_path.size(), 0, "Initial path should be empty")
	print("DEBUG: Initial path assertion passed")
	
	mock_grid_manager.set_path_positions(test_path)
	print("DEBUG: Path positions set")
	
	var retrieved_path = mock_grid_manager.get_path_positions()
	print("DEBUG: Retrieved path: ", retrieved_path)
	
	assert_eq(retrieved_path, test_path, "Path positions should be set correctly")
	print("DEBUG: First assertion passed")
	
	var on_path = mock_grid_manager.is_on_enemy_path(Vector2i(1, 1))
	print("DEBUG: Position (1,1) on path: ", on_path)
	assert_true(on_path, "Position on path should be detected")
	print("DEBUG: Second assertion passed")
	
	var off_path = mock_grid_manager.is_on_enemy_path(Vector2i(5, 5))
	print("DEBUG: Position (5,5) on path: ", off_path)
	assert_false(off_path, "Position off path should not be detected")
	print("DEBUG: Third assertion passed")

func test_interface_contract():
	# Test that all interface methods are available
	assert_not_null(mock_grid_manager.initialize_with_container, "initialize_with_container should exist")
	assert_not_null(mock_grid_manager.is_valid_grid_position, "is_valid_grid_position should exist")
	assert_not_null(mock_grid_manager.is_grid_occupied, "is_grid_occupied should exist")
	assert_not_null(mock_grid_manager.set_grid_occupied, "set_grid_occupied should exist")
	assert_not_null(mock_grid_manager.grid_to_world, "grid_to_world should exist")
	assert_not_null(mock_grid_manager.world_to_grid, "world_to_grid should exist")
	assert_not_null(mock_grid_manager.set_path_positions, "set_path_positions should exist")
	assert_not_null(mock_grid_manager.get_path_positions, "get_path_positions should exist")
	assert_not_null(mock_grid_manager.handle_mouse_hover, "handle_mouse_hover should exist")
	assert_not_null(mock_grid_manager.get_grid_container, "get_grid_container should exist")
	assert_not_null(mock_grid_manager.get_grid_size, "get_grid_size should exist")
	assert_not_null(mock_grid_manager.is_on_enemy_path, "is_on_enemy_path should exist")
	assert_not_null(mock_grid_manager.is_grid_blocked, "is_grid_blocked should exist")
	assert_not_null(mock_grid_manager.set_grid_blocked, "set_grid_blocked should exist")

func test_mock_helper_methods():
	# Test mock-specific helper methods
	var test_data = [[true, false], [false, true]]
	
	mock_grid_manager.set_grid_data(test_data)
	assert_eq(mock_grid_manager.get_grid_data(), test_data, "Grid data should be settable")
	
	mock_grid_manager.set_blocked_grid_data(test_data)
	assert_eq(mock_grid_manager.get_blocked_grid_data(), test_data, "Blocked grid data should be settable") 