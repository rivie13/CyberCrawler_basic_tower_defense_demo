extends Tower
class_name PowerfulTower

# Enhanced tower properties for powerful tower
# These stats will give a power level of ~0.82 (well above 0.7 threshold)

func _ready():
	# Set enhanced stats before calling parent _ready()
	damage = 4  # Enhanced damage (vs 1 for basic tower)
	tower_range = 250.0  # Enhanced range (vs 150.0 for basic tower)
	attack_rate = 2.5  # Enhanced attack rate (vs 1.0 for basic tower)
	projectile_speed = 400.0  # Faster projectiles
	max_health = 6  # More health than basic tower
	health = 6
	
	# Call parent setup
	super._ready()

func create_tower_visual():
	# Create tower body with distinct powerful tower appearance (red-orange)
	tower_body = ColorRect.new()
	tower_body.size = Vector2(70, 70)  # Slightly larger than basic tower
	tower_body.position = Vector2(-35, -35)
	tower_body.color = Color(0.9, 0.3, 0.1, 0.9)  # Red-orange color to indicate power
	add_child(tower_body)
	
	# Create a border to make it more distinct
	var tower_border = ColorRect.new()
	tower_border.size = Vector2(74, 74)
	tower_border.position = Vector2(-37, -37)
	tower_border.color = Color(1.0, 0.6, 0.0, 0.8)  # Orange border
	add_child(tower_border)
	move_child(tower_border, 0)  # Put border behind main body
	
	# Create health bar background
	health_bar_bg = ColorRect.new()
	health_bar_bg.size = Vector2(76, 8)
	health_bar_bg.position = Vector2(-38, -48)
	health_bar_bg.color = Color(0.3, 0.3, 0.3, 0.8)
	add_child(health_bar_bg)
	
	# Create health bar
	health_bar = ColorRect.new()
	health_bar.size = Vector2(72, 6)
	health_bar.position = Vector2(-36, -47)
	health_bar.color = Color(0.9, 0.1, 0.1, 0.9)  # Red health bar for powerful tower
	add_child(health_bar)
	
	# Create range indicator (visible when selected)
	range_circle = Node2D.new()
	add_child(range_circle)

func get_tower_description() -> String:
	return "Powerful Tower - Enhanced damage, range, and attack speed. Will trigger rival alert systems!"

func get_tower_cost() -> int:
	return 75  # More expensive than basic tower (basic is likely 25-50) 