extends MineManagerInterface
class_name FreezeMineManager

# FreezeMineManager implements MineManagerInterface
# All methods from MineManagerInterface are implemented below

# Manager references
var grid_manager: GridManagerInterface
var currency_manager: CurrencyManagerInterface

# Mine tracking (using generic Mine type)
var mines: Array[Mine] = []

# Freeze mine scene
const FREEZE_MINE_SCENE = preload("res://scenes/FreezeMine.tscn")

func initialize(grid_mgr: GridManagerInterface, currency_mgr: CurrencyManagerInterface):
	grid_manager = grid_mgr
	currency_manager = currency_mgr

func can_place_mine_at(grid_pos: Vector2i, mine_type: String = "freeze") -> bool:
	# Check if position is valid for mine placement
	if not grid_manager.is_valid_grid_position(grid_pos):
		return false
	if grid_manager.is_grid_occupied(grid_pos):
		return false
	if grid_manager.is_on_enemy_path(grid_pos):
		return false
	if grid_manager.is_grid_ruined(grid_pos):
		return false
	return true

func place_mine(grid_pos: Vector2i, mine_type: String = "freeze") -> bool:
	var mine_cost = get_mine_cost(mine_type)
	
	# Check if player has enough currency
	if currency_manager.get_currency() < mine_cost:
		mine_placement_failed.emit("Not enough currency for " + mine_type + " mine")
		return false
	
	# Check if position is valid
	if not can_place_mine_at(grid_pos, mine_type):
		mine_placement_failed.emit("Cannot place " + mine_type + " mine at this position")
		return false
	
	# Create mine
	var mine = create_mine_at_position(grid_pos, mine_type)
	if mine:
		# Deduct currency
		currency_manager.spend_currency(mine_cost)
		
		# Track the mine
		mines.append(mine)
		
		# Connect signals
		mine.mine_triggered.connect(_on_mine_triggered)
		mine.mine_depleted.connect(_on_mine_depleted)
		
		# Mark grid position as occupied
		grid_manager.set_grid_occupied(grid_pos, true)
		
		# Emit success signal
		mine_placed.emit(mine)
		
		print(mine.get_mine_name() + " placed at ", grid_pos, " for ", mine_cost, " currency")
		return true
	else:
		mine_placement_failed.emit("Failed to create " + mine_type + " mine")
		return false

func create_mine_at_position(grid_pos: Vector2i, mine_type: String = "freeze") -> Mine:
	# Create mine instance based on type
	var mine: Mine
	match mine_type:
		"freeze":
			mine = FreezeMine.new()
		_:
			print("Unknown mine type: ", mine_type)
			return null
	
	# Set position
	var world_pos = grid_manager.grid_to_world(grid_pos)
	mine.global_position = world_pos
	mine.set_grid_position(grid_pos)
	
	# Add to scene - add to self (works in both test and real environments)
	add_child(mine)
	
	return mine

func _on_mine_triggered(mine: Mine):
	mine_triggered.emit(mine)

func _on_mine_depleted(mine: Mine):
	# Remove from tracking
	mines.erase(mine)
	
	# Free grid position
	grid_manager.set_grid_occupied(mine.grid_position, false)
	# Also unblock the grid cell
	grid_manager.set_grid_blocked(mine.grid_position, false)
	
	# Remove from scene
	mine.queue_free()
	
	mine_depleted.emit(mine)

func get_mines() -> Array[Mine]:
	return mines

func get_mine_count() -> int:
	return mines.size()

func clear_all_mines():
	for mine in mines:
		if is_instance_valid(mine):
			grid_manager.set_grid_occupied(mine.grid_position, false)
			# Also unblock the grid cell
			grid_manager.set_grid_blocked(mine.grid_position, false)
			mine.queue_free()
	mines.clear()

func get_mine_cost(mine_type: String = "freeze") -> int:
	match mine_type:
		"freeze":
			return 15  # Cost for freeze mine
		_:
			print("Unknown mine type: ", mine_type)
			return 0 
