extends GameManagerInterface
class_name GameManager

# Game state
var player_health: int = 10
var enemies_killed: int = 0
var game_over: bool = false
var game_won: bool = false

# Victory type
var victory_type: VictoryType = VictoryType.WAVE_SURVIVAL

# Timer system
var game_session_start_time: int = 0
var wave_countdown_time: float = 0.0
var wave_countdown_active: bool = false

# References to other managers
var wave_manager: WaveManagerInterface
var currency_manager: CurrencyManagerInterface
var tower_manager: TowerManagerInterface

func _ready():
	# Initialize timer system
	game_session_start_time = Time.get_ticks_msec()

func initialize(wave_mgr: WaveManagerInterface, currency_mgr: CurrencyManagerInterface, tower_mgr: TowerManagerInterface):
	wave_manager = wave_mgr
	currency_manager = currency_mgr
	tower_manager = tower_mgr
	
	# Connect to wave manager signals
	if wave_manager:
		wave_manager.enemy_died.connect(_on_enemy_died)
		wave_manager.enemy_reached_end.connect(_on_enemy_reached_end)
		wave_manager.wave_started.connect(_on_wave_started)
		wave_manager.wave_completed.connect(_on_wave_completed)
		wave_manager.all_waves_completed.connect(_on_all_waves_completed)

func _process(_delta):
	# Update wave countdown if active
	if wave_countdown_active and wave_manager:
		wave_countdown_time = wave_manager.get_wave_timer_time_left()

func _on_enemy_died(enemy: Enemy):
	enemies_killed += 1
	
	# Notify currency manager
	if currency_manager and currency_manager.has_method("add_currency_for_kill"):
		currency_manager.add_currency_for_kill()
	
	print("Enemy killed! Total killed: ", enemies_killed)
	
	# Check victory condition: final wave completed and all enemies dead
	if wave_manager and wave_manager.get_current_wave() >= wave_manager.get_max_waves() and not wave_manager.are_enemies_alive() and not wave_manager.is_wave_active():
		trigger_game_won()

func _on_enemy_reached_end(enemy: Enemy):
	player_health -= 1
	player_health = max(player_health, 0)  # Prevent going below 0
	
	print("Enemy reached end! Player health: ", player_health)
	
	if player_health <= 0 and not game_over:
		trigger_game_over()

func _on_wave_started(_wave_number: int):
	wave_countdown_active = false

func _on_wave_completed(_wave_number: int):
	wave_countdown_active = true
	wave_countdown_time = wave_manager.get_wave_timer_time_left() if wave_manager else 0.0

func _on_all_waves_completed():
	# Victory will be triggered by _on_enemy_died when last enemy dies
	pass

func trigger_game_over():
	if game_over:
		return
	
	game_over = true
	print("Game Over! You survived ", wave_manager.get_current_wave() if wave_manager else 0, " waves and killed ", enemies_killed, " enemies.")
	
	# Stop all systems
	if wave_manager:
		wave_manager.stop_all_timers()
		wave_manager.cleanup_all_enemies()
	
	if tower_manager and tower_manager.has_method("stop_all_towers"):
		tower_manager.stop_all_towers()
	
	# Clean up projectiles
	cleanup_projectiles()
	
	# Emit signal for UI handling
	game_over_triggered.emit()

func trigger_game_won():
	if game_won or game_over:
		return
	
	game_won = true
	victory_type = VictoryType.WAVE_SURVIVAL
	var max_waves = wave_manager.get_max_waves() if wave_manager else 10
	print("Victory! You survived all ", max_waves, " waves and killed ", enemies_killed, " enemies!")
	
	# Stop all systems (same as game over)
	if wave_manager:
		wave_manager.stop_all_timers()
		wave_manager.cleanup_all_enemies()
	
	if tower_manager and tower_manager.has_method("stop_all_towers"):
		tower_manager.stop_all_towers()
	
	# Clean up projectiles
	cleanup_projectiles()
	
	# Emit signal for UI handling
	game_won_triggered.emit()

func trigger_game_won_packet():
	"""Trigger game won when program data packet reaches end"""
	if game_won or game_over:
		return
	
	game_won = true
	victory_type = VictoryType.PROGRAM_DATA_PACKET
	print("Victory! Program data packet successfully infiltrated the enemy network!")
	
	# Stop all systems (same as game over)
	if wave_manager:
		wave_manager.stop_all_timers()
		wave_manager.cleanup_all_enemies()
	
	if tower_manager and tower_manager.has_method("stop_all_towers"):
		tower_manager.stop_all_towers()
	
	# Clean up projectiles
	cleanup_projectiles()
	
	# Emit signal for UI handling
	game_won_triggered.emit()

func get_victory_data() -> Dictionary:
	var max_waves = wave_manager.max_waves if wave_manager else 10
	var current_wave = wave_manager.get_current_wave() if wave_manager else 1
	var current_currency = currency_manager.get_currency() if currency_manager else 0
	var session_time = get_session_time()
	var final_time = format_time(session_time)
	
	return {
		"victory_type": victory_type,  # Return enum value directly, not string
		"max_waves": max_waves,
		"current_wave": current_wave,
		"waves_survived": max_waves,  # For victory, they survived all waves
		"enemies_killed": enemies_killed,
		"currency": current_currency,
		"time_played": final_time,
		"session_time": session_time
	}

func get_game_over_data() -> Dictionary:
	var current_wave = wave_manager.current_wave if wave_manager else 1
	var current_currency = currency_manager.get_currency() if currency_manager else 0
	var session_time = get_session_time()
	var final_time = format_time(session_time)
	
	return {
		"waves_survived": current_wave - 1,  # Since they failed on current wave
		"current_wave": current_wave,
		"enemies_killed": enemies_killed,
		"currency": current_currency,
		"time_played": final_time,
		"session_time": session_time,
		"player_health": player_health
	}

func get_info_label_text() -> String:
	var timer_text = ""
	
	# Add wave countdown if active
	if wave_countdown_active and wave_countdown_time > 0:
		timer_text = " | Next Wave: %ds" % [int(wave_countdown_time)]
	
	# Add session time
	var session_time = get_session_time()
	timer_text += " | Time: %s" % [format_time(session_time)]
	
	var current_wave = wave_manager.get_current_wave() if wave_manager else 1
	var current_currency = currency_manager.get_currency() if currency_manager else 0
	var tower_cost = currency_manager.get_basic_tower_cost() if currency_manager else 50
	
	return "Wave: %d | Health: %d | Currency: %d | Enemies Killed: %d%s\nClick on grid to place towers (Cost: %d)" % [current_wave, player_health, current_currency, enemies_killed, timer_text, tower_cost]

func get_session_time() -> float:
	var current_time = Time.get_ticks_msec()
	return (current_time - game_session_start_time) / 1000.0  # Convert milliseconds to seconds

func format_time(seconds: float) -> String:
	var total_seconds = int(seconds)
	var minutes = total_seconds / 60
	var secs = total_seconds % 60
	return "%d:%02d" % [minutes, secs]

func cleanup_projectiles():
	# Remove all projectiles
	for child in get_children():
		if child is Projectile:
			child.queue_free()
	
	# Also check grid_container for projectiles (if accessible)
	var grid_container = get_node_or_null("GridContainer")
	if grid_container:
		for child in grid_container.get_children():
			if child is Projectile:
				child.queue_free()

func _on_play_again_pressed():
	# Restart the game by reloading the scene
	get_tree().reload_current_scene()

func _on_exit_game_pressed():
	# Exit the game
	get_tree().quit()

func is_game_over() -> bool:
	return game_over or game_won

func get_player_health() -> int:
	return player_health

func get_enemies_killed() -> int:
	return enemies_killed 