extends Node2D
class_name MainController

# Manager references
var grid_manager: GridManager
var wave_manager: WaveManager  
var tower_manager: TowerManager
var currency_manager: CurrencyManager
var game_manager: GameManager
var rival_hacker_manager: RivalHackerManager

# UI update timer
var ui_update_timer: Timer

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
	rival_hacker_manager = RivalHackerManager.new()
	
	# Add them as children
	add_child(grid_manager)
	add_child(wave_manager)
	add_child(tower_manager)
	add_child(currency_manager)
	add_child(game_manager)
	add_child(rival_hacker_manager)

func initialize_systems():
	# Initialize GridManager with the GridContainer from the scene
	var grid_container = $GridContainer
	grid_manager.initialize_with_container(grid_container)
	
	# Initialize managers with references to each other
	wave_manager.initialize(grid_manager)
	tower_manager.initialize(grid_manager, currency_manager, wave_manager)
	game_manager.initialize(wave_manager, currency_manager, tower_manager)
	rival_hacker_manager.initialize(grid_manager, currency_manager, tower_manager, wave_manager)
	
	# Set up enemy path in grid
	var path_positions = wave_manager.get_path_grid_positions()
	grid_manager.set_path_positions(path_positions)
	
	# Connect currency manager to UI updates
	currency_manager.currency_changed.connect(_on_currency_changed)
	
	# Connect tower manager signals
	tower_manager.tower_placed.connect(_on_tower_placed)
	tower_manager.tower_placement_failed.connect(_on_tower_placement_failed)
	
	# Connect game manager signals
	game_manager.game_over_triggered.connect(_on_game_over)
	game_manager.game_won_triggered.connect(_on_game_won)
	
	# Connect rival hacker manager signals
	rival_hacker_manager.rival_hacker_activated.connect(_on_rival_hacker_activated)
	rival_hacker_manager.enemy_tower_placed.connect(_on_enemy_tower_placed)

func setup_ui():
	# Setup tower selection UI
	var tower_button = $UI/TowerSelectionPanel/BasicTowerButton
	if tower_button:
		tower_button.pressed.connect(_on_tower_selected)
	
	# Setup UI update timer to refresh every second
	ui_update_timer = Timer.new()
	ui_update_timer.wait_time = 1.0  # Update every second
	ui_update_timer.timeout.connect(_on_ui_update_timer_timeout)
	ui_update_timer.autostart = true
	add_child(ui_update_timer)
	
	# Update initial UI state
	update_tower_selection_ui()
	update_info_label()

func start_game():
	# Start the first wave
	wave_manager.start_wave()
	
	# Activate rival hacker (will start placing enemy towers after delay)
	rival_hacker_manager.activate()

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

func _on_ui_update_timer_timeout():
	# Update info label every second to refresh timer display
	update_info_label()

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

func _on_game_over():
	print("Game Over - UI handling not yet implemented")
	
	# Stop all activity immediately when game over occurs
	stop_all_game_activity()
	
	# TODO: Implement game over screen

func _on_game_won():
	print("Victory! - Displaying victory screen")
	show_victory_screen()

func show_victory_screen():
	# Stop the UI update timer
	if ui_update_timer:
		ui_update_timer.stop()
	
	# Stop all game activity
	stop_all_game_activity()
	
	# Get victory data from game manager
	var victory_data = game_manager.get_victory_data()
	
	# Update info label to show victory message
	var info_label = $UI/InfoLabel
	if info_label:
		var victory_text = "VICTORY!\n"
		victory_text += "Survived all %d waves!\n" % [victory_data.max_waves]
		victory_text += "Enemies killed: %d\n" % [victory_data.enemies_killed]
		victory_text += "Final currency: %d\n" % [victory_data.currency]
		victory_text += "Time played: %s\n" % [victory_data.time_played]
		victory_text += "\nCongratulations on completing the tower defense demo!"
		
		info_label.text = victory_text
		info_label.modulate = Color.GREEN  # Make it green to indicate victory 

func _on_rival_hacker_activated():
	print("MainController: Rival Hacker has been activated!")
	# Could add UI updates here to notify player

func _on_enemy_tower_placed(grid_pos: Vector2i):
	print("MainController: Enemy tower placed at ", grid_pos)
	# Could add visual/audio feedback here

func stop_all_game_activity():
	# Stop rival hacker activity
	if rival_hacker_manager:
		rival_hacker_manager.stop_all_activity()
	
	# Stop all player towers
	if tower_manager:
		var player_towers = tower_manager.get_towers()
		for tower in player_towers:
			if is_instance_valid(tower):
				tower.stop_attacking()
	
	# Stop all enemy towers
	if rival_hacker_manager:
		var enemy_towers = rival_hacker_manager.get_enemy_towers()
		for enemy_tower in enemy_towers:
			if is_instance_valid(enemy_tower):
				enemy_tower.stop_attacking()
	
	# Destroy all projectiles
	destroy_all_projectiles()

func destroy_all_projectiles():
	# Find and destroy all projectiles in the scene
	var grid_container = grid_manager.get_grid_container()
	if grid_container:
		for child in grid_container.get_children():
			if child is Projectile:
				child.queue_free()
