extends Node2D
class_name MainController

# Accessible color scheme for UI feedback
const VICTORY_COLOR = Color(0.2, 0.8, 0.2)  # Accessible green for victory
const DEFEAT_COLOR = Color(0.8, 0.2, 0.2)   # Accessible red for defeat
const WARNING_COLOR = Color(0.8, 0.8, 0.2)  # Accessible yellow for warnings

# Tower type constants - consistent with TowerManager
const BASIC_TOWER = "basic"
const POWERFUL_TOWER = "powerful"

# Item type constants
const FREEZE_MINE = "freeze_mine"

# Click mode constants
const MODE_BUILD_TOWERS = "build_towers"
const MODE_ATTACK_ENEMIES = "attack_enemies"
const MODE_PLACE_FREEZE_MINE = "place_freeze_mine"

# Manager references
var grid_manager: GridManagerInterface
var wave_manager: WaveManagerInterface  
var tower_manager: TowerManagerInterface
var currency_manager: CurrencyManagerInterface
var game_manager: GameManagerInterface
var rival_hacker_manager: RivalHackerManagerInterface
var program_data_packet_manager: ProgramDataPacketManagerInterface
var freeze_mine_manager: MineManagerInterface

# UI update timer
var ui_update_timer: Timer

# Tower selection system
var selected_tower_type: String = BASIC_TOWER  # Default to basic tower

# Click mode system
var current_click_mode: String = MODE_BUILD_TOWERS  # Default to tower building mode

func _ready():
	# Initialize debug logger first
	DebugLogger.initialize()
	DebugLogger.info("MainController starting up...", "INIT")
	
	add_to_group("main_controller")
	
	# Check if we're in a test environment (no managers injected)
	if not grid_manager:
		# In test environment, create managers for backwards compatibility
		setup_managers()
	
	initialize_systems()
	setup_ui()
	
	# Only start the game if we're not in a test environment
	if get_node_or_null("GridContainer"):
		start_game()

func initialize(grid_mgr: GridManagerInterface, wave_mgr: WaveManagerInterface, 
				tower_mgr: TowerManagerInterface, currency_mgr: CurrencyManagerInterface,
				game_mgr: GameManagerInterface, rival_mgr: RivalHackerManagerInterface,
				packet_mgr: ProgramDataPacketManagerInterface, mine_mgr: MineManagerInterface):
	"""Initialize MainController with injected dependencies"""
	grid_manager = grid_mgr
	wave_manager = wave_mgr
	tower_manager = tower_mgr
	currency_manager = currency_mgr
	game_manager = game_mgr
	rival_hacker_manager = rival_mgr
	program_data_packet_manager = packet_mgr
	freeze_mine_manager = mine_mgr
	
	# Add them as children if they aren't already
	if not grid_manager.get_parent():
		add_child(grid_manager)
	if not wave_manager.get_parent():
		add_child(wave_manager)
	if not tower_manager.get_parent():
		add_child(tower_manager)
	if not currency_manager.get_parent():
		add_child(currency_manager)
	if not game_manager.get_parent():
		add_child(game_manager)
	if not rival_hacker_manager.get_parent():
		add_child(rival_hacker_manager)
	if not program_data_packet_manager.get_parent():
		add_child(program_data_packet_manager)
	if not freeze_mine_manager.get_parent():
		add_child(freeze_mine_manager)

func setup_managers():
	# Create all manager instances (for backwards compatibility)
	grid_manager = GridManager.new()
	wave_manager = WaveManager.new() as WaveManagerInterface
	tower_manager = TowerManager.new() as TowerManagerInterface
	currency_manager = CurrencyManager.new() as CurrencyManagerInterface
	game_manager = GameManager.new() as GameManagerInterface
	rival_hacker_manager = RivalHackerManager.new() as RivalHackerManagerInterface
	program_data_packet_manager = ProgramDataPacketManager.new() as ProgramDataPacketManagerInterface
	freeze_mine_manager = FreezeMineManager.new() as MineManagerInterface
	
	# Add them as children
	add_child(grid_manager)
	add_child(wave_manager)
	add_child(tower_manager)
	add_child(currency_manager)
	add_child(game_manager)
	add_child(rival_hacker_manager)
	add_child(program_data_packet_manager)
	add_child(freeze_mine_manager)

func initialize_systems():
	# Initialize GridManager with the GridContainer from the scene and inject GameManager
	# Skip if we're in a test environment or GridContainer doesn't exist
	var grid_container = get_node_or_null("GridContainer")
	if not grid_container:
		# In test environment, skip scene-dependent initialization
		return
	
	grid_manager.initialize_with_container(grid_container, game_manager)
	
	# Initialize managers with references to each other
	wave_manager.initialize(grid_manager)
	tower_manager.initialize(grid_manager, currency_manager, wave_manager)
	game_manager.initialize(wave_manager, currency_manager, tower_manager)
	rival_hacker_manager.initialize(grid_manager, currency_manager, tower_manager, wave_manager, game_manager)
	program_data_packet_manager.initialize(grid_manager, game_manager, wave_manager)
	freeze_mine_manager.initialize(grid_manager, currency_manager)
	
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
	
	# Connect program data packet manager signals
	program_data_packet_manager.program_packet_ready.connect(_on_program_packet_ready)
	program_data_packet_manager.program_packet_destroyed.connect(_on_program_packet_destroyed)
	program_data_packet_manager.program_packet_reached_end.connect(_on_program_packet_reached_end)
	
	# Connect freeze mine manager signals
	freeze_mine_manager.mine_placed.connect(_on_freeze_mine_placed)
	freeze_mine_manager.mine_placement_failed.connect(_on_freeze_mine_placement_failed)
	freeze_mine_manager.mine_triggered.connect(_on_freeze_mine_triggered)
	freeze_mine_manager.mine_depleted.connect(_on_freeze_mine_depleted)

func setup_ui():
	# Skip UI setup if we're in a test environment or UI nodes don't exist
	if not has_node("UI/TowerSelectionPanel"):
		return
	
	# Setup basic tower selection UI
	var basic_tower_button = $UI/TowerSelectionPanel/BasicTowerButton
	if basic_tower_button:
		basic_tower_button.pressed.connect(_on_basic_tower_selected)
	
	# Setup powerful tower selection UI
	var powerful_tower_button = $UI/TowerSelectionPanel/PowerfulTowerButton
	if powerful_tower_button:
		powerful_tower_button.pressed.connect(_on_powerful_tower_selected)
	
	# Setup mode toggle button
	var mode_toggle_button = $UI/TowerSelectionPanel/ModeToggleButton
	if mode_toggle_button:
		mode_toggle_button.pressed.connect(_on_mode_toggle_pressed)
	
	# Setup program data packet button
	var packet_button = $UI/TowerSelectionPanel/ProgramDataPacketButton
	if packet_button:
		packet_button.pressed.connect(_on_program_data_packet_button_pressed)
	
	# Setup freeze mine button
	var freeze_mine_button = $UI/TowerSelectionPanel/FreezeMineButton
	if freeze_mine_button:
		freeze_mine_button.pressed.connect(_on_freeze_mine_button_pressed)
	
	# Setup UI update timer to refresh every second
	ui_update_timer = Timer.new()
	ui_update_timer.wait_time = 1.0  # Update every second
	ui_update_timer.timeout.connect(_on_ui_update_timer_timeout)
	ui_update_timer.autostart = true
	add_child(ui_update_timer)
	
	# Update initial UI state
	update_tower_selection_ui()
	update_mode_ui()
	update_info_label()

func start_game():
	# Skip if we're in a test environment or systems aren't initialized
	if not wave_manager or not rival_hacker_manager:
		return
	
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
	# Handle click based on current mode
	if current_click_mode == MODE_ATTACK_ENEMIES:
		# In attack mode, only try to damage enemies
		try_click_damage_enemy(global_pos)
	elif current_click_mode == MODE_PLACE_FREEZE_MINE:
		# In freeze mine mode, try to place freeze mine
		var grid_pos = grid_manager.world_to_grid(global_pos)
		if grid_manager.is_valid_grid_position(grid_pos):
			freeze_mine_manager.place_mine(grid_pos, "freeze")
	elif current_click_mode == MODE_BUILD_TOWERS:
		# In build mode, only try tower placement
		var grid_pos = grid_manager.world_to_grid(global_pos)
		if grid_manager.is_valid_grid_position(grid_pos):
			tower_manager.attempt_tower_placement(grid_pos, selected_tower_type)

func try_click_damage_enemy(global_pos: Vector2) -> bool:
	"""Try to damage an enemy entity at the clicked position. Returns true if an enemy was hit."""
	
	# Check enemy towers first (larger targets, easier to click)
	if rival_hacker_manager:
		var enemy_towers = rival_hacker_manager.get_enemy_towers()
		for enemy_tower in enemy_towers:
			if is_instance_valid(enemy_tower) and enemy_tower.is_clicked_at(global_pos):
				return enemy_tower.handle_click_damage()
	
	# Check RivalHacker special enemies (high-value targets)
	if rival_hacker_manager:
		var rival_hackers = rival_hacker_manager.get_rival_hackers()
		for rival_hacker in rival_hackers:
			if is_instance_valid(rival_hacker) and rival_hacker.is_clicked_at(global_pos):
				return rival_hacker.handle_click_damage()
	
	# Check regular enemies
	if wave_manager:
		var enemies = wave_manager.get_enemies()
		for enemy in enemies:
			if is_instance_valid(enemy) and enemy.is_clicked_at(global_pos):
				return enemy.handle_click_damage()
	
	return false  # No enemy was hit

func _on_basic_tower_selected():
	selected_tower_type = BASIC_TOWER
	print("Basic Tower selected (Cost: %d) - Click on grid to place" % [currency_manager.get_basic_tower_cost()])
	update_tower_selection_ui()

func _on_powerful_tower_selected():
	selected_tower_type = POWERFUL_TOWER
	print("Powerful Tower selected (Cost: %d) - Click on grid to place" % [currency_manager.get_powerful_tower_cost()])
	update_tower_selection_ui()

func _on_mode_toggle_pressed():
	# Toggle between build and attack modes
	if current_click_mode == MODE_BUILD_TOWERS:
		current_click_mode = MODE_ATTACK_ENEMIES
		print("Switched to Attack Mode - Click enemies to damage them (tower placement disabled)")
	else:
		current_click_mode = MODE_BUILD_TOWERS
		print("Switched to Build Mode - Click to place towers (enemy clicking disabled)")
	
	update_mode_ui()

# Backwards compatibility
func _on_tower_selected():
	_on_basic_tower_selected()

func _on_currency_changed(_new_amount: int):
	update_tower_selection_ui()
	update_info_label()

func _on_tower_placed(grid_pos: Vector2i, tower_type: String):
	print("MainController: %s tower placed at %s" % [tower_type.capitalize(), grid_pos])
	update_tower_selection_ui()
	update_info_label()
	
	# Check if this was a powerful tower for alert system integration
	if tower_type == POWERFUL_TOWER:
		print("MainController: Powerful tower placed - this should trigger alert system!")

func _on_tower_placement_failed(reason: String):
	print("Tower placement failed: ", reason)

func _on_ui_update_timer_timeout():
	# Update info label every second to refresh timer display
	update_info_label()
	# Update packet UI 
	update_packet_ui()

func update_tower_selection_ui():
	# Skip UI updates if we're in a test environment or UI nodes don't exist
	if not has_node("UI/TowerSelectionPanel"):
		return
	
	# Skip if currency_manager is not initialized (like in tests)
	if not currency_manager:
		return
	
	# Update cost label to show both tower types
	var cost_label = $UI/TowerSelectionPanel/CostLabel
	if cost_label:
		cost_label.text = "Basic: %d | Powerful: %d" % [
			currency_manager.get_basic_tower_cost(),
			currency_manager.get_powerful_tower_cost()
		]
	
	# Update currency label
	var currency_label = $UI/TowerSelectionPanel/CurrencyLabel  
	if currency_label:
		currency_label.text = "Currency: %d" % [currency_manager.get_currency()]
		
		# Change color based on affordability of selected tower
		if currency_manager.can_afford_tower_type(selected_tower_type):
			currency_label.modulate = Color.WHITE
		else:
			currency_label.modulate = Color.RED
	
	# Update selected tower label
	var selected_label = $UI/TowerSelectionPanel/SelectedTowerLabel
	if selected_label:
		var cost = currency_manager.get_basic_tower_cost() if selected_tower_type == BASIC_TOWER else currency_manager.get_powerful_tower_cost()
		selected_label.text = "Selected: %s (%d)" % [selected_tower_type.capitalize(), cost]
		
		# Change color based on affordability
		if currency_manager.can_afford_tower_type(selected_tower_type):
			selected_label.modulate = Color.WHITE
		else:
			selected_label.modulate = Color.RED

func update_mode_ui():
	# Skip UI updates if we're in a test environment or UI nodes don't exist
	if not has_node("UI/TowerSelectionPanel"):
		return
	
	# Update mode toggle button text
	var mode_toggle_button = $UI/TowerSelectionPanel/ModeToggleButton
	if mode_toggle_button:
		if current_click_mode == MODE_BUILD_TOWERS:
			mode_toggle_button.text = "Mode: Build Towers"
		elif current_click_mode == MODE_PLACE_FREEZE_MINE:
			mode_toggle_button.text = "Mode: Place Freeze Mine"
		else:
			mode_toggle_button.text = "Mode: Attack Enemies"
	
	# Update mode indicator label
	var mode_indicator = $UI/TowerSelectionPanel/ModeIndicatorLabel
	if mode_indicator:
		if current_click_mode == MODE_BUILD_TOWERS:
			mode_indicator.text = "Click: Place Towers Only"
			mode_indicator.modulate = Color.CYAN
		elif current_click_mode == MODE_PLACE_FREEZE_MINE:
			mode_indicator.text = "Click: Place Freeze Mine"
			mode_indicator.modulate = Color.MAGENTA
		else:
			mode_indicator.text = "Click: Attack Enemies Only"
			mode_indicator.modulate = Color.ORANGE

func update_info_label():
	# Skip UI updates if we're in a test environment or UI nodes don't exist
	if not has_node("UI/InfoLabel"):
		return
	
	# Skip if game_manager is not initialized (like in tests)
	if not game_manager:
		return
	
	var info_label = $UI/InfoLabel
	if info_label:
		info_label.text = game_manager.get_info_label_text()

func _on_game_over():
	print("Game Over!")
	
	# Stop all activity immediately when game over occurs
	stop_all_game_activity()
	
	# Show game over screen
	show_game_over_screen()

func _on_game_won():
	print("Victory! - Displaying victory screen")
	show_victory_screen()

func show_victory_screen():
	# Stop the UI update timer
	if ui_update_timer:
		ui_update_timer.stop()
	
	# Stop all game activity
	stop_all_game_activity()
	
	# Skip if game_manager is not initialized (like in tests)
	if not game_manager:
		return
	
	# Get victory data from game manager
	var victory_data = game_manager.get_victory_data()
	
	# Update info label to show victory message (only if UI exists)
	if not has_node("UI/InfoLabel"):
		return
	var info_label = $UI/InfoLabel
	if info_label:
		var victory_text = "VICTORY!\n"
		
		# Show different victory messages based on victory type
		if victory_data.victory_type == GameManagerInterface.VictoryType.PROGRAM_DATA_PACKET:
			victory_text += "Program data packet successfully infiltrated the enemy network!\n"
			victory_text += "Mission accomplished during wave %d!\n" % [victory_data.current_wave]
			victory_text += "\nYou've hacked into the enemy system and retrieved critical data!"
		else:
			victory_text += "Survived all %d waves!\n" % [victory_data.max_waves]
			victory_text += "You've successfully defended against all enemy attacks!"
		
		victory_text += "\n\nMission Statistics:"
		victory_text += "\nEnemies eliminated: %d" % [victory_data.enemies_killed]
		victory_text += "\nFinal currency: %d" % [victory_data.currency]
		victory_text += "\nTime played: %s" % [victory_data.time_played]
		victory_text += "\n\nCongratulations on completing the tower defense demo!"
		
		info_label.text = victory_text
		info_label.modulate = VICTORY_COLOR  # Use accessible color for victory 

func show_game_over_screen():
	# Stop the UI update timer
	if ui_update_timer:
		ui_update_timer.stop()
	
	# Stop all game activity
	stop_all_game_activity()
	
	# Skip if game_manager is not initialized (like in tests)
	if not game_manager:
		return
	
	# Get game over data from game manager
	var game_over_data = game_manager.get_game_over_data()
	
	# Update info label to show game over message (only if UI exists)
	if not has_node("UI/InfoLabel"):
		return
	var info_label = $UI/InfoLabel
	if info_label:
		var game_over_text = "GAME OVER!\n"
		game_over_text += "You were defeated on wave %d!\n" % [game_over_data.current_wave]
		game_over_text += "Waves survived: %d\n" % [game_over_data.waves_survived]
		game_over_text += "Enemies killed: %d\n" % [game_over_data.enemies_killed]
		game_over_text += "Final currency: %d\n" % [game_over_data.currency]
		game_over_text += "Time played: %s\n" % [game_over_data.time_played]
		game_over_text += "\nBetter luck next time! The rival hacker won this round."
		
		info_label.text = game_over_text
		info_label.modulate = DEFEAT_COLOR  # Use accessible color for defeat

func _on_rival_hacker_activated():
	print("MainController: Rival Hacker has been activated!")
	# Could add UI updates here to notify player

func _on_enemy_tower_placed(grid_pos: Vector2i):
	print("MainController: Enemy tower placed at ", grid_pos)
	# Could add visual/audio feedback here

func stop_all_game_activity():
	# Stop wave manager first
	if wave_manager:
		wave_manager.stop_all_timers()
	
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

# Program Data Packet Manager signal callbacks
func _on_program_packet_ready():
	print("MainController: Program data packet ready for release")
	update_packet_ui()

func _on_program_packet_destroyed(_packet: ProgramDataPacket):
	print("MainController: Program data packet destroyed")
	update_packet_ui()

func _on_program_packet_reached_end(_packet: ProgramDataPacket):
	print("MainController: Program data packet reached enemy network! Victory!")
	update_packet_ui()

func _on_program_data_packet_button_pressed():
	print("MainController: Program data packet button pressed")
	if program_data_packet_manager and program_data_packet_manager.can_player_release_packet():
		program_data_packet_manager.release_program_data_packet()
		update_packet_ui()
	else:
		print("MainController: Cannot release program data packet")

func _on_freeze_mine_button_pressed():
	print("MainController: Freeze mine button pressed")
	current_click_mode = MODE_PLACE_FREEZE_MINE
	update_mode_ui()
	update_info_label()

func update_packet_ui():
	# Skip UI updates if we're in a test environment or UI nodes don't exist
	if not has_node("UI/TowerSelectionPanel"):
		return
	
	# Skip if program_data_packet_manager is not initialized (like in tests)
	if not program_data_packet_manager:
		return
	
	var packet_button = $UI/TowerSelectionPanel/ProgramDataPacketButton
	var packet_status_label = $UI/TowerSelectionPanel/PacketStatusLabel
	
	if packet_button and packet_status_label:
		var can_release = program_data_packet_manager.can_player_release_packet()
		var is_spawned = program_data_packet_manager.is_packet_spawned
		var is_active = program_data_packet_manager.is_packet_active
		var is_alive = program_data_packet_manager.is_packet_alive()
		
		packet_button.disabled = not can_release
		
		if not is_spawned:
			packet_status_label.text = "Packet: Not Ready"
		elif is_active:
			if is_alive:
				packet_status_label.text = "Packet: Active"
			else:
				packet_status_label.text = "Packet: Destroyed"
		else:
			packet_status_label.text = "Packet: Ready"

func destroy_all_projectiles():
	# Find and destroy all projectiles in the scene
	# Skip if grid_manager is not initialized (like in tests)
	if not grid_manager:
		return
		
	var grid_container = grid_manager.get_grid_container()
	if grid_container:
		for child in grid_container.get_children():
			if child is Projectile:
				child.queue_free()

# Freeze mine signal handlers
func _on_freeze_mine_placed(mine: Mine):
	print("MainController: Freeze mine placed at ", mine.grid_position)
	update_info_label()

func _on_freeze_mine_placement_failed(reason: String):
	print("MainController: Freeze mine placement failed - ", reason)
	update_info_label()

func _on_freeze_mine_triggered(mine: Mine):
	print("MainController: Freeze mine triggered at ", mine.grid_position)

func _on_freeze_mine_depleted(mine: Mine):
	print("MainController: Freeze mine depleted at ", mine.grid_position)
	update_info_label()

# Getter methods for manager access
func get_program_data_packet_manager() -> ProgramDataPacketManagerInterface:
	"""Get the program data packet manager"""
	return program_data_packet_manager

func get_tower_manager() -> TowerManagerInterface:
	"""Get the tower manager"""
	return tower_manager

# Utility: Show a temporary message in the InfoLabel
func show_temp_message(message: String, duration: float = 1.5):
	# Skip UI updates if we're in a test environment or UI nodes don't exist
	if not has_node("UI/InfoLabel"):
		return
	
	var info_label = $UI/InfoLabel
	if info_label:
		var prev_text = info_label.text
		info_label.text = message
		info_label.modulate = WARNING_COLOR
		# Restore previous text after duration
		var timer = Timer.new()
		timer.wait_time = duration
		timer.one_shot = true
		timer.timeout.connect(func():
			info_label.text = prev_text
			info_label.modulate = Color.WHITE
			timer.queue_free()
		)
		add_child(timer)
