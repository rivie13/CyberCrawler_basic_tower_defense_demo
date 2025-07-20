extends GutTest

# Small integration test to verify currency flow through the system
# This tests that when enemies die, currency is properly awarded

var game_manager: GameManager
var wave_manager: WaveManager
var currency_manager: CurrencyManager
var tower_manager: TowerManager

func before_each():
	# Create managers for integration testing
	game_manager = GameManager.new()
	wave_manager = WaveManager.new()
	currency_manager = CurrencyManager.new()
	tower_manager = TowerManager.new()
	
	# Create a mock GridManager for tower placement tests
	var grid_manager = GridManager.new()
	
	# Add to scene
	add_child_autofree(game_manager)
	add_child_autofree(wave_manager)
	add_child_autofree(currency_manager)
	add_child_autofree(tower_manager)
	add_child_autofree(grid_manager)
	
	# Initialize the integration
	game_manager.initialize(wave_manager, currency_manager, tower_manager)
	tower_manager.initialize(grid_manager, currency_manager, wave_manager)

func test_currency_flow_when_enemy_dies():
	# Test that currency flows correctly when an enemy dies
	# This is a SMALL integration test focusing on one mechanic
	
	# Get initial currency
	var initial_currency = currency_manager.get_currency()
	
	# Create a mock enemy
	var enemy = Enemy.new()
	add_child_autofree(enemy)
	
	# Simulate enemy death by calling the game manager's enemy died handler
	game_manager._on_enemy_died(enemy)
	
	# Verify currency increased
	var new_currency = currency_manager.get_currency()
	assert_gt(new_currency, initial_currency, "Currency should increase when enemy dies")
	
	# Verify enemy kill count increased
	assert_eq(game_manager.enemies_killed, 1, "Enemy kill count should increase")

func test_currency_flow_multiple_enemies():
	# Test currency flow with multiple enemies
	# This tests the integration over multiple events
	
	var initial_currency = currency_manager.get_currency()
	
	# Kill multiple enemies
	for i in range(3):
		var enemy = Enemy.new()
		add_child_autofree(enemy)
		game_manager._on_enemy_died(enemy)
	
	# Verify currency increased by expected amount
	var new_currency = currency_manager.get_currency()
	var expected_increase = 3 * currency_manager.get_currency_per_kill()
	assert_eq(new_currency, initial_currency + expected_increase, "Currency should increase by correct amount for 3 kills")
	
	# Verify kill count
	assert_eq(game_manager.enemies_killed, 3, "Enemy kill count should be 3")

func test_currency_flow_with_tower_purchase():
	# Test that currency is properly deducted when buying towers
	# This tests the integration between currency and tower systems
	
	var initial_currency = currency_manager.get_currency()
	
	# Attempt to place a tower at a valid grid position (not on path, not blocked)
	var grid_pos = Vector2i(1, 1)  # Use a position that should be valid
	var result = tower_manager.attempt_tower_placement(grid_pos)
	
	# Verify tower placement was successful
	assert_true(result, "Tower placement should succeed")
	
	# Verify currency was deducted
	var new_currency = currency_manager.get_currency()
	assert_lt(new_currency, initial_currency, "Currency should decrease after tower purchase")

func test_currency_flow_insufficient_funds():
	# Test that tower placement fails when insufficient funds
	# This tests the integration between currency and tower validation
	
	# Spend all currency using valid grid positions
	var grid_positions = [Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2), Vector2i(3, 1)]
	var pos_index = 0
	
	while currency_manager.get_currency() >= currency_manager.get_basic_tower_cost():
		if pos_index >= grid_positions.size():
			break  # Prevent infinite loop
		tower_manager.attempt_tower_placement(grid_positions[pos_index])
		pos_index += 1
	
	# Verify we're out of money
	assert_lt(currency_manager.get_currency(), currency_manager.get_basic_tower_cost(), "Should be out of money")
	
	# Try to place another tower
	var result = tower_manager.attempt_tower_placement(Vector2i(4, 4))
	
	# Verify placement failed due to insufficient funds
	assert_false(result, "Tower placement should fail when insufficient funds")

func test_currency_flow_game_state_integration():
	# Test that currency flow integrates with game state
	# This tests that the game manager properly tracks currency in game state
	
	var initial_currency = currency_manager.get_currency()
	
	# Kill an enemy
	var enemy = Enemy.new()
	add_child_autofree(enemy)
	game_manager._on_enemy_died(enemy)
	
	# Verify game manager's victory data includes correct currency
	var victory_data = game_manager.get_victory_data()
	assert_eq(victory_data.currency, currency_manager.get_currency(), "Victory data should include current currency")
	assert_gt(victory_data.currency, initial_currency, "Victory data currency should reflect enemy kill") 