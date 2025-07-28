extends MainController
class_name MockMainController

# Mock state
var mock_click_mode: String = MODE_BUILD_TOWERS
var mock_selected_tower_type: String = BASIC_TOWER
var mock_ui_update_timer: Timer

# Mock manager references for testing
var mock_rival_hacker_manager: RivalHackerManagerInterface = null

# Signal tracking
var tower_placed_called: bool = false
var tower_placement_failed_called: bool = false
var game_over_called: bool = false
var game_won_called: bool = false
var rival_hacker_activated_called: bool = false
var enemy_tower_placed_called: bool = false
var program_packet_ready_called: bool = false
var program_packet_destroyed_called: bool = false
var program_packet_reached_end_called: bool = false
var freeze_mine_placed_called: bool = false
var freeze_mine_placement_failed_called: bool = false
var freeze_mine_triggered_called: bool = false
var freeze_mine_depleted_called: bool = false
var currency_changed_called: bool = false

# Mock data
var mock_placed_tower_position: Vector2i = Vector2i.ZERO
var mock_placed_tower_type: String = ""
var mock_failed_placement_reason: String = ""
var mock_enemy_tower_position: Vector2i = Vector2i.ZERO
var mock_freeze_mine_position: Vector2i = Vector2i.ZERO
var mock_currency_amount: int = 100

func _ready():
	# Override _ready to prevent automatic manager creation
	DebugLogger.initialize()
	DebugLogger.info("MockMainController starting up...", "INIT")
	
	add_to_group("main_controller")
	
	# Create a mock UI update timer
	mock_ui_update_timer = Timer.new()
	mock_ui_update_timer.wait_time = 0.1
	mock_ui_update_timer.timeout.connect(_on_mock_ui_update_timer_timeout)
	add_child(mock_ui_update_timer)
	mock_ui_update_timer.start()

# Test-specific method to set up signal connections without scene nodes
func setup_test_signal_connections():
	"""Set up signal connections for testing without requiring scene nodes"""
	if not grid_manager or not currency_manager or not tower_manager or not game_manager or not rival_hacker_manager or not program_data_packet_manager or not freeze_mine_manager:
		print("MockMainController: Cannot set up signal connections - managers not initialized")
		return
	
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
	
	print("MockMainController: Signal connections set up for testing")

# Override signal handlers to track calls
func _on_tower_placed(grid_pos: Vector2i, tower_type: String):
	tower_placed_called = true
	mock_placed_tower_position = grid_pos
	mock_placed_tower_type = tower_type
	print("MockMainController: ", tower_type.capitalize(), " tower placed at grid position: ", grid_pos)

func _on_tower_placement_failed(reason: String):
	tower_placement_failed_called = true
	mock_failed_placement_reason = reason
	print("MockMainController: Tower placement failed - ", reason)

func _on_game_over():
	game_over_called = true
	print("MockMainController: Game Over!")

func _on_game_won():
	game_won_called = true
	print("MockMainController: Victory! - Displaying victory screen")

func _on_rival_hacker_activated():
	rival_hacker_activated_called = true
	print("MockMainController: Rival Hacker has been activated!")

func _on_enemy_tower_placed(grid_pos: Vector2i):
	enemy_tower_placed_called = true
	mock_enemy_tower_position = grid_pos
	print("MockMainController: Enemy tower placed at ", grid_pos)

func _on_program_packet_ready():
	program_packet_ready_called = true
	print("MockMainController: Program data packet ready for release")

func _on_program_packet_destroyed(packet: ProgramDataPacket):
	program_packet_destroyed_called = true
	print("MockMainController: Program data packet destroyed")

func _on_program_packet_reached_end(packet: ProgramDataPacket):
	program_packet_reached_end_called = true
	print("MockMainController: Program data packet reached enemy network! Victory!")

func _on_freeze_mine_placed(mine: Mine):
	freeze_mine_placed_called = true
	mock_freeze_mine_position = mine.get_grid_position()
	print("MockMainController: Freeze mine placed at ", mock_freeze_mine_position)

func _on_freeze_mine_placement_failed(reason: String):
	freeze_mine_placement_failed_called = true
	print("MockMainController: Freeze mine placement failed - ", reason)

func _on_freeze_mine_triggered(mine: Mine):
	freeze_mine_triggered_called = true
	mock_freeze_mine_position = mine.get_grid_position()
	print("MockMainController: Freeze mine triggered at ", mock_freeze_mine_position)

func _on_freeze_mine_depleted(mine: Mine):
	freeze_mine_depleted_called = true
	mock_freeze_mine_position = mine.get_grid_position()
	print("MockMainController: Freeze mine depleted at ", mock_freeze_mine_position)

func _on_currency_changed(amount: int):
	currency_changed_called = true
	mock_currency_amount = amount
	print("MockMainController: Currency changed to ", amount)

func _on_mock_ui_update_timer_timeout():
	# Mock UI update timer timeout
	pass

# Mock utility methods for testing
func reset_signal_tracking():
	"""Reset all signal tracking flags"""
	tower_placed_called = false
	tower_placement_failed_called = false
	game_over_called = false
	game_won_called = false
	rival_hacker_activated_called = false
	enemy_tower_placed_called = false
	program_packet_ready_called = false
	program_packet_destroyed_called = false
	program_packet_reached_end_called = false
	freeze_mine_placed_called = false
	freeze_mine_placement_failed_called = false
	freeze_mine_triggered_called = false
	freeze_mine_depleted_called = false
	currency_changed_called = false

func set_mock_click_mode(mode: String):
	"""Set the mock click mode"""
	mock_click_mode = mode

func set_mock_selected_tower_type(tower_type: String):
	"""Set the mock selected tower type"""
	mock_selected_tower_type = tower_type

func set_mock_rival_hacker_manager(manager: RivalHackerManagerInterface):
	"""Set the mock rival hacker manager"""
	mock_rival_hacker_manager = manager

func get_mock_click_mode() -> String:
	"""Get the mock click mode"""
	return mock_click_mode

func get_mock_selected_tower_type() -> String:
	"""Get the mock selected tower type"""
	return mock_selected_tower_type

func get_mock_currency_amount() -> int:
	"""Get the mock currency amount"""
	return mock_currency_amount

func get_mock_placed_tower_position() -> Vector2i:
	"""Get the mock placed tower position"""
	return mock_placed_tower_position

func get_mock_placed_tower_type() -> String:
	"""Get the mock placed tower type"""
	return mock_placed_tower_type

func get_mock_failed_placement_reason() -> String:
	"""Get the mock failed placement reason"""
	return mock_failed_placement_reason

func get_mock_enemy_tower_position() -> Vector2i:
	"""Get the mock enemy tower position"""
	return mock_enemy_tower_position

func get_mock_freeze_mine_position() -> Vector2i:
	"""Get the mock freeze mine position"""
	return mock_freeze_mine_position 