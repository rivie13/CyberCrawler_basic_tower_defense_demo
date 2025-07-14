extends Node2D
class_name RivalHackerManager

# Signals
signal enemy_tower_placed(grid_pos: Vector2i)
signal rival_hacker_activated()

# AI behavior configuration
@export var placement_interval: float = 3.0  # Time between tower placements
@export var max_enemy_towers: int = 10
@export var activation_delay: float = 5.0  # Delay before AI starts placing towers

# State management
var is_active: bool = false
var placement_timer: Timer
var activation_timer: Timer
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
	activation_timer = Timer.new()
	activation_timer.wait_time = activation_delay
	activation_timer.timeout.connect(_on_activation_timer_timeout)
	activation_timer.one_shot = true
	add_child(activation_timer)

func initialize(grid_mgr: GridManager, currency_mgr: CurrencyManager, tower_mgr: TowerManager, wave_mgr: WaveManager):
	grid_manager = grid_mgr
	currency_manager = currency_mgr
	tower_manager = tower_mgr
	wave_manager = wave_mgr
	
	# Set up preferred zones (enemy side of the grid)
	setup_preferred_zones()
	
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

func activate():
	if is_active:
		return
	
	print("RivalHacker: Starting activation sequence...")
	activation_timer.start()

func _on_activation_timer_timeout():
	is_active = true
	placement_timer.start()
	rival_hacker_activated.emit()
	print("RivalHacker: Now active and placing enemy towers!")

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
	
	# Create enemy tower instance
	var enemy_tower = EnemyTower.new()
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
	
	# If player is getting aggressive, activate rival hacker early
	if not is_active and player_threat_level >= 3:
		print("RivalHacker: Player threat detected! Activating early...")
		activation_timer.stop()
		_on_activation_timer_timeout()

func deactivate():
	is_active = false
	placement_timer.stop()
	activation_timer.stop()

func get_enemy_towers() -> Array:
	return enemy_towers_placed

func stop_all_activity():
	# Stop all AI activity (for game over scenarios)
	deactivate()

func _on_enemy_tower_destroyed(enemy_tower: EnemyTower):
	# Remove from our tracking array
	enemy_towers_placed.erase(enemy_tower)
	print("RivalHacker: Enemy tower destroyed, ", enemy_towers_placed.size(), " towers remaining") 