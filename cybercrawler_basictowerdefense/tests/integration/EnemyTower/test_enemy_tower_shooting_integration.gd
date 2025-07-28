extends GutTest

# Integration tests for EnemyTower shooting functionality
# These tests verify that enemy towers can actually target and shoot at real targets
# using the real game systems and components

var main_controller: MainController
var enemy_tower: EnemyTower
var player_tower: Tower
var program_data_packet: ProgramDataPacket

func before_each():
	# Setup real main controller with real managers
	main_controller = MainController.new()
	add_child_autofree(main_controller)
	main_controller.add_to_group("main_controller")
	
	# Initialize main controller with real managers
	var grid_manager = GridManager.new()
	var wave_manager = WaveManager.new()
	var tower_manager = TowerManager.new()
	var currency_manager = CurrencyManager.new()
	var game_manager = GameManager.new()
	var rival_hacker_manager = RivalHackerManager.new()
	var program_data_packet_manager = ProgramDataPacketManager.new()
	var freeze_mine_manager = FreezeMineManager.new()
	
	main_controller.initialize(
		grid_manager,
		wave_manager,
		tower_manager,
		currency_manager,
		game_manager,
		rival_hacker_manager,
		program_data_packet_manager,
		freeze_mine_manager
	)
	
	# Setup enemy tower
	enemy_tower = EnemyTower.new()
	add_child_autofree(enemy_tower)
	enemy_tower._ready()
	enemy_tower.global_position = Vector2(100, 100)
	enemy_tower.tower_range = 150.0

func test_enemy_tower_can_target_and_shoot_player_tower():
	# Create a real player tower
	player_tower = Tower.new()
	player_tower._ready()
	player_tower.global_position = Vector2(150, 100)  # Within range
	player_tower.is_alive = true
	player_tower.health = 4
	player_tower.max_health = 4
	add_child_autofree(player_tower)
	
	# Add player tower to tower manager directly
	main_controller.tower_manager.towers_placed.append(player_tower)
	
	# Test targeting
	enemy_tower.find_target()
	
	assert_not_null(enemy_tower.current_target, "Enemy tower should find player tower as target")
	assert_eq(enemy_tower.current_target, player_tower, "Enemy tower should target the player tower")
	
	# Test shooting
	var initial_health = player_tower.health
	enemy_tower.attack_target()
	
	assert_eq(player_tower.health, initial_health - 1, "Player tower should take damage from enemy tower attack")

func test_enemy_tower_can_target_and_shoot_program_data_packet():
	# Create a real program data packet
	program_data_packet = ProgramDataPacket.new()
	program_data_packet._ready()
	program_data_packet.global_position = Vector2(150, 100)  # Within range
	program_data_packet.is_alive = true
	program_data_packet.is_active = true
	program_data_packet.health = 30
	program_data_packet.max_health = 30
	add_child_autofree(program_data_packet)
	
	# Set program data packet in manager
	main_controller.program_data_packet_manager.program_data_packet = program_data_packet
	
	# Test targeting
	enemy_tower.find_target()
	
	assert_not_null(enemy_tower.current_target, "Enemy tower should find program data packet as target")
	assert_eq(enemy_tower.current_target, program_data_packet, "Enemy tower should target the program data packet")
	
	# Test shooting
	var initial_health = program_data_packet.health
	enemy_tower.attack_target()
	
	assert_eq(program_data_packet.health, initial_health - 1, "Program data packet should take damage from enemy tower attack")

func test_enemy_tower_prioritizes_program_data_packet_over_player_tower():
	# Create both targets
	player_tower = Tower.new()
	player_tower._ready()
	player_tower.global_position = Vector2(150, 100)
	player_tower.is_alive = true
	add_child_autofree(player_tower)
	
	program_data_packet = ProgramDataPacket.new()
	program_data_packet._ready()
	program_data_packet.global_position = Vector2(200, 100)  # Further but should be prioritized
	program_data_packet.is_alive = true
	program_data_packet.is_active = true
	add_child_autofree(program_data_packet)
	
	# Add both to managers
	main_controller.tower_manager.towers_placed.append(player_tower)
	main_controller.program_data_packet_manager.program_data_packet = program_data_packet
	
	# Test targeting
	enemy_tower.find_target()
	
	assert_not_null(enemy_tower.current_target, "Enemy tower should find a target")
	assert_eq(enemy_tower.current_target, program_data_packet, "Enemy tower should prioritize program data packet")

func test_enemy_tower_attack_timer_triggers_attack():
	# Create a real player tower
	player_tower = Tower.new()
	player_tower._ready()
	player_tower.global_position = Vector2(150, 100)
	player_tower.is_alive = true
	player_tower.health = 4
	player_tower.max_health = 4
	add_child_autofree(player_tower)
	
	# Add player tower to tower manager directly
	main_controller.tower_manager.towers_placed.append(player_tower)
	
	# Start attacking
	enemy_tower.start_attacking()
	
	# Simulate attack timer timeout
	enemy_tower._on_attack_timer_timeout()
	
	assert_not_null(enemy_tower.current_target, "Enemy tower should find target on timer timeout")
	assert_eq(enemy_tower.current_target, player_tower, "Enemy tower should target player tower")

func test_enemy_tower_does_not_target_out_of_range():
	# Create a player tower out of range
	player_tower = Tower.new()
	player_tower._ready()
	player_tower.global_position = Vector2(300, 100)  # Out of range (150 > 120)
	player_tower.is_alive = true
	add_child_autofree(player_tower)
	
	# Add player tower to tower manager directly
	main_controller.tower_manager.towers_placed.append(player_tower)
	
	# Test targeting
	enemy_tower.find_target()
	
	assert_null(enemy_tower.current_target, "Enemy tower should not target out-of-range tower")

func test_enemy_tower_clears_target_when_target_dies():
	# Create a player tower with low health
	player_tower = Tower.new()
	player_tower._ready()
	player_tower.global_position = Vector2(150, 100)
	player_tower.is_alive = true
	player_tower.health = 1
	player_tower.max_health = 4
	add_child_autofree(player_tower)
	
	# Add player tower to tower manager directly
	main_controller.tower_manager.towers_placed.append(player_tower)
	
	# Set target and attack (should kill the tower)
	enemy_tower.current_target = player_tower
	enemy_tower.attack_target()
	
	assert_null(enemy_tower.current_target, "Enemy tower should clear target when it dies")
	assert_false(player_tower.is_alive, "Player tower should be dead") 