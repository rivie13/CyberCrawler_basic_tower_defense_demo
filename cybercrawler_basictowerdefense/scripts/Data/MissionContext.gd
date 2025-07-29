# MissionContext.gd - Simple mission data for parent integration
extends Resource
class_name MissionContext

# Mission Parameters from Parent/Stealth System
@export var mission_id: String = ""
@export var difficulty_modifier: float = 1.0
@export var starting_currency: int = 600
@export var available_towers: Array[String] = ["basic", "powerful"]
@export var mission_time_limit: float = 0.0  # 0 = no time limit

# Optional mission-specific configuration
@export var enable_rival_hacker: bool = true
@export var max_waves: int = 10

func _init(id: String = "", difficulty: float = 1.0, currency: int = 600):
	mission_id = id
	difficulty_modifier = difficulty
	starting_currency = currency

func get_mission_summary() -> String:
	"""Get a readable summary of the mission context"""
	return "Mission: %s | Difficulty: %.1f | Currency: %d" % [mission_id, difficulty_modifier, starting_currency]