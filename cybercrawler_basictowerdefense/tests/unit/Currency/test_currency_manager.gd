extends GutTest

# Unit tests for CurrencyManager class
# These tests verify the currency system functionality using the real CurrencyManager

var currency_manager: CurrencyManager

func before_each():
	# Setup fresh CurrencyManager for each test (real implementation)
	currency_manager = CurrencyManager.new()
	add_child_autofree(currency_manager)

func test_initial_state():
	# Test that CurrencyManager starts with correct initial values
	assert_eq(currency_manager.get_currency(), 100, "Should start with 100 currency")
	assert_eq(currency_manager.get_basic_tower_cost(), 50, "Basic tower should cost 50")
	assert_eq(currency_manager.get_powerful_tower_cost(), 75, "Powerful tower should cost 75")
	assert_eq(currency_manager.get_currency_per_kill(), 10, "Should get 10 currency per kill")

func test_ready_emits_currency_signal():
	# Test that _ready() emits the initial currency signal
	watch_signals(currency_manager)
	currency_manager._ready()
	
	assert_signal_emitted(currency_manager, "currency_changed", "Should emit currency_changed signal on _ready")

func test_affordability_checks():
	# Test basic tower affordability
	assert_true(currency_manager.can_afford_basic_tower(), "Should be able to afford basic tower initially")
	assert_true(currency_manager.can_afford_powerful_tower(), "Should be able to afford powerful tower initially")
	assert_true(currency_manager.can_afford_tower(), "Backwards compatibility method should work")
	
	# Test with insufficient funds
	currency_manager.player_currency = 25
	assert_false(currency_manager.can_afford_basic_tower(), "Should not afford basic tower with 25 currency")
	assert_false(currency_manager.can_afford_powerful_tower(), "Should not afford powerful tower with 25 currency")
	
	# Test edge case - exactly enough currency
	currency_manager.player_currency = 50
	assert_true(currency_manager.can_afford_basic_tower(), "Should afford basic tower with exactly 50 currency")
	assert_false(currency_manager.can_afford_powerful_tower(), "Should not afford powerful tower with only 50 currency")

func test_tower_type_affordability():
	# Test the tower type specific affordability method
	assert_true(currency_manager.can_afford_tower_type(CurrencyManager.BASIC_TOWER), "Should afford basic tower type")
	assert_true(currency_manager.can_afford_tower_type(CurrencyManager.POWERFUL_TOWER), "Should afford powerful tower type")
	
	# Test with invalid tower type
	assert_false(currency_manager.can_afford_tower_type("invalid_type"), "Should return false for invalid tower type")
	
	# Test with insufficient funds
	currency_manager.player_currency = 25
	assert_false(currency_manager.can_afford_tower_type(CurrencyManager.BASIC_TOWER), "Should not afford basic with 25 currency")
	assert_false(currency_manager.can_afford_tower_type(CurrencyManager.POWERFUL_TOWER), "Should not afford powerful with 25 currency")

func test_basic_tower_purchase():
	# Test successful basic tower purchase
	watch_signals(currency_manager)
	var result = currency_manager.purchase_basic_tower()
	
	assert_true(result, "Purchase should succeed")
	assert_eq(currency_manager.get_currency(), 50, "Should have 50 currency remaining after basic tower purchase")
	assert_signal_emitted(currency_manager, "currency_changed", "Should emit currency_changed signal")

func test_basic_tower_purchase_insufficient_funds():
	# Test failed basic tower purchase with insufficient funds
	currency_manager.player_currency = 25
	watch_signals(currency_manager)
	
	var result = currency_manager.purchase_basic_tower()
	
	assert_false(result, "Purchase should fail with insufficient funds")
	assert_eq(currency_manager.get_currency(), 25, "Currency should remain unchanged")
	assert_signal_not_emitted(currency_manager, "currency_changed", "Should not emit signal when purchase fails")

func test_powerful_tower_purchase():
	# Test successful powerful tower purchase
	watch_signals(currency_manager)
	var result = currency_manager.purchase_powerful_tower()
	
	assert_true(result, "Purchase should succeed")
	assert_eq(currency_manager.get_currency(), 25, "Should have 25 currency remaining after powerful tower purchase")
	assert_signal_emitted(currency_manager, "currency_changed", "Should emit currency_changed signal")

func test_powerful_tower_purchase_insufficient_funds():
	# Test failed powerful tower purchase with insufficient funds
	currency_manager.player_currency = 50
	watch_signals(currency_manager)
	
	var result = currency_manager.purchase_powerful_tower()
	
	assert_false(result, "Purchase should fail with insufficient funds")
	assert_eq(currency_manager.get_currency(), 50, "Currency should remain unchanged")
	assert_signal_not_emitted(currency_manager, "currency_changed", "Should not emit signal when purchase fails")

func test_tower_type_purchase():
	# Test purchasing by tower type
	watch_signals(currency_manager)
	
	var result_basic = currency_manager.purchase_tower_type(CurrencyManager.BASIC_TOWER)
	assert_true(result_basic, "Should successfully purchase basic tower type")
	assert_eq(currency_manager.get_currency(), 50, "Should have 50 currency after basic purchase")
	
	var result_powerful = currency_manager.purchase_tower_type(CurrencyManager.POWERFUL_TOWER)
	assert_false(result_powerful, "Should fail to purchase powerful tower with 50 currency")
	
	# Test invalid tower type
	var result_invalid = currency_manager.purchase_tower_type("invalid_type")
	assert_false(result_invalid, "Should fail with invalid tower type")

func test_backwards_compatibility_purchase():
	# Test backwards compatibility purchase_tower method
	watch_signals(currency_manager)
	var result = currency_manager.purchase_tower()
	
	assert_true(result, "Backwards compatibility purchase should succeed")
	assert_eq(currency_manager.get_currency(), 50, "Should deduct basic tower cost")
	assert_signal_emitted(currency_manager, "currency_changed", "Should emit signal")

func test_add_currency_for_kill():
	# Test adding currency for enemy kills
	watch_signals(currency_manager)
	var initial_currency = currency_manager.get_currency()
	
	currency_manager.add_currency_for_kill()
	
	assert_eq(currency_manager.get_currency(), initial_currency + 10, "Should add 10 currency for kill")
	assert_signal_emitted(currency_manager, "currency_changed", "Should emit currency_changed signal")

func test_add_currency():
	# Test generic add currency method
	watch_signals(currency_manager)
	var initial_currency = currency_manager.get_currency()
	
	currency_manager.add_currency(50)
	assert_eq(currency_manager.get_currency(), initial_currency + 50, "Should add 50 currency")
	assert_signal_emitted(currency_manager, "currency_changed", "Should emit signal")
	
	# Test adding zero or negative (should not change)
	currency_manager.add_currency(0)
	currency_manager.add_currency(-10)
	assert_eq(currency_manager.get_currency(), initial_currency + 50, "Should not change currency for zero/negative amounts")

func test_spend_currency():
	# Test spending currency
	watch_signals(currency_manager)
	
	# Test successful spending
	var result_success = currency_manager.spend_currency(30)
	assert_true(result_success, "Should successfully spend 30 currency")
	assert_eq(currency_manager.get_currency(), 70, "Should have 70 currency remaining")
	assert_signal_emitted(currency_manager, "currency_changed", "Should emit signal on successful spend")
	
	# Test spending more than available
	var result_fail = currency_manager.spend_currency(100)
	assert_false(result_fail, "Should fail to spend 100 currency when only 70 available")
	assert_eq(currency_manager.get_currency(), 70, "Currency should remain unchanged when spending fails")

func test_cost_setters():
	# Test setting tower costs - this test modifies costs but doesn't affect other tests
	# because each test gets a fresh CurrencyManager instance
	
	# Test setting basic tower cost
	currency_manager.set_basic_tower_cost(60)
	assert_eq(currency_manager.get_basic_tower_cost(), 60, "Should update basic tower cost")
	
	# Test setting powerful tower cost
	currency_manager.set_powerful_tower_cost(100)
	assert_eq(currency_manager.get_powerful_tower_cost(), 100, "Should update powerful tower cost")
	
	# Test backwards compatibility setter
	currency_manager.set_tower_cost(80)
	assert_eq(currency_manager.get_basic_tower_cost(), 80, "Backwards compatibility setter should work")
	
	# Test invalid cost values (should not change)
	currency_manager.set_basic_tower_cost(0)
	assert_eq(currency_manager.get_basic_tower_cost(), 80, "Should not set cost to 0")
	
	currency_manager.set_basic_tower_cost(-10)
	assert_eq(currency_manager.get_basic_tower_cost(), 80, "Should not set negative cost")

func test_cost_modification_affects_purchase():
	# Test that cost modifications actually affect purchase behavior
	currency_manager.set_basic_tower_cost(40)
	
	# Should now be able to purchase basic tower for 40 instead of 50
	watch_signals(currency_manager)
	var result = currency_manager.purchase_basic_tower()
	
	assert_true(result, "Purchase should succeed with modified cost")
	assert_eq(currency_manager.get_currency(), 60, "Should have 60 currency remaining after 40 cost purchase")
	assert_signal_emitted(currency_manager, "currency_changed", "Should emit signal")

func test_currency_per_kill_setter():
	# Test setting currency per kill
	currency_manager.set_currency_per_kill(15)
	assert_eq(currency_manager.get_currency_per_kill(), 15, "Should update currency per kill")
	
	# Test zero is valid
	currency_manager.set_currency_per_kill(0)
	assert_eq(currency_manager.get_currency_per_kill(), 0, "Should allow zero currency per kill")
	
	# Test negative should not change
	currency_manager.set_currency_per_kill(-5)
	assert_eq(currency_manager.get_currency_per_kill(), 0, "Should not set negative currency per kill")

func test_reset_currency():
	# Test resetting currency to initial amount
	currency_manager.player_currency = 200
	watch_signals(currency_manager)
	
	currency_manager.reset_currency()
	
	assert_eq(currency_manager.get_currency(), 100, "Should reset to 100 currency")
	assert_signal_emitted(currency_manager, "currency_changed", "Should emit signal on reset")

func test_currency_constants():
	# Test that the constants are accessible
	assert_eq(CurrencyManager.BASIC_TOWER, "basic", "Basic tower constant should be 'basic'")
	assert_eq(CurrencyManager.POWERFUL_TOWER, "powerful", "Powerful tower constant should be 'powerful'") 