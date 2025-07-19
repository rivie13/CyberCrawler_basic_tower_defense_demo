extends GutTest

# Unit tests for ProgramDataPacketManager class
# These tests verify the program data packet management functionality

var program_data_packet_manager: ProgramDataPacketManager
var mock_grid_manager: GridManager
var mock_game_manager: GameManager
var mock_wave_manager: WaveManager

func before_each():
	# Setup fresh ProgramDataPacketManager for each test
	program_data_packet_manager = ProgramDataPacketManager.new()
	mock_grid_manager = GridManager.new()
	mock_game_manager = GameManager.new()
	mock_wave_manager = WaveManager.new()
	
	add_child_autofree(program_data_packet_manager)
	add_child_autofree(mock_grid_manager)
	add_child_autofree(mock_game_manager)
	add_child_autofree(mock_wave_manager)

func test_initial_state():
	# Test that ProgramDataPacketManager starts with correct initial values
	assert_null(program_data_packet_manager.program_data_packet, "Should start with no packet")
	assert_eq(program_data_packet_manager.packet_path.size(), 0, "Should start with no path")
	assert_false(program_data_packet_manager.is_packet_spawned, "Should not start spawned")
	assert_false(program_data_packet_manager.is_packet_active, "Should not start active")
	assert_false(program_data_packet_manager.can_release_packet, "Should not start able to release")
	assert_null(program_data_packet_manager.grid_manager, "Should start with no grid manager")
	assert_null(program_data_packet_manager.game_manager, "Should start with no game manager")
	assert_null(program_data_packet_manager.wave_manager, "Should start with no wave manager")

func test_initialize():
	# Test that initialize sets manager references
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	assert_eq(program_data_packet_manager.grid_manager, mock_grid_manager, "Should set grid manager")
	assert_eq(program_data_packet_manager.game_manager, mock_game_manager, "Should set game manager")
	assert_eq(program_data_packet_manager.wave_manager, mock_wave_manager, "Should set wave manager")

func test_create_packet_path_with_valid_enemy_path():
	# Test path creation with valid enemy path
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0), Vector2(100, 100)]
	mock_wave_manager.enemy_path = enemy_path
	
	program_data_packet_manager.create_packet_path()
	
	# Should create reversed path
	assert_eq(program_data_packet_manager.packet_path.size(), 3, "Should have 3 path points")
	assert_eq(program_data_packet_manager.packet_path[0], Vector2(100, 100), "Should start with last enemy point")
	assert_eq(program_data_packet_manager.packet_path[2], Vector2(0, 0), "Should end with first enemy point")

func test_create_packet_path_with_empty_enemy_path():
	# Test path creation with empty enemy path
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	mock_wave_manager.enemy_path = []
	
	program_data_packet_manager.create_packet_path()
	
	# Should not create path
	assert_eq(program_data_packet_manager.packet_path.size(), 0, "Should not create path from empty enemy path")

func test_create_packet_path_without_managers():
	# Test path creation without managers
	program_data_packet_manager.create_packet_path()
	
	# Should not create path
	assert_eq(program_data_packet_manager.packet_path.size(), 0, "Should not create path without managers")

func test_spawn_program_data_packet():
	# Test packet spawning
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.enemy_path = enemy_path
	program_data_packet_manager.create_packet_path()
	
	program_data_packet_manager.spawn_program_data_packet()
	
	assert_true(program_data_packet_manager.is_packet_spawned, "Should be spawned")
	assert_not_null(program_data_packet_manager.program_data_packet, "Should create packet instance")

func test_spawn_program_data_packet_already_spawned():
	# Test spawning when already spawned
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.enemy_path = enemy_path
	program_data_packet_manager.create_packet_path()
	program_data_packet_manager.spawn_program_data_packet()
	
	# Try to spawn again
	program_data_packet_manager.spawn_program_data_packet()
	
	# Should still have only one packet
	assert_true(program_data_packet_manager.is_packet_spawned, "Should remain spawned")

func test_spawn_program_data_packet_no_path():
	# Test spawning without path
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	program_data_packet_manager.spawn_program_data_packet()
	
	assert_false(program_data_packet_manager.is_packet_spawned, "Should not spawn without path")

func test_release_program_data_packet():
	# Test packet release
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.enemy_path = enemy_path
	program_data_packet_manager.create_packet_path()
	program_data_packet_manager.spawn_program_data_packet()
	
	program_data_packet_manager.release_program_data_packet()
	
	assert_true(program_data_packet_manager.is_packet_active, "Should be active after release")
	assert_true(program_data_packet_manager.program_data_packet.is_active, "Packet should be active")

func test_release_program_data_packet_not_spawned():
	# Test releasing when not spawned
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	program_data_packet_manager.release_program_data_packet()
	
	assert_false(program_data_packet_manager.is_packet_active, "Should not be active when not spawned")

func test_release_program_data_packet_already_active():
	# Test releasing when already active
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.enemy_path = enemy_path
	program_data_packet_manager.create_packet_path()
	program_data_packet_manager.spawn_program_data_packet()
	program_data_packet_manager.release_program_data_packet()
	
	# Try to release again
	program_data_packet_manager.release_program_data_packet()
	
	# Should still be active
	assert_true(program_data_packet_manager.is_packet_active, "Should remain active")

func test_can_player_release_packet():
	# Test release permission checks
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	# Initially should not be able to release
	assert_false(program_data_packet_manager.can_player_release_packet(), "Should not be able to release initially")
	
	# Enable release
	program_data_packet_manager.can_release_packet = true
	assert_false(program_data_packet_manager.can_player_release_packet(), "Should not be able to release when not spawned")
	
	# Spawn packet
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.enemy_path = enemy_path
	program_data_packet_manager.create_packet_path()
	program_data_packet_manager.spawn_program_data_packet()
	
	assert_true(program_data_packet_manager.can_player_release_packet(), "Should be able to release when spawned and enabled")
	
	# Release packet
	program_data_packet_manager.release_program_data_packet()
	assert_false(program_data_packet_manager.can_player_release_packet(), "Should not be able to release when active")

func test_enable_packet_release():
	# Test enabling packet release
	watch_signals(program_data_packet_manager)
	
	program_data_packet_manager.enable_packet_release()
	
	assert_true(program_data_packet_manager.can_release_packet, "Should enable release")
	assert_signal_emitted(program_data_packet_manager, "program_packet_ready", "Should emit ready signal")

func test_on_wave_started_wave_1():
	# Test wave 1 start handling
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.enemy_path = enemy_path
	watch_signals(program_data_packet_manager)
	
	program_data_packet_manager._on_wave_started(1)
	
	assert_true(program_data_packet_manager.is_packet_spawned, "Should spawn packet on wave 1")
	assert_true(program_data_packet_manager.can_release_packet, "Should enable release on wave 1")
	assert_signal_emitted(program_data_packet_manager, "program_packet_ready", "Should emit ready signal")

func test_on_wave_started_auto_release_wave():
	# Test auto-release wave handling
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.enemy_path = enemy_path
	program_data_packet_manager.spawn_program_data_packet()
	program_data_packet_manager.enable_packet_release()
	
	program_data_packet_manager._on_wave_started(ProgramDataPacketManager.AUTO_RELEASE_WAVE_NUMBER)
	
	assert_true(program_data_packet_manager.is_packet_active, "Should auto-release on final wave")

func test_on_program_packet_destroyed():
	# Test packet destruction handling
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	watch_signals(program_data_packet_manager)
	
	var mock_packet = ProgramDataPacket.new()
	add_child_autofree(mock_packet)
	
	program_data_packet_manager._on_program_packet_destroyed(mock_packet)
	
	assert_signal_emitted(program_data_packet_manager, "program_packet_destroyed", "Should emit destroyed signal")
	assert_true(mock_game_manager.game_over_triggered, "Should trigger game over")

func test_on_program_packet_reached_end():
	# Test packet reaching end handling
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	watch_signals(program_data_packet_manager)
	
	var mock_packet = ProgramDataPacket.new()
	add_child_autofree(mock_packet)
	
	program_data_packet_manager._on_program_packet_reached_end(mock_packet)
	
	assert_signal_emitted(program_data_packet_manager, "program_packet_reached_end", "Should emit reached_end signal")
	assert_true(mock_game_manager.game_won_triggered, "Should trigger game won")

func test_on_game_over():
	# Test game over handling
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.enemy_path = enemy_path
	program_data_packet_manager.create_packet_path()
	program_data_packet_manager.spawn_program_data_packet()
	program_data_packet_manager.release_program_data_packet()
	
	program_data_packet_manager._on_game_over()
	
	assert_false(program_data_packet_manager.program_data_packet.is_active, "Should stop packet movement")

func test_get_program_data_packet():
	# Test getting packet instance
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.enemy_path = enemy_path
	program_data_packet_manager.create_packet_path()
	program_data_packet_manager.spawn_program_data_packet()
	
	var packet = program_data_packet_manager.get_program_data_packet()
	
	assert_eq(packet, program_data_packet_manager.program_data_packet, "Should return current packet")

func test_is_packet_alive():
	# Test packet alive status
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	# No packet
	assert_false(program_data_packet_manager.is_packet_alive(), "Should not be alive when no packet")
	
	# Spawn packet
	var enemy_path: Array[Vector2] = [Vector2(0, 0), Vector2(100, 0)]
	mock_wave_manager.enemy_path = enemy_path
	program_data_packet_manager.create_packet_path()
	program_data_packet_manager.spawn_program_data_packet()
	
	assert_true(program_data_packet_manager.is_packet_alive(), "Should be alive when packet exists")
	
	# Kill packet
	program_data_packet_manager.program_data_packet.is_alive = false
	assert_false(program_data_packet_manager.is_packet_alive(), "Should not be alive when packet is dead")

func test_constants():
	# Test that constants are properly defined
	assert_eq(ProgramDataPacketManager.AUTO_RELEASE_WAVE_NUMBER, 10, "AUTO_RELEASE_WAVE_NUMBER should be 10")

func test_signal_connections():
	# Test that signals are properly connected during initialization
	program_data_packet_manager.initialize(mock_grid_manager, mock_game_manager, mock_wave_manager)
	
	# Test that initialization completed successfully
	assert_not_null(program_data_packet_manager.grid_manager, "Should have grid manager")
	assert_not_null(program_data_packet_manager.game_manager, "Should have game manager")
	assert_not_null(program_data_packet_manager.wave_manager, "Should have wave manager")

# No mock classes needed - using real classes 