extends Node2D
class_name RivalHackerManager

# Scene references
const ENEMY_TOWER_SCENE = preload("res://scenes/EnemyTower.tscn")
const RIVAL_HACKER_SCENE = preload("res://scenes/RivalHacker.tscn")

# Tower type constants - consistent with TowerManager  
const POWERFUL_TOWER = "powerful"

# Signals
signal enemy_tower_placed(grid_pos: Vector2i)
signal rival_hacker_activated()

# Alert system
var alert_system: RivalAlertSystem

# AI behavior configuration
@export var placement_interval: float = 3.0  # Time between tower placements
@export var max_enemy_towers: int = 10
@export var hacker_spawn_interval: float = 8.0  # Time between RivalHacker spawns
@export var max_rival_hackers: int = 3  # Maximum RivalHackers alive at once
# Remove activation_delay since we're using alert-based activation only

# State management
var is_active: bool = false
var placement_timer: Timer
var hacker_spawn_timer: Timer
# Remove activation_timer since we're using alert-based activation only
var enemy_towers_placed: Array = []
var rival_hackers_active: Array[RivalHacker] = []

# Add a timer for path blocking
var path_block_timer: Timer
@export var path_block_interval: float = 6.0  # Time between path blocks

# Add a timer for non-path blocking (tower placement blocking)
var non_path_block_timer: Timer
@export var non_path_block_interval: float = 10.0

# AI strategy parameters
var preferred_grid_zones: Array[Vector2i] = []  # Areas AI prefers to place towers
var player_threat_level: int = 0  # Tracks how threatening player is

# References to other managers
var grid_manager: GridManager
var currency_manager: CurrencyManager
var tower_manager: TowerManager
var wave_manager: WaveManager

# Detour points for adversarial path repair
var detour_points: Array[Vector2i] = []

# Weights for adversarial pathfinding
var cell_weights: Dictionary = {}

# Reference to ProgramDataPacketManager
var program_data_packet_manager: Node = null

func _ready():
	setup_timers()

func setup_timers():
	# Timer for tower placement attempts
	placement_timer = Timer.new()
	placement_timer.wait_time = placement_interval
	placement_timer.timeout.connect(_on_placement_timer_timeout)
	placement_timer.autostart = false
	add_child(placement_timer)
	
	# Timer for RivalHacker spawning
	hacker_spawn_timer = Timer.new()
	hacker_spawn_timer.wait_time = hacker_spawn_interval
	hacker_spawn_timer.timeout.connect(_on_hacker_spawn_timer_timeout)
	hacker_spawn_timer.autostart = false
	add_child(hacker_spawn_timer)
	
	# Timer for path blocking
	path_block_timer = Timer.new()
	path_block_timer.wait_time = path_block_interval
	path_block_timer.timeout.connect(_on_path_block_timer_timeout)
	path_block_timer.autostart = false
	add_child(path_block_timer)

	# Timer for non-path blocking
	non_path_block_timer = Timer.new()
	non_path_block_timer.wait_time = non_path_block_interval
	non_path_block_timer.timeout.connect(_on_non_path_block_timer_timeout)
	non_path_block_timer.autostart = false
	add_child(non_path_block_timer)
	
	# Timer for initial activation delay - removed (now using alert-based activation)

func initialize(grid_mgr: GridManager, currency_mgr: CurrencyManager, tower_mgr: TowerManager, wave_mgr: WaveManager):
	grid_manager = grid_mgr
	currency_manager = currency_mgr
	tower_manager = tower_mgr
	wave_manager = wave_mgr
	# Store reference to ProgramDataPacketManager if available
	if has_node("../ProgramPacket/ProgramDataPacketManager"):
		program_data_packet_manager = get_node("../ProgramPacket/ProgramDataPacketManager")
	setup_preferred_zones()
	setup_alert_system()
	if tower_manager:
		tower_manager.tower_placed.connect(_on_player_tower_placed)
	setup_detour_points()
	setup_cell_weights()

func setup_preferred_zones():
	# Define zones where the AI prefers to place towers
	# For now, focus on the right side of the grid (enemy territory)
	preferred_grid_zones.clear()
	
	if grid_manager:
		var grid_size = grid_manager.get_grid_size()
		# Focus on right half of the grid
		for x in range(int(grid_size.x / 2), grid_size.x):
			for y in range(grid_size.y):
				preferred_grid_zones.append(Vector2i(x, y))

func setup_alert_system():
	# Create and initialize the alert system
	alert_system = RivalAlertSystem.new()
	alert_system.initialize(grid_manager)
	add_child(alert_system)
	
	# Connect alert system signals
	alert_system.alert_triggered.connect(_on_alert_triggered)
	
	# Start monitoring when the rival hacker is activated
	print("RivalHackerManager: Alert system initialized")

func activate():
	if is_active:
		return
	print("RivalHacker: Starting activation sequence...")
	if alert_system:
		alert_system.start_monitoring()
	print("RivalHacker: Alert system monitoring started - waiting for alerts to trigger tower placement")
	# Removed: Do not start path_block_timer or non_path_block_timer here

func _on_placement_timer_timeout():
	if not is_active:
		return
	
	# Check if we've reached maximum towers
	if enemy_towers_placed.size() >= max_enemy_towers:
		return
	
	# Analyze situation and attempt tower placement
	analyze_player_threat()
	attempt_enemy_tower_placement()

func _on_hacker_spawn_timer_timeout():
	if not is_active:
		return
	
	# Check if we've reached maximum RivalHackers
	if rival_hackers_active.size() >= max_rival_hackers:
		return
	
	# Attempt to spawn a RivalHacker
	attempt_rival_hacker_spawn()

func analyze_player_threat():
	# Calculate threat level based on player towers
	if not tower_manager:
		return
	
	var player_towers = tower_manager.get_towers()
	player_threat_level = player_towers.size()
	
	# Adjust placement frequency based on threat
	if player_threat_level > 3:
		placement_timer.wait_time = max(1.0, placement_interval - 1.0)  # Place faster
	else:
		placement_timer.wait_time = placement_interval

func attempt_enemy_tower_placement():
	var target_position = find_optimal_tower_position()
	
	if target_position != Vector2i(-1, -1):
		place_enemy_tower(target_position)

func find_optimal_tower_position() -> Vector2i:
	# Strategy: Place towers in preferred zones that aren't occupied
	var available_positions: Array[Vector2i] = []
	
	for grid_pos in preferred_grid_zones:
		if is_valid_enemy_tower_position(grid_pos):
			available_positions.append(grid_pos)
	
	if available_positions.size() == 0:
		return Vector2i(-1, -1)
	
	# For now, pick a random valid position
	# TODO: Add more sophisticated AI strategy
	var random_index = randi() % available_positions.size()
	return available_positions[random_index]

func is_valid_enemy_tower_position(grid_pos: Vector2i) -> bool:
	if not grid_manager:
		return false
	
	# Check basic grid validity
	if not grid_manager.is_valid_grid_position(grid_pos):
		return false
	
	# Check if position is occupied
	if grid_manager.is_grid_occupied(grid_pos):
		return false
	
	# Check if position is on enemy path
	if grid_manager.is_on_enemy_path(grid_pos):
		return false
	
	return true

func place_enemy_tower(grid_pos: Vector2i) -> bool:
	if not grid_manager:
		return false
	
	# Mark grid as occupied
	grid_manager.set_grid_occupied(grid_pos, true)
	
	# Create enemy tower instance using scene instantiation
	var enemy_tower = ENEMY_TOWER_SCENE.instantiate()
	var world_pos = grid_manager.grid_to_world(grid_pos)
	enemy_tower.global_position = world_pos
	enemy_tower.set_grid_position(grid_pos)
	
	# Connect destruction signal
	enemy_tower.enemy_tower_destroyed.connect(_on_enemy_tower_destroyed)
	
	# Add to containers
	enemy_towers_placed.append(enemy_tower)
	var grid_container = grid_manager.get_grid_container()
	if grid_container:
		grid_container.add_child(enemy_tower)
	else:
		add_child(enemy_tower)
	
	print("RivalHacker: Enemy tower placed at ", grid_pos)
	enemy_tower_placed.emit(grid_pos)
	return true

func attempt_rival_hacker_spawn():
	var spawn_position = find_rival_hacker_spawn_position()
	
	if spawn_position != Vector2.ZERO:
		spawn_rival_hacker(spawn_position)

func find_rival_hacker_spawn_position() -> Vector2:
	if not grid_manager:
		return Vector2.ZERO
	
	# Spawn RivalHackers on the enemy side (right side) of the grid
	var grid_size = grid_manager.get_grid_size()
	var spawn_attempts = 10  # Try multiple positions
	
	for i in range(spawn_attempts):
		# Random position on enemy side (right 1/3 of the grid)
		var spawn_x = randi_range(int(grid_size.x * 0.67), grid_size.x - 1)
		var spawn_y = randi_range(0, grid_size.y - 1)
		var grid_pos = Vector2i(spawn_x, spawn_y)
		
		# Check if position is valid (not occupied, not on path)
		if grid_manager.is_valid_grid_position(grid_pos) and not grid_manager.is_grid_occupied(grid_pos) and not grid_manager.is_on_enemy_path(grid_pos):
			return grid_manager.grid_to_world(grid_pos)
	
	# Fallback: spawn at edge if no good position found
	var edge_x = grid_size.x - 1
	var edge_y = randi_range(1, grid_size.y - 2)
	return grid_manager.grid_to_world(Vector2i(edge_x, edge_y))

func spawn_rival_hacker(world_position: Vector2) -> bool:
	# Create RivalHacker instance
	var rival_hacker = RIVAL_HACKER_SCENE.instantiate()
	rival_hacker.global_position = world_position
	
	# Connect signals
	rival_hacker.rival_hacker_destroyed.connect(_on_rival_hacker_destroyed)
	rival_hacker.tower_attacked.connect(_on_rival_hacker_tower_attacked)
	
	# Add to tracking and scene
	rival_hackers_active.append(rival_hacker)
	var grid_container = grid_manager.get_grid_container()
	if grid_container:
		grid_container.add_child(rival_hacker)
	else:
		add_child(rival_hacker)
	
	print("RivalHacker: Special enemy RivalHacker spawned at ", world_position)
	return true

func _on_rival_hacker_destroyed(hacker: RivalHacker):
	# Remove from tracking array
	rival_hackers_active.erase(hacker)
	print("RivalHacker: Special enemy destroyed, ", rival_hackers_active.size(), " hackers remaining")

func _on_rival_hacker_tower_attacked(_tower: Tower, damage: int):
	# RivalHacker successfully attacked a player tower
	print("RivalHacker: Player tower attacked for ", damage, " damage!")
	# Could add additional logic here for AI learning or escalation

func get_rival_hackers() -> Array[RivalHacker]:
	# Clean up any invalid hackers from our array
	var valid_hackers: Array[RivalHacker] = []
	for hacker in rival_hackers_active:
		if is_instance_valid(hacker) and hacker.is_alive:
			valid_hackers.append(hacker)
	rival_hackers_active = valid_hackers
	return rival_hackers_active

func _on_player_tower_placed(grid_pos: Vector2i, tower_type: String):
	# React to player tower placement
	print("RivalHacker: Player placed %s tower at %s - threat level increased!" % [tower_type, grid_pos])
	
	# Increase threat level more for powerful towers
	if tower_type == POWERFUL_TOWER:
		player_threat_level += 3  # Powerful towers are much more threatening
		print("RivalHacker: POWERFUL TOWER DETECTED - Significant threat increase!")
	else:
		player_threat_level += 1  # Basic towers get normal threat increase
	
	# Notify alert system about tower placement
	if alert_system and alert_system.is_monitoring:
		# Get the actual tower object from the tower manager
		var towers = tower_manager.get_towers()
		if towers.size() > 0:
			var latest_tower = towers[towers.size() - 1]  # Get the most recently placed tower
			alert_system.on_player_tower_placed(grid_pos, latest_tower)
	
	# Update placement frequency based on current threat level
	analyze_player_threat()

func deactivate():
	is_active = false
	placement_timer.stop()
	hacker_spawn_timer.stop()

func get_enemy_towers() -> Array:
	return enemy_towers_placed

func stop_all_activity():
	# Stop all AI activity (for game over scenarios)
	deactivate()
	
	# Stop all RivalHackers
	for hacker in rival_hackers_active:
		if is_instance_valid(hacker):
			hacker.is_alive = false

func _on_enemy_tower_destroyed(enemy_tower: EnemyTower):
	# Remove from our tracking array
	enemy_towers_placed.erase(enemy_tower)
	print("RivalHacker: Enemy tower destroyed, ", enemy_towers_placed.size(), " towers remaining") 

func _on_alert_triggered(alert_type: String, severity: float):
	# Respond to alerts from the alert system
	print("RivalHacker: ALERT DETECTED - ", alert_type, " (severity: ", severity, ")")
	
	# If this is the first alert and we're not active yet, activate now
	if not is_active:
		is_active = true
		placement_timer.start()
		hacker_spawn_timer.start()
		# Start path and non-path block timers ONLY after alert triggers
		if path_block_timer:
			path_block_timer.start()
		if non_path_block_timer:
			non_path_block_timer.start()
		rival_hacker_activated.emit()
		print("RivalHacker: FIRST ALERT TRIGGERED - Now active and placing enemy towers and spawning hackers!")
	
	# Adjust AI behavior based on alert type and severity
	match alert_type:
		"TOWERS_TOO_CLOSE_TO_EXIT":
			respond_to_exit_proximity_alert(severity)
		"TOO_MANY_TOWERS_AT_ONCE":
			respond_to_burst_placement_alert(severity)
		"TOO_MANY_POWERFUL_TOWERS":
			respond_to_powerful_tower_alert(severity)
		"HONEYPOT_TRAP_DETECTED":
			respond_to_honeypot_alert(severity)
		"TRAP_STRATEGY_DETECTED":
			respond_to_trap_strategy_alert(severity)
		"RUSH_STRATEGY_DETECTED":
			respond_to_rush_strategy_alert(severity)
		"MULTI_FACTOR_THREAT", "CRITICAL_COMBINATION_THREAT", "SOPHISTICATED_THREAT":
			respond_to_critical_alert(alert_type, severity)
		_:
			# Default response
			increase_aggression_level(severity * 0.5)

func respond_to_exit_proximity_alert(severity: float):
	# Player is placing towers near exit - increase placement speed and focus on disruption
	placement_timer.wait_time = max(0.8, placement_interval - severity * 1.5)
	print("RivalHacker: Responding to exit proximity threat - increasing placement speed")

func respond_to_burst_placement_alert(severity: float):
	# Player is placing many towers quickly - match their pace
	placement_timer.wait_time = max(0.5, placement_interval - severity * 2.0)
	print("RivalHacker: Responding to burst placement - matching player pace")

func respond_to_powerful_tower_alert(severity: float):
	# Player has powerful towers - prioritize counter-placement
	# Increase max enemy towers and placement speed
	max_enemy_towers = min(15, max_enemy_towers + int(severity * 3))
	placement_timer.wait_time = max(0.7, placement_interval - severity * 1.0)
	print("RivalHacker: Responding to powerful towers - increasing tower limit and speed")

func respond_to_honeypot_alert(severity: float):
	# Player fell for honeypot trap - this is good for us, be more aggressive
	placement_timer.wait_time = max(0.5, placement_interval - severity * 1.8)
	print("RivalHacker: Player triggered honeypot - increasing aggression")

func respond_to_trap_strategy_alert(severity: float):
	# Player is using trap strategy (honeypot + burst placement) - counter with strategic placement
	placement_timer.wait_time = max(0.6, placement_interval - severity * 1.5)
	print("RivalHacker: Trap strategy detected - deploying counter-measures")

func respond_to_rush_strategy_alert(severity: float):
	# Player is using rush strategy (proximity + burst placement) - respond with defensive positioning
	placement_timer.wait_time = max(0.4, placement_interval - severity * 2.0)
	print("RivalHacker: Rush strategy detected - activating defensive protocols")

func respond_to_critical_alert(alert_type: String, severity: float):
	# Critical threat detected - maximum response
	placement_timer.wait_time = max(0.3, placement_interval - severity * 2.5)
	max_enemy_towers = min(20, max_enemy_towers + int(severity * 5))
	print("RivalHacker: CRITICAL ALERT (", alert_type, ") - maximum response activated!")

func increase_aggression_level(amount: float):
	# General aggression increase
	var speed_reduction = amount * 1.2
	placement_timer.wait_time = max(0.5, placement_timer.wait_time - speed_reduction)
	print("RivalHacker: Increasing aggression level by ", amount)

# Add a method to set up detour points (corners, strategic points)
func setup_detour_points():
	if not grid_manager:
		return
	detour_points.clear()
	var grid_size = grid_manager.get_grid_size()
	# Example: corners and center
	detour_points.append(Vector2i(0, 0))
	detour_points.append(Vector2i(grid_size.x - 1, 0))
	detour_points.append(Vector2i(0, grid_size.y - 1))
	detour_points.append(Vector2i(grid_size.x - 1, grid_size.y - 1))
	detour_points.append(Vector2i(int(grid_size.x / 2), int(grid_size.y / 2)))
	# Add more as needed (e.g., near enemy towers)

# Add a method to set up cell weights (e.g., near enemy towers)
func setup_cell_weights():
	cell_weights.clear()
	if not grid_manager or not tower_manager:
		return
	var towers = tower_manager.get_towers()
	for tower in towers:
		if is_instance_valid(tower):
			var grid_pos = tower.get_grid_position()
			cell_weights[grid_pos] = 10  # High cost for pathfinding
	# Add more logic for other "bad" cells if needed

# Weighted pathfinding (adversarial): returns a path from start to end, preferring high-cost cells
func find_weighted_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var open_set = [start]
	var came_from = {}
	var g_score = {}
	var f_score = {}
	g_score[start] = 0
	f_score[start] = start.distance_to(end)
	while open_set.size() > 0:
		open_set.sort_custom(func(a, b): return f_score.get(a, INF) < f_score.get(b, INF))
		var current = open_set[0]
		if current == end:
			var path: Array[Vector2i] = [current]
			while current in came_from:
				current = came_from[current]
				path.insert(0, current)
			return path
		open_set.remove_at(0)
		for neighbor in grid_manager.get_neighbors(current):
			if grid_manager.is_grid_blocked(neighbor) or grid_manager.is_grid_occupied(neighbor):
				continue
			var weight = cell_weights.get(neighbor, 1)
			var tentative_g = g_score.get(current, INF) + weight
			if tentative_g < g_score.get(neighbor, INF):
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + neighbor.distance_to(end)
				if neighbor not in open_set:
					open_set.append(neighbor)
	return [] as Array[Vector2i]

# Path repair logic: choose strategy and update path
func repair_path_after_block():
	if not grid_manager or not wave_manager:
		return
	var path_positions = grid_manager.path_grid_positions
	if path_positions.size() <= 2:
		return
	var start = path_positions[0]
	var end = path_positions[path_positions.size() - 1]
	var block_indices = []
	for i in range(path_positions.size()):
		if grid_manager.is_grid_blocked(path_positions[i]):
			block_indices.append(i)
	if block_indices.size() == 0:
		return
	# For now, only handle single block for simplicity
	var block_idx = block_indices[0]
	# Guard against invalid slice bounds
	if block_idx <= 0 or block_idx >= path_positions.size() - 1:
		return
	var seg1 = path_positions.slice(0, block_idx)
	var seg2 = path_positions.slice(block_idx + 1, path_positions.size())

	# Corridor-limited detour logic
	var max_corridor_width = 3
	var corridor_width = 1
	var connector: Array[Vector2i] = []
	while corridor_width <= max_corridor_width and connector.size() == 0:
		var corridor_cells = get_corridor_cells_around_path(path_positions, corridor_width)
		connector = find_corridor_limited_path(seg1[seg1.size() - 1], seg2[0], corridor_cells)
		corridor_width += 1

	if connector.size() > 0:
		var new_path = seg1 + connector + seg2
		grid_manager.set_path_positions(new_path)
		wave_manager.enemy_path = []
		for grid_pos in new_path:
			wave_manager.enemy_path.append(grid_manager.grid_to_world(grid_pos))
		# Update packet path as well
		if program_data_packet_manager:
			program_data_packet_manager.create_packet_path()
		print("RivalHacker: Path repaired using corridor-limited detour (width: ", corridor_width-1, ")")
	else:
		print("RivalHacker: Failed to repair path within corridor limits!")

# Helper: Get all grid cells within 'width' cells of any cell in the path
func get_corridor_cells_around_path(path: Array[Vector2i], width: int) -> Array[Vector2i]:
	var corridor: Array[Vector2i] = []
	var grid_size = grid_manager.get_grid_size()
	var seen = {}
	for path_cell in path:
		for dx in range(-width, width+1):
			for dy in range(-width, width+1):
				var cell = path_cell + Vector2i(dx, dy)
				if grid_manager.is_valid_grid_position(cell) and not seen.has(cell):
					corridor.append(cell)
					seen[cell] = true
	return corridor

# Helper: Find a path between two points, only using allowed_cells
func find_corridor_limited_path(start: Vector2i, end: Vector2i, allowed_cells: Array[Vector2i]) -> Array[Vector2i]:
	var allowed_set = {}
	for cell in allowed_cells:
		allowed_set[cell] = true
	var open_set = [start]
	var came_from = {}
	var g_score = {}
	var f_score = {}
	g_score[start] = 0
	f_score[start] = start.distance_to(end)
	while open_set.size() > 0:
		open_set.sort_custom(func(a, b): return f_score.get(a, INF) < f_score.get(b, INF))
		var current = open_set[0]
		if current == end:
			var path: Array[Vector2i] = [current]
			while current in came_from:
				current = came_from[current]
				path.insert(0, current)
			return path
		open_set.remove_at(0)
		for neighbor in grid_manager.get_neighbors(current):
			if not allowed_set.has(neighbor):
				continue
			if grid_manager.is_grid_blocked(neighbor) or grid_manager.is_grid_occupied(neighbor):
				continue
			var tentative_g = g_score.get(current, INF) + 1
			if tentative_g < g_score.get(neighbor, INF):
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + neighbor.distance_to(end)
				if neighbor not in open_set:
					open_set.append(neighbor)
	return [] as Array[Vector2i]

# Call repair_path_after_block after blocking a path cell
func _on_path_block_timer_timeout():
	if not grid_manager:
		return
	var path_positions = grid_manager.path_grid_positions
	if path_positions.size() <= 2:
		return  # Not enough path to block
	# Exclude start/end
	var blockable = path_positions.slice(1, path_positions.size() - 2)
	if blockable.size() == 0:
		return
	var idx = randi() % blockable.size()
	var grid_pos = blockable[idx]
	if not grid_manager.is_grid_blocked(grid_pos):
		grid_manager.set_grid_blocked(grid_pos, true)
	print("RivalHacker: Blocked path cell at ", grid_pos)
	# Repair the path using one of the strategies
	repair_path_after_block()
	# Restart timer
	path_block_timer.start()

# Timer callback: block a random non-path cell (for tower placement only)
func _on_non_path_block_timer_timeout():
	if not grid_manager:
		return
	var grid_size = grid_manager.get_grid_size()
	var candidates: Array[Vector2i] = []
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var pos = Vector2i(x, y)
			if not grid_manager.is_on_enemy_path(pos) and not grid_manager.is_grid_occupied(pos) and not grid_manager.is_grid_blocked(pos):
				candidates.append(pos)
	if candidates.size() == 0:
		return
	var idx = randi() % candidates.size()
	var grid_pos = candidates[idx]
	grid_manager.set_grid_blocked(grid_pos, true)
	print("RivalHacker: Blocked non-path cell at ", grid_pos)
	non_path_block_timer.start()
