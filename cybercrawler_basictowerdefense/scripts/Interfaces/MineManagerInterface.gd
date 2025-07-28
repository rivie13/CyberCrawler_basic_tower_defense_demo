class_name MineManagerInterface
extends Node

"""
Interface for mine management systems.
Defines the contract that all mine managers must implement.
This allows for different types of mines (freeze, explosive, EMP, etc.)
"""

# Signals for mine events
signal mine_placed(mine: Mine)
signal mine_placement_failed(reason: String)
signal mine_triggered(mine: Mine)
signal mine_depleted(mine: Mine)

# Abstract methods that mine managers must implement
func initialize(grid_mgr: GridManagerInterface, currency_mgr: CurrencyManagerInterface):
	push_error("initialize() must be implemented by subclass")

func can_place_mine_at(grid_pos: Vector2i, mine_type: String = "freeze") -> bool:
	push_error("can_place_mine_at() must be implemented by subclass")
	return false

func place_mine(grid_pos: Vector2i, mine_type: String = "freeze") -> bool:
	push_error("place_mine() must be implemented by subclass")
	return false

func create_mine_at_position(grid_pos: Vector2i, mine_type: String = "freeze") -> Mine:
	push_error("create_mine_at_position() must be implemented by subclass")
	return null

func get_mines() -> Array[Mine]:
	push_error("get_mines() must be implemented by subclass")
	return []

func get_mine_count() -> int:
	push_error("get_mine_count() must be implemented by subclass")
	return 0

func clear_all_mines():
	push_error("clear_all_mines() must be implemented by subclass")

func get_mine_cost(mine_type: String = "freeze") -> int:
	push_error("get_mine_cost() must be implemented by subclass")
	return 0 