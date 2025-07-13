extends Node2D
class_name MainController

# Manager references
var grid_manager: GridManager
var wave_manager: WaveManager  
var tower_manager: TowerManager
var currency_manager: CurrencyManager
var game_manager: GameManager

func _ready():
	setup_managers()
	initialize_systems()
	setup_ui()
	start_game()

func setup_managers():
	# Create all manager instances
	grid_manager = GridManager.new()
	wave_manager = WaveManager.new()
	tower_manager = TowerManager.new()
	currency_manager = CurrencyManager.new()
	game_manager = GameManager.new()
	
	# Add them as children
	add_child(grid_manager)
	add_child(wave_manager)
	add_child(tower_manager)
	add_child(currency_manager)
	add_child(game_manager)

func initialize_systems():
	# Initialize GridManager with the GridContainer from the scene
	var grid_container = $GridContainer
	grid_manager.initialize_with_container(grid_container)
	
	# Initialize managers with references to each other
	wave_manager.initialize(grid_manager)
	tower_manager.initialize(grid_manager, currency_manager, wave_manager)
	game_manager.initialize(wave_manager, currency_manager, tower_manager)
	
	# Set up enemy path in grid
	var path_positions = wave_manager.get_path_grid_positions()
	grid_manager.set_path_positions(path_positions)
	
	# Connect currency manager to UI updates
	currency_manager.currency_changed.connect(_on_currency_changed)
	
	# Connect tower manager signals
	tower_manager.tower_placed.connect(_on_tower_placed)
	tower_manager.tower_placement_failed.connect(_on_tower_placement_failed)

func setup_ui():
	# Setup tower selection UI
	var tower_button = $UI/TowerSelectionPanel/BasicTowerButton
	if tower_button:
		tower_button.pressed.connect(_on_tower_selected)
	
	# Update initial UI state
	update_tower_selection_ui()

func start_game():
	# Start the first wave
	wave_manager.start_wave()

func _input(event):
	if game_manager.is_game_over():
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var world_mouse_pos = get_global_mouse_position()
		handle_grid_click(world_mouse_pos)
	elif event is InputEventMouseMotion:
		var world_mouse_pos = get_global_mouse_position()
		grid_manager.handle_mouse_hover(world_mouse_pos)

func handle_grid_click(global_pos: Vector2):
	var grid_pos = grid_manager.world_to_grid(global_pos)
	
	if grid_manager.is_valid_grid_position(grid_pos):
		tower_manager.attempt_tower_placement(grid_pos)

func _on_tower_selected():
	# For now, just provide feedback that tower is selected
	print("Basic Tower selected - Click on grid to place (Cost: %d)" % [currency_manager.get_tower_cost()])

func _on_currency_changed(_new_amount: int):
	update_tower_selection_ui()
	update_info_label()

func _on_tower_placed(_grid_pos: Vector2i):
	update_tower_selection_ui()
	update_info_label()

func _on_tower_placement_failed(reason: String):
	print("Tower placement failed: ", reason)

func update_tower_selection_ui():
	# Update cost label
	var cost_label = $UI/TowerSelectionPanel/CostLabel
	if cost_label:
		cost_label.text = "Cost: %d" % [currency_manager.get_tower_cost()]
	
	# Update currency label
	var currency_label = $UI/TowerSelectionPanel/CurrencyLabel  
	if currency_label:
		currency_label.text = "Currency: %d" % [currency_manager.get_currency()]
		
		# Change color based on affordability
		if currency_manager.can_afford_tower():
			currency_label.modulate = Color.WHITE
		else:
			currency_label.modulate = Color.RED

func update_info_label():
	var info_label = $UI/InfoLabel
	if info_label and game_manager:
		info_label.text = game_manager.get_info_label_text() 