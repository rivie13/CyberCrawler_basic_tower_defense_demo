extends CurrencyManagerInterface
class_name MockCurrencyManager

# Mock state
var _currency: int = 1000
var _purchase_history: Array = []
var _spent_amount: int = 0
var _basic_tower_cost: int = 50
var _powerful_tower_cost: int = 75
var _currency_per_kill: int = 10

func get_currency() -> int:
	return _currency

func get_basic_tower_cost() -> int:
	return _basic_tower_cost

func get_powerful_tower_cost() -> int:
	return _powerful_tower_cost

func get_currency_per_kill() -> int:
	return _currency_per_kill

func can_afford_basic_tower() -> bool:
	return _currency >= _basic_tower_cost

func can_afford_powerful_tower() -> bool:
	return _currency >= _powerful_tower_cost

func can_afford_tower_type(tower_type: String) -> bool:
	match tower_type:
		BASIC_TOWER:
			return can_afford_basic_tower()
		POWERFUL_TOWER:
			return can_afford_powerful_tower()
		_:
			return false

func add_currency_for_kill():
	add_currency(_currency_per_kill)

func purchase_basic_tower() -> bool:
	return purchase_tower_type(BASIC_TOWER)

func purchase_powerful_tower() -> bool:
	return purchase_tower_type(POWERFUL_TOWER)

func purchase_tower_type(tower_type: String) -> bool:
	var cost = 0
	match tower_type:
		BASIC_TOWER:
			cost = _basic_tower_cost
		POWERFUL_TOWER:
			cost = _powerful_tower_cost
		_:
			return false
	
	return spend_currency(cost)

func add_currency(amount: int):
	_currency += amount
	currency_changed.emit(_currency)

func spend_currency(amount: int) -> bool:
	if _currency >= amount:
		_currency -= amount
		_spent_amount = amount
		_purchase_history.append(amount)
		currency_changed.emit(_currency)
		return true
	return false

func can_afford(amount: int) -> bool:
	return _currency >= amount

func set_basic_tower_cost(new_cost: int):
	_basic_tower_cost = new_cost

func set_powerful_tower_cost(new_cost: int):
	_powerful_tower_cost = new_cost

func set_currency_per_kill(new_amount: int):
	_currency_per_kill = new_amount

func reset_currency():
	_currency = 1000
	_purchase_history.clear()
	_spent_amount = 0
	currency_changed.emit(_currency)

# Helper methods for tests
func set_currency(amount: int) -> void:
	_currency = amount
	currency_changed.emit(_currency)

func get_purchase_history() -> Array:
	return _purchase_history

func get_spent_amount() -> int:
	return _spent_amount

func reset() -> void:
	_currency = 1000
	_purchase_history.clear()
	_spent_amount = 0
	currency_changed.emit(_currency) 