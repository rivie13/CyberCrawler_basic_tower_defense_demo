extends RefCounted
class_name TargetingUtil

# Shared targeting utility for entities that need to prioritize program data packet
# This addresses code duplication between EnemyTower and RivalHacker

static func find_priority_target(global_position: Vector2, detection_range: float, main_controller) -> Node:
	"""Find the highest priority target within range, prioritizing program data packet"""
	
	if not main_controller:
		return null
	
	var current_target = null
	var closest_distance = detection_range
	
	# First priority: Program data packet (if active and alive)
	if main_controller.program_data_packet_manager:
		var program_packet = main_controller.program_data_packet_manager.get_program_data_packet()
		if program_packet and is_instance_valid(program_packet) and program_packet.is_alive and program_packet.is_active:
			var distance = global_position.distance_to(program_packet.global_position)
			if distance <= detection_range:
				current_target = program_packet
				closest_distance = distance
	
	return current_target

static func find_player_towers_in_range(global_position: Vector2, detection_range: float, main_controller) -> Node:
	"""Find the closest player tower within range"""
	
	if not main_controller or not main_controller.tower_manager:
		return null
	
	var current_target = null
	var closest_distance = detection_range
	
	var towers = main_controller.tower_manager.get_towers()
	for tower in towers:
		if not is_instance_valid(tower) or not tower.is_alive:
			continue
		
		var distance = global_position.distance_to(tower.global_position)
		if distance <= detection_range and distance < closest_distance:
			current_target = tower
			closest_distance = distance
	
	return current_target

static func find_best_target(global_position: Vector2, detection_range: float, main_controller) -> Node:
	"""Find the best target, prioritizing program data packet then player towers"""
	
	# First, try to find program data packet (highest priority)
	var priority_target = find_priority_target(global_position, detection_range, main_controller)
	if priority_target:
		return priority_target
	
	# If no program data packet found, look for player towers
	return find_player_towers_in_range(global_position, detection_range, main_controller)

static func is_target_in_range(attacker_position: Vector2, target: Node, detection_range: float) -> bool:
	"""Check if a target is within range and valid"""
	
	if not is_instance_valid(target):
		return false
	
	# Check if target has global_position property (Node2D and subclasses)
	if not "global_position" in target:
		return false
	
	# Check if target is alive (different methods for different types)
	if target is Tower and not target.is_alive:
		return false
	elif target is ProgramDataPacket and not target.is_alive:
		return false
	
	var distance_to_target = attacker_position.distance_to(target.global_position)
	return distance_to_target <= detection_range 