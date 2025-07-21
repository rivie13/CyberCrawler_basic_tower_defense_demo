extends GutTest

# Unit tests for TowerManagerInterface
# These tests verify the interface contract and constants

# Mock implementation for testing the interface
class MockTowerManagerInterface extends TowerManagerInterface:
	var _towers: Array = []
	var _enemies: Array = []
	var _initialized: bool = false
	var _grid_manager: Node
	var _currency_manager: CurrencyManagerInterface
	var _wave_manager: Node
	
	func initialize(grid_mgr: Node, currency_mgr: CurrencyManagerInterface, wave_mgr: Node) -> void:
		_grid_manager = grid_mgr
		_currency_manager = currency_mgr
		_wave_manager = wave_mgr
		_initialized = true
	
	func attempt_tower_placement(grid_pos: Vector2i, tower_type: String = BASIC_TOWER) -> bool:
		if not _initialized:
			return false
		return place_tower(grid_pos, tower_type)
	
	func attempt_basic_tower_placement(grid_pos: Vector2i) -> bool:
		return attempt_tower_placement(grid_pos, BASIC_TOWER)
	
	func place_tower(grid_pos: Vector2i, tower_type: String = BASIC_TOWER) -> bool:
		if not _initialized:
			return false
		
		# Create a mock tower node
		var mock_tower = Node.new()
		mock_tower.set_meta("grid_pos", grid_pos)
		mock_tower.set_meta("tower_type", tower_type)
		_towers.append(mock_tower)
		
		tower_placed.emit(grid_pos, tower_type)
		return true
	
	func get_enemies_for_towers() -> Array:
		return _enemies
	
	func get_towers() -> Array:
		return _towers
	
	func stop_all_towers() -> void:
		# Mock implementation - just mark as stopped
		for tower in _towers:
			tower.set_meta("stopped", true)
	
	func cleanup_all_towers() -> void:
		_towers.clear()
	
	func get_tower_count() -> int:
		return _towers.size()
	
	func get_tower_count_by_type(tower_type: String) -> int:
		var count = 0
		for tower in _towers:
			if tower.get_meta("tower_type") == tower_type:
				count += 1
		return count
	
	func remove_tower(tower: Node) -> void:
		if tower in _towers:
			_towers.erase(tower)
	
	func get_total_power_level() -> float:
		return float(_towers.size()) * 1.5  # Mock power calculation
	
	# Helper methods for testing
	func add_enemy(enemy: Node):
		_enemies.append(enemy)
	
	func clear_enemies():
		_enemies.clear()

var mock_tower_manager: MockTowerManagerInterface
var mock_grid_manager: Node
var mock_currency_manager: CurrencyManagerInterface
var mock_wave_manager: Node

func before_each():
	# Setup fresh mock objects for each test
	mock_tower_manager = MockTowerManagerInterface.new()
	mock_grid_manager = Node.new()
	mock_currency_manager = CurrencyManager.new()
	mock_wave_manager = Node.new()
	
	# Add to scene so they don't get garbage collected
	add_child_autofree(mock_tower_manager)
	add_child_autofree(mock_grid_manager)
	add_child_autofree(mock_currency_manager)
	add_child_autofree(mock_wave_manager)

func test_tower_type_constants():
	# Test that tower type constants are defined correctly
	assert_eq(TowerManagerInterface.BASIC_TOWER, "basic", "Basic tower constant should be 'basic'")
	assert_eq(TowerManagerInterface.POWERFUL_TOWER, "powerful", "Powerful tower constant should be 'powerful'")

func test_interface_inheritance():
	# Test that our mock properly extends the interface
	assert_true(mock_tower_manager is TowerManagerInterface, "Mock should be instance of TowerManagerInterface")
	assert_true(mock_tower_manager is Node, "Mock should also be instance of Node")

func test_initialize_sets_references():
	# Test that initialize properly sets manager references
	mock_tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	# Verify initialization worked
	assert_true(mock_tower_manager._initialized, "Mock should be initialized after initialize() call")

func test_attempt_tower_placement_without_initialization():
	# Test that placement fails if not initialized
	var result = mock_tower_manager.attempt_tower_placement(Vector2i(0, 0))
	assert_false(result, "Tower placement should fail without initialization")

func test_attempt_tower_placement_with_initialization():
	# Test that placement works when initialized
	mock_tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	var result = mock_tower_manager.attempt_tower_placement(Vector2i(0, 0))
	assert_true(result, "Tower placement should succeed when initialized")

func test_attempt_basic_tower_placement():
	# Test basic tower placement convenience method
	mock_tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	var result = mock_tower_manager.attempt_basic_tower_placement(Vector2i(1, 1))
	assert_true(result, "Basic tower placement should succeed")

func test_place_tower_without_initialization():
	# Test that place_tower fails if not initialized
	var result = mock_tower_manager.place_tower(Vector2i(0, 0))
	assert_false(result, "place_tower should fail without initialization")

func test_place_tower_with_initialization():
	# Test that place_tower works when initialized
	mock_tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	var result = mock_tower_manager.place_tower(Vector2i(2, 2))
	assert_true(result, "place_tower should succeed when initialized")

func test_place_tower_with_different_types():
	# Test placing different tower types
	mock_tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	var basic_result = mock_tower_manager.place_tower(Vector2i(0, 0), TowerManagerInterface.BASIC_TOWER)
	var powerful_result = mock_tower_manager.place_tower(Vector2i(1, 1), TowerManagerInterface.POWERFUL_TOWER)
	
	assert_true(basic_result, "Basic tower placement should succeed")
	assert_true(powerful_result, "Powerful tower placement should succeed")

func test_get_enemies_for_towers():
	# Test getting enemies
	var mock_enemy = Node.new()
	mock_tower_manager.add_enemy(mock_enemy)
	
	var enemies = mock_tower_manager.get_enemies_for_towers()
	assert_eq(enemies.size(), 1, "Should return one enemy")
	assert_eq(enemies[0], mock_enemy, "Should return the correct enemy")

func test_get_towers():
	# Test getting towers
	mock_tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_tower_manager.place_tower(Vector2i(0, 0))
	
	var towers = mock_tower_manager.get_towers()
	assert_eq(towers.size(), 1, "Should return one tower")

func test_stop_all_towers():
	# Test stopping all towers
	mock_tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_tower_manager.place_tower(Vector2i(0, 0))
	mock_tower_manager.place_tower(Vector2i(1, 1))
	
	mock_tower_manager.stop_all_towers()
	
	var towers = mock_tower_manager.get_towers()
	for tower in towers:
		assert_true(tower.get_meta("stopped", false), "All towers should be marked as stopped")

func test_cleanup_all_towers():
	# Test cleaning up all towers
	mock_tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	mock_tower_manager.place_tower(Vector2i(0, 0))
	mock_tower_manager.place_tower(Vector2i(1, 1))
	
	assert_eq(mock_tower_manager.get_tower_count(), 2, "Should have 2 towers before cleanup")
	
	mock_tower_manager.cleanup_all_towers()
	
	assert_eq(mock_tower_manager.get_tower_count(), 0, "Should have 0 towers after cleanup")

func test_get_tower_count():
	# Test getting tower count
	mock_tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	assert_eq(mock_tower_manager.get_tower_count(), 0, "Should start with zero towers")
	
	mock_tower_manager.place_tower(Vector2i(0, 0))
	assert_eq(mock_tower_manager.get_tower_count(), 1, "Should have one tower after placement")
	
	mock_tower_manager.place_tower(Vector2i(1, 1))
	assert_eq(mock_tower_manager.get_tower_count(), 2, "Should have two towers after second placement")

func test_get_tower_count_by_type():
	# Test getting tower count by type
	mock_tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	mock_tower_manager.place_tower(Vector2i(0, 0), TowerManagerInterface.BASIC_TOWER)
	mock_tower_manager.place_tower(Vector2i(1, 1), TowerManagerInterface.BASIC_TOWER)
	mock_tower_manager.place_tower(Vector2i(2, 2), TowerManagerInterface.POWERFUL_TOWER)
	
	var basic_count = mock_tower_manager.get_tower_count_by_type(TowerManagerInterface.BASIC_TOWER)
	var powerful_count = mock_tower_manager.get_tower_count_by_type(TowerManagerInterface.POWERFUL_TOWER)
	
	assert_eq(basic_count, 2, "Should have 2 basic towers")
	assert_eq(powerful_count, 1, "Should have 1 powerful tower")

func test_remove_tower():
	# Test removing a specific tower
	mock_tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	var tower1 = mock_tower_manager.place_tower(Vector2i(0, 0))
	var tower2 = mock_tower_manager.place_tower(Vector2i(1, 1))
	
	assert_eq(mock_tower_manager.get_tower_count(), 2, "Should have 2 towers before removal")
	
	var towers = mock_tower_manager.get_towers()
	mock_tower_manager.remove_tower(towers[0])
	
	assert_eq(mock_tower_manager.get_tower_count(), 1, "Should have 1 tower after removal")

func test_get_total_power_level():
	# Test getting total power level
	mock_tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	assert_eq(mock_tower_manager.get_total_power_level(), 0.0, "Should start with zero power level")
	
	mock_tower_manager.place_tower(Vector2i(0, 0))
	assert_eq(mock_tower_manager.get_total_power_level(), 1.5, "Should have power level of 1.5 for one tower")
	
	mock_tower_manager.place_tower(Vector2i(1, 1))
	assert_eq(mock_tower_manager.get_total_power_level(), 3.0, "Should have power level of 3.0 for two towers")

func test_signal_emission_on_tower_placement():
	# Test that signals are emitted when towers are placed
	mock_tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	# Watch for signal emission
	watch_signals(mock_tower_manager)
	
	mock_tower_manager.place_tower(Vector2i(3, 3), TowerManagerInterface.BASIC_TOWER)
	
	assert_signal_emitted_with_parameters(mock_tower_manager, "tower_placed", [Vector2i(3, 3), TowerManagerInterface.BASIC_TOWER])

func test_interface_contract_compliance():
	# Test that all required methods exist and are callable
	mock_tower_manager.initialize(mock_grid_manager, mock_currency_manager, mock_wave_manager)
	
	# Test all interface methods can be called without errors
	assert_not_null(mock_tower_manager.attempt_tower_placement(Vector2i(0, 0)), "attempt_tower_placement should return a value")
	assert_not_null(mock_tower_manager.attempt_basic_tower_placement(Vector2i(0, 0)), "attempt_basic_tower_placement should return a value")
	assert_not_null(mock_tower_manager.place_tower(Vector2i(0, 0)), "place_tower should return a value")
	assert_not_null(mock_tower_manager.get_enemies_for_towers(), "get_enemies_for_towers should return a value")
	assert_not_null(mock_tower_manager.get_towers(), "get_towers should return a value")
	assert_not_null(mock_tower_manager.get_tower_count(), "get_tower_count should return a value")
	assert_not_null(mock_tower_manager.get_tower_count_by_type(TowerManagerInterface.BASIC_TOWER), "get_tower_count_by_type should return a value")
	assert_not_null(mock_tower_manager.get_total_power_level(), "get_total_power_level should return a value")
	
	# Test void methods don't crash
	mock_tower_manager.stop_all_towers()
	mock_tower_manager.cleanup_all_towers()
	mock_tower_manager.remove_tower(Node.new())
	
	assert_true(true, "All interface methods should be callable without errors")

func test_interface_abstract_methods_error_handling():
	# Test that calling abstract methods on the interface directly causes errors
	var interface = TowerManagerInterface.new()
	add_child_autofree(interface)
	
	# These should all cause push_error() calls, which we can't easily test
	# But we can verify the methods exist and are callable
	interface.initialize(Node.new(), CurrencyManager.new(), Node.new())  # void method
	assert_not_null(interface.attempt_tower_placement(Vector2i(0, 0)), "attempt_tower_placement should be callable")
	assert_not_null(interface.attempt_basic_tower_placement(Vector2i(0, 0)), "attempt_basic_tower_placement should be callable")
	assert_not_null(interface.place_tower(Vector2i(0, 0)), "place_tower should be callable")
	assert_not_null(interface.get_enemies_for_towers(), "get_enemies_for_towers should be callable")
	assert_not_null(interface.get_towers(), "get_towers should be callable")
	assert_not_null(interface.get_tower_count(), "get_tower_count should be callable")
	assert_not_null(interface.get_tower_count_by_type(TowerManagerInterface.BASIC_TOWER), "get_tower_count_by_type should be callable")
	assert_not_null(interface.get_total_power_level(), "get_total_power_level should be callable")
	
	# Test void methods don't crash
	interface.stop_all_towers()
	interface.cleanup_all_towers()
	interface.remove_tower(Node.new())
	
	assert_true(true, "All interface abstract methods should be callable")

func test_interface_signals_definition():
	# Test that signals are properly defined on the interface
	var interface = TowerManagerInterface.new()
	add_child_autofree(interface)
	
	# Verify signals exist
	assert_true(interface.has_signal("tower_placed"), "tower_placed signal should exist")
	assert_true(interface.has_signal("tower_placement_failed"), "tower_placement_failed signal should exist")
	
	# Test signal emission (should work even on interface)
	watch_signals(interface)
	interface.tower_placed.emit(Vector2i(1, 1), TowerManagerInterface.BASIC_TOWER)
	interface.tower_placement_failed.emit("Test failure")
	
	assert_signal_emitted_with_parameters(interface, "tower_placed", [Vector2i(1, 1), TowerManagerInterface.BASIC_TOWER])
	assert_signal_emitted_with_parameters(interface, "tower_placement_failed", ["Test failure"])

func test_interface_constants_access():
	# Test that constants can be accessed from the interface
	var interface = TowerManagerInterface.new()
	add_child_autofree(interface)
	
	# Test constant access
	assert_eq(interface.BASIC_TOWER, "basic", "BASIC_TOWER constant should be accessible")
	assert_eq(interface.POWERFUL_TOWER, "powerful", "POWERFUL_TOWER constant should be accessible")
	
	# Test class-level constant access
	assert_eq(TowerManagerInterface.BASIC_TOWER, "basic", "BASIC_TOWER constant should be accessible via class")
	assert_eq(TowerManagerInterface.POWERFUL_TOWER, "powerful", "POWERFUL_TOWER constant should be accessible via class") 