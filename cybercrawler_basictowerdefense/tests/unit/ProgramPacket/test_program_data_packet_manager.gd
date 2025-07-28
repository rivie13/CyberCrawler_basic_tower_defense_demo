extends GutTest

# Unit tests for ProgramDataPacketManager
# Tests program data packet management functionality with mocks

var program_data_packet_manager: ProgramDataPacketManager
var mock_grid_manager: MockGridManager
var mock_game_manager: MockGameManager
var mock_wave_manager: MockWaveManager

func before_each():
	# Setup fresh mocks and manager for each test
	mock_grid_manager = MockGridManager.new()
	add_child_autofree(mock_grid_manager)
	
	mock_game_manager = MockGameManager.new()
	add_child_autofree(mock_game_manager)
	
	mock_wave_manager = MockWaveManager.new()
	add_child_autofree(mock_wave_manager)
	
	program_data_packet_manager = ProgramDataPacketManager.new()
	add_child_autofree(program_data_packet_manager)

func test_initialization():
	# Test that ProgramDataPacketManager is properly initialized
	assert_not_null(program_data_packet_manager, "ProgramDataPacketManager should be created")
	
	# Test initial state
	assert_false(program_data_packet_manager.is_packet_spawned, "Should not start with packet spawned")
	assert_false(program_data_packet_manager.is_packet_active, "Should not start with packet active")
	assert_false(program_data_packet_manager.can_release_packet, "Should not start with packet release enabled")
	assert_eq(program_data_packet_manager.packet_path.size(), 0, "Should start with empty packet path")

func test_initialize_with_all_managers():
	# Test initialization with all managers
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	# Check that managers are set
	assert_eq(program_data_packet_manager.grid_manager, mock_grid_manager, "Grid manager should be set")
	assert_eq(program_data_packet_manager.game_manager, mock_game_manager, "Game manager should be set")
	assert_eq(program_data_packet_manager.wave_manager, mock_wave_manager, "Wave manager should be set")

func test_initialize_with_null_managers():
	# Test initialization with null managers (should handle gracefully)
	program_data_packet_manager.initialize(null, null, null)
	
	# Should not crash and should set managers to null
	assert_eq(program_data_packet_manager.grid_manager, null, "Grid manager should be null")
	assert_eq(program_data_packet_manager.game_manager, null, "Game manager should be null")
	assert_eq(program_data_packet_manager.wave_manager, null, "Wave manager should be null")

func test_create_packet_path_with_valid_enemy_path():
	# Test creating packet path from valid enemy path
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	# Set up mock enemy path
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0), Vector2(100, 100)]
	mock_wave_manager.set_mock_enemy_path(enemy_path)
	
	program_data_packet_manager.create_packet_path()
	
	# Should create reversed path
	assert_eq(program_data_packet_manager.packet_path.size(), 3, "Should create packet path with 3 points")
	assert_eq(program_data_packet_manager.packet_path[0], Vector2(100, 100), "First point should be last enemy point")
	assert_eq(program_data_packet_manager.packet_path[2], Vector2(0, 0), "Last point should be first enemy point")

func test_create_packet_path_with_empty_enemy_path():
	# Test creating packet path with empty enemy path
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	# Set up empty enemy path
	mock_wave_manager.set_mock_enemy_path([])
	
	program_data_packet_manager.create_packet_path()
	
	# Should not create path
	assert_eq(program_data_packet_manager.packet_path.size(), 0, "Should not create path from empty enemy path")

func test_create_packet_path_without_managers():
	# Test creating packet path without managers
	program_data_packet_manager.create_packet_path()
	
	# Should handle gracefully
	assert_eq(program_data_packet_manager.packet_path.size(), 0, "Should not create path without managers")

func test_spawn_program_data_packet():
	# Test spawning program data packet
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	# Set up packet path
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.set_mock_enemy_path(enemy_path)
	program_data_packet_manager.create_packet_path()
	
	program_data_packet_manager.spawn_program_data_packet()
	
	# Should spawn packet
	assert_true(program_data_packet_manager.is_packet_spawned, "Should mark packet as spawned")
	assert_not_null(program_data_packet_manager.program_data_packet, "Should create program data packet")
	assert_not_null(program_data_packet_manager.get_program_data_packet(), "Should return packet instance")

func test_spawn_program_data_packet_without_path():
	# Test spawning packet without path
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	program_data_packet_manager.spawn_program_data_packet()
	
	# Should not spawn packet
	assert_false(program_data_packet_manager.is_packet_spawned, "Should not spawn packet without path")
	assert_eq(program_data_packet_manager.program_data_packet, null, "Should not create packet without path")

func test_spawn_program_data_packet_already_spawned():
	# Test spawning packet when already spawned
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	# Set up and spawn packet
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.set_mock_enemy_path(enemy_path)
	program_data_packet_manager.create_packet_path()
	program_data_packet_manager.spawn_program_data_packet()
	
	# Try to spawn again
	program_data_packet_manager.spawn_program_data_packet()
	
	# Should not spawn again
	assert_true(program_data_packet_manager.is_packet_spawned, "Should remain spawned")

func test_release_program_data_packet():
	# Test releasing program data packet
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	# Set up and spawn packet
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.set_mock_enemy_path(enemy_path)
	program_data_packet_manager.create_packet_path()
	program_data_packet_manager.spawn_program_data_packet()
	
	program_data_packet_manager.release_program_data_packet()
	
	# Should activate packet
	assert_true(program_data_packet_manager.is_packet_active, "Should mark packet as active")

func test_release_program_data_packet_not_spawned():
	# Test releasing packet that's not spawned
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	program_data_packet_manager.release_program_data_packet()
	
	# Should not activate
	assert_false(program_data_packet_manager.is_packet_active, "Should not activate unsawned packet")

func test_release_program_data_packet_already_active():
	# Test releasing packet that's already active
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	# Set up and spawn packet
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.set_mock_enemy_path(enemy_path)
	program_data_packet_manager.create_packet_path()
	program_data_packet_manager.spawn_program_data_packet()
	program_data_packet_manager.release_program_data_packet()
	
	# Try to release again
	program_data_packet_manager.release_program_data_packet()
	
	# Should remain active
	assert_true(program_data_packet_manager.is_packet_active, "Should remain active")

func test_can_player_release_packet():
	# Test can_player_release_packet method
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	# Initially should not be able to release
	assert_false(program_data_packet_manager.can_player_release_packet(), "Should not be able to release initially")
	
	# Enable release
	program_data_packet_manager.enable_packet_release()
	
	# Should still not be able to release (not spawned)
	assert_false(program_data_packet_manager.can_player_release_packet(), "Should not be able to release if not spawned")
	
	# Spawn packet
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.set_mock_enemy_path(enemy_path)
	program_data_packet_manager.create_packet_path()
	program_data_packet_manager.spawn_program_data_packet()
	
	# Now should be able to release
	assert_true(program_data_packet_manager.can_player_release_packet(), "Should be able to release spawned packet")
	
	# Release packet
	program_data_packet_manager.release_program_data_packet()
	
	# Should not be able to release active packet
	assert_false(program_data_packet_manager.can_player_release_packet(), "Should not be able to release active packet")

func test_enable_packet_release():
	# Test enabling packet release
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	program_data_packet_manager.enable_packet_release()
	
	# Should enable release
	assert_true(program_data_packet_manager.can_release_packet, "Should enable packet release")

func test_is_packet_alive():
	# Test is_packet_alive method
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	# Initially no packet
	assert_false(program_data_packet_manager.is_packet_alive(), "Should not be alive initially")
	
	# Spawn packet
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.set_mock_enemy_path(enemy_path)
	program_data_packet_manager.create_packet_path()
	program_data_packet_manager.spawn_program_data_packet()
	
	# Should be alive
	assert_true(program_data_packet_manager.is_packet_alive(), "Should be alive when spawned")

func test_on_wave_started_wave_1():
	# Test wave 1 start behavior
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	# Set up enemy path
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.set_mock_enemy_path(enemy_path)
	
	# Create packet path first (this is what the real system does)
	program_data_packet_manager.create_packet_path()
	
	# Trigger wave 1 start
	program_data_packet_manager._on_wave_started(1)
	
	# Should spawn packet and enable release
	assert_true(program_data_packet_manager.is_packet_spawned, "Should spawn packet on wave 1")
	assert_true(program_data_packet_manager.can_release_packet, "Should enable packet release on wave 1")

func test_on_wave_started_final_wave():
	# Test final wave start behavior
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	# Set up enemy path and spawn packet
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.set_mock_enemy_path(enemy_path)
	program_data_packet_manager.create_packet_path()
	program_data_packet_manager.spawn_program_data_packet()
	program_data_packet_manager.enable_packet_release()
	
	# Trigger final wave start
	program_data_packet_manager._on_wave_started(10)
	
	# Should auto-release packet
	assert_true(program_data_packet_manager.is_packet_active, "Should auto-release packet on final wave")

func test_on_program_packet_destroyed():
	# Test program packet destroyed behavior
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	# Spawn packet
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.set_mock_enemy_path(enemy_path)
	program_data_packet_manager.create_packet_path()
	program_data_packet_manager.spawn_program_data_packet()
	
	# Trigger packet destroyed
	program_data_packet_manager._on_program_packet_destroyed(program_data_packet_manager.program_data_packet)
	
	# Should trigger game over
	assert_true(mock_game_manager.game_over_triggered_called, "Should trigger game over when packet destroyed")

func test_on_program_packet_reached_end():
	# Test program packet reached end behavior
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	# Spawn packet
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.set_mock_enemy_path(enemy_path)
	program_data_packet_manager.create_packet_path()
	program_data_packet_manager.spawn_program_data_packet()
	
	# Trigger packet reached end
	program_data_packet_manager._on_program_packet_reached_end(program_data_packet_manager.program_data_packet)
	
	# Should trigger game won
	assert_true(mock_game_manager.game_won_triggered_called, "Should trigger game won when packet reaches end")

func test_on_game_over():
	# Test game over behavior
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	# Spawn and activate packet
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.set_mock_enemy_path(enemy_path)
	program_data_packet_manager.create_packet_path()
	program_data_packet_manager.spawn_program_data_packet()
	program_data_packet_manager.release_program_data_packet()
	
	# Trigger game over
	program_data_packet_manager._on_game_over()
	
	# Should deactivate packet
	assert_false(program_data_packet_manager.program_data_packet.is_active, "Should deactivate packet on game over")

func test_on_game_won():
	# Test game won behavior
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	# Spawn and activate packet
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.set_mock_enemy_path(enemy_path)
	program_data_packet_manager.create_packet_path()
	program_data_packet_manager.spawn_program_data_packet()
	program_data_packet_manager.release_program_data_packet()
	
	# Trigger game won
	program_data_packet_manager._on_game_won()
	
	# Should keep packet active (for visual feedback)
	assert_true(program_data_packet_manager.program_data_packet.is_active, "Should keep packet active on game won")

func test_on_grid_blocked_changed():
	# Test grid blocked changed behavior
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	# Set up initial path
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.set_mock_enemy_path(enemy_path)
	program_data_packet_manager.create_packet_path()
	program_data_packet_manager.spawn_program_data_packet()
	
	# Change enemy path
	var new_enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(50, 50), Vector2(100, 100)]
	mock_wave_manager.set_mock_enemy_path(new_enemy_path)
	
	# Trigger grid blocked changed
	program_data_packet_manager._on_grid_blocked_changed(Vector2i(1, 1), true)
	
	# Should update packet path (tested by checking path size)
	# Note: The actual path update happens after a timer, so we just verify the method doesn't crash
	assert_not_null(program_data_packet_manager.program_data_packet, "Should still have packet after grid change")

func test_constants():
	# Test that constants are properly defined
	assert_eq(ProgramDataPacketManager.AUTO_RELEASE_WAVE_NUMBER, 10, "AUTO_RELEASE_WAVE_NUMBER should be 10")
	assert_not_null(ProgramDataPacketManager.PROGRAM_DATA_PACKET_SCENE, "PROGRAM_DATA_PACKET_SCENE should be defined") 