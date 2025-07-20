extends Node
class_name FreezeMineManager

# Manager references
var grid_manager: GridManager
var currency_manager: CurrencyManager

# Freeze mine tracking
var freeze_mines: Array[FreezeMine] = []

# Freeze mine scene
const FREEZE_MINE_SCENE = preload("res://scenes/FreezeMine.tscn")

# Signals
signal freeze_mine_placed(mine: FreezeMine)
signal freeze_mine_placement_failed(reason: String)
signal freeze_mine_triggered(mine: FreezeMine)
signal freeze_mine_depleted(mine: FreezeMine)

func initialize(grid_mgr: GridManager, currency_mgr: CurrencyManager):
	grid_manager = grid_mgr
	currency_manager = currency_mgr

func can_place_freeze_mine_at(grid_pos: Vector2i) -> bool:
	# Check if position is valid for freeze mine placement
	if not grid_manager.is_valid_grid_position(grid_pos):
		return false
	if grid_manager.is_grid_occupied(grid_pos):
		return false
	if grid_manager.is_on_enemy_path(grid_pos):
		return false
	return true

func place_freeze_mine(grid_pos: Vector2i) -> bool:
	var freeze_mine_cost = 15  # Cost for freeze mine
	
	# Check if player has enough currency
	if currency_manager.get_currency() < freeze_mine_cost:
		freeze_mine_placement_failed.emit("Not enough currency for freeze mine")
		return false
	
	# Check if position is valid
	if not can_place_freeze_mine_at(grid_pos):
		freeze_mine_placement_failed.emit("Cannot place freeze mine at this position")
		return false
	
	# Create freeze mine
	var freeze_mine = create_freeze_mine_at_position(grid_pos)
	if freeze_mine:
		# Deduct currency
		currency_manager.spend_currency(freeze_mine_cost)
		
		# Track the freeze mine
		freeze_mines.append(freeze_mine)
		
		# Connect signals
		freeze_mine.mine_triggered.connect(_on_freeze_mine_triggered)
		freeze_mine.mine_depleted.connect(_on_freeze_mine_depleted)
		
		# Mark grid position as occupied
		grid_manager.set_grid_occupied(grid_pos, true)
		
		# Emit success signal
		freeze_mine_placed.emit(freeze_mine)
		
		print("Freeze mine placed at ", grid_pos, " for ", freeze_mine_cost, " currency")
		return true
	else:
		freeze_mine_placement_failed.emit("Failed to create freeze mine")
		return false

func create_freeze_mine_at_position(grid_pos: Vector2i) -> FreezeMine:
	# Create freeze mine instance
	var freeze_mine = FreezeMine.new()
	
	# Set position
	var world_pos = grid_manager.grid_to_world(grid_pos)
	freeze_mine.global_position = world_pos
	freeze_mine.set_grid_position(grid_pos)
	
	# Add to scene - add to self (works in both test and real environments)
	add_child(freeze_mine)
	
	return freeze_mine

func _on_freeze_mine_triggered(mine: FreezeMine):
	freeze_mine_triggered.emit(mine)

func _on_freeze_mine_depleted(mine: FreezeMine):
	# Remove from tracking
	freeze_mines.erase(mine)
	
	# Free grid position
	grid_manager.set_grid_occupied(mine.grid_position, false)
	# Also unblock the grid cell
	grid_manager.set_grid_blocked(mine.grid_position, false)
	
	# Remove from scene
	mine.queue_free()
	
	freeze_mine_depleted.emit(mine)

func get_freeze_mines() -> Array[FreezeMine]:
	return freeze_mines

func get_freeze_mine_count() -> int:
	return freeze_mines.size()

func clear_all_freeze_mines():
	for mine in freeze_mines:
		if is_instance_valid(mine):
			grid_manager.set_grid_occupied(mine.grid_position, false)
			# Also unblock the grid cell
			grid_manager.set_grid_blocked(mine.grid_position, false)
			mine.queue_free()
	freeze_mines.clear()

func get_freeze_mine_cost() -> int:
	return 15  # Cost for freeze mine 
