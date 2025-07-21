class_name CurrencyManagerInterface
extends Node

"""
Interface for currency management systems.
Defines the contract that all currency managers must implement.
"""

# Tower type constants - consistent with TowerManager  
const BASIC_TOWER = "basic"
const POWERFUL_TOWER = "powerful"

# Signals for UI updates
signal currency_changed(new_amount: int)

# Abstract methods that must be implemented
func get_currency() -> int:
	push_error("get_currency() must be implemented by subclass")
	return 0

func get_basic_tower_cost() -> int:
	push_error("get_basic_tower_cost() must be implemented by subclass")
	return 0

func get_powerful_tower_cost() -> int:
	push_error("get_powerful_tower_cost() must be implemented by subclass")
	return 0

func get_currency_per_kill() -> int:
	push_error("get_currency_per_kill() must be implemented by subclass")
	return 0

func can_afford_basic_tower() -> bool:
	push_error("can_afford_basic_tower() must be implemented by subclass")
	return false

func can_afford_powerful_tower() -> bool:
	push_error("can_afford_powerful_tower() must be implemented by subclass")
	return false

func can_afford_tower_type(tower_type: String) -> bool:
	push_error("can_afford_tower_type() must be implemented by subclass")
	return false

func add_currency_for_kill():
	push_error("add_currency_for_kill() must be implemented by subclass")

func purchase_basic_tower() -> bool:
	push_error("purchase_basic_tower() must be implemented by subclass")
	return false

func purchase_powerful_tower() -> bool:
	push_error("purchase_powerful_tower() must be implemented by subclass")
	return false

func purchase_tower_type(tower_type: String) -> bool:
	push_error("purchase_tower_type() must be implemented by subclass")
	return false

func add_currency(amount: int):
	push_error("add_currency() must be implemented by subclass")

func spend_currency(amount: int) -> bool:
	push_error("spend_currency() must be implemented by subclass")
	return false

func set_basic_tower_cost(new_cost: int):
	push_error("set_basic_tower_cost() must be implemented by subclass")

func set_powerful_tower_cost(new_cost: int):
	push_error("set_powerful_tower_cost() must be implemented by subclass")

func set_currency_per_kill(new_amount: int):
	push_error("set_currency_per_kill() must be implemented by subclass")

func reset_currency():
	push_error("reset_currency() must be implemented by subclass")

# Backwards compatibility methods
func can_afford_tower() -> bool:
	return can_afford_basic_tower()

func purchase_tower() -> bool:
	return purchase_basic_tower()

func set_tower_cost(new_cost: int):
	set_basic_tower_cost(new_cost) 