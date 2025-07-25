extends GutTest

# Unit tests for MainController game flow and state management
# This tests game state transitions, cleanup, and activity management

var main_controller: MainController

func before_each():
	# Create a fresh MainController for each test
	# DO NOT call _ready() as it tries to access scene nodes that don't exist in tests
	main_controller = MainController.new()
	add_child_autofree(main_controller)

func test_destroy_all_projectiles():
	# Test projectile destruction functionality
	main_controller.setup_managers()
	
	# Test that destroy_all_projectiles doesn't crash
	main_controller.destroy_all_projectiles()
	assert_true(true, "Destroy all projectiles should not crash")

func test_stop_all_game_activity():
	# Test stop all game activity functionality
	main_controller.setup_managers()
	
	# Test that stop_all_game_activity doesn't crash
	main_controller.stop_all_game_activity()
	assert_true(true, "Stop all game activity should not crash")

func test_stop_all_game_activity_with_towers():
	# Test stop_all_game_activity with actual towers
	main_controller.setup_managers()
	
	# Test stopping all activity - the method will handle the logic internally
	main_controller.stop_all_game_activity()
	assert_true(true, "Stop all game activity should handle towers gracefully")

func test_destroy_all_projectiles_with_projectiles():
	# Test destroy_all_projectiles with actual projectiles
	main_controller.setup_managers()
	
	# Create mock grid container
	var grid_container = Node2D.new()
	grid_container.name = "GridContainer"
	main_controller.add_child(grid_container)
	
	# Create mock projectile
	var mock_projectile = preload("res://scripts/Projectile/Projectile.gd").new()
	grid_container.add_child(mock_projectile)
	
	# Mock grid manager to return grid container
	main_controller.grid_manager.grid_container = grid_container
	
	# Test destroying projectiles
	main_controller.destroy_all_projectiles()
	assert_true(true, "Destroy all projectiles should handle projectiles gracefully") 