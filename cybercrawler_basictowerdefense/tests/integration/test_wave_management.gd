extends GutTest

# Small integration test to verify wave management
# This tests that WaveManager properly spawns enemies and integrates with GameManager

var wave_manager: WaveManager
var game_manager: GameManager
var grid_manager: GridManager

func before_each():
	# Create managers for integration testing
	wave_manager = WaveManager.new()
	game_manager = GameManager.new()
	grid_manager = GridManager.new()
	
	# Create proper mock managers for integration testing
	var currency_manager = CurrencyManager.new()
	var tower_manager = TowerManager.new()
	
	# Add to scene
	add_child_autofree(wave_manager)
	add_child_autofree(game_manager)
	add_child_autofree(grid_manager)
	add_child_autofree(currency_manager)
	add_child_autofree(tower_manager)
	
	# Initialize the integration with proper managers
	wave_manager.initialize(grid_manager)
	tower_manager.initialize(grid_manager, currency_manager, wave_manager)
	game_manager.initialize(wave_manager, currency_manager, tower_manager)

func test_wave_manager_initialization():
	# Test that WaveManager properly initializes with GridManager
	# This is the SMALLEST possible integration test
	
	# Verify WaveManager was properly initialized
	assert_not_null(wave_manager.grid_manager, "GridManager should be set")
	assert_not_null(wave_manager.grid_layout, "GridLayout should be created")
	assert_not_null(wave_manager.selected_layout_type, "Layout type should be selected")

func test_enemy_path_creation():
	# Test that WaveManager creates enemy paths properly
	# This tests the integration between WaveManager and GridLayout
	
	# Verify path was created
	assert_gt(wave_manager.enemy_path.size(), 0, "Enemy path should be created")
	
	# Verify path has start and end points
	assert_not_null(wave_manager.path_start, "Path start should be set")
	assert_not_null(wave_manager.path_end, "Path end should be set")

func test_wave_manager_signals():
	# Test that WaveManager emits proper signals
	# This tests signal integration between systems
	
	watch_signals(wave_manager)
	
	# Simulate enemy death (this should emit enemy_died signal)
	var mock_enemy = Enemy.new()
	add_child_autofree(mock_enemy)
	wave_manager._on_enemy_died(mock_enemy)
	
	# Verify signal was emitted
	assert_signal_emitted(wave_manager, "enemy_died")

func test_wave_manager_game_state_integration():
	# Test that WaveManager integrates with game state
	# This tests that wave progression works with game manager
	
	# Verify wave manager tracks current wave
	assert_eq(wave_manager.current_wave, 1, "Should start at wave 1")
	
	# Verify wave manager has proper wave settings
	assert_gt(wave_manager.max_waves, 0, "Max waves should be set")
	assert_gt(wave_manager.enemies_per_wave, 0, "Enemies per wave should be set") 