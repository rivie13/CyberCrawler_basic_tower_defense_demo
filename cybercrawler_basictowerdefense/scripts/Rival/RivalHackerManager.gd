extends Node2D
class_name RivalHackerManager

# Enemy tower scene reference
const ENEMY_TOWER_SCENE = preload("res://scenes/EnemyTower.tscn")

# Signals
signal enemy_tower_placed(grid_pos: Vector2i)
signal rival_hacker_activated()

# Alert system
var alert_system: RivalAlertSystem

# AI behavior configuration
@export var placement_interval: float = 3.0  # Time between tower placements
@export var max_enemy_towers: int = 10
# Remove activation_delay since we're using alert-based activation only

# State management
var is_active: bool = false
var placement_timer: Timer
# Remove activation_timer since we're using alert-based activation only
var enemy_towers_placed: Array = []

# AI strategy parameters
var preferred_grid_zones: Array[Vector2i] = []  # Areas AI prefers to place towers
var player_threat_level: int = 0  # Tracks how threatening player is

# References to other managers
var grid_manager: GridManager
var currency_manager: CurrencyManager
var tower_manager: TowerManager
var wave_manager: WaveManager

func _ready():
	setup_timers()

func setup_timers():
	# Timer for tower placement attempts
	placement_timer = Timer.new()
	placement_timer.wait_time = placement_interval
	placement_timer.timeout.connect(_on_placement_timer_timeout)
	placement_timer.autostart = false
	add_child(placement_timer)
	
	# Timer for initial activation delay
	# Remove activation_timer = Timer.new()
	# Remove activation_timer.wait_time = activation_delay
	# Remove activation_timer.timeout.connect(_on_activation_timer_timeout)
	# Remove activation_timer.one_shot = true
	# add_child(activation_timer)

func initialize(grid_mgr: GridManager, currency_mgr: CurrencyManager, tower_mgr: TowerManager, wave_mgr: WaveManager):
	grid_manager = grid_mgr
	currency_manager = currency_mgr
	tower_manager = tower_mgr
	wave_manager = wave_mgr
	
	# Set up preferred zones (enemy side of the grid)
	setup_preferred_zones()
	
	# Initialize alert system
	setup_alert_system()
	
	# Connect to tower manager to monitor player actions
	if tower_manager:
		tower_manager.tower_placed.connect(_on_player_tower_placed)

func setup_preferred_zones():
	# Define zones where the AI prefers to place towers
	# For now, focus on the right side of the grid (enemy territory)
	preferred_grid_zones.clear()
	
	if grid_manager:
		var grid_size = grid_manager.get_grid_size()
		# Focus on right half of the grid
		for x in range(grid_size.x / 2, grid_size.x):
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
	# Remove activation_timer.start()
	
	# Start alert system monitoring immediately
	if alert_system:
		alert_system.start_monitoring()
	
	print("RivalHacker: Alert system monitoring started - waiting for alerts to trigger tower placement")

func _on_placement_timer_timeout():
	if not is_active:
		return
	
	# Check if we've reached maximum towers
	if enemy_towers_placed.size() >= max_enemy_towers:
		return
	
	# Analyze situation and attempt tower placement
	analyze_player_threat()
	attempt_enemy_tower_placement()

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

func _on_player_tower_placed(grid_pos: Vector2i):
	# React to player tower placement
	print("RivalHacker: Player placed tower at ", grid_pos, " - threat level increased!")
	player_threat_level += 1
	
	# Notify alert system about tower placement
	if alert_system and alert_system.is_monitoring:
		# Get the actual tower object from the tower manager
		var towers = tower_manager.get_towers()
		if towers.size() > 0:
			var latest_tower = towers[-1]  # Get the most recently placed tower
			alert_system.on_player_tower_placed(grid_pos, latest_tower)
	
	# Remove early activation logic since we only want alert-based activation
	# if not is_active and player_threat_level >= 3:
	#	print("RivalHacker: Player threat detected! Activating early...")
	#	# Remove activation_timer.stop()
	#	_on_activation_timer_timeout()

func deactivate():
	is_active = false
	placement_timer.stop()
	# Remove activation_timer.stop()

func get_enemy_towers() -> Array:
	return enemy_towers_placed

func stop_all_activity():
	# Stop all AI activity (for game over scenarios)
	deactivate()

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
		rival_hacker_activated.emit()
		print("RivalHacker: FIRST ALERT TRIGGERED - Now active and placing enemy towers!")
	
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
