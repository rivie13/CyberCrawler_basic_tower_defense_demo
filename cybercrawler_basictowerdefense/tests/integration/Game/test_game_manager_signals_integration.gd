extends GutTest

var game_manager: GameManager
var wave_manager: WaveManager
var currency_manager: CurrencyManager
var tower_manager: TowerManager

func before_each():
	game_manager = GameManager.new()
	wave_manager = WaveManager.new()
	currency_manager = CurrencyManager.new()
	tower_manager = TowerManager.new()
	add_child_autofree(game_manager)
	add_child_autofree(wave_manager)
	add_child_autofree(currency_manager)
	add_child_autofree(tower_manager)
	game_manager.initialize(wave_manager, currency_manager, tower_manager)
	await wait_idle_frames(3)
	await get_tree().process_frame

func test_trigger_game_over_sets_correct_state():
	# Test that trigger_game_over() sets the correct game state
	assert_false(game_manager.game_over, "Game should not be over initially")
	
	game_manager.trigger_game_over()
	
	assert_true(game_manager.game_over, "Game over should be set to true")
	assert_false(game_manager.game_won, "Game should not be won when game over is triggered")

func test_trigger_game_won_sets_correct_state():
	# Test that trigger_game_won() sets the correct game state
	assert_false(game_manager.game_won, "Game should not be won initially")
	assert_eq(game_manager.victory_type, GameManager.VictoryType.WAVE_SURVIVAL, "Initial victory type should be WAVE_SURVIVAL")
	
	game_manager.trigger_game_won()
	
	assert_true(game_manager.game_won, "Game won should be set to true")
	assert_false(game_manager.game_over, "Game should not be over when game won is triggered")
	assert_eq(game_manager.victory_type, GameManager.VictoryType.WAVE_SURVIVAL, "Victory type should remain WAVE_SURVIVAL after win")

func test_trigger_game_won_packet_sets_correct_state():
	# Test that trigger_game_won_packet() sets the correct game state
	assert_false(game_manager.game_won, "Game should not be won initially")
	assert_eq(game_manager.victory_type, GameManager.VictoryType.WAVE_SURVIVAL, "Initial victory type should be WAVE_SURVIVAL")
	
	game_manager.trigger_game_won_packet()
	
	assert_true(game_manager.game_won, "Game won should be set to true")
	assert_false(game_manager.game_over, "Game should not be over when game won packet is triggered")
	assert_eq(game_manager.victory_type, GameManager.VictoryType.PROGRAM_DATA_PACKET, "Victory type should be PROGRAM_DATA_PACKET after win packet")

func test_trigger_methods_are_idempotent():
	# Test that calling trigger methods multiple times doesn't change state
	game_manager.trigger_game_over()
	assert_true(game_manager.game_over, "Game should be over after first trigger")
	
	# Call again - should not change state
	game_manager.trigger_game_over()
	assert_true(game_manager.game_over, "Game should still be over after second trigger")
	
	# Reset for next test
	game_manager = GameManager.new()
	wave_manager = WaveManager.new()
	currency_manager = CurrencyManager.new()
	tower_manager = TowerManager.new()
	add_child_autofree(game_manager)
	add_child_autofree(wave_manager)
	add_child_autofree(currency_manager)
	add_child_autofree(tower_manager)
	game_manager.initialize(wave_manager, currency_manager, tower_manager)
	await wait_idle_frames(3)
	
	game_manager.trigger_game_won()
	assert_true(game_manager.game_won, "Game should be won after first trigger")
	
	# Call again - should not change state
	game_manager.trigger_game_won()
	assert_true(game_manager.game_won, "Game should still be won after second trigger")
	assert_eq(game_manager.victory_type, GameManager.VictoryType.WAVE_SURVIVAL, "Victory type should remain WAVE_SURVIVAL")

func test_game_over_and_won_are_mutually_exclusive():
	# Test that game_over and game_won states are mutually exclusive
	game_manager.trigger_game_over()
	assert_true(game_manager.game_over, "Game should be over")
	assert_false(game_manager.game_won, "Game should not be won when over")
	
	# Reset for reverse test
	game_manager = GameManager.new()
	wave_manager = WaveManager.new()
	currency_manager = CurrencyManager.new()
	tower_manager = TowerManager.new()
	add_child_autofree(game_manager)
	add_child_autofree(wave_manager)
	add_child_autofree(currency_manager)
	add_child_autofree(tower_manager)
	game_manager.initialize(wave_manager, currency_manager, tower_manager)
	await wait_idle_frames(3)
	
	game_manager.trigger_game_won()
	assert_true(game_manager.game_won, "Game should be won")
	assert_false(game_manager.game_over, "Game should not be over when won") 