extends GutTest

# Unit tests for MainController UI updates and display
# This tests UI updates, message display, and screen management

var main_controller: MainController

func before_each():
	# Create a fresh MainController for each test
	# DO NOT call _ready() as it tries to access scene nodes that don't exist in tests
	main_controller = MainController.new()
	add_child_autofree(main_controller)

func test_update_packet_ui():
	# Test packet UI update functionality
	main_controller.setup_managers()
	
	# Test that update_packet_ui doesn't crash
	main_controller.update_packet_ui()
	assert_true(true, "Update packet UI should not crash")

func test_update_tower_selection_ui():
	# Test tower selection UI update functionality
	main_controller.setup_managers()
	
	# Test that update_tower_selection_ui doesn't crash
	main_controller.update_tower_selection_ui()
	assert_true(true, "Update tower selection UI should not crash")

func test_update_mode_ui():
	# Test mode UI update functionality
	main_controller.setup_managers()
	
	# Test that update_mode_ui doesn't crash
	main_controller.update_mode_ui()
	assert_true(true, "Update mode UI should not crash")

func test_update_info_label():
	# Test info label update functionality
	main_controller.setup_managers()
	
	# Test that update_info_label doesn't crash
	main_controller.update_info_label()
	assert_true(true, "Update info label should not crash")

func test_show_temp_message():
	# Test temporary message display functionality
	main_controller.setup_managers()
	
	# Test that show_temp_message doesn't crash
	main_controller.show_temp_message("Test message", 1.0)
	assert_true(true, "Show temp message should not crash")

func test_show_victory_screen():
	# Test victory screen display functionality
	main_controller.setup_managers()
	
	# Test that show_victory_screen doesn't crash
	main_controller.show_victory_screen()
	assert_true(true, "Show victory screen should not crash")

func test_show_game_over_screen():
	# Test game over screen display functionality
	main_controller.setup_managers()
	
	# Test that show_game_over_screen doesn't crash
	main_controller.show_game_over_screen()
	assert_true(true, "Show game over screen should not crash")

func test_show_victory_screen_with_mock_ui():
	# Test show_victory_screen with mock UI nodes
	main_controller.setup_managers()
	
	# Create mock UI structure
	var ui_node = Node.new()
	ui_node.name = "UI"
	main_controller.add_child(ui_node)
	
	var info_label = Label.new()
	info_label.name = "InfoLabel"
	ui_node.add_child(info_label)
	
	# Mock game manager victory data
	main_controller.game_manager.trigger_game_won()
	
	# Test victory screen with UI
	main_controller.show_victory_screen()
	assert_true(info_label.text.contains("VICTORY"), "Victory screen should show victory message")

func test_show_game_over_screen_with_mock_ui():
	# Test show_game_over_screen with mock UI nodes
	main_controller.setup_managers()
	
	# Create mock UI structure
	var ui_node = Node.new()
	ui_node.name = "UI"
	main_controller.add_child(ui_node)
	
	var info_label = Label.new()
	info_label.name = "InfoLabel"
	ui_node.add_child(info_label)
	
	# Mock game manager game over data
	main_controller.game_manager.trigger_game_over()
	
	# Test game over screen with UI
	main_controller.show_game_over_screen()
	assert_true(info_label.text.contains("GAME OVER"), "Game over screen should show game over message")

func test_update_tower_selection_ui_with_mock_ui():
	# Test update_tower_selection_ui with mock UI nodes
	main_controller.setup_managers()
	
	# Create mock UI structure
	var ui_node = Node.new()
	ui_node.name = "UI"
	main_controller.add_child(ui_node)
	
	var tower_selection_panel = Node.new()
	tower_selection_panel.name = "TowerSelectionPanel"
	ui_node.add_child(tower_selection_panel)
	
	var cost_label = Label.new()
	cost_label.name = "CostLabel"
	tower_selection_panel.add_child(cost_label)
	
	var currency_label = Label.new()
	currency_label.name = "CurrencyLabel"
	tower_selection_panel.add_child(currency_label)
	
	var selected_tower_label = Label.new()
	selected_tower_label.name = "SelectedTowerLabel"
	tower_selection_panel.add_child(selected_tower_label)
	
	# Test UI update
	main_controller.update_tower_selection_ui()
	assert_true(cost_label.text.contains("Basic: 50"), "Cost label should show basic tower cost")
	assert_true(currency_label.text.contains("Currency: 100"), "Currency label should show current currency")

func test_update_mode_ui_with_mock_ui():
	# Test update_mode_ui with mock UI nodes
	main_controller.setup_managers()
	
	# Create mock UI structure
	var ui_node = Node.new()
	ui_node.name = "UI"
	main_controller.add_child(ui_node)
	
	var tower_selection_panel = Node.new()
	tower_selection_panel.name = "TowerSelectionPanel"
	ui_node.add_child(tower_selection_panel)
	
	var mode_toggle_button = Button.new()
	mode_toggle_button.name = "ModeToggleButton"
	tower_selection_panel.add_child(mode_toggle_button)
	
	var mode_indicator_label = Label.new()
	mode_indicator_label.name = "ModeIndicatorLabel"
	tower_selection_panel.add_child(mode_indicator_label)
	
	# Test UI update for build mode
	main_controller.current_click_mode = MainController.MODE_BUILD_TOWERS
	main_controller.update_mode_ui()
	assert_true(mode_toggle_button.text.contains("Build Towers"), "Mode toggle button should show build mode")
	assert_true(mode_indicator_label.text.contains("Place Towers"), "Mode indicator should show build mode")

func test_update_info_label_with_mock_ui():
	# Test update_info_label with mock UI nodes
	main_controller.setup_managers()
	
	# Create mock UI structure
	var ui_node = Node.new()
	ui_node.name = "UI"
	main_controller.add_child(ui_node)
	
	var info_label = Label.new()
	info_label.name = "InfoLabel"
	ui_node.add_child(info_label)
	
	# Test UI update
	main_controller.update_info_label()
	assert_true(info_label.text.length() > 0, "Info label should have text content")

func test_update_packet_ui_with_mock_ui():
	# Test update_packet_ui with mock UI nodes
	main_controller.setup_managers()
	
	# Create mock UI structure
	var ui_node = Node.new()
	ui_node.name = "UI"
	main_controller.add_child(ui_node)
	
	var tower_selection_panel = Node.new()
	tower_selection_panel.name = "TowerSelectionPanel"
	ui_node.add_child(tower_selection_panel)
	
	var packet_button = Button.new()
	packet_button.name = "ProgramDataPacketButton"
	tower_selection_panel.add_child(packet_button)
	
	var packet_status_label = Label.new()
	packet_status_label.name = "PacketStatusLabel"
	tower_selection_panel.add_child(packet_status_label)
	
	# Test UI update
	main_controller.update_packet_ui()
	assert_true(packet_status_label.text.contains("Packet:"), "Packet status label should show packet status")

func test_show_temp_message_with_mock_ui():
	# Test show_temp_message with mock UI nodes
	main_controller.setup_managers()
	
	# Create mock UI structure
	var ui_node = Node.new()
	ui_node.name = "UI"
	main_controller.add_child(ui_node)
	
	var info_label = Label.new()
	info_label.name = "InfoLabel"
	info_label.text = "Original text"
	ui_node.add_child(info_label)
	
	# Test temporary message
	main_controller.show_temp_message("Test message", 0.1)
	assert_eq(info_label.text, "Test message", "Info label should show temporary message")
	assert_eq(info_label.modulate, MainController.WARNING_COLOR, "Info label should use warning color") 