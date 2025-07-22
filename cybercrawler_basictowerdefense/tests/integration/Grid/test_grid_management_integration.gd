extends GutTest

# Small integration test to verify grid management integration
# This tests that grid blocking and pathfinding work together

var grid_manager: GridManager
var grid_layout: GridLayout
var wave_manager: WaveManager

func before_each():
	# Create components for integration testing
	grid_manager = GridManager.new()
	grid_layout = GridLayout.new(grid_manager)
	wave_manager = WaveManager.new()
	
	# Add to scene
	add_child_autofree(grid_manager)
	add_child_autofree(grid_layout)
	add_child_autofree(wave_manager)
	
	# Initialize the integration
	wave_manager.initialize(grid_manager)

func test_grid_management_initialization():
	# Test that grid management initializes properly
	# This is the SMALLEST possible integration test
	
	# Verify grid manager was created with proper properties
	assert_not_null(grid_manager, "GridManager should be created")
	assert_not_null(grid_layout, "GridLayout should be created")
	assert_not_null(wave_manager, "WaveManager should be created")

func test_grid_blocking_integration():
	# Test that grid blocking affects pathfinding
	# This tests the integration between grid blocking and path generation
	
	# Create initial path
	var initial_path = grid_layout.create_path(GridLayout.LayoutType.STRAIGHT_LINE)
	assert_gt(initial_path.size(), 0, "Initial path should have points")
	
	# Block a grid position
	var block_pos = Vector2i(5, 5)
	grid_manager.set_grid_blocked(block_pos, true)
	
	# Verify position is blocked
	assert_true(grid_manager.is_grid_blocked(block_pos), "Position should be blocked")
	
	# Create new path after blocking
	var new_path = grid_layout.create_path(GridLayout.LayoutType.STRAIGHT_LINE)
	
	# Path should still exist (might be different due to blocking)
	assert_gt(new_path.size(), 0, "New path should still have points after blocking")

func test_grid_occupation_integration():
	# Test that grid occupation affects placement validation
	# This tests the integration between grid occupation and placement systems
	
	var test_pos = Vector2i(3, 3)
	
	# Verify position is initially free
	assert_false(grid_manager.is_grid_occupied(test_pos), "Position should be initially free")
	
	# Occupy the position
	grid_manager.set_grid_occupied(test_pos, true)
	
	# Verify position is now occupied
	assert_true(grid_manager.is_grid_occupied(test_pos), "Position should be occupied")
	
	# Verify position is still valid (bounds check) but occupied
	assert_true(grid_manager.is_valid_grid_position(test_pos), "Position should still be valid (within bounds)")
	assert_true(grid_manager.is_grid_occupied(test_pos), "Position should be occupied")

func test_path_grid_positions_integration():
	# Test that path grid positions are properly calculated
	# This tests the integration between path generation and grid position calculation
	
	# Create a path
	var path = grid_layout.create_path(GridLayout.LayoutType.STRAIGHT_LINE)
	
	# Get grid positions for the path
	var grid_positions = grid_layout.get_path_grid_positions(GridLayout.LayoutType.STRAIGHT_LINE)
	
	# Verify grid positions were calculated
	assert_gt(grid_positions.size(), 0, "Grid positions should be calculated for path")
	
	# Verify all grid positions are valid
	for pos in grid_positions:
		assert_true(grid_manager.is_valid_grid_position(pos), "All path grid positions should be valid")

func test_grid_to_world_conversion():
	# Test that grid to world position conversion works
	# This tests the integration between grid coordinates and world coordinates
	
	var grid_pos = Vector2i(2, 3)
	var world_pos = grid_manager.grid_to_world(grid_pos)
	
	# Verify conversion produces valid world position
	assert_not_null(world_pos, "Grid to world conversion should produce valid position")
	assert_true(world_pos.x >= 0, "World position X should be non-negative")
	assert_true(world_pos.y >= 0, "World position Y should be non-negative")

func test_wave_manager_path_integration():
	# Test that wave manager integrates with grid path system
	# This tests the integration between wave management and grid pathfinding
	
	# Wave manager should have access to enemy path
	var enemy_path = wave_manager.get_enemy_path()
	
	# Path might be empty initially, but the system should be integrated
	assert_not_null(enemy_path, "Enemy path should exist (even if empty)")
	
	# Verify wave manager can work with grid manager
	assert_not_null(wave_manager.grid_manager, "WaveManager should have grid manager reference") 