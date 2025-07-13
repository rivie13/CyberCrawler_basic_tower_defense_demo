extends Node2D
class_name TowerManager

# Signals
signal tower_placed(grid_pos: Vector2i)
signal tower_placement_failed(reason: String)

# Tower management
const TOWER_SCENE = preload("res://scenes/Tower.tscn")
var towers_placed: Array[Tower] = []

# References to other managers
var grid_manager: Node
var currency_manager: CurrencyManager
var wave_manager: WaveManager

func initialize(grid_mgr: Node, currency_mgr: CurrencyManager, wave_mgr: WaveManager):
	grid_manager = grid_mgr
	currency_manager = currency_mgr
	wave_manager = wave_mgr

func attempt_tower_placement(grid_pos: Vector2i) -> bool:
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
	
	# Check if position is on enemy path
	if grid_manager.is_on_enemy_path(grid_pos):
		tower_placement_failed.emit("Cannot place tower on enemy path")
		return false
	
	# Check currency
	if not currency_manager.can_afford_tower():
		tower_placement_failed.emit("Insufficient funds")
		return false
	
	# All checks passed, place the tower
	return place_tower(grid_pos)

func place_tower(grid_pos: Vector2i) -> bool:
	if not currency_manager.purchase_tower():
		return false
	
	# Mark grid as occupied
	grid_manager.set_grid_occupied(grid_pos, true)
	
	# Create tower from scene
	var tower = TOWER_SCENE.instantiate()
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
	
	tower_placed.emit(grid_pos)
	print("Tower placed at grid position: ", grid_pos)
	return true

func get_enemies_for_towers() -> Array[Enemy]:
	if wave_manager:
		return wave_manager.get_enemies()
	return []

func get_towers() -> Array[Tower]:
	return towers_placed

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

func remove_tower(tower: Tower):
	if tower in towers_placed:
		towers_placed.erase(tower)
		# Could add logic here to mark grid position as unoccupied
		# if we need tower removal functionality 