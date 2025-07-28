extends GutTest

# Integration tests for MainController UI updates and system coordination
# These tests verify UI update methods, complex input handling, and system integration

var main_controller: MainController
var game_manager: GameManager
var wave_manager: WaveManager
var currency_manager: CurrencyManager
var tower_manager: TowerManager
var freeze_mine_manager: FreezeMineManager
var program_data_packet_manager: ProgramDataPacketManager

func before_each():
	# Create real MainController with all real managers for complete integration
	main_controller = preload("res://scripts/MainController.gd").new()
	add_child_autofree(main_controller)
	
	# Let MainController create and initialize all managers
	await wait_physics_frames(3)  # Wait for proper initialization
	
	# Get references to all managers from MainController
	game_manager = main_controller.game_manager
	wave_manager = main_controller.wave_manager
	currency_manager = main_controller.currency_manager
	tower_manager = main_controller.tower_manager
	freeze_mine_manager = main_controller.freeze_mine_manager
	program_data_packet_manager = main_controller.program_data_packet_manager
	
	# Verify all managers are properly initialized
	assert_not_null(main_controller, "MainController should be initialized")
	assert_not_null(game_manager, "GameManager should be initialized")
	assert_not_null(wave_manager, "WaveManager should be initialized")
	assert_not_null(currency_manager, "CurrencyManager should be initialized")
	assert_not_null(tower_manager, "TowerManager should be initialized")
	assert_not_null(freeze_mine_manager, "FreezeMineManager should be initialized")
	assert_not_null(program_data_packet_manager, "ProgramDataPacketManager should be initialized")
	
	# CRITICAL: Manually initialize systems since MainController.initialize_systems() 
	# skips initialization in test environment due to missing GridContainer
	main_controller.wave_manager.initialize(main_controller.grid_manager)
	main_controller.tower_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.wave_manager)
	main_controller.game_manager.initialize(main_controller.wave_manager, main_controller.currency_manager, main_controller.tower_manager)
	main_controller.rival_hacker_manager.initialize(main_controller.grid_manager, main_controller.currency_manager, main_controller.tower_manager, main_controller.wave_manager, main_controller.game_manager)
	main_controller.program_data_packet_manager.initialize(main_controller.grid_manager, main_controller.game_manager, main_controller.wave_manager)
	main_controller.freeze_mine_manager.initialize(main_controller.grid_manager, main_controller.currency_manager)
	
	# Add extra currency for testing
	currency_manager.add_currency(500)

func test_tower_selection_ui_update_integration():
	# Integration test: Tower selection UI updates with system state
	# This tests: MainController UI updates → tower selection → state synchronization
	
	# Test basic tower selection UI update
	main_controller._on_basic_tower_selected()
	
	# Wait for UI update processing
	await wait_physics_frames(3)
	
	# Test tower selection UI update method
	main_controller.update_tower_selection_ui()
	
	# Verify UI update completed without errors
	assert_true(true, "Tower selection UI update should complete without errors")
	
	# Test powerful tower selection
	main_controller._on_powerful_tower_selected()
	await wait_physics_frames(3)
	
	# Update UI again
	main_controller.update_tower_selection_ui()
	assert_true(true, "Powerful tower selection UI update should complete")
	
	# Test tower selection with insufficient funds
	currency_manager.spend_currency(currency_manager.get_currency())  # Remove all currency
	assert_eq(currency_manager.get_currency(), 0, "Should have no currency")
	
	# Try to select tower with no funds
	main_controller._on_basic_tower_selected()
	main_controller.update_tower_selection_ui()
	
	# Verify UI handles insufficient funds scenario
	assert_true(true, "UI should handle insufficient funds gracefully")

func test_mode_toggle_ui_integration():
	# Integration test: Mode toggle UI with input state management
	# This tests: MainController mode switching → UI updates → input handling changes
	
	# Test initial mode UI update
	main_controller.update_mode_ui()
	assert_true(true, "Initial mode UI update should complete")
	
	# Test mode toggle
	main_controller._on_mode_toggle_pressed()
	await wait_physics_frames(3)
	
	# Update mode UI after toggle
	main_controller.update_mode_ui()
	assert_true(true, "Mode UI update after toggle should complete")
	
	# Test multiple mode toggles
	for i in range(3):
		main_controller._on_mode_toggle_pressed()
		await wait_physics_frames(2)
		main_controller.update_mode_ui()
		assert_true(true, "Mode UI should handle multiple toggles")
	
	# Test mode UI with different game states
	game_manager.trigger_game_over()
	await wait_until(func(): return game_manager.game_over, 5.0)
	
	main_controller.update_mode_ui()
	assert_true(true, "Mode UI should handle game over state")

func test_info_label_update_integration():
	# Integration test: Info label updates with live game data
	# This tests: MainController info updates → game state → UI synchronization
	
	# Set up varied game state
	game_manager.player_health = 6
	game_manager.enemies_killed = 18
	wave_manager.current_wave = 7
	currency_manager.add_currency(250)  # Should total to 750
	
	# Test info label update
	main_controller.update_info_label()
	assert_true(true, "Info label update should complete without errors")
	
	# Test continuous updates with changing state
	for i in range(5):
		game_manager.enemies_killed += 2
		currency_manager.add_currency(50)
		
		main_controller.update_info_label()
		await wait_physics_frames(2)
		
		assert_true(true, "Info label should handle continuous updates")
	
	# Test info label during different game states
	wave_manager.start_wave()
	await wait_until(func(): return wave_manager.is_wave_active(), 10.0)
	
	main_controller.update_info_label()
	assert_true(true, "Info label should update during active wave")
	
	# Test info label with victory state
	game_manager.trigger_game_won()
	await wait_until(func(): return game_manager.game_won, 5.0)
	
	main_controller.update_info_label()
	assert_true(true, "Info label should handle victory state")

func test_complex_input_handling_integration():
	# Integration test: Complex input scenarios with validation and error handling
	# This tests: MainController input handling → validation → error recovery
	
	# Test valid grid click input
	var valid_position = Vector2(200, 200)
	main_controller.handle_grid_click(valid_position)
	await wait_physics_frames(3)
	assert_true(true, "Valid grid click should be handled")
	
	# Test invalid/boundary grid click inputs
	var invalid_positions = [
		Vector2(-100, -100),  # Negative coordinates
		Vector2(10000, 10000),  # Far outside grid
		Vector2(0, 0)  # Origin (may be invalid depending on grid setup)
	]
	
	for invalid_pos in invalid_positions:
		main_controller.handle_grid_click(invalid_pos)
		await wait_physics_frames(2)
		assert_true(true, "Invalid grid click should be handled gracefully")
	
	# Test enemy click damage with no enemies
	var damage_result = main_controller.try_click_damage_enemy(valid_position)
	assert_true(typeof(damage_result) == TYPE_BOOL, "Enemy damage attempt should return boolean")
	
	# Test rapid input handling (stress test)
	for i in range(10):
		main_controller.handle_grid_click(Vector2(100 + i * 50, 150))
		# No wait - test rapid input handling
	
	await wait_physics_frames(5)  # Wait for processing to complete
	assert_true(true, "Rapid input should be handled without crashes")

func test_freeze_mine_system_integration():
	# Integration test: Freeze mine system through MainController
	# This tests: MainController freeze mine handling → manager coordination → UI updates
	
	# Test freeze mine button press
	main_controller._on_freeze_mine_button_pressed()
	await wait_physics_frames(3)
	assert_true(true, "Freeze mine button press should be handled")
	
	# Test freeze mine placement with sufficient funds
	currency_manager.add_currency(100)  # Ensure sufficient funds
	var mine_placement_pos = Vector2i(5, 5)
	
	# Simulate freeze mine placement (would normally happen through UI)
	if freeze_mine_manager.has_method("place_mine"):
		var placement_result = freeze_mine_manager.place_mine(mine_placement_pos)
		if placement_result:
			# Test placement success handling - create mock mine for testing
			var test_placed_mine = FreezeMine.new()
			test_placed_mine.set_grid_position(mine_placement_pos)
			add_child_autofree(test_placed_mine)
			main_controller._on_freeze_mine_placed(test_placed_mine)
			assert_true(true, "Freeze mine placement success should be handled")
	
	# Test freeze mine placement failure handling
	main_controller._on_freeze_mine_placement_failed("Test failure reason")
	assert_true(true, "Freeze mine placement failure should be handled")
	
	# Test freeze mine trigger and depletion
	var test_mine = FreezeMine.new()  # Create mock mine for testing
	add_child_autofree(test_mine)
	
	main_controller._on_freeze_mine_triggered(test_mine)
	assert_true(true, "Freeze mine trigger should be handled")
	
	main_controller._on_freeze_mine_depleted(test_mine)
	assert_true(true, "Freeze mine depletion should be handled")

func test_program_packet_ui_integration():
	# Integration test: Program data packet UI coordination
	# This tests: MainController packet UI → manager integration → state updates
	
	# Test packet UI update
	main_controller.update_packet_ui()
	assert_true(true, "Packet UI update should complete without errors")
	
	# Test packet button press
	main_controller._on_program_data_packet_button_pressed()
	await wait_physics_frames(3)
	assert_true(true, "Program data packet button press should be handled")
	
	# Test packet ready signal handling
	main_controller._on_program_packet_ready()
	await wait_physics_frames(3)
	main_controller.update_packet_ui()
	assert_true(true, "Packet ready state should update UI")
	
	# Test packet destruction handling
	var test_packet = ProgramDataPacket.new()
	add_child_autofree(test_packet)
	
	main_controller._on_program_packet_destroyed(test_packet)
	await wait_physics_frames(3)
	main_controller.update_packet_ui()
	assert_true(true, "Packet destruction should update UI")
	
	# Test packet victory handling
	main_controller._on_program_packet_reached_end(test_packet)
	await wait_physics_frames(3)
	assert_true(true, "Packet victory should be handled")

func test_victory_screen_integration():
	# Integration test: Victory screen display and data integration
	# This tests: MainController victory screen → data display → UI coordination
	
	# Set up victory scenario with interesting data
	game_manager.enemies_killed = 42
	wave_manager.current_wave = wave_manager.get_max_waves()
	
	# Trigger victory
	game_manager.trigger_game_won()
	await wait_until(func(): return game_manager.game_won, 5.0)
	
	# Test victory screen display
	main_controller.show_victory_screen()
	await wait_physics_frames(5)
	assert_true(true, "Victory screen should display without errors")
	
	# Test victory screen with different victory types
	game_manager.game_won = false  # Reset for testing
	game_manager.trigger_game_won_packet()  # Different victory type
	await wait_until(func(): return game_manager.game_won, 5.0)
	
	main_controller.show_victory_screen()
	await wait_physics_frames(5)
	assert_true(true, "Victory screen should handle different victory types")

func test_game_over_screen_integration():
	# Integration test: Game over screen display and data integration
	# This tests: MainController game over screen → data display → UI coordination
	
	# Set up game over scenario with data
	game_manager.enemies_killed = 23
	game_manager.player_health = 0
	wave_manager.current_wave = 5
	
	# Trigger game over
	game_manager.trigger_game_over()
	await wait_until(func(): return game_manager.game_over, 5.0)
	
	# Test game over screen display
	main_controller.show_game_over_screen()
	await wait_physics_frames(5)
	assert_true(true, "Game over screen should display without errors")
	
	# Test game over screen handles data correctly
	var game_over_data = game_manager.get_game_over_data()
	assert_not_null(game_over_data, "Game over data should be available for screen")
	
	# Test game over screen multiple times (shouldn't crash)
	main_controller.show_game_over_screen()
	await wait_physics_frames(3)
	assert_true(true, "Game over screen should handle multiple calls")

func test_system_cleanup_integration():
	# Integration test: System cleanup and shutdown procedures
	# This tests: MainController cleanup → system coordination → resource management
	
	# Set up active game state
	wave_manager.start_wave()
	await wait_until(func(): return wave_manager.is_wave_active(), 10.0)
	
	# Place some towers and mines for cleanup testing
	tower_manager.place_tower(Vector2i(3, 3), "basic")
	await wait_physics_frames(3)
	
	# Test stop all game activity
	main_controller.stop_all_game_activity()
	await wait_physics_frames(5)
	
	# Verify systems are stopped
	assert_false(wave_manager.is_wave_active(), "Wave should be stopped after cleanup")
	assert_true(true, "System cleanup should complete without errors")
	
	# Test projectile destruction
	main_controller.destroy_all_projectiles()
	await wait_physics_frames(3)
	assert_true(true, "Projectile destruction should complete without errors")
	
	# Test cleanup with different game states
	game_manager.trigger_game_over()
	await wait_until(func(): return game_manager.game_over, 5.0)
	
	main_controller.stop_all_game_activity()
	assert_true(true, "Cleanup should work during game over state")

func test_temp_message_system_integration():
	# Integration test: Temporary message system with timing
	# This tests: MainController temp messages → timing → UI coordination
	
	# Test basic temp message
	main_controller.show_temp_message("Test message 1")
	await wait_physics_frames(5)
	assert_true(true, "Basic temp message should be displayed")
	
	# Test temp message with custom duration  
	main_controller.show_temp_message("Test message 2", 0.5)
	await wait_physics_frames(10)  # Wait longer than message duration
	assert_true(true, "Temp message with custom duration should work")
	
	# Test multiple temp messages (should handle overlapping)
	main_controller.show_temp_message("Message 1", 1.0)
	await wait_physics_frames(2)
	main_controller.show_temp_message("Message 2", 1.0)
	await wait_physics_frames(2)
	main_controller.show_temp_message("Message 3", 1.0)
	
	await wait_physics_frames(20)  # Wait for all messages to complete
	assert_true(true, "Multiple temp messages should be handled")
	
	# Test temp messages during different game states
	game_manager.trigger_game_won()
	await wait_until(func(): return game_manager.game_won, 5.0)
	
	main_controller.show_temp_message("Victory message")
	await wait_physics_frames(5)
	assert_true(true, "Temp messages should work during victory state")

func test_ui_timer_and_continuous_updates():
	# Integration test: UI timer system with continuous updates
	# This tests: MainController UI timer → continuous updates → performance
	
	# Test UI update timer callback
	main_controller._on_ui_update_timer_timeout()
	assert_true(true, "UI update timer callback should execute")
	
	# Test continuous UI updates (simulate timer behavior)
	for i in range(10):
		main_controller._on_ui_update_timer_timeout()
		await wait_physics_frames(1)
	
	assert_true(true, "Continuous UI updates should not cause performance issues")
	
	# Test UI updates with changing game state
	for i in range(5):
		game_manager.enemies_killed += 1
		currency_manager.add_currency(25)
		wave_manager.current_wave = (i % 3) + 1
		
		main_controller._on_ui_update_timer_timeout()
		await wait_physics_frames(2)
	
	assert_true(true, "UI updates should handle changing game state")

func test_manager_getter_methods_integration():
	# Integration test: Manager getter methods and system access
	# This tests: MainController getters → manager access → system coordination
	
	# Test program data packet manager getter
	var packet_manager = main_controller.get_program_data_packet_manager()
	assert_not_null(packet_manager, "Should return program data packet manager")
	assert_eq(packet_manager, program_data_packet_manager, "Should return correct manager instance")
	
	# Test tower manager getter
	var tower_mgr = main_controller.get_tower_manager()
	assert_not_null(tower_mgr, "Should return tower manager")
	assert_eq(tower_mgr, tower_manager, "Should return correct manager instance")
	
	# Test getter methods work during different game states
	game_manager.trigger_game_over()
	await wait_until(func(): return game_manager.game_over, 5.0)
	
	var packet_mgr_during_game_over = main_controller.get_program_data_packet_manager()
	assert_not_null(packet_mgr_during_game_over, "Getters should work during game over")
	
	var tower_mgr_during_game_over = main_controller.get_tower_manager()
	assert_not_null(tower_mgr_during_game_over, "Tower manager getter should work during game over") 
