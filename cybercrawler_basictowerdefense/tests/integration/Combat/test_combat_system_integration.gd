extends GutTest

# Small integration test to verify combat system integration
# This tests that projectiles, damage, and targeting work between entities

var tower: Tower
var enemy: Enemy
var rival_hacker: RivalHacker
var projectile: Projectile

func before_each():
	# Create components for integration testing
	tower = Tower.new()
	enemy = Enemy.new()
	rival_hacker = RivalHacker.new()
	projectile = Projectile.new()
	
	# Add to scene
	add_child_autofree(tower)
	add_child_autofree(enemy)
	add_child_autofree(rival_hacker)
	add_child_autofree(projectile)

func test_combat_system_initialization():
	# Test that combat entities initialize properly
	# This is the SMALLEST possible integration test
	
	# Verify entities were created with proper properties
	assert_true(tower.is_alive, "Tower should be alive initially")
	assert_true(enemy.is_alive, "Enemy should be alive initially")
	assert_true(rival_hacker.is_alive, "RivalHacker should be alive initially")
	assert_not_null(projectile, "Projectile should be created")

func test_tower_vs_enemy_combat():
	# Test that towers can target and damage enemies
	# This tests the integration between tower targeting and enemy damage
	
	# Set up tower and enemy positions
	tower.global_position = Vector2(100, 100)
	enemy.global_position = Vector2(200, 100)
	
	# Get initial enemy health
	var initial_health = enemy.health
	
	# Create projectile from tower to enemy
	projectile.setup(tower.global_position, enemy, 2, 100.0)
	
	# Simulate projectile hit
	projectile.hit_target()
	
	# Verify enemy took damage
	assert_lt(enemy.health, initial_health, "Enemy should take damage from projectile")

func test_tower_vs_rival_hacker_combat():
	# Test that towers can target and damage rival hackers
	# This tests the integration between tower targeting and rival hacker damage
	
	# Set up tower and rival hacker positions
	tower.global_position = Vector2(100, 100)
	rival_hacker.global_position = Vector2(200, 100)
	
	# Get initial rival hacker health
	var initial_health = rival_hacker.health
	
	# Create projectile from tower to rival hacker
	projectile.setup_for_rival_hacker(tower.global_position, rival_hacker, 3, 100.0)
	
	# Simulate projectile hit
	projectile.hit_target()
	
	# Verify rival hacker took damage
	assert_lt(rival_hacker.health, initial_health, "RivalHacker should take damage from projectile")

func test_rival_hacker_vs_tower_combat():
	# Test that rival hackers can target and damage towers
	# This tests the integration between rival hacker targeting and tower damage
	
	# Set up rival hacker and tower positions
	rival_hacker.global_position = Vector2(100, 100)
	tower.global_position = Vector2(200, 100)
	
	# Get initial tower health
	var initial_health = tower.health
	
	# Create projectile from rival hacker to tower
	projectile.setup_for_tower_target(rival_hacker.global_position, tower, 2, 100.0)
	
	# Simulate projectile hit
	projectile.hit_target()
	
	# Verify tower took damage
	assert_lt(tower.health, initial_health, "Tower should take damage from projectile")

func test_combat_death_integration():
	# Test that entities can die from combat damage
	# This tests the integration between damage and death systems
	
	# Set up tower and enemy
	tower.global_position = Vector2(100, 100)
	enemy.global_position = Vector2(200, 100)
	
	# Create projectile with enough damage to kill enemy
	projectile.setup(tower.global_position, enemy, 10, 100.0)
	
	# Simulate projectile hit
	projectile.hit_target()
	
	# Verify enemy is dead
	assert_false(enemy.is_alive, "Enemy should be dead after taking lethal damage")

func test_projectile_targeting_integration():
	# Test that projectiles can target different entity types
	# This tests the integration between projectile system and entity targeting
	
	# Test targeting enemy
	var enemy_projectile = Projectile.new()
	add_child_autofree(enemy_projectile)
	enemy_projectile.setup(Vector2(0, 0), enemy, 1, 50.0)
	assert_eq(enemy_projectile.target, enemy, "Projectile should target enemy")
	
	# Test targeting rival hacker
	var hacker_projectile = Projectile.new()
	add_child_autofree(hacker_projectile)
	hacker_projectile.setup_for_rival_hacker(Vector2(0, 0), rival_hacker, 1, 50.0)
	assert_eq(hacker_projectile.target, rival_hacker, "Projectile should target rival hacker")
	
	# Test targeting tower
	var tower_projectile = Projectile.new()
	add_child_autofree(tower_projectile)
	tower_projectile.setup_for_tower_target(Vector2(0, 0), tower, 1, 50.0)
	assert_eq(tower_projectile.target, tower, "Projectile should target tower") 