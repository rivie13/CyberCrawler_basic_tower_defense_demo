extends GutTest

# Unit tests for PowerfulTower class
# These tests verify the powerful tower behavior and functionality

var powerful_tower: PowerfulTower

func before_each():
	# Setup fresh PowerfulTower for each test
	powerful_tower = PowerfulTower.new()
	add_child_autofree(powerful_tower)

func test_initial_state():
	# Test that PowerfulTower starts with correct initial values
	# Note: _ready() might be called automatically during test setup
	# So we check for either the default Tower values or the enhanced PowerfulTower values
	assert_true(powerful_tower.damage == 1 or powerful_tower.damage == 4, "Should start with default or enhanced damage")
	assert_true(powerful_tower.tower_range == 150.0 or powerful_tower.tower_range == 250.0, "Should start with default or enhanced range")
	assert_true(powerful_tower.attack_rate == 1.0 or powerful_tower.attack_rate == 2.5, "Should start with default or enhanced attack rate")
	assert_true(powerful_tower.projectile_speed == 300.0 or powerful_tower.projectile_speed == 400.0, "Should start with default or enhanced projectile speed")
	assert_true(powerful_tower.max_health == 4 or powerful_tower.max_health == 6, "Should start with default or enhanced max health")
	assert_true(powerful_tower.health == 4 or powerful_tower.health == 6, "Should start with default or enhanced health")

func test_ready_sets_enhanced_stats():
	# Test that _ready() sets the enhanced stats
	powerful_tower._ready()
	
	assert_eq(powerful_tower.damage, 4, "Should have enhanced damage of 4")
	assert_eq(powerful_tower.tower_range, 250.0, "Should have enhanced range of 250.0")
	assert_eq(powerful_tower.attack_rate, 2.5, "Should have enhanced attack rate of 2.5")
	assert_eq(powerful_tower.projectile_speed, 400.0, "Should have faster projectile speed of 400.0")
	assert_eq(powerful_tower.max_health, 6, "Should have enhanced max health of 6")
	assert_eq(powerful_tower.health, 6, "Should have full health of 6")

func test_create_tower_visual():
	# Test visual creation
	var child_count_before = powerful_tower.get_child_count()
	
	powerful_tower.create_tower_visual()
	
	# Should have created visual elements
	assert_gt(powerful_tower.get_child_count(), child_count_before, "Should create visual children")
	
	# Check for specific visual components
	assert_not_null(powerful_tower.tower_body, "Should create tower body")
	assert_not_null(powerful_tower.health_bar_bg, "Should create health bar background")
	assert_not_null(powerful_tower.health_bar, "Should create health bar")
	assert_not_null(powerful_tower.range_circle, "Should create range circle")

func test_tower_body_properties():
	# Test tower body visual properties
	powerful_tower.create_tower_visual()
	
	assert_eq(powerful_tower.tower_body.size, Vector2(70, 70), "Should have size 70x70")
	assert_eq(powerful_tower.tower_body.position, Vector2(-35, -35), "Should be centered")
	assert_eq(powerful_tower.tower_body.color, Color(0.9, 0.3, 0.1, 0.9), "Should have red-orange color")

func test_health_bar_properties():
	# Test health bar visual properties
	powerful_tower.create_tower_visual()
	
	assert_eq(powerful_tower.health_bar_bg.size, Vector2(76, 8), "Health bar background should be 76x8")
	assert_eq(powerful_tower.health_bar_bg.position, Vector2(-38, -48), "Health bar background should be positioned correctly")
	assert_eq(powerful_tower.health_bar_bg.color, Color(0.3, 0.3, 0.3, 0.8), "Health bar background should be dark gray")
	
	assert_eq(powerful_tower.health_bar.size, Vector2(72, 6), "Health bar should be 72x6")
	assert_eq(powerful_tower.health_bar.position, Vector2(-36, -47), "Health bar should be positioned correctly")
	assert_eq(powerful_tower.health_bar.color, Color(0.9, 0.1, 0.1, 0.9), "Health bar should be red")

func test_tower_border():
	# Test that tower border is created
	powerful_tower.create_tower_visual()
	
	# Look for the border (should be the first child)
	var border = powerful_tower.get_child(0)
	assert_not_null(border, "Should have border as first child")
	assert_true(border is ColorRect, "Border should be a ColorRect")
	assert_eq(border.size, Vector2(74, 74), "Border should be 74x74")
	assert_eq(border.position, Vector2(-37, -37), "Border should be positioned correctly")
	assert_eq(border.color, Color(1.0, 0.6, 0.0, 0.8), "Border should be orange")

func test_get_tower_description():
	# Test tower description
	var description = powerful_tower.get_tower_description()
	assert_eq(description, "Powerful Tower - Enhanced damage, range, and attack speed. Will trigger rival alert systems!", "Should return correct description")

func test_get_tower_cost():
	# Test tower cost
	var cost = powerful_tower.get_tower_cost()
	assert_eq(cost, 75, "Should cost 75 currency")

func test_enhanced_stats_comparison():
	# Test that stats are enhanced compared to basic tower
	powerful_tower._ready()
	
	# These should be significantly higher than basic tower values
	assert_gt(powerful_tower.damage, 1, "Damage should be higher than basic tower")
	assert_gt(powerful_tower.tower_range, 150.0, "Range should be higher than basic tower")
	assert_gt(powerful_tower.attack_rate, 1.0, "Attack rate should be higher than basic tower")
	assert_gt(powerful_tower.max_health, 4, "Max health should be higher than basic tower")

func test_power_level_calculation():
	# Test that power level is above threshold (0.7)
	powerful_tower._ready()
	
	# Calculate approximate power level based on stats
	var damage_factor = powerful_tower.damage / 4.0  # Normalize damage
	var range_factor = powerful_tower.tower_range / 250.0  # Normalize range
	var attack_factor = powerful_tower.attack_rate / 2.5  # Normalize attack rate
	var health_factor = powerful_tower.max_health / 6.0  # Normalize health
	
	var power_level = (damage_factor + range_factor + attack_factor + health_factor) / 4.0
	assert_gte(power_level, 0.7, "Power level should be above 0.7 threshold")

func test_visual_hierarchy():
	# Test that visual elements are created in correct hierarchy
	powerful_tower.create_tower_visual()
	
	# Border should be first child (behind everything)
	var border = powerful_tower.get_child(0)
	assert_true(border is ColorRect, "First child should be border")
	assert_eq(border.size, Vector2(74, 74), "First child should be border with correct size")
	
	# Tower body should be third child (after parent's visual elements and border)
	var body = powerful_tower.get_child(2)
	assert_true(body is ColorRect, "Third child should be tower body")
	assert_eq(body.size, Vector2(70, 70), "Third child should be tower body with correct size")

func test_health_bar_initial_state():
	# Test health bar reflects initial health
	powerful_tower._ready()
	powerful_tower.create_tower_visual()
	
	# Health bar should reflect full health initially
	var expected_width = 72 * (powerful_tower.health / float(powerful_tower.max_health))
	assert_almost_eq(powerful_tower.health_bar.size.x, expected_width, 1.0, "Health bar width should reflect current health")

func test_range_circle_creation():
	# Test range circle is created
	powerful_tower.create_tower_visual()
	
	assert_not_null(powerful_tower.range_circle, "Range circle should be created")
	assert_true(powerful_tower.range_circle is Node2D, "Range circle should be Node2D")

func test_inheritance_from_tower():
	# Test that PowerfulTower properly inherits from Tower
	assert_true(powerful_tower is Tower, "PowerfulTower should inherit from Tower")
	
	# Test that it can use Tower methods
	powerful_tower._ready()
	powerful_tower.set_grid_position(Vector2i(3, 4))
	assert_eq(powerful_tower.get_grid_position(), Vector2i(3, 4), "Should inherit grid position methods from Tower")

func test_visual_distinctiveness():
	# Test that powerful tower has distinct visual appearance
	powerful_tower.create_tower_visual()
	
	# Should have red-orange color to indicate power
	assert_eq(powerful_tower.tower_body.color, Color(0.9, 0.3, 0.1, 0.9), "Should have distinctive red-orange color")
	
	# Should have orange border
	var border = powerful_tower.get_child(0)
	assert_eq(border.color, Color(1.0, 0.6, 0.0, 0.8), "Should have distinctive orange border")
	
	# Should have red health bar
	assert_eq(powerful_tower.health_bar.color, Color(0.9, 0.1, 0.1, 0.9), "Should have distinctive red health bar") 
