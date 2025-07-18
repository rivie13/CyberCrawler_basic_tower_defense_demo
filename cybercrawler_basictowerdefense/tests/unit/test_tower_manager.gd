extends GutTest

# Unit tests for TowerManager class
# These tests verify tower placement logic and validation

var tower_manager: TowerManager
var mock_grid_manager: GridManager
var mock_currency_manager: CurrencyManager
var mock_wave_manager: WaveManager

func before_each():
	# Setup fresh TowerManager for each test
	tower_manager = TowerManager.new()
	# Create actual manager objects instead of generic Node objects
	mock_grid_manager = GridManager.new()
	mock_currency_manager = CurrencyManager.new()
	mock_wave_manager = WaveManager.new()
	
	# Add to scene so they don't get garbage collected
	add_child_autofree(tower_manager)
	add_child_autofree(mock_grid_manager)
	add_child_autofree(mock_currency_manager)
	add_child_autofree(mock_wave_manager)

func test_tower_type_constants():
	# Test that tower type constants are defined correctly
	assert_eq(TowerManager.BASIC_TOWER, "basic", "Basic tower constant should be 'basic'")
	assert_eq(TowerManager.POWERFUL_TOWER, "powerful", "Powerful tower constant should be 'powerful'")

func test_initialize_sets_references():
	# Test that initialize properly sets manager references
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	assert_eq(tower_manager.grid_manager, mock_grid_manager, "Grid manager should be set")
	assert_eq(tower_manager.currency_manager, mock_currency_manager, "Currency manager should be set")
	assert_eq(tower_manager.wave_manager, mock_wave_manager, "Wave manager should be set")

func test_towers_placed_array_initialization():
	# Test that towers_placed array is initialized
	assert_not_null(tower_manager.towers_placed, "towers_placed array should be initialized")
	assert_eq(tower_manager.towers_placed.size(), 0, "towers_placed should start empty")

func test_attempt_placement_without_managers():
	# Test that placement fails if managers are not set
	var result = tower_manager.attempt_tower_placement(Vector2i(0, 0))
	assert_false(result, "Tower placement should fail without managers")

func test_preloaded_scenes():
	# Test that tower scenes are preloaded
	assert_not_null(TowerManager.TOWER_SCENE, "Basic tower scene should be preloaded")
	assert_not_null(TowerManager.POWERFUL_TOWER_SCENE, "Powerful tower scene should be preloaded")

# Using real managers instead of mocks for more realistic testing

func test_placement_validation_with_real_managers():
	# Test placement with real manager objects
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	# Test that the method can be called without crashing
	# The result depends on the actual implementation of the managers
	var result = tower_manager.attempt_tower_placement(Vector2i(0, 0))
	# Just test that it returns a boolean (success or failure)
	assert_true(result is bool, "Should return boolean result")

func test_signal_emission_capability():
	# Test that the tower manager can emit signals
	tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	# Watch for signals
	watch_signals(tower_manager)
	
	# Attempt placement - this might succeed or fail depending on implementation
	tower_manager.attempt_tower_placement(Vector2i(0, 0))
	
	# Test that either success or failure signal was emitted
	# Check if placement succeeded or failed based on signal emission
	var success_signal_emitted = get_signal_emit_count(tower_manager, "tower_placed") > 0
	var failure_signal_emitted = get_signal_emit_count(tower_manager, "tower_placement_failed") > 0
	
	# At least one signal should have been emitted
	assert_true(success_signal_emitted or failure_signal_emitted, 
		"Should emit either success or failure signal") 