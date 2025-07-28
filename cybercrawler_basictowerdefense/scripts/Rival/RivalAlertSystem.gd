extends Node2D
class_name RivalAlertSystem

# Signals
signal alert_triggered(alert_type: String, severity: float)

# Alert types
enum AlertType {
	TOWERS_TOO_CLOSE_TO_EXIT,
	TOO_MANY_TOWERS_AT_ONCE,
	TOO_MANY_POWERFUL_TOWERS,
	HONEYPOT_TRAP_DETECTED,
	MULTI_FACTOR_THREAT
}

# Alert configuration
@export var time_window_for_burst: float = 5.0  # Time window to check for "at once" placements
@export var max_towers_per_burst: int = 3  # Max towers allowed in time window
@export var max_powerful_towers_per_burst: int = 1  # Max powerful towers in time window (lowered from 2 for testing)
@export var exit_proximity_threshold: int = 3  # Grid cells from exit point
@export var powerful_tower_damage_threshold: int = 1  # Damage threshold for "powerful" towers (lowered from 3 for testing)
@export var powerful_tower_range_threshold: float = 120.0  # Range threshold for "powerful" towers (lowered from 200 for testing)

# State tracking
var recent_tower_placements: Array = []  # Array of {position: Vector2i, timestamp: float, tower_stats: Dictionary}
var honeypot_positions: Array[Vector2i] = []  # Predefined honeypot trap positions
var grid_manager: GridManagerInterface
var is_monitoring: bool = false

# Alert severity levels
var current_alert_level: float = 0.0  # 0-1 scale
var alert_factors: Dictionary = {}  # Track which factors are active

func _ready():
	# Initialize honeypot positions (strategic locations that would be obvious traps)
	setup_honeypot_positions()

func initialize(grid_mgr: GridManagerInterface):
	grid_manager = grid_mgr
	setup_honeypot_positions()

func setup_honeypot_positions():
	# Define honeypot positions - these are strategic locations that would be obvious traps
	# Honeypots are positions that seem advantageous but are actually traps
	honeypot_positions.clear()
	
	if grid_manager:
		var grid_size = grid_manager.get_grid_size()
		
		# Category 1: Positions near enemy exit (right edge) - high value but obvious
		for y in range(2, grid_size.y - 2):
			honeypot_positions.append(Vector2i(grid_size.x - 2, y))
			honeypot_positions.append(Vector2i(grid_size.x - 3, y))
		
		# Category 2: Corner positions - seem strategic but are traps
		honeypot_positions.append(Vector2i(0, 0))  # Top-left corner
		honeypot_positions.append(Vector2i(0, grid_size.y - 1))  # Bottom-left corner
		honeypot_positions.append(Vector2i(grid_size.x - 1, 0))  # Top-right corner
		honeypot_positions.append(Vector2i(grid_size.x - 1, grid_size.y - 1))  # Bottom-right corner
		
		# Category 3: Center choke points - seem like good defensive positions
		var center_x = int(grid_size.x / 2)
		var center_y = int(grid_size.y / 2)
		honeypot_positions.append(Vector2i(center_x, center_y))
		honeypot_positions.append(Vector2i(center_x - 1, center_y))
		honeypot_positions.append(Vector2i(center_x + 1, center_y))
		honeypot_positions.append(Vector2i(center_x, center_y - 1))
		honeypot_positions.append(Vector2i(center_x, center_y + 1))
		
		print("RivalAlertSystem: Honeypot positions set up - ", honeypot_positions.size(), " positions")
		print("RivalAlertSystem: Grid size: ", grid_size, " | Exit threshold: ", exit_proximity_threshold)

func start_monitoring():
	if not grid_manager:
		print("RivalAlertSystem: Cannot start monitoring - GridManager not initialized")
		return
	
	is_monitoring = true
	print("RivalAlertSystem: Started monitoring player behavior")

func stop_monitoring():
	is_monitoring = false
	recent_tower_placements.clear()
	alert_factors.clear()
	current_alert_level = 0.0

func on_player_tower_placed(grid_pos: Vector2i, tower: Tower):
	if not is_monitoring:
		return
	
	# Record tower placement with timestamp and stats
	var placement_data = {
		"position": grid_pos,
		"timestamp": Time.get_unix_time_from_system(),
		"tower_stats": {
			"damage": tower.damage,
			"range": tower.tower_range,
			"attack_rate": tower.attack_rate
		}
	}
	
	recent_tower_placements.append(placement_data)
	
	print("RivalAlertSystem: Tower placed at ", grid_pos, " | Total recent: ", recent_tower_placements.size())
	print("RivalAlertSystem: Tower stats - Damage: ", tower.damage, " Range: ", tower.tower_range, " Attack: ", tower.attack_rate)
	
	# Clean up old placements (outside time window)
	cleanup_old_placements()
	
	# Check for various alert conditions
	check_exit_proximity_alert(grid_pos)
	check_burst_placement_alert()
	check_powerful_tower_alert()
	check_honeypot_alert(grid_pos)
	
	# Calculate overall alert level
	calculate_alert_level()

func cleanup_old_placements():
	var current_time = Time.get_unix_time_from_system()
	var cutoff_time = current_time - time_window_for_burst
	
	recent_tower_placements = recent_tower_placements.filter(func(placement): 
		return placement.timestamp > cutoff_time
	)

func check_exit_proximity_alert(grid_pos: Vector2i):
	if not grid_manager:
		return
	
	# Check if tower is too close to enemy exit point
	var grid_size = grid_manager.get_grid_size()
	var distance_to_exit = abs(grid_pos.x - (grid_size.x - 1))
	
	if distance_to_exit <= exit_proximity_threshold:
		# Check if this is "too soon" - based on game progression factors
		var severity = calculate_exit_proximity_severity(grid_pos, distance_to_exit)
		
		alert_factors["exit_proximity"] = severity
		
		if severity >= 0.4:  # Lowered from 0.6 for testing
			alert_triggered.emit("TOWERS_TOO_CLOSE_TO_EXIT", severity)
			print("RivalAlertSystem: EXIT PROXIMITY ALERT - Tower placed too close to exit too soon (severity: ", severity, ")")

func calculate_exit_proximity_severity(_grid_pos: Vector2i, distance_to_exit: int) -> float:
	# Calculate severity based on multiple factors
	var severity = 0.0
	
	# Factor 1: How close to exit (closer = more suspicious)
	var distance_factor = 1.0 - (distance_to_exit / float(exit_proximity_threshold))
	severity += distance_factor * 0.4  # 40% weight
	
	# Factor 2: Game progression (early placement = more suspicious)
	var total_towers_placed = recent_tower_placements.size()
	var progression_factor = 0.0
	if total_towers_placed <= 2:  # Very early game
		progression_factor = 1.0
	elif total_towers_placed <= 4:  # Early game
		progression_factor = 0.8
	elif total_towers_placed <= 6:  # Mid-early game
		progression_factor = 0.5
	else:  # Later game (less suspicious)
		progression_factor = 0.2
	
	severity += progression_factor * 0.4  # 40% weight
	
	# Factor 3: Clustering (multiple towers near exit = more suspicious)
	var nearby_towers = 0
	for placement in recent_tower_placements:
		var other_pos = placement.position
		var other_distance = abs(other_pos.x - (grid_manager.get_grid_size().x - 1))
		if other_distance <= exit_proximity_threshold:
			nearby_towers += 1
	
	var cluster_factor = min(1.0, nearby_towers / 3.0)  # Cap at 3 nearby towers
	severity += cluster_factor * 0.2  # 20% weight
	
	return min(1.0, severity)

func check_burst_placement_alert():
	var recent_count = recent_tower_placements.size()
	
	if recent_count >= max_towers_per_burst:
		var severity = calculate_burst_placement_severity(recent_count)
		alert_factors["burst_placement"] = severity
		
		alert_triggered.emit("TOO_MANY_TOWERS_AT_ONCE", severity)
		print("RivalAlertSystem: BURST PLACEMENT ALERT - ", recent_count, " towers placed in ", time_window_for_burst, " seconds (severity: ", severity, ")")

func calculate_burst_placement_severity(recent_count: int) -> float:
	# Calculate severity based on multiple factors
	var severity = 0.0
	
	# Factor 1: Number of towers placed (more = more suspicious)
	var count_factor = min(1.0, recent_count / float(max_towers_per_burst + 3))
	severity += count_factor * 0.5  # 50% weight
	
	# Factor 2: Time distribution (all at once vs spread out)
	var time_distribution_factor = calculate_time_distribution_factor()
	severity += time_distribution_factor * 0.3  # 30% weight
	
	# Factor 3: Consecutive placement pattern (rapid fire = more suspicious)
	var pattern_factor = calculate_consecutive_placement_factor()
	severity += pattern_factor * 0.2  # 20% weight
	
	return min(1.0, severity)

func calculate_time_distribution_factor() -> float:
	if recent_tower_placements.size() <= 1:
		return 0.0
	
	# Calculate how clustered the placements are in time
	var timestamps = []
	for placement in recent_tower_placements:
		timestamps.append(placement.timestamp)
	
	timestamps.sort()
	
	# Calculate average time between placements
	var total_time_diff = 0.0
	for i in range(1, timestamps.size()):
		total_time_diff += timestamps[i] - timestamps[i-1]
	
	var avg_time_diff = total_time_diff / (timestamps.size() - 1)
	
	# If average time between placements is very small, it's more suspicious
	var ideal_time_diff = time_window_for_burst / max_towers_per_burst
	return max(0.0, 1.0 - (avg_time_diff / ideal_time_diff))

func calculate_consecutive_placement_factor() -> float:
	if recent_tower_placements.size() <= 2:
		return 0.0
	
	# Look for rapid consecutive placements (within 1 second of each other)
	var consecutive_count = 0
	var timestamps = []
	for placement in recent_tower_placements:
		timestamps.append(placement.timestamp)
	
	timestamps.sort()
	
	for i in range(1, timestamps.size()):
		if timestamps[i] - timestamps[i-1] <= 1.0:  # Within 1 second
			consecutive_count += 1
	
	return min(1.0, consecutive_count / float(max_towers_per_burst))

func check_powerful_tower_alert():
	var powerful_towers_data = []
	
	for placement in recent_tower_placements:
		var stats = placement.tower_stats
		var power_level = calculate_tower_power_level(stats)
		if power_level >= 0.7:  # Threshold for "powerful"
			powerful_towers_data.append({
				"placement": placement,
				"power_level": power_level
			})
	
	var powerful_towers_count = powerful_towers_data.size()
	
	if powerful_towers_count >= max_powerful_towers_per_burst:
		var severity = calculate_powerful_tower_severity(powerful_towers_data)
		alert_factors["powerful_towers"] = severity
		
		alert_triggered.emit("TOO_MANY_POWERFUL_TOWERS", severity)
		print("RivalAlertSystem: POWERFUL TOWER ALERT - ", powerful_towers_count, " powerful towers placed recently (severity: ", severity, ")")

func calculate_tower_power_level(stats: Dictionary) -> float:
	var damage = stats.get("damage", 1)
	var tower_range = stats.get("range", 100.0)  # Renamed to avoid built-in function conflict
	var attack_rate = stats.get("attack_rate", 1.0)
	
	# Normalize each stat to 0-1 scale based on expected values
	var damage_score = min(1.0, damage / 5.0)  # Assuming max damage of 5 for normalization
	var range_score = min(1.0, tower_range / 300.0)  # Assuming max range of 300 for normalization
	var attack_rate_score = min(1.0, attack_rate / 3.0)  # Assuming max attack rate of 3 for normalization
	
	# Calculate weighted power level
	var power_level = (damage_score * 0.4) + (range_score * 0.3) + (attack_rate_score * 0.3)
	
	return power_level

func calculate_powerful_tower_severity(powerful_towers_data: Array) -> float:
	var severity = 0.0
	
	# Factor 1: Number of powerful towers
	var count_factor = min(1.0, powerful_towers_data.size() / float(max_powerful_towers_per_burst + 2))
	severity += count_factor * 0.4  # 40% weight
	
	# Factor 2: Average power level of the towers
	var total_power = 0.0
	for tower_data in powerful_towers_data:
		total_power += tower_data["power_level"]
	var avg_power = total_power / powerful_towers_data.size()
	severity += avg_power * 0.3  # 30% weight
	
	# Factor 3: Time clustering of powerful towers
	var time_cluster_factor = calculate_powerful_tower_time_clustering(powerful_towers_data)
	severity += time_cluster_factor * 0.3  # 30% weight
	
	return min(1.0, severity)

func calculate_powerful_tower_time_clustering(powerful_towers_data: Array) -> float:
	if powerful_towers_data.size() <= 1:
		return 0.0
	
	# Get timestamps of powerful tower placements
	var timestamps = []
	for tower_data in powerful_towers_data:
		timestamps.append(tower_data.placement.timestamp)
	
	timestamps.sort()
	
	# Calculate how clustered they are in time
	var total_time_span = timestamps[timestamps.size() - 1] - timestamps[0]
	var expected_time_span = time_window_for_burst * 0.8  # 80% of window is reasonable spread
	
	# If they're all placed very close together in time, it's more suspicious
	if total_time_span <= expected_time_span * 0.3:  # All within 30% of expected span
		return 1.0
	elif total_time_span <= expected_time_span * 0.6:  # All within 60% of expected span
		return 0.7
	else:
		return 0.3

func check_honeypot_alert(grid_pos: Vector2i):
	if grid_pos in honeypot_positions:
		var severity = calculate_honeypot_severity(grid_pos)
		alert_factors["honeypot"] = severity
		
		alert_triggered.emit("HONEYPOT_TRAP_DETECTED", severity)
		print("RivalAlertSystem: HONEYPOT ALERT - Tower placed on honeypot position at ", grid_pos, " (severity: ", severity, ")")

func calculate_honeypot_severity(grid_pos: Vector2i) -> float:
	if not grid_manager:
		return 0.9  # Default high severity
	
	var grid_size = grid_manager.get_grid_size()
	var severity = 0.0
	
	# Category 1: Near enemy exit (right edge) - very high severity
	var distance_to_exit = abs(grid_pos.x - (grid_size.x - 1))
	if distance_to_exit <= 2:
		severity = 0.95
	
	# Category 2: Corner positions - high severity
	elif (grid_pos.x == 0 or grid_pos.x == grid_size.x - 1) and (grid_pos.y == 0 or grid_pos.y == grid_size.y - 1):
		severity = 0.85
	
	# Category 3: Center choke points - medium-high severity
	else:
		var center_x = int(grid_size.x / 2)
		var center_y = int(grid_size.y / 2)
		var distance_to_center = abs(grid_pos.x - center_x) + abs(grid_pos.y - center_y)
		if distance_to_center <= 1:
			severity = 0.75
		else:
			severity = 0.70  # Default for other honeypot positions
	
	# Increase severity if placed early in the game
	var total_towers = recent_tower_placements.size()
	if total_towers <= 3:
		severity = min(1.0, severity + 0.05)  # Slight increase for early placement
	
	return severity

func is_powerful_tower(stats: Dictionary) -> bool:
	var damage = stats.get("damage", 0)
	var tower_range = stats.get("range", 0.0)  # Renamed to avoid built-in function conflict
	var attack_rate = stats.get("attack_rate", 0.0)
	
	# A tower is considered "powerful" if it has high damage, range, or attack rate
	return damage >= powerful_tower_damage_threshold or \
		   tower_range >= powerful_tower_range_threshold or \
		   attack_rate >= 2.0  # High attack rate threshold

func calculate_alert_level():
	# Calculate overall alert level based on active factors with sophisticated weighting
	var weighted_severity = 0.0
	var total_weight = 0.0
	
	# Define factor weights (higher = more important)
	var factor_weights = {
		"honeypot": 1.0,           # Honeypot traps are very suspicious
		"exit_proximity": 0.9,     # Placing near exit is highly suspicious
		"powerful_towers": 0.8,    # Powerful towers are quite suspicious
		"burst_placement": 0.7     # Burst placement is moderately suspicious
	}
	
	# Calculate weighted average
	for factor_name in alert_factors:
		var severity = alert_factors[factor_name]
		var weight = factor_weights.get(factor_name, 0.5)  # Default weight
		weighted_severity += severity * weight
		total_weight += weight
	
	if total_weight > 0:
		current_alert_level = min(1.0, weighted_severity / total_weight)
		
		# Check for specific factor combinations
		check_factor_combinations()
		
		# Check for general multi-factor threat
		if alert_factors.size() >= 2 and current_alert_level >= 0.7:
			alert_triggered.emit("MULTI_FACTOR_THREAT", current_alert_level)
			print("RivalAlertSystem: MULTI-FACTOR THREAT ALERT - Multiple suspicious patterns detected (level: ", current_alert_level, ")")

func check_factor_combinations():
	# Check for specific dangerous combinations of alert factors
	
	# Combination 1: Exit proximity + Powerful towers = immediate threat
	if "exit_proximity" in alert_factors and "powerful_towers" in alert_factors:
		var combined_severity = (alert_factors["exit_proximity"] + alert_factors["powerful_towers"]) / 2.0
		if combined_severity >= 0.8:
			alert_triggered.emit("CRITICAL_COMBINATION_THREAT", combined_severity)
			print("RivalAlertSystem: CRITICAL COMBINATION - Powerful towers near exit detected!")
	
	# Combination 2: Honeypot + Burst placement = trap strategy
	if "honeypot" in alert_factors and "burst_placement" in alert_factors:
		var combined_severity = (alert_factors["honeypot"] + alert_factors["burst_placement"]) / 2.0
		if combined_severity >= 0.7:
			alert_triggered.emit("TRAP_STRATEGY_DETECTED", combined_severity)
			print("RivalAlertSystem: TRAP STRATEGY - Honeypot position with burst placement!")
	
	# Combination 3: Exit proximity + Burst placement = rush strategy
	if "exit_proximity" in alert_factors and "burst_placement" in alert_factors:
		var combined_severity = (alert_factors["exit_proximity"] + alert_factors["burst_placement"]) / 2.0
		if combined_severity >= 0.75:
			alert_triggered.emit("RUSH_STRATEGY_DETECTED", combined_severity)
			print("RivalAlertSystem: RUSH STRATEGY - Rapid placement near exit!")
	
	# Combination 4: All three main factors = sophisticated threat
	if "exit_proximity" in alert_factors and "powerful_towers" in alert_factors and "burst_placement" in alert_factors:
		var combined_severity = (alert_factors["exit_proximity"] + alert_factors["powerful_towers"] + alert_factors["burst_placement"]) / 3.0
		if combined_severity >= 0.6:
			alert_triggered.emit("SOPHISTICATED_THREAT", combined_severity)
			print("RivalAlertSystem: SOPHISTICATED THREAT - Complex attack pattern detected!")

func get_current_alert_level() -> float:
	return current_alert_level

func get_active_alert_factors() -> Dictionary:
	return alert_factors.duplicate()

func reset_alerts():
	alert_factors.clear()
	current_alert_level = 0.0 
