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
	await wait_idle_frames(1)

func test_trigger_game_over_emits_signal():
	var signal_emitted = false
	game_manager.game_over_triggered.connect(func(): signal_emitted = true)
	game_manager.trigger_game_over()
	await wait_for_signal(game_manager.game_over_triggered, 1)
	assert_true(game_manager.game_over, "Game over should be set to true")
	assert_true(signal_emitted, "game_over_triggered signal should be emitted")

func test_trigger_game_won_emits_signal():
	var signal_emitted = false
	game_manager.game_won_triggered.connect(func(): signal_emitted = true)
	game_manager.trigger_game_won()
	await wait_for_signal(game_manager.game_won_triggered, 1)
	assert_true(game_manager.game_won, "Game won should be set to true")
	assert_eq(game_manager.victory_type, GameManager.VictoryType.WAVE_SURVIVAL, "Victory type should be WAVE_SURVIVAL after win")
	assert_true(signal_emitted, "game_won_triggered signal should be emitted")

func test_trigger_game_won_packet_emits_signal():
	var signal_emitted = false
	game_manager.game_won_triggered.connect(func(): signal_emitted = true)
	game_manager.trigger_game_won_packet()
	await wait_for_signal(game_manager.game_won_triggered, 1)
	assert_true(game_manager.game_won, "Game won should be set to true")
	assert_eq(game_manager.victory_type, GameManager.VictoryType.PROGRAM_DATA_PACKET, "Victory type should be PROGRAM_DATA_PACKET after win packet")
	assert_true(signal_emitted, "game_won_triggered signal should be emitted") 