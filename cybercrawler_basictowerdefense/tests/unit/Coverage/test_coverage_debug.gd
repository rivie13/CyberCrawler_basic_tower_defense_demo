extends GutTest

# Debug test to check coverage instrumentation
func test_coverage_debug():
	print("=== COVERAGE DEBUG TEST ===")
	
	# Test 1: Create MockGameManager and call _ready()
	print("Creating MockGameManager...")
	var game_manager = MockGameManager.new()
	add_child_autofree(game_manager)
	
	print("Calling _ready()...")
	game_manager._ready()
	
	print("MockGameManager session time: ", game_manager.get_session_time())
	
	# Test 2: Create BaseMockTowerManager and call initialize()
	print("Creating BaseMockTowerManager...")
	var tower_manager = BaseMockTowerManager.new()
	add_child_autofree(tower_manager)
	
	print("Calling initialize()...")
	tower_manager.initialize(null, null, null)
	
	print("BaseMockTowerManager tower count: ", tower_manager.get_tower_count())
	
	# Test 3: Create Clickable config (this works)
	print("Creating Clickable config...")
	var config = Clickable.ClickConfig.new()
	print("Clickable config damage: ", config.damage_taken)
	
	# Test 4: Check if coverage collectors exist
	print("Checking coverage collectors...")
	var coverage = preload("res://addons/coverage/coverage.gd").instance
	if coverage:
		print("Coverage instance exists")
		print("Coverage collectors count: ", coverage.coverage_collectors.size())
		print("Coverage collectors keys: ", coverage.coverage_collectors.keys())
		for script_path in coverage.coverage_collectors:
			var collector = coverage.coverage_collectors[script_path]
			print("  ", script_path, " - ", collector.coverage_count(), "/", collector.coverage_line_count(), " lines")
		
		# Test specific script paths
		var game_manager_path = "res://scripts/GameManager.gd"
		var tower_manager_path = "res://scripts/Tower/TowerManager.gd"
		var clickable_path = "res://scripts/Interfaces/Clickable.gd"
		
		print("Checking specific paths:")
		print("  GameManager.gd in collectors: ", game_manager_path in coverage.coverage_collectors)
		print("  TowerManager.gd in collectors: ", tower_manager_path in coverage.coverage_collectors)
		print("  Clickable.gd in collectors: ", clickable_path in coverage.coverage_collectors)
		
		# Test get_coverage_collector method
		print("Testing get_coverage_collector method:")
		var gm_collector = coverage.get_coverage_collector(game_manager_path)
		var tm_collector = coverage.get_coverage_collector(tower_manager_path)
		var cl_collector = coverage.get_coverage_collector(clickable_path)
		
		print("  GameManager collector: ", gm_collector)
		print("  TowerManager collector: ", tm_collector)
		print("  Clickable collector: ", cl_collector)
		
	else:
		print("No coverage instance found!")
	
	# Always pass - this is just for debugging
	assert_true(true, "Debug test always passes") 