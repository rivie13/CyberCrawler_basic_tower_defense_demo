class_name GridManagerInterface
extends Node2D

# Grid management interface for dependency injection
# This defines the contract that any grid manager implementation must follow

# Grid properties
var grid_size: Vector2i
var cell_size: Vector2i
var grid_container: Node2D

# Path management
var path_positions: Array[Vector2i]

# Virtual methods that must be implemented
func initialize_with_container(container: Node2D, game_mgr = null) -> void:
	pass

func is_valid_grid_position(grid_pos: Vector2i) -> bool:
	return false

func is_grid_occupied(grid_pos: Vector2i) -> bool:
	return false

func set_grid_occupied(grid_pos: Vector2i, occupied: bool) -> void:
	pass

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2.ZERO

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i.ZERO

func set_path_positions(positions: Array[Vector2i]) -> void:
	pass

func get_path_positions() -> Array[Vector2i]:
	return []

func handle_mouse_hover(world_pos: Vector2) -> void:
	pass

func get_grid_container() -> Node2D:
	return null

func get_grid_size() -> Vector2i:
	return Vector2i.ZERO

func is_on_enemy_path(grid_pos: Vector2i) -> bool:
	return false

func is_grid_blocked(grid_pos: Vector2i) -> bool:
	return false

func set_grid_blocked(grid_pos: Vector2i, blocked: bool) -> void:
	pass 