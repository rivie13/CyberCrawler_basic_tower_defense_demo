class_name Mine
extends Node2D

"""
Base class for all mines in the game.
All specific mine types (FreezeMine, ExplosiveMine, etc.) should extend this class.
"""

# Base mine properties
var grid_position: Vector2i
var cost: int
var is_active: bool = true
var is_triggered: bool = false

# Abstract methods that mines must implement
func trigger_mine():
	push_error("trigger_mine() must be implemented by subclass")

func get_mine_type() -> String:
	push_error("get_mine_type() must be implemented by subclass")
	return ""

func get_mine_name() -> String:
	push_error("get_mine_name() must be implemented by subclass")
	return "" 