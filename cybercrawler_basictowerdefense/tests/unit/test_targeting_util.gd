extends GutTest

# Unit tests for TargetingUtil class
# These tests verify the static targeting utility functions for prioritizing targets

# Mock classes for testing
class MockController extends Node:
	var program_data_packet_manager = null
	var tower_manager = null

class MockPacketManager extends Node:
	var _packet = null
	
	func set_packet(packet):
		_packet = packet
	
	func get_program_data_packet():
		return _packet

class MockTowerManager extends Node:
	var _towers = []
	
	func set_towers(towers):
		_towers = towers
	
	func get_towers():
		return _towers

func test_find_priority_target_with_no_controller():
	# Test finding priority target with no main controller
	var target = TargetingUtil.find_priority_target(Vector2(100, 100), 150.0, null)
	
	assert_null(target, "Should return null when no main controller")

func test_find_priority_target_with_no_packet_manager():
	# Test finding priority target with controller but no packet manager
	var mock_controller = MockController.new()
	add_child_autofree(mock_controller)
	mock_controller.program_data_packet_manager = null
	
	var target = TargetingUtil.find_priority_target(Vector2(100, 100), 150.0, mock_controller)
	
	assert_null(target, "Should return null when no packet manager")

func test_find_priority_target_with_valid_packet():
	# Test finding priority target with valid program data packet
	var mock_controller = MockController.new()
	var mock_packet_manager = MockPacketManager.new()
	var mock_packet = ProgramDataPacket.new()
	
	add_child_autofree(mock_controller)
	add_child_autofree(mock_packet_manager)
	add_child_autofree(mock_packet)
	
	# Setup mock objects
	mock_controller.program_data_packet_manager = mock_packet_manager
	mock_packet_manager.set_packet(mock_packet)
	mock_packet.is_alive = true
	mock_packet.is_active = true
	mock_packet.global_position = Vector2(120, 100)  # Within range of 150
	
	var target = TargetingUtil.find_priority_target(Vector2(100, 100), 150.0, mock_controller)
	
	assert_eq(target, mock_packet, "Should return the program data packet when alive and in range")

func test_find_priority_target_with_dead_packet():
	# Test finding priority target with dead program data packet
	var mock_controller = MockController.new()
	var mock_packet_manager = MockPacketManager.new()
	var mock_packet = ProgramDataPacket.new()
	
	add_child_autofree(mock_controller)
	add_child_autofree(mock_packet_manager)
	add_child_autofree(mock_packet)
	
	# Setup mock objects
	mock_controller.program_data_packet_manager = mock_packet_manager
	mock_packet_manager.set_packet(mock_packet)
	mock_packet.is_alive = false  # Dead packet
	mock_packet.is_active = true
	mock_packet.global_position = Vector2(120, 100)
	
	var target = TargetingUtil.find_priority_target(Vector2(100, 100), 150.0, mock_controller)
	
	assert_null(target, "Should return null when packet is dead")

func test_find_priority_target_with_inactive_packet():
	# Test finding priority target with inactive program data packet
	var mock_controller = MockController.new()
	var mock_packet_manager = MockPacketManager.new()
	var mock_packet = ProgramDataPacket.new()
	
	add_child_autofree(mock_controller)
	add_child_autofree(mock_packet_manager)
	add_child_autofree(mock_packet)
	
	# Setup mock objects
	mock_controller.program_data_packet_manager = mock_packet_manager
	mock_packet_manager.set_packet(mock_packet)
	mock_packet.is_alive = true
	mock_packet.is_active = false  # Inactive packet
	mock_packet.global_position = Vector2(120, 100)
	
	var target = TargetingUtil.find_priority_target(Vector2(100, 100), 150.0, mock_controller)
	
	assert_null(target, "Should return null when packet is inactive")

func test_find_priority_target_out_of_range():
	# Test finding priority target with packet out of range
	var mock_controller = MockController.new()
	var mock_packet_manager = MockPacketManager.new()
	var mock_packet = ProgramDataPacket.new()
	
	add_child_autofree(mock_controller)
	add_child_autofree(mock_packet_manager)
	add_child_autofree(mock_packet)
	
	# Setup mock objects
	mock_controller.program_data_packet_manager = mock_packet_manager
	mock_packet_manager.set_packet(mock_packet)
	mock_packet.is_alive = true
	mock_packet.is_active = true
	mock_packet.global_position = Vector2(300, 100)  # Out of range (200 > 150)
	
	var target = TargetingUtil.find_priority_target(Vector2(100, 100), 150.0, mock_controller)
	
	assert_null(target, "Should return null when packet is out of range")

func test_find_player_towers_in_range_no_controller():
	# Test finding player towers with no controller
	var target = TargetingUtil.find_player_towers_in_range(Vector2(100, 100), 150.0, null)
	
	assert_null(target, "Should return null when no controller")

func test_find_player_towers_in_range_no_tower_manager():
	# Test finding player towers with no tower manager
	var mock_controller = MockController.new()
	add_child_autofree(mock_controller)
	mock_controller.tower_manager = null
	
	var target = TargetingUtil.find_player_towers_in_range(Vector2(100, 100), 150.0, mock_controller)
	
	assert_null(target, "Should return null when no tower manager")

func test_find_player_towers_in_range_with_valid_tower():
	# Test finding player towers with valid tower in range
	var mock_controller = MockController.new()
	var mock_tower_manager = MockTowerManager.new()
	var mock_tower = Tower.new()
	
	add_child_autofree(mock_controller)
	add_child_autofree(mock_tower_manager)
	add_child_autofree(mock_tower)
	
	# Setup mock objects
	mock_controller.tower_manager = mock_tower_manager
	mock_tower_manager.set_towers([mock_tower])
	mock_tower.is_alive = true
	mock_tower.global_position = Vector2(120, 100)  # Within range
	
	var target = TargetingUtil.find_player_towers_in_range(Vector2(100, 100), 150.0, mock_controller)
	
	assert_eq(target, mock_tower, "Should return the tower when alive and in range")

func test_find_player_towers_in_range_with_dead_tower():
	# Test finding player towers with dead tower
	var mock_controller = MockController.new()
	var mock_tower_manager = MockTowerManager.new()
	var mock_tower = Tower.new()
	
	add_child_autofree(mock_controller)
	add_child_autofree(mock_tower_manager)
	add_child_autofree(mock_tower)
	
	# Setup mock objects
	mock_controller.tower_manager = mock_tower_manager
	mock_tower_manager.set_towers([mock_tower])
	mock_tower.is_alive = false  # Dead tower
	mock_tower.global_position = Vector2(120, 100)
	
	var target = TargetingUtil.find_player_towers_in_range(Vector2(100, 100), 150.0, mock_controller)
	
	assert_null(target, "Should return null when tower is dead")

func test_find_player_towers_in_range_closest_tower():
	# Test finding closest tower when multiple towers in range
	var mock_controller = MockController.new()
	var mock_tower_manager = MockTowerManager.new()
	var mock_tower1 = Tower.new()
	var mock_tower2 = Tower.new()
	
	add_child_autofree(mock_controller)
	add_child_autofree(mock_tower_manager)
	add_child_autofree(mock_tower1)
	add_child_autofree(mock_tower2)
	
	# Setup mock objects
	mock_controller.tower_manager = mock_tower_manager
	mock_tower_manager.set_towers([mock_tower1, mock_tower2])
	mock_tower1.is_alive = true
	mock_tower1.global_position = Vector2(130, 100)  # Distance 30
	mock_tower2.is_alive = true
	mock_tower2.global_position = Vector2(120, 100)  # Distance 20 (closer)
	
	var target = TargetingUtil.find_player_towers_in_range(Vector2(100, 100), 150.0, mock_controller)
	
	assert_eq(target, mock_tower2, "Should return the closest tower")

func test_find_best_target_prioritizes_packet():
	# Test that find_best_target prioritizes program data packet over towers
	var mock_controller = MockController.new()
	var mock_packet_manager = MockPacketManager.new()
	var mock_tower_manager = MockTowerManager.new()
	var mock_packet = ProgramDataPacket.new()
	var mock_tower = Tower.new()
	
	add_child_autofree(mock_controller)
	add_child_autofree(mock_packet_manager)
	add_child_autofree(mock_tower_manager)
	add_child_autofree(mock_packet)
	add_child_autofree(mock_tower)
	
	# Setup mock objects
	mock_controller.program_data_packet_manager = mock_packet_manager
	mock_controller.tower_manager = mock_tower_manager
	mock_packet_manager.set_packet(mock_packet)
	mock_tower_manager.set_towers([mock_tower])
	
	# Both packet and tower are valid and in range
	mock_packet.is_alive = true
	mock_packet.is_active = true
	mock_packet.global_position = Vector2(140, 100)  # Distance 40
	mock_tower.is_alive = true
	mock_tower.global_position = Vector2(120, 100)   # Distance 20 (closer but lower priority)
	
	var target = TargetingUtil.find_best_target(Vector2(100, 100), 150.0, mock_controller)
	
	assert_eq(target, mock_packet, "Should prioritize program data packet over towers")

func test_find_best_target_falls_back_to_tower():
	# Test that find_best_target falls back to towers when no packet available
	var mock_controller = MockController.new()
	var mock_packet_manager = MockPacketManager.new()
	var mock_tower_manager = MockTowerManager.new()
	var mock_tower = Tower.new()
	
	add_child_autofree(mock_controller)
	add_child_autofree(mock_packet_manager)
	add_child_autofree(mock_tower_manager)
	add_child_autofree(mock_tower)
	
	# Setup mock objects
	mock_controller.program_data_packet_manager = mock_packet_manager
	mock_controller.tower_manager = mock_tower_manager
	mock_packet_manager.set_packet(null)  # No packet
	mock_tower_manager.set_towers([mock_tower])
	
	mock_tower.is_alive = true
	mock_tower.global_position = Vector2(120, 100)
	
	var target = TargetingUtil.find_best_target(Vector2(100, 100), 150.0, mock_controller)
	
	assert_eq(target, mock_tower, "Should fall back to tower when no packet available")

func test_is_target_in_range_invalid_target():
	# Test is_target_in_range with invalid target
	var invalid_target = Node.new()
	invalid_target.queue_free()
	
	var in_range = TargetingUtil.is_target_in_range(Vector2(100, 100), invalid_target, 150.0)
	
	assert_false(in_range, "Should return false for invalid target")

func test_is_target_in_range_dead_tower():
	# Test is_target_in_range with dead tower
	var tower = Tower.new()
	add_child_autofree(tower)
	tower.is_alive = false
	tower.global_position = Vector2(120, 100)
	
	var in_range = TargetingUtil.is_target_in_range(Vector2(100, 100), tower, 150.0)
	
	assert_false(in_range, "Should return false for dead tower")

func test_is_target_in_range_dead_packet():
	# Test is_target_in_range with dead program data packet
	var packet = ProgramDataPacket.new()
	add_child_autofree(packet)
	packet.is_alive = false
	packet.global_position = Vector2(120, 100)
	
	var in_range = TargetingUtil.is_target_in_range(Vector2(100, 100), packet, 150.0)
	
	assert_false(in_range, "Should return false for dead packet")

func test_is_target_in_range_valid_target_in_range():
	# Test is_target_in_range with valid target in range
	var tower = Tower.new()
	add_child_autofree(tower)
	tower.is_alive = true
	tower.global_position = Vector2(120, 100)  # Distance 20, within range 150
	
	var in_range = TargetingUtil.is_target_in_range(Vector2(100, 100), tower, 150.0)
	
	assert_true(in_range, "Should return true for valid target in range")

func test_is_target_in_range_valid_target_out_of_range():
	# Test is_target_in_range with valid target out of range
	var tower = Tower.new()
	add_child_autofree(tower)
	tower.is_alive = true
	tower.global_position = Vector2(300, 100)  # Distance 200, beyond range 150
	
	var in_range = TargetingUtil.is_target_in_range(Vector2(100, 100), tower, 150.0)
	
	assert_false(in_range, "Should return false for valid target out of range")

func test_is_target_in_range_with_other_node_type():
	# Test is_target_in_range with other node type (should work as long as it's valid)
	var enemy = Enemy.new()
	add_child_autofree(enemy)
	enemy.global_position = Vector2(120, 100)  # Distance 20, within range 150
	
	var in_range = TargetingUtil.is_target_in_range(Vector2(100, 100), enemy, 150.0)
	
	assert_true(in_range, "Should return true for other valid node types in range") 