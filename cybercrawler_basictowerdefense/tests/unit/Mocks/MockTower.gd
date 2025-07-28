extends Tower
class_name MockTower

# Mock tower properties for testing RivalAlertSystem
# These override the base Tower properties

func _init():
	# Initialize with test values
	damage = 1
	tower_range = 100.0
	attack_rate = 1.0
	max_health = 4
	health = 4

# Mock methods that might be called during testing
func get_damage() -> int:
	return damage

func get_tower_range() -> float:
	return tower_range

func get_attack_rate() -> float:
	return attack_rate 