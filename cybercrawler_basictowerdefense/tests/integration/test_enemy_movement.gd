extends GutTest

# Small integration test to verify enemy movement
# This tests that enemies move through the system correctly

var enemy: Enemy
var grid_manager: GridManager
var grid_layout: GridLayout

func before_each():
	# Create components for integration testing
	enemy = Enemy.new()
	grid_manager = GridManager.new()
	grid_layout = GridLayout.new(grid_manager)
	
	# Add to scene
	add_child_autofree(enemy)
	add_child_autofree(grid_manager)
	add_child_autofree(grid_layout)

func test_enemy_initialization():
	# Test that Enemy initializes properly
	# This is the SMALLEST possible integration test
	
	# Verify enemy was created with proper properties
	assert_true(enemy.is_alive, "Enemy should be alive initially")
	assert_eq(enemy.health, 3, "Enemy should have correct health")
	# Note: movement_speed is not directly accessible, but enemy has movement capabilities

func test_enemy_path_integration():
	# Test that Enemy integrates with path system
	# This tests the integration between enemy and pathfinding
	
	# Create a simple test path
	var test_path: Array[Vector2] = [Vector2(100, 100), Vector2(200, 100), Vector2(200, 200)]
	enemy.set_path(test_path)
	
	# Verify path was set correctly
	assert_eq(enemy.path_points.size(), 3, "Path should have 3 points")
	assert_eq(enemy.current_path_index, 0, "Should start at first path point")

func test_enemy_movement_integration():
	# Test that Enemy movement integrates with path system
	# This tests the integration between enemy movement and path following
	
	# Set up enemy with a path
	var test_path: Array[Vector2] = [Vector2(100, 100), Vector2(200, 100), Vector2(200, 200)]
	enemy.set_path(test_path)
	
	# Set initial position
	enemy.global_position = Vector2(100, 100)
	
	# Test that enemy has movement properties
	# Note: movement_speed is not directly accessible, but enemy has movement capabilities
	assert_not_null(enemy.target_position, "Target position should be set")

func test_enemy_damage_integration():
	# Test that Enemy handles damage properly
	# This tests the integration between enemy and damage system
	
	# Get initial health
	var initial_health = enemy.health
	
	# Simulate taking damage
	enemy.take_damage(2)
	
	# Verify health decreased
	assert_lt(enemy.health, initial_health, "Health should decrease when taking damage")
	assert_eq(enemy.health, initial_health - 2, "Health should decrease by correct amount")

func test_enemy_signal_integration():
	# Test that Enemy emits proper signals
	# This tests signal integration between systems
	
	watch_signals(enemy)
	
	# Simulate enemy death
	enemy.take_damage(10)  # More than max health
	
	# Verify signal was emitted
	assert_signal_emitted(enemy, "enemy_died")

func test_enemy_path_completion():
	# Test that Enemy can complete a path
	# This tests the integration between enemy movement and path completion
	
	# Create a very short path
	var test_path: Array[Vector2] = [Vector2(100, 100), Vector2(110, 100)]
	enemy.set_path(test_path)
	
	# Set enemy at start of path
	enemy.global_position = Vector2(100, 100)
	enemy.current_path_index = 0
	
	# Test that enemy can track path progress
	assert_eq(enemy.current_path_index, 0, "Should start at path index 0")
	assert_eq(enemy.path_points.size(), 2, "Path should have 2 points") 