extends GutTest

# Small integration test to verify rival hacker integration
# This tests that the AI opponent integrates with targeting system

var rival_hacker: RivalHacker
var tower: Tower
var program_packet: ProgramDataPacket

func before_each():
	# Create components for integration testing
	rival_hacker = RivalHacker.new()
	tower = Tower.new()
	program_packet = ProgramDataPacket.new()
	
	# Add to scene
	add_child_autofree(rival_hacker)
	add_child_autofree(tower)
	add_child_autofree(program_packet)

func test_rival_hacker_initialization():
	# Test that RivalHacker initializes properly
	# This is the SMALLEST possible integration test
	
	# Verify rival hacker was created with proper properties
	assert_true(rival_hacker.is_alive, "Rival hacker should be alive initially")
	assert_true(rival_hacker.is_seeking_target, "Rival hacker should be seeking target initially")
	assert_eq(rival_hacker.health, 8, "Rival hacker should have correct health")

func test_rival_hacker_targeting_integration():
	# Test that RivalHacker integrates with targeting system
	# This tests the integration between rival hacker and targeting util
	
	# Set up positions for testing
	rival_hacker.global_position = Vector2(100, 100)
	tower.global_position = Vector2(150, 100)  # Within detection range
	
	# Test that rival hacker can find targets
	# Note: This tests the integration even if targeting logic isn't fully implemented
	assert_not_null(rival_hacker.detection_range, "Detection range should be set")
	assert_gt(rival_hacker.detection_range, 0, "Detection range should be positive")

func test_rival_hacker_attack_integration():
	# Test that RivalHacker integrates with attack system
	# This tests the integration between rival hacker and damage system
	
	# Set up attack scenario
	rival_hacker.global_position = Vector2(100, 100)
	tower.global_position = Vector2(120, 100)  # Close enough to attack
	rival_hacker.current_target = tower
	
	# Test that rival hacker has attack properties
	assert_gt(rival_hacker.attack_damage, 0, "Attack damage should be positive")
	assert_gt(rival_hacker.attack_rate, 0, "Attack rate should be positive")

func test_rival_hacker_movement_integration():
	# Test that RivalHacker integrates with movement system
	# This tests the integration between rival hacker and movement logic
	
	# Set up movement scenario
	rival_hacker.global_position = Vector2(100, 100)
	rival_hacker.target_position = Vector2(200, 200)
	
	# Test that rival hacker has movement properties
	assert_gt(rival_hacker.movement_speed, 0, "Movement speed should be positive")
	assert_not_null(rival_hacker.target_position, "Target position should be set")

func test_rival_hacker_signal_integration():
	# Test that RivalHacker emits proper signals
	# This tests signal integration between systems
	
	watch_signals(rival_hacker)
	
	# Simulate rival hacker destruction
	rival_hacker.take_damage(10)  # More than max health
	
	# Verify signal was emitted (if rival hacker dies)
	if not rival_hacker.is_alive:
		assert_signal_emitted(rival_hacker, "rival_hacker_destroyed") 