extends Node
class_name CurrencyManager

# Signals for UI updates
signal currency_changed(new_amount: int)

# Currency system
var player_currency: int = 100  # Starting money for towers
var currency_per_kill: int = 10  # Money earned per enemy killed
var tower_cost: int = 50  # Cost to purchase a tower

func _ready():
	# Emit initial currency amount
	currency_changed.emit(player_currency)

func get_currency() -> int:
	return player_currency

func get_tower_cost() -> int:
	return tower_cost

func get_currency_per_kill() -> int:
	return currency_per_kill

func can_afford_tower() -> bool:
	return player_currency >= tower_cost

func add_currency_for_kill():
	player_currency += currency_per_kill
	currency_changed.emit(player_currency)
	print("Currency earned for kill: +%d | Total: %d" % [currency_per_kill, player_currency])

func purchase_tower() -> bool:
	if not can_afford_tower():
		print("Insufficient funds! Need %d currency, have %d" % [tower_cost, player_currency])
		return false
	
	player_currency -= tower_cost
	currency_changed.emit(player_currency)
	print("Tower purchased! Cost: %d | Remaining currency: %d" % [tower_cost, player_currency])
	return true

func add_currency(amount: int):
	if amount > 0:
		player_currency += amount
		currency_changed.emit(player_currency)

func set_tower_cost(new_cost: int):
	if new_cost > 0:
		tower_cost = new_cost

func set_currency_per_kill(new_amount: int):
	if new_amount >= 0:
		currency_per_kill = new_amount

func reset_currency():
	player_currency = 100  # Reset to starting amount
	currency_changed.emit(player_currency) 