class_name ProgramDataPacketManagerInterface
extends Node

"""
Interface for program data packet management systems.
Defines the contract that all program data packet managers must implement.
"""

# Constants
const AUTO_RELEASE_WAVE_NUMBER: int = 10

# Signals for communication with other managers
signal program_packet_ready()
signal program_packet_destroyed(packet: ProgramDataPacket)
signal program_packet_reached_end(packet: ProgramDataPacket)

# Abstract methods that must be implemented
func initialize(grid_mgr: GridManagerInterface, game_mgr: GameManagerInterface, wave_mgr: WaveManagerInterface) -> void:
	push_error("ProgramDataPacketManagerInterface.initialize() must be overridden")

func create_packet_path() -> void:
	push_error("ProgramDataPacketManagerInterface.create_packet_path() must be overridden")

func spawn_program_data_packet() -> void:
	push_error("ProgramDataPacketManagerInterface.spawn_program_data_packet() must be overridden")

func release_program_data_packet() -> void:
	push_error("ProgramDataPacketManagerInterface.release_program_data_packet() must be overridden")

func can_player_release_packet() -> bool:
	push_error("ProgramDataPacketManagerInterface.can_player_release_packet() must be overridden")
	return false

func enable_packet_release() -> void:
	push_error("ProgramDataPacketManagerInterface.enable_packet_release() must be overridden")

func get_program_data_packet() -> ProgramDataPacket:
	push_error("ProgramDataPacketManagerInterface.get_program_data_packet() must be overridden")
	return null

func is_packet_alive() -> bool:
	push_error("ProgramDataPacketManagerInterface.is_packet_alive() must be overridden")
	return false 