class_name Clickable
extends RefCounted

"""
Clickable interface for entities that can be clicked by the player.
Centralizes click detection and damage handling logic.
"""

# Click damage configuration
class ClickConfig:
	var damage_taken: int = 1
	var click_radius: float = 20.0
	var feedback_color: Color = Color.WHITE
	var feedback_font_size: int = 14
	var feedback_offset: Vector2 = Vector2(-10, -35)
	var feedback_move_distance: float = -25.0
	var feedback_duration: float = 0.8
	
	func _init(damage: int = 1, radius: float = 20.0, color: Color = Color.WHITE, 
			  font_size: int = 14, offset: Vector2 = Vector2(-10, -35), 
			  move_distance: float = -25.0, duration: float = 0.8):
		damage_taken = damage
		click_radius = radius
		feedback_color = color
		feedback_font_size = font_size
		feedback_offset = offset
		feedback_move_distance = move_distance
		feedback_duration = duration

# Static constants for common configurations
static var ENEMY_CONFIG = ClickConfig.new(1, 20.0, Color.ORANGE, 14, Vector2(-10, -35), -25.0, 0.8)
static var ENEMY_TOWER_CONFIG = ClickConfig.new(1, 35.0, Color.YELLOW, 16, Vector2(-15, -50), -30.0, 1.0)
static var RIVAL_HACKER_CONFIG = ClickConfig.new(2, 25.0, Color.RED, 18, Vector2(-12, -40), -35.0, 1.2)

# Check if a world position click hits the entity
static func is_clicked_at(entity_position: Vector2, world_pos: Vector2, config: ClickConfig) -> bool:
	"""Check if a world position click hits this entity"""
	return entity_position.distance_to(world_pos) <= config.click_radius

# Handle click damage for an entity
static func handle_click_damage(entity: Node2D, config: ClickConfig, entity_name: String = "Entity") -> bool:
	"""Handle damage from player click"""
	# Simple check - trust that entities using this interface have is_alive and take_damage
	if not entity.is_alive:
		return false
	
	if not entity.has_method("take_damage"):
		push_error("Entity " + entity_name + " does not have take_damage method")
		return false
	
	# Apply click damage
	entity.take_damage(config.damage_taken)
	
	# Create visual feedback
	create_click_feedback(entity, config)
	
	# Log the click
	var health_info = ""
	if entity.has_method("get_health_info"):
		health_info = entity.get_health_info()
	else:
		health_info = " (health info unavailable)"
	
	print(entity_name + " was clicked! Took ", config.damage_taken, " damage." + health_info)
	return true

# Create visual feedback when entity is clicked
static func create_click_feedback(entity: Node2D, config: ClickConfig):
	"""Create visual feedback when entity is clicked"""
	# Create a temporary damage indicator
	var damage_label = Label.new()
	damage_label.text = "-" + str(config.damage_taken)
	damage_label.position = config.feedback_offset
	damage_label.add_theme_color_override("font_color", config.feedback_color)
	damage_label.add_theme_font_size_override("font_size", config.feedback_font_size)
	entity.add_child(damage_label)
	
	# Animate the damage number
	var tween = entity.create_tween()
	tween.parallel().tween_property(damage_label, "position", 
		damage_label.position + Vector2(0, config.feedback_move_distance), config.feedback_duration)
	tween.parallel().tween_property(damage_label, "modulate:a", 0.0, config.feedback_duration)
	tween.tween_callback(damage_label.queue_free) 