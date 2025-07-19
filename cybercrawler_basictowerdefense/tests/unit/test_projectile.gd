extends GutTest

# Unit tests for Projectile class
# These tests verify the projectile behavior and functionality

var projectile: Projectile

func before_each():
	# Setup fresh Projectile for each test
	projectile = Projectile.new()
	add_child_autofree(projectile)

func test_initial_state():
	# Test that Projectile starts with correct initial values
	assert_null(projectile.target, "Should start with no target")
	assert_eq(projectile.damage, 0, "Should start with 0 damage")
	assert_eq(projectile.speed, 0.0, "Should start with 0 speed")
	assert_eq(projectile.start_position, Vector2.ZERO, "Should start with zero position")

func test_ready_creates_visual():
	# Test that _ready() creates the visual components
	var child_count_before = projectile.get_child_count()
	projectile._ready()
	
	# Should have created visual elements
	assert_gt(projectile.get_child_count(), child_count_before, "Should create visual children")

func test_setup():
	# Test basic setup method
	var enemy = Enemy.new()
	add_child_autofree(enemy)
	var start_pos = Vector2(100, 100)
	
	projectile.setup(start_pos, enemy, 5, 200.0)
	
	assert_eq(projectile.global_position, start_pos, "Should set global position")
	assert_eq(projectile.start_position, start_pos, "Should set start position")
	assert_eq(projectile.target, enemy, "Should set target")
	assert_eq(projectile.damage, 5, "Should set damage")
	assert_eq(projectile.speed, 200.0, "Should set speed")

func test_setup_for_tower_target():
	# Test setup for tower target
	var tower = Tower.new()
	add_child_autofree(tower)
	var start_pos = Vector2(50, 50)
	
	projectile.setup_for_tower_target(start_pos, tower, 3, 150.0)
	
	assert_eq(projectile.global_position, start_pos, "Should set global position")
	assert_eq(projectile.target, tower, "Should set tower target")
	assert_eq(projectile.damage, 3, "Should set damage")
	assert_eq(projectile.speed, 150.0, "Should set speed")

func test_setup_for_rival_hacker():
	# Test setup for rival hacker target
	var rival_hacker = RivalHacker.new()
	add_child_autofree(rival_hacker)
	var start_pos = Vector2(75, 75)
	
	projectile.setup_for_rival_hacker(start_pos, rival_hacker, 4, 250.0)
	
	assert_eq(projectile.global_position, start_pos, "Should set global position")
	assert_eq(projectile.target, rival_hacker, "Should set rival hacker target")
	assert_eq(projectile.damage, 4, "Should set damage")
	assert_eq(projectile.speed, 250.0, "Should set speed")

func test_hit_target():
	# Test hitting a target
	var enemy = Enemy.new()
	add_child_autofree(enemy)
	projectile.target = enemy
	projectile.damage = 2
	
	var initial_health = enemy.health
	projectile.hit_target()
	
	assert_eq(enemy.health, initial_health - 2, "Should damage the target")

func test_hit_threshold_constant():
	# Test that the hit threshold constant exists
	assert_eq(Projectile.HIT_THRESHOLD, 10.0, "Hit threshold should be 10.0")

func test_process_with_invalid_target():
	# Test _process with invalid target
	projectile.target = null
	
	# Should handle null target gracefully (will queue_free)
	projectile._process(0.016)
	
	assert_true(true, "Should handle null target without crashing")

func test_get_main_controller():
	# Test getting main controller
	var main_controller = projectile.get_main_controller()
	
	# Should return something (even if null)
	assert_true(main_controller == null or main_controller is Node, "Should return null or Node") 