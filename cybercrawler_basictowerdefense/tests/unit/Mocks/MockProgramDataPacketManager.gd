extends ProgramDataPacketManagerInterface
class_name MockProgramDataPacketManager

# Mock state
var mock_program_data_packet: ProgramDataPacket = null
var mock_packet_path: Array[Vector2] = []
var mock_is_packet_spawned: bool = false
var mock_is_packet_active: bool = false
var mock_can_release_packet: bool = false
var mock_is_packet_alive: bool = true

# Mock dependencies
var mock_grid_manager: GridManagerInterface = null
var mock_game_manager: Node = null
var mock_wave_manager: WaveManagerInterface = null

# Mock signals
var mock_program_packet_ready_called: bool = false
var mock_program_packet_destroyed_called: bool = false
var mock_program_packet_reached_end_called: bool = false

func initialize(grid_mgr: GridManagerInterface, game_mgr: Node, wave_mgr: WaveManagerInterface) -> void:
	mock_grid_manager = grid_mgr
	mock_game_manager = game_mgr
	mock_wave_manager = wave_mgr

func create_packet_path() -> void:
	# Mock implementation - do nothing
	pass

func spawn_program_data_packet() -> void:
	mock_is_packet_spawned = true
	mock_program_data_packet = ProgramDataPacket.new()

func release_program_data_packet() -> void:
	if mock_is_packet_spawned and not mock_is_packet_active:
		mock_is_packet_active = true

func can_player_release_packet() -> bool:
	return mock_can_release_packet and mock_is_packet_spawned and not mock_is_packet_active

func enable_packet_release() -> void:
	mock_can_release_packet = true
	mock_program_packet_ready_called = true
	program_packet_ready.emit()

func get_program_data_packet() -> ProgramDataPacket:
	return mock_program_data_packet

func is_packet_alive() -> bool:
	return mock_is_packet_alive

# Mock helper methods for testing
func set_mock_packet_alive(alive: bool):
	mock_is_packet_alive = alive

func set_mock_can_release_packet(can_release: bool):
	mock_can_release_packet = can_release

func set_mock_is_packet_spawned(spawned: bool):
	mock_is_packet_spawned = spawned

func set_mock_is_packet_active(active: bool):
	mock_is_packet_active = active

func reset_mock_signals():
	mock_program_packet_ready_called = false
	mock_program_packet_destroyed_called = false
	mock_program_packet_reached_end_called = false 