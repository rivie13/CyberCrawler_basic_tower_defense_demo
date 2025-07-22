extends GutTest

# Small integration test to verify program data packet integration
# This tests that the packet system integrates with game mechanics

var program_packet: ProgramDataPacket
var grid_manager: GridManager
var grid_layout: GridLayout

func before_each():
	# Create components for integration testing
	program_packet = ProgramDataPacket.new()
	grid_manager = GridManager.new()
	grid_layout = GridLayout.new(grid_manager)
	
	# Add to scene
	add_child_autofree(program_packet)
	add_child_autofree(grid_manager)
	add_child_autofree(grid_layout)

func test_program_packet_initialization():
	# Test that ProgramDataPacket initializes properly
	# This is the SMALLEST possible integration test
	
	# Verify packet was created with proper properties
	assert_true(program_packet.is_alive, "Packet should be alive initially")
	assert_false(program_packet.is_active, "Packet should not be active initially")
	assert_eq(program_packet.health, 30, "Packet should have correct health")

func test_program_packet_path_integration():
	# Test that ProgramDataPacket integrates with path system
	# This tests the integration between packet and grid layout
	
	# Create a simple test path (use typed array)
	var test_path: Array[Vector2] = [Vector2(100, 100), Vector2(200, 100), Vector2(200, 200)]
	program_packet.set_path(test_path)
	
	# Verify path was set correctly
	assert_eq(program_packet.path_points.size(), 3, "Path should have 3 points")
	assert_eq(program_packet.current_path_index, 0, "Should start at first path point")

func test_program_packet_damage_integration():
	# Test that ProgramDataPacket handles damage properly
	# This tests the integration between packet and damage system
	
	# Get initial health
	var initial_health = program_packet.health
	
	# Simulate taking damage
	program_packet.take_damage(5)
	
	# Verify health decreased
	assert_lt(program_packet.health, initial_health, "Health should decrease when taking damage")
	assert_eq(program_packet.health, initial_health - 5, "Health should decrease by correct amount")

func test_program_packet_activation_integration():
	# Test that ProgramDataPacket activation works properly
	# This tests the integration between packet and activation system
	
	# Verify packet starts inactive
	assert_false(program_packet.is_active, "Packet should start inactive")
	assert_false(program_packet.was_ever_activated, "Packet should not have been activated")
	
	# Activate the packet
	program_packet.activate()
	
	# Verify packet is now active
	assert_true(program_packet.is_active, "Packet should be active after activation")
	assert_true(program_packet.was_ever_activated, "Packet should track activation") 