extends Node2D

# Grid constants
const GRID_SIZE = 64  # Size of each grid cell in pixels
const GRID_WIDTH = 15  # Number of grid cells horizontally
const GRID_HEIGHT = 10  # Number of grid cells vertically

# Grid data - true means occupied, false means empty
var grid_data: Array = []
var path_grid_positions: Array[Vector2i] = []  # Track which grid positions are on enemy path
var path_visual_elements: Array = []  # Visual indicators for the path
var grid_container: Node2D
var grid_lines: Array = []

# Colors for visualization
const GRID_COLOR = Color(0.8, 0.8, 0.8, 1.0)
const OCCUPIED_COLOR = Color(0.8, 0.2, 0.2, 0.6)
const HOVER_COLOR = Color(0.2, 0.8, 0.2, 0.6)
const PATH_COLOR = Color(0.9, 0.7, 0.3, 0.8)  # Orange/yellow for enemy path

# Current hover position
var hover_grid_pos: Vector2i = Vector2i(-1, -1)

# Enemy spawning
const ENEMY_SCENE = preload("res://scenes/Enemy.tscn")
const TOWER_SCENE = preload("res://scenes/Tower.tscn")
var enemy_spawn_timer: Timer
var wave_timer: Timer
var enemies_alive: Array[Enemy] = []
var enemy_path: Array[Vector2] = []
var towers_placed: Array[Tower] = []

# Wave system
var current_wave: int = 1
var enemies_per_wave: int = 5
var enemies_spawned_this_wave: int = 0
var wave_active: bool = false
var time_between_enemies: float = 1.0
var time_between_waves: float = 3.0
var max_waves: int = 10  # Win condition: survive 10 waves

# Timer system
var game_session_start_time: int = 0
var wave_countdown_time: float = 0.0
var wave_countdown_active: bool = false

# Game state
var player_health: int = 10
var enemies_killed: int = 0
var player_currency: int = 100  # Starting money for towers
var currency_per_kill: int = 10  # Money earned per enemy killed
var tower_cost: int = 50  # Cost to purchase a tower
var game_over: bool = false
var game_won: bool = false

func _ready():
	grid_container = $GridContainer
	initialize_grid()
	draw_grid()
	setup_enemy_spawning()
	create_enemy_path()
	draw_enemy_path()
	
	# Initialize timer system
	game_session_start_time = Time.get_ticks_msec()
	
	# Initialize tower selection UI
	setup_tower_selection_ui()
	
	start_wave()

func setup_tower_selection_ui():
	# Connect to tower selection button
	var tower_button = $UI/TowerSelectionPanel/BasicTowerButton
	if tower_button:
		tower_button.pressed.connect(_on_tower_selected)
	
	# Update tower selection UI
	update_tower_selection_ui()

func _on_tower_selected():
	# For now, just provide feedback that tower is selected
	# In future versions, this could switch between different tower types
	print("Basic Tower selected - Click on grid to place (Cost: %d)" % [tower_cost])

func update_tower_selection_ui():
	# Update cost label
	var cost_label = $UI/TowerSelectionPanel/CostLabel
	if cost_label:
		cost_label.text = "Cost: %d" % [tower_cost]
	
	# Update currency label
	var currency_label = $UI/TowerSelectionPanel/CurrencyLabel  
	if currency_label:
		currency_label.text = "Currency: %d" % [player_currency]
		
		# Change color based on affordability
		if player_currency >= tower_cost:
			currency_label.modulate = Color.WHITE
		else:
			currency_label.modulate = Color.RED

func _process(_delta):
	# Update wave countdown if active
	if wave_countdown_active:
		wave_countdown_time = wave_timer.time_left
		update_info_label()

func initialize_grid():
	# Initialize grid data array
	grid_data = []
	for y in range(GRID_HEIGHT):
		var row = []
		for x in range(GRID_WIDTH):
			row.append(false)  # false = empty, true = occupied
		grid_data.append(row)

func draw_grid():
	# Clear existing grid lines
	for line in grid_lines:
		if line:
			line.queue_free()
	grid_lines.clear()
	
	# Create grid lines
	# Vertical lines
	for x in range(GRID_WIDTH + 1):
		var line = Line2D.new()
		line.add_point(Vector2(x * GRID_SIZE, 0))
		line.add_point(Vector2(x * GRID_SIZE, GRID_HEIGHT * GRID_SIZE))
		line.default_color = GRID_COLOR
		line.width = 2
		line.z_index = 1  # Make sure lines are visible
		grid_container.add_child(line)
		grid_lines.append(line)
	
	# Horizontal lines
	for y in range(GRID_HEIGHT + 1):
		var line = Line2D.new()
		line.add_point(Vector2(0, y * GRID_SIZE))
		line.add_point(Vector2(GRID_WIDTH * GRID_SIZE, y * GRID_SIZE))
		line.default_color = GRID_COLOR
		line.width = 2
		line.z_index = 1  # Make sure lines are visible
		grid_container.add_child(line)
		grid_lines.append(line)

func _input(event):
	if game_over or game_won:
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var world_mouse_pos = get_global_mouse_position()
		handle_grid_click(world_mouse_pos)
	elif event is InputEventMouseMotion:
		var world_mouse_pos = get_global_mouse_position()
		handle_mouse_hover(world_mouse_pos)

func handle_grid_click(global_pos: Vector2):
	var grid_pos = world_to_grid(global_pos)
	
	if is_valid_grid_position(grid_pos):
		if is_on_enemy_path(grid_pos):
			print("Cannot place tower on enemy path: ", grid_pos)
		elif not is_grid_occupied(grid_pos):
			place_tower(grid_pos)
		else:
			print("Grid position already occupied: ", grid_pos)

func handle_mouse_hover(global_pos: Vector2):
	var new_hover_pos = world_to_grid(global_pos)
	
	if new_hover_pos != hover_grid_pos:
		hover_grid_pos = new_hover_pos
		queue_redraw()

func world_to_grid(world_pos: Vector2) -> Vector2i:
	# Convert world position directly to grid coordinates
	# Since get_global_mouse_position() accounts for camera transform,
	# we just need to convert to grid space
	var grid_x = int(floor(world_pos.x / GRID_SIZE))
	var grid_y = int(floor(world_pos.y / GRID_SIZE))
	return Vector2i(grid_x, grid_y)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	var world_x = grid_pos.x * GRID_SIZE + GRID_SIZE / 2.0
	var world_y = grid_pos.y * GRID_SIZE + GRID_SIZE / 2.0
	return Vector2(world_x, world_y)

func is_valid_grid_position(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < GRID_WIDTH and grid_pos.y >= 0 and grid_pos.y < GRID_HEIGHT

func is_grid_occupied(grid_pos: Vector2i) -> bool:
	if not is_valid_grid_position(grid_pos):
		return true
	return grid_data[grid_pos.y][grid_pos.x]

func is_on_enemy_path(grid_pos: Vector2i) -> bool:
	return grid_pos in path_grid_positions

func is_game_over() -> bool:
	return game_over

func place_tower(grid_pos: Vector2i):
	if not is_valid_grid_position(grid_pos) or is_grid_occupied(grid_pos):
		return false
	
	# Prevent placing towers on enemy path
	if is_on_enemy_path(grid_pos):
		print("Cannot place tower on enemy path at position: ", grid_pos)
		return false
	
	# Check if player has enough currency
	if player_currency < tower_cost:
		print("Insufficient funds! Need %d currency, have %d" % [tower_cost, player_currency])
		return false
	
	# Deduct currency for tower purchase
	player_currency -= tower_cost
	
	# Mark grid as occupied
	grid_data[grid_pos.y][grid_pos.x] = true
	
	# Create tower from scene
	var tower = TOWER_SCENE.instantiate()
	var world_pos = grid_to_world(grid_pos)
	tower.global_position = world_pos
	tower.set_grid_position(grid_pos)
	
	# Add to containers
	towers_placed.append(tower)
	grid_container.add_child(tower)
	
	# Update UI immediately after purchase
	update_info_label()
	update_tower_selection_ui()
	
	print("Tower purchased at grid position: ", grid_pos, " | Cost: ", tower_cost, " | Remaining currency: ", player_currency)
	return true

func get_enemies() -> Array[Enemy]:
	return enemies_alive

func _draw():
	# Draw hover highlight
	if is_valid_grid_position(hover_grid_pos) and not is_grid_occupied(hover_grid_pos) and not is_on_enemy_path(hover_grid_pos):
		var world_pos = grid_to_world(hover_grid_pos)
		var local_pos = world_pos - global_position
		
		var rect = Rect2(
			local_pos.x - GRID_SIZE / 2.0,
			local_pos.y - GRID_SIZE / 2.0,
			GRID_SIZE,
			GRID_SIZE
		)
		draw_rect(rect, HOVER_COLOR)
	elif is_valid_grid_position(hover_grid_pos) and is_on_enemy_path(hover_grid_pos):
		# Show red highlight for path positions to indicate they can't be used
		var world_pos = grid_to_world(hover_grid_pos)
		var local_pos = world_pos - global_position
		
		var rect = Rect2(
			local_pos.x - GRID_SIZE / 2.0,
			local_pos.y - GRID_SIZE / 2.0,
			GRID_SIZE,
			GRID_SIZE
		)
		draw_rect(rect, Color(0.8, 0.2, 0.2, 0.4))  # Red highlight for invalid positions
	
	# Debug: Red dot removed - grid is working!

# Enemy spawning system
func setup_enemy_spawning():
	# Create enemy spawn timer
	enemy_spawn_timer = Timer.new()
	enemy_spawn_timer.wait_time = time_between_enemies
	enemy_spawn_timer.timeout.connect(_on_enemy_spawn_timer_timeout)
	add_child(enemy_spawn_timer)
	
	# Create wave timer
	wave_timer = Timer.new()
	wave_timer.wait_time = time_between_waves
	wave_timer.one_shot = true
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	add_child(wave_timer)

func create_enemy_path():
	# Create a simple path from left to right across the grid
	enemy_path = []
	path_grid_positions = []
	var start_y = GRID_HEIGHT / 2.0
	var path_grid_y = int(start_y)
	
	# Path goes from left edge to right edge
	for x in range(GRID_WIDTH + 2):
		var world_pos = Vector2((x - 1) * GRID_SIZE + GRID_SIZE / 2.0, start_y * GRID_SIZE + GRID_SIZE / 2.0)
		enemy_path.append(world_pos)
		
		# Track grid positions that are part of the path (only those within the grid)
		if x >= 1 and x <= GRID_WIDTH:
			var grid_pos = Vector2i(x - 1, path_grid_y)
			path_grid_positions.append(grid_pos)

func draw_enemy_path():
	# Clear existing path visuals
	for element in path_visual_elements:
		if element:
			element.queue_free()
	path_visual_elements.clear()
	
	# Create visual indicators for each path tile
	for grid_pos in path_grid_positions:
		var path_tile = ColorRect.new()
		path_tile.size = Vector2(GRID_SIZE, GRID_SIZE)
		path_tile.color = PATH_COLOR
		
		# Position the tile in world coordinates
		var world_pos = grid_to_world(grid_pos)
		path_tile.position = world_pos - Vector2(GRID_SIZE / 2.0, GRID_SIZE / 2.0)
		path_tile.z_index = 0  # Behind towers and other elements
		
		grid_container.add_child(path_tile)
		path_visual_elements.append(path_tile)

func start_wave():
	if wave_active or game_over or game_won:
		return
	
	# Don't start waves beyond maximum
	if current_wave > max_waves:
		return
	
	wave_active = true
	enemies_spawned_this_wave = 0
	enemy_spawn_timer.start()
	
	# Update info label
	update_info_label()
	print("Wave ", current_wave, " started!")

func _on_enemy_spawn_timer_timeout():
	if enemies_spawned_this_wave >= enemies_per_wave:
		enemy_spawn_timer.stop()
		wave_active = false
		
		# Start countdown for next wave
		wave_countdown_active = true
		wave_countdown_time = time_between_waves
		wave_timer.start()
		update_info_label()
		return
	
	spawn_enemy()
	enemies_spawned_this_wave += 1

func _on_wave_timer_timeout():
	# Stop countdown and start next wave
	wave_countdown_active = false
	wave_countdown_time = 0.0
	
	# Start next wave (victory check moved to _on_enemy_died)
	current_wave += 1
	enemies_per_wave += 2  # Increase difficulty
	start_wave()

func spawn_enemy():
	var enemy = ENEMY_SCENE.instantiate()
	enemy.set_path(enemy_path)
	enemy.global_position = enemy_path[0]
	
	# Connect enemy signals
	enemy.enemy_died.connect(_on_enemy_died)
	enemy.enemy_reached_end.connect(_on_enemy_reached_end)
	
	enemies_alive.append(enemy)
	add_child(enemy)

func _on_enemy_died(enemy: Enemy):
	enemies_alive.erase(enemy)
	enemies_killed += 1
	
	# Add currency for killing enemy
	player_currency += currency_per_kill
	
	update_info_label()
	update_tower_selection_ui()
	print("Enemy killed! Total killed: ", enemies_killed, " | Currency: ", player_currency)
	
	# Check victory condition: final wave completed and all enemies dead
	if current_wave >= max_waves and enemies_alive.is_empty() and not wave_active:
		trigger_game_won()

func _on_enemy_reached_end(enemy: Enemy):
	enemies_alive.erase(enemy)
	player_health -= 1
	
	# Prevent health from going below 0 for display purposes
	player_health = max(player_health, 0)
	
	update_info_label()
	print("Enemy reached end! Player health: ", player_health)
	
	if player_health <= 0 and not game_over:
		trigger_game_over()

func update_info_label():
	var info_label = $UI/InfoLabel
	if info_label:
		var timer_text = ""
		
		# Add wave countdown if active
		if wave_countdown_active and wave_countdown_time > 0:
			timer_text = " | Next Wave: %ds" % [int(wave_countdown_time)]
		
		# Add session time
		var session_time = get_session_time()
		timer_text += " | Time: %s" % [format_time(session_time)]
		
		info_label.text = "Wave: %d | Health: %d | Currency: %d | Enemies Killed: %d%s\nClick on grid to place towers (Cost: %d)" % [current_wave, player_health, player_currency, enemies_killed, timer_text, tower_cost]

func get_session_time() -> float:
	var current_time = Time.get_ticks_msec()
	return (current_time - game_session_start_time) / 1000.0  # Convert milliseconds to seconds

func format_time(seconds: float) -> String:
	var total_seconds = int(seconds)
	var minutes = total_seconds / 60
	var secs = total_seconds % 60
	return "%d:%02d" % [minutes, secs]

func trigger_game_over():
	if game_over:
		return
	
	game_over = true
	print("Game Over! You survived ", current_wave, " waves and killed ", enemies_killed, " enemies.")
	
	# Stop all timers immediately
	enemy_spawn_timer.stop()
	wave_timer.stop()
	wave_active = false
	
	# Remove all remaining enemies to stop further damage
	for enemy in enemies_alive.duplicate():  # Use duplicate to avoid modifying array while iterating
		if is_instance_valid(enemy):
			enemy.queue_free()
	enemies_alive.clear()
	
	# Disable all towers to stop attacking
	for tower in towers_placed:
		if is_instance_valid(tower):
			tower.set_process(false)  # Stop tower processing
			if tower.has_method("stop_attacking"):
				tower.stop_attacking()
	
	# Remove all projectiles
	for child in get_children():
		if child is Projectile:
			child.queue_free()
	# Also check grid_container for projectiles
	if grid_container:
		for child in grid_container.get_children():
			if child is Projectile:
				child.queue_free()
	
	# Update UI
	var info_label = $UI/InfoLabel
	if info_label:
		var final_time = format_time(get_session_time())
		info_label.text = "GAME OVER! Waves survived: %d | Enemies killed: %d | Currency earned: %d | Time played: %s" % [current_wave, enemies_killed, player_currency, final_time]

func trigger_game_won():
	if game_won or game_over:
		return
	
	game_won = true
	print("Victory! You survived all ", max_waves, " waves and killed ", enemies_killed, " enemies!")
	# Stop all timers
	enemy_spawn_timer.stop()
	wave_timer.stop()
	
	# Update UI
	var info_label = $UI/InfoLabel
	if info_label:
		var final_time = format_time(get_session_time())
		info_label.text = "VICTORY! You survived all %d waves! Enemies killed: %d | Total currency: %d | Time played: %s" % [max_waves, enemies_killed, player_currency, final_time] 