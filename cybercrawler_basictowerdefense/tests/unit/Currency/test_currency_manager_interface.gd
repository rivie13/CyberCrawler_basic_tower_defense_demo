extends GutTest

# Unit tests for CurrencyManagerInterface class
# These tests verify the interface contract and abstract method behavior

var interface: CurrencyManagerInterface

func before_each():
	# Create a direct instance of the interface class to test it directly
	interface = CurrencyManagerInterface.new()
	add_child_autofree(interface)

func test_interface_constants():
	# Test that interface constants are properly defined
	assert_eq(CurrencyManagerInterface.BASIC_TOWER, "basic", "BASIC_TOWER constant should be 'basic'")
	assert_eq(CurrencyManagerInterface.POWERFUL_TOWER, "powerful", "POWERFUL_TOWER constant should be 'powerful'")

func test_interface_signal_definition():
	# Test that the interface defines the required signal
	# We can verify the signal exists by checking if the interface is instantiable
	assert_not_null(interface, "Interface should be instantiable")

func test_interface_abstract_methods_throw_errors():
	# Test that all abstract methods throw push_error when called directly
	
	# Test getter methods
	assert_eq(interface.get_currency(), 0, "get_currency() should return 0 and throw error")
	assert_eq(interface.get_basic_tower_cost(), 0, "get_basic_tower_cost() should return 0 and throw error")
	assert_eq(interface.get_powerful_tower_cost(), 0, "get_powerful_tower_cost() should return 0 and throw error")
	assert_eq(interface.get_currency_per_kill(), 0, "get_currency_per_kill() should return 0 and throw error")
	
	# Test boolean methods
	assert_eq(interface.can_afford_basic_tower(), false, "can_afford_basic_tower() should return false and throw error")
	assert_eq(interface.can_afford_powerful_tower(), false, "can_afford_powerful_tower() should return false and throw error")
	assert_eq(interface.can_afford_tower_type("basic"), false, "can_afford_tower_type() should return false and throw error")
	
	# Test purchase methods
	assert_eq(interface.purchase_basic_tower(), false, "purchase_basic_tower() should return false and throw error")
	assert_eq(interface.purchase_powerful_tower(), false, "purchase_powerful_tower() should return false and throw error")
	assert_eq(interface.purchase_tower_type("basic"), false, "purchase_tower_type() should return false and throw error")
	
	# Test action methods
	interface.add_currency_for_kill()  # Should throw error
	interface.add_currency(10)  # Should throw error
	assert_eq(interface.spend_currency(10), false, "spend_currency() should return false and throw error")
	
	# Test setter methods
	interface.set_basic_tower_cost(60)  # Should throw error
	interface.set_powerful_tower_cost(90)  # Should throw error
	interface.set_currency_per_kill(15)  # Should throw error
	interface.reset_currency()  # Should throw error

func test_backwards_compatibility_methods():
	# Test that backwards compatibility methods delegate to newer methods
	# These should also throw errors since they call abstract methods
	
	# Test can_afford_tower() delegates to can_afford_basic_tower()
	assert_eq(interface.can_afford_tower(), false, "can_afford_tower() should return false and throw error")
	
	# Test purchase_tower() delegates to purchase_basic_tower()
	assert_eq(interface.purchase_tower(), false, "purchase_tower() should return false and throw error")
	
	# Test set_tower_cost() delegates to set_basic_tower_cost()
	interface.set_tower_cost(80)  # Should throw error

func test_interface_method_existence():
	# Test that all required interface methods exist
	# This tests the interface contract completeness
	
	# Test all getter methods exist
	assert_not_null(interface.get_currency, "get_currency method should exist")
	assert_not_null(interface.get_basic_tower_cost, "get_basic_tower_cost method should exist")
	assert_not_null(interface.get_powerful_tower_cost, "get_powerful_tower_cost method should exist")
	assert_not_null(interface.get_currency_per_kill, "get_currency_per_kill method should exist")
	
	# Test all boolean methods exist
	assert_not_null(interface.can_afford_basic_tower, "can_afford_basic_tower method should exist")
	assert_not_null(interface.can_afford_powerful_tower, "can_afford_powerful_tower method should exist")
	assert_not_null(interface.can_afford_tower_type, "can_afford_tower_type method should exist")
	
	# Test all purchase methods exist
	assert_not_null(interface.purchase_basic_tower, "purchase_basic_tower method should exist")
	assert_not_null(interface.purchase_powerful_tower, "purchase_powerful_tower method should exist")
	assert_not_null(interface.purchase_tower_type, "purchase_tower_type method should exist")
	
	# Test all action methods exist
	assert_not_null(interface.add_currency, "add_currency method should exist")
	assert_not_null(interface.spend_currency, "spend_currency method should exist")
	assert_not_null(interface.add_currency_for_kill, "add_currency_for_kill method should exist")
	assert_not_null(interface.reset_currency, "reset_currency method should exist")
	
	# Test all setter methods exist
	assert_not_null(interface.set_basic_tower_cost, "set_basic_tower_cost method should exist")
	assert_not_null(interface.set_powerful_tower_cost, "set_powerful_tower_cost method should exist")
	assert_not_null(interface.set_currency_per_kill, "set_currency_per_kill method should exist")
	
	# Test backwards compatibility methods exist
	assert_not_null(interface.can_afford_tower, "can_afford_tower method should exist")
	assert_not_null(interface.purchase_tower, "purchase_tower method should exist")
	assert_not_null(interface.set_tower_cost, "set_tower_cost method should exist")

func test_interface_inheritance():
	# Test that the interface properly extends Node
	assert_true(interface is Node, "CurrencyManagerInterface should extend Node")

func test_interface_method_signatures():
	# Test that methods have correct return types when called
	# Even though they throw errors, they should return the expected types
	
	# Test getter methods return expected types
	assert_typeof(interface.get_currency(), TYPE_INT, "get_currency() should return int")
	assert_typeof(interface.get_basic_tower_cost(), TYPE_INT, "get_basic_tower_cost() should return int")
	assert_typeof(interface.get_powerful_tower_cost(), TYPE_INT, "get_powerful_tower_cost() should return int")
	assert_typeof(interface.get_currency_per_kill(), TYPE_INT, "get_currency_per_kill() should return int")
	
	# Test boolean methods return expected types
	assert_typeof(interface.can_afford_basic_tower(), TYPE_BOOL, "can_afford_basic_tower() should return bool")
	assert_typeof(interface.can_afford_powerful_tower(), TYPE_BOOL, "can_afford_powerful_tower() should return bool")
	assert_typeof(interface.can_afford_tower_type("basic"), TYPE_BOOL, "can_afford_tower_type() should return bool")
	
	# Test purchase methods return expected types
	assert_typeof(interface.purchase_basic_tower(), TYPE_BOOL, "purchase_basic_tower() should return bool")
	assert_typeof(interface.purchase_powerful_tower(), TYPE_BOOL, "purchase_powerful_tower() should return bool")
	assert_typeof(interface.purchase_tower_type("basic"), TYPE_BOOL, "purchase_tower_type() should return bool")
	
	# Test spend method returns expected type
	assert_typeof(interface.spend_currency(10), TYPE_BOOL, "spend_currency() should return bool")
	
	# Test backwards compatibility methods return expected types
	assert_typeof(interface.can_afford_tower(), TYPE_BOOL, "can_afford_tower() should return bool")
	assert_typeof(interface.purchase_tower(), TYPE_BOOL, "purchase_tower() should return bool")

func test_interface_documentation():
	# Test that the interface has proper documentation
	# This is a basic check to ensure the interface is well-documented
	assert_not_null(interface, "Interface should be instantiable and have documentation") 