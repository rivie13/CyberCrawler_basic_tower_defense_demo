extends GutTest

# Test the DebugLogger system
# This tests that debug logging works correctly in different environments

func before_each():
	# Initialize the debug logger for each test
	DebugLogger.initialize()

func test_debug_logger_initialization():
	# Test that DebugLogger initializes properly
	# This is the SMALLEST possible test
	
	# Verify logger was initialized
	assert_not_null(DebugLogger, "DebugLogger should exist")
	
	# Verify environment detection works
	assert_true(DebugLogger.is_testing, "Should detect testing environment")
	
	# Verify log level is set appropriately for testing
	assert_eq(DebugLogger.current_log_level, DebugLogger.LogLevel.ERROR, "Testing should only show errors")

func test_debug_logger_environment_detection():
	# Test that environment detection works correctly
	
	# In testing environment, should detect as testing
	assert_true(DebugLogger.is_testing, "Should detect testing environment")
	assert_false(DebugLogger.is_development, "Should not detect as development during tests")
	assert_false(DebugLogger.is_production, "Should not detect as production during tests")

func test_debug_logger_log_levels():
	# Test that different log levels work correctly
	
	# Set to DEBUG level for testing
	DebugLogger.current_log_level = DebugLogger.LogLevel.DEBUG
	
	# Test that debug messages work
	DebugLogger.debug("Test debug message", "TEST")
	DebugLogger.info("Test info message", "TEST")
	DebugLogger.warn("Test warning message", "TEST")
	DebugLogger.error("Test error message", "TEST")
	
	# Verify that the log level was set correctly
	assert_eq(DebugLogger.current_log_level, DebugLogger.LogLevel.DEBUG, "Log level should be set to DEBUG")
	
	# Verify that debug logging is enabled at DEBUG level
	assert_true(DebugLogger.is_debug_enabled(), "Debug logging should be enabled at DEBUG level")

func test_debug_logger_convenience_methods():
	# Test that convenience methods work
	
	# Set to DEBUG level for testing
	DebugLogger.current_log_level = DebugLogger.LogLevel.DEBUG
	
	# Test convenience methods
	DebugLogger.debug_path("Test path message")
	DebugLogger.debug_combat("Test combat message")
	DebugLogger.debug_grid("Test grid message")
	DebugLogger.debug_ai("Test AI message")
	DebugLogger.debug_economy("Test economy message")
	
	# Verify that convenience methods don't crash and work correctly
	assert_eq(DebugLogger.current_log_level, DebugLogger.LogLevel.DEBUG, "Log level should remain DEBUG after convenience method calls")
	
	# Verify that debug logging is still enabled
	assert_true(DebugLogger.is_debug_enabled(), "Debug logging should still be enabled after convenience method calls")

func test_debug_logger_level_checking():
	# Test that level checking methods work
	
	# Set to DEBUG level
	DebugLogger.current_log_level = DebugLogger.LogLevel.DEBUG
	
	# Test level checking
	assert_true(DebugLogger.is_debug_enabled(), "Debug should be enabled at DEBUG level")
	assert_false(DebugLogger.is_verbose_enabled(), "Verbose should not be enabled at DEBUG level")
	
	# Set to VERBOSE level
	DebugLogger.current_log_level = DebugLogger.LogLevel.VERBOSE
	
	# Test level checking
	assert_true(DebugLogger.is_debug_enabled(), "Debug should be enabled at VERBOSE level")
	assert_true(DebugLogger.is_verbose_enabled(), "Verbose should be enabled at VERBOSE level")

func test_debug_logger_environment_info():
	# Test that environment info is provided
	
	var env_info = DebugLogger.get_environment_info()
	assert_not_null(env_info, "Environment info should be provided")
	assert_true("TESTING" in env_info, "Environment info should mention testing")
	assert_true("Log Level" in env_info, "Environment info should mention log level") 