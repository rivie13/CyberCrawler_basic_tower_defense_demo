extends CurrencyManagerInterface
class_name CurrencyManager

# CurrencyManager implements CurrencyManagerInterface
# All methods from CurrencyManagerInterface are implemented below

# Currency system
var player_currency: int = 100  # Starting money for towers
var currency_per_kill: int = 10  # Money earned per enemy killed

# Tower costs - updated to support multiple tower types
var basic_tower_cost: int = 50  # Cost for basic tower
var powerful_tower_cost: int = 75  # Cost for powerful tower

func _ready():
	# Emit initial currency amount
	currency_changed.emit(player_currency)

func get_currency() -> int:
	return player_currency

func get_basic_tower_cost() -> int:
	return basic_tower_cost

func get_powerful_tower_cost() -> int:
	return powerful_tower_cost

func get_currency_per_kill() -> int:
	return currency_per_kill

func can_afford_basic_tower() -> bool:
	return player_currency >= basic_tower_cost

func can_afford_powerful_tower() -> bool:
	return player_currency >= powerful_tower_cost

func can_afford_tower_type(tower_type: String) -> bool:
	match tower_type:
		BASIC_TOWER:
			return can_afford_basic_tower()
		POWERFUL_TOWER:
			return can_afford_powerful_tower()
		_:
			print("Unknown tower type: ", tower_type)
			return false

# Backwards compatibility
func can_afford_tower() -> bool:
	return can_afford_basic_tower()

func add_currency_for_kill():
	player_currency += currency_per_kill
	currency_changed.emit(player_currency)
	print("Currency earned for kill: +%d | Total: %d" % [currency_per_kill, player_currency])

func purchase_basic_tower() -> bool:
	if not can_afford_basic_tower():
		print("Insufficient funds! Need %d currency, have %d" % [basic_tower_cost, player_currency])
		return false
	
	player_currency -= basic_tower_cost
	currency_changed.emit(player_currency)
	print("Basic Tower purchased! Cost: %d | Remaining currency: %d" % [basic_tower_cost, player_currency])
	return true

func purchase_powerful_tower() -> bool:
	if not can_afford_powerful_tower():
		print("Insufficient funds! Need %d currency, have %d" % [powerful_tower_cost, player_currency])
		return false
	
	player_currency -= powerful_tower_cost
	currency_changed.emit(player_currency)
	print("Powerful Tower purchased! Cost: %d | Remaining currency: %d" % [powerful_tower_cost, player_currency])
	return true

func purchase_tower_type(tower_type: String) -> bool:
	match tower_type:
		BASIC_TOWER:
			return purchase_basic_tower()
		POWERFUL_TOWER:
			return purchase_powerful_tower()
		_:
			print("Unknown tower type: ", tower_type)
			return false

# Backwards compatibility 
func purchase_tower() -> bool:
	return purchase_basic_tower()

func add_currency(amount: int):
	if amount > 0:
		player_currency += amount
		currency_changed.emit(player_currency)

func spend_currency(amount: int) -> bool:
	if player_currency >= amount:
		player_currency -= amount
		currency_changed.emit(player_currency)
		return true
	else:
		print("Insufficient funds! Need %d currency, have %d" % [amount, player_currency])
		return false

# Backwards compatibility
func set_tower_cost(new_cost: int):
	if new_cost > 0:
		basic_tower_cost = new_cost

func set_basic_tower_cost(new_cost: int):
	if new_cost > 0:
		basic_tower_cost = new_cost

func set_powerful_tower_cost(new_cost: int):
	if new_cost > 0:
		powerful_tower_cost = new_cost

func set_currency_per_kill(new_amount: int):
	if new_amount >= 0:
		currency_per_kill = new_amount

func reset_currency():
	player_currency = 100  # Reset to starting amount
	currency_changed.emit(player_currency) 
