extends Node2D
class_name ProgramDataPacketManager

# Constants (addressing Copilot review)
const AUTO_RELEASE_WAVE_NUMBER: int = 10

# Signals for communication with other managers
signal program_packet_ready()
signal program_packet_destroyed(packet: ProgramDataPacket)
signal program_packet_reached_end(packet: ProgramDataPacket)

# Program data packet scene reference
const PROGRAM_DATA_PACKET_SCENE = preload("res://scenes/ProgramDataPacket.tscn")

# Program data packet state
var program_data_packet: ProgramDataPacket = null
var packet_path: Array[Vector2] = []
var is_packet_spawned: bool = false
var is_packet_active: bool = false
var can_release_packet: bool = false

# References to other managers
var grid_manager: GridManager
var game_manager: GameManager
var wave_manager: WaveManager

func initialize(grid_mgr: GridManager, game_mgr: GameManager, wave_mgr: WaveManager):
	grid_manager = grid_mgr
	game_manager = game_mgr
	wave_manager = wave_mgr
	
	# Connect to wave manager signals to know when final wave starts
	if wave_manager:
		wave_manager.wave_started.connect(_on_wave_started)
		wave_manager.all_waves_completed.connect(_on_all_waves_completed)
	
	# Connect to game manager signals
	if game_manager:
		game_manager.game_over_triggered.connect(_on_game_over)
		game_manager.game_won_triggered.connect(_on_game_won)
	
	# Generate the packet path (opposite direction from enemies)
	create_packet_path()

	# NEW: Listen for grid block changes
	if grid_manager.has_signal("grid_blocked_changed"):
		grid_manager.grid_blocked_changed.connect(_on_grid_blocked_changed)

func create_packet_path():
	"""Create the path for the program data packet (opposite direction from enemies)"""
	if not wave_manager or not grid_manager:
		print("ProgramDataPacketManager: Cannot create path - missing manager")
		return

	# Get the current enemy path grid positions from the wave manager's layout
	var grid_layout = wave_manager.grid_layout
	var selected_layout_type = wave_manager.selected_layout_type
	if not grid_layout or selected_layout_type == null:
		print("ProgramDataPacketManager: No grid layout or layout type available")
		return

	var grid_path = grid_layout.get_path_grid_positions(selected_layout_type)
	if grid_path.size() == 0:
		print("ProgramDataPacketManager: No grid path available")
		return

	# Reverse the path for the packet
	var reversed_path = grid_path.duplicate()
	reversed_path.reverse()

	# Convert grid path to world positions for packet movement
	packet_path = []
	for grid_pos in reversed_path:
		packet_path.append(grid_manager.grid_to_world(grid_pos))
	
	print("ProgramDataPacketManager: Created packet path with ", packet_path.size(), " points")

func spawn_program_data_packet():
	"""Spawn the program data packet at the starting position"""
	if is_packet_spawned:
		print("ProgramDataPacketManager: Packet already spawned")
		return
	
	if packet_path.size() == 0:
		print("ProgramDataPacketManager: Cannot spawn packet - no path available")
		return
	
	# Create the program data packet
	program_data_packet = PROGRAM_DATA_PACKET_SCENE.instantiate()
	program_data_packet.set_path(packet_path)
	
	# Position at start of path
	program_data_packet.global_position = packet_path[0]
	
	# Connect signals
	program_data_packet.program_packet_destroyed.connect(_on_program_packet_destroyed)
	program_data_packet.program_packet_reached_end.connect(_on_program_packet_reached_end)
	
	# Add to scene
	get_parent().add_child(program_data_packet)
	
	is_packet_spawned = true
	print("ProgramDataPacketManager: Program data packet spawned at ", packet_path[0])

func release_program_data_packet():
	"""Release the program data packet to start moving"""
	if not is_packet_spawned:
		print("ProgramDataPacketManager: Cannot release packet - not spawned")
		return
	
	if is_packet_active:
		print("ProgramDataPacketManager: Packet already active")
		return
	
	if program_data_packet:
		program_data_packet.activate()
		is_packet_active = true
		print("ProgramDataPacketManager: Program data packet released!")

func can_player_release_packet() -> bool:
	"""Check if the player can release the packet"""
	return can_release_packet and is_packet_spawned and not is_packet_active

func enable_packet_release():
	"""Enable the ability to release the packet"""
	can_release_packet = true
	program_packet_ready.emit()
	print("ProgramDataPacketManager: Packet release enabled!")

func _on_wave_started(wave_number: int):
	"""Handle wave start events"""
	print("ProgramDataPacketManager: Wave ", wave_number, " started")
	
	# Allow packet release from wave 1, but auto-release on final wave
	if wave_number == 1 and not is_packet_spawned:
		spawn_program_data_packet()
		enable_packet_release()
	elif wave_number == AUTO_RELEASE_WAVE_NUMBER and can_player_release_packet():
		# Auto-release on final wave if player hasn't done it yet
		release_program_data_packet()

func _on_all_waves_completed():
	"""Handle all waves completed event"""
	print("ProgramDataPacketManager: All waves completed")

func _on_program_packet_destroyed(packet: ProgramDataPacket):
	"""Handle program data packet destruction"""
	print("ProgramDataPacketManager: Program data packet destroyed!")
	program_packet_destroyed.emit(packet)
	
	# This is a loss condition - the packet was destroyed
	if game_manager:
		game_manager.trigger_game_over()

func _on_program_packet_reached_end(packet: ProgramDataPacket):
	"""Handle program data packet reaching the end"""
	print("ProgramDataPacketManager: Program data packet reached enemy network!")
	program_packet_reached_end.emit(packet)
	
	# This is a win condition - the packet reached the enemy network
	if game_manager:
		game_manager.trigger_game_won_packet()

func _on_game_over():
	"""Handle game over event"""
	# Stop packet movement
	if program_data_packet:
		program_data_packet.is_active = false

func _on_game_won():
	"""Handle game won event"""
	# Keep packet active for visual feedback
	pass

func get_program_data_packet() -> ProgramDataPacket:
	"""Get the current program data packet instance"""
	return program_data_packet

func is_packet_alive() -> bool:
	"""Check if the packet is alive"""
	return program_data_packet != null and program_data_packet.is_alive 

# NEW: Handle grid block changes
func _on_grid_blocked_changed(grid_pos: Vector2i, blocked: bool):
	create_packet_path()
	# Update the active program_data_packet with the new path
	if program_data_packet and is_packet_spawned and program_data_packet.is_alive:
		program_data_packet.set_path(packet_path) 
