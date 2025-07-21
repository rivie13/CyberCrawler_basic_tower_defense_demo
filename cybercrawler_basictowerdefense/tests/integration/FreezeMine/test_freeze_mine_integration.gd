extends GutTest

# Small integration test to verify freeze mine integration
# This tests that freeze mines integrate with grid and enemy systems

var freeze_mine_manager: FreezeMineManager
var grid_manager: GridManager
var currency_manager: CurrencyManager
var enemy: Enemy

func before_each():
	# Create components for integration testing
	freeze_mine_manager = FreezeMineManager.new()
	grid_manager = GridManager.new()
	currency_manager = CurrencyManager.new()
	enemy = Enemy.new()
	
	# Add to scene
	add_child_autofree(freeze_mine_manager)
	add_child_autofree(grid_manager)
	add_child_autofree(currency_manager)
	add_child_autofree(enemy)
	
	# Initialize the integration
	freeze_mine_manager.initialize(grid_manager, currency_manager)

func test_freeze_mine_initialization():
	# Test that FreezeMineManager initializes properly
	# This is the SMALLEST possible integration test
	
	# Verify manager was created with proper properties
	assert_not_null(freeze_mine_manager.grid_manager, "GridManager should be set")
	assert_not_null(freeze_mine_manager.currency_manager, "CurrencyManager should be set")
	assert_eq(freeze_mine_manager.get_mine_count(), 0, "Should start with 0 mines")

func test_freeze_mine_placement_integration():
	# Test that freeze mine placement integrates with grid system
	# This tests the integration between freeze mine and grid management
	
	# Get initial currency
	var initial_currency = currency_manager.get_currency()
	
	# Place a freeze mine at a valid position
	var grid_pos = Vector2i(2, 2)
	var result = freeze_mine_manager.place_mine(grid_pos, "freeze")
	
	# Verify placement was successful
	assert_true(result, "Freeze mine placement should succeed")
	
	# Verify currency was deducted
	var new_currency = currency_manager.get_currency()
	assert_lt(new_currency, initial_currency, "Currency should decrease after freeze mine placement")
	
	# Verify mine count increased
	assert_eq(freeze_mine_manager.get_mine_count(), 1, "Mine count should increase")

func test_freeze_mine_grid_occupation():
	# Test that freeze mines properly occupy grid positions
	# This tests the integration between freeze mine and grid occupation
	
	var grid_pos = Vector2i(3, 3)
	
	# Verify position is initially free
	assert_false(grid_manager.is_grid_occupied(grid_pos), "Position should be initially free")
	
	# Place freeze mine
	freeze_mine_manager.place_mine(grid_pos, "freeze")
	
	# Verify position is now occupied
	assert_true(grid_manager.is_grid_occupied(grid_pos), "Position should be occupied after freeze mine placement")

func test_freeze_mine_trigger_integration():
	# Test that freeze mines can trigger and affect enemies
	# This tests the integration between freeze mine and enemy systems
	
	# Place a freeze mine
	var grid_pos = Vector2i(2, 2)
	freeze_mine_manager.place_mine(grid_pos, "freeze")
	
	# Get the freeze mine
	var mines = freeze_mine_manager.get_mines()
	assert_eq(mines.size(), 1, "Should have one mine")
	
	# Test that freeze mine can be triggered
	var freeze_mine = mines[0]
	watch_signals(freeze_mine)
	
	# Trigger the freeze mine
	freeze_mine.trigger_mine()
	
	# Verify signal was emitted
	assert_signal_emitted(freeze_mine, "mine_triggered")

func test_freeze_mine_insufficient_funds():
	# Test that freeze mine placement fails when insufficient funds
	# This tests the integration between freeze mine and currency systems
	
	# Spend all currency
	currency_manager.spend_currency(currency_manager.get_currency())
	
	# Try to place freeze mine
	var grid_pos = Vector2i(2, 2)
	var result = freeze_mine_manager.place_mine(grid_pos, "freeze")
	
	# Verify placement failed due to insufficient funds
	assert_false(result, "Freeze mine placement should fail when insufficient funds") 