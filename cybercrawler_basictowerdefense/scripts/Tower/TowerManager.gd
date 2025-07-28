extends TowerManagerInterface
class_name TowerManager

# Tower type constants are inherited from TowerManagerInterface

# Tower scenes
const TOWER_SCENE = preload("res://scenes/Tower.tscn")
const POWERFUL_TOWER_SCENE = preload("res://scenes/PowerfulTower.tscn")

# Tower management
var towers_placed: Array[Tower] = []

# References to other managers
var grid_manager: GridManagerInterface
var currency_manager: CurrencyManagerInterface
var wave_manager: WaveManagerInterface

func initialize(grid_mgr: GridManagerInterface, currency_mgr: CurrencyManagerInterface, wave_mgr: WaveManagerInterface) -> void:
	grid_manager = grid_mgr
	currency_manager = currency_mgr
	wave_manager = wave_mgr

func attempt_tower_placement(grid_pos: Vector2i, tower_type: String = BASIC_TOWER) -> bool:
	if not grid_manager or not currency_manager:
		print("TowerManager: Required managers not set!")
		return false
	
	# Validate grid position
	if not grid_manager.is_valid_grid_position(grid_pos):
		tower_placement_failed.emit("Invalid grid position")
		return false
	
	if grid_manager.is_grid_occupied(grid_pos):
		tower_placement_failed.emit("Grid position already occupied")
		return false
	
	# NEW: Prevent placement on blocked cells
	if grid_manager.is_grid_blocked(grid_pos):
		tower_placement_failed.emit("Grid position is blocked")
		return false
	
	# NEW: Prevent placement on ruined cells
	if grid_manager.is_grid_ruined(grid_pos):
		tower_placement_failed.emit("Grid position is ruined")
		return false
	
	# Check if position is on enemy path
	if grid_manager.is_on_enemy_path(grid_pos):
		tower_placement_failed.emit("Cannot place tower on enemy path")
		return false
	
	# Check currency for the specific tower type
	if not currency_manager.can_afford_tower_type(tower_type):
		tower_placement_failed.emit("Insufficient funds for " + tower_type + " tower")
		return false
	
	# All checks passed, place the tower
	return place_tower(grid_pos, tower_type)

# Backwards compatibility
func attempt_basic_tower_placement(grid_pos: Vector2i) -> bool:
	return attempt_tower_placement(grid_pos, BASIC_TOWER)

func place_tower(grid_pos: Vector2i, tower_type: String = BASIC_TOWER) -> bool:
	if not currency_manager:
		return false
	if not currency_manager.purchase_tower_type(tower_type):
		return false
	
	# Mark grid as occupied
	grid_manager.set_grid_occupied(grid_pos, true)
	
	# Create tower from appropriate scene
	var tower: Tower
	match tower_type:
		BASIC_TOWER:
			tower = TOWER_SCENE.instantiate()
		POWERFUL_TOWER:
			tower = POWERFUL_TOWER_SCENE.instantiate()
		_:
			print("TowerManager: Unknown tower type: ", tower_type)
			# Refund the purchase since we can't create the tower
			if tower_type == BASIC_TOWER:
				currency_manager.add_currency(currency_manager.get_basic_tower_cost())
			elif tower_type == POWERFUL_TOWER:
				currency_manager.add_currency(currency_manager.get_powerful_tower_cost())
			grid_manager.set_grid_occupied(grid_pos, false)
			return false
	
	var world_pos = grid_manager.grid_to_world(grid_pos)
	tower.global_position = world_pos
	tower.set_grid_position(grid_pos)
	
	# Add to containers
	towers_placed.append(tower)
	var grid_container = grid_manager.get_grid_container()
	if grid_container:
		grid_container.add_child(tower)
	else:
		add_child(tower)
	
	tower_placed.emit(grid_pos, tower_type)
	print("TowerManager: ", tower_type.capitalize(), " tower placed at grid position: ", grid_pos)
	return true

func get_enemies_for_towers() -> Array[Enemy]:
	if wave_manager:
		return wave_manager.get_enemies()
	return []

func get_towers() -> Array[Tower]:
	return towers_placed

func get_tower_at_position(grid_pos: Vector2i) -> Tower:
	for tower in towers_placed:
		if is_instance_valid(tower) and tower.get_grid_position() == grid_pos:
			return tower
	return null

func stop_all_towers():
	for tower in towers_placed:
		if is_instance_valid(tower):
			tower.set_process(false)  # Stop tower processing
			if tower.has_method("stop_attacking"):
				tower.stop_attacking()

func cleanup_all_towers():
	for tower in towers_placed.duplicate():
		if is_instance_valid(tower):
			tower.queue_free()
	towers_placed.clear()

func get_tower_count() -> int:
	return towers_placed.size()

# Get count of towers by type - addresses Copilot feedback for docstring
func get_tower_count_by_type(tower_type: String) -> int:
	var count = 0
	for tower in towers_placed:
		if is_instance_valid(tower):
			match tower_type:
				BASIC_TOWER:
					# Type-safe check: basic tower is Tower but not PowerfulTower
					if tower is Tower and not tower is PowerfulTower:
						count += 1
				POWERFUL_TOWER:
					if tower is PowerfulTower:
						count += 1
	return count

func remove_tower(tower: Node) -> void:
	if tower in towers_placed:
		towers_placed.erase(tower)
		# Could add logic here to mark grid position as unoccupied
		# if we need tower removal functionality 

# Get total power level of all placed towers (for alert system)
func get_total_power_level() -> float:
	var total_power = 0.0
	for tower in towers_placed:
		if is_instance_valid(tower):
			var damage = tower.damage
			var tower_range = tower.tower_range
			var attack_rate = tower.attack_rate
			
			# Use same power calculation as alert system
			var damage_score = min(1.0, damage / 5.0)
			var range_score = min(1.0, tower_range / 300.0)
			var attack_rate_score = min(1.0, attack_rate / 3.0)
			var power_level = (damage_score * 0.4) + (range_score * 0.3) + (attack_rate_score * 0.3)
			total_power += power_level
	
	return total_power 
