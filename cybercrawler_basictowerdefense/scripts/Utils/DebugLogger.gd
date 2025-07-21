extends RefCounted
class_name DebugLogger

# Debug levels
enum LogLevel {
	NONE = 0,
	ERROR = 1,
	WARN = 2,
	INFO = 3,
	DEBUG = 4,
	VERBOSE = 5
}

# Current log level - can be set via environment variable or project setting
static var current_log_level: LogLevel = LogLevel.INFO

# Manual override for testing - can be set to true to force test mode
static var force_test_mode: bool = false

# Environment detection
static var is_development: bool = false
static var is_testing: bool = false
static var is_production: bool = false

# Cache for scene tree root
static var _cached_scene_tree_root = null

# Initialize the logger based on environment
static func initialize(test_mode = null):
	# Detect environment - testing takes priority over development
	if test_mode is bool:
		force_test_mode = test_mode
	is_testing = force_test_mode or _is_running_tests()
	is_development = OS.is_debug_build() and not is_testing
	is_production = not OS.is_debug_build()
	
	# Set log level based on environment
	if is_testing:
		current_log_level = LogLevel.ERROR  # Only errors during tests
	elif is_production:
		current_log_level = LogLevel.NONE   # No debug logs in production
	elif is_development:
		current_log_level = LogLevel.DEBUG  # Full debug in development
	else:
		current_log_level = LogLevel.INFO   # Default fallback

# Check if we're running tests
static func _is_running_tests() -> bool:
	# Check if GUT is running
	if _cached_scene_tree_root == null:
		_cached_scene_tree_root = Engine.get_main_loop().get_root()
	var gut_runner = _cached_scene_tree_root.get_node_or_null("GutRunner")
	if gut_runner:
		return true
	
	# Check if we're in headless mode (common for tests)
	if OS.has_feature("headless"):
		return true
	
	# Check command line arguments for test indicators
	var args = OS.get_cmdline_args()
	for arg in args:
		if "test" in arg.to_lower() or "gut" in arg.to_lower() or "headless" in arg.to_lower():
			return true
	
	# Check if we're running from a test script context
	# This is a more reliable way to detect test environment
	# Note: We can't use get_script() in static context, so we'll rely on other methods
	
	# Check if we're in a test scene or test context
	if _cached_scene_tree_root:
		# Look for test-related nodes in the scene tree (targeted group only)
		var test_nodes = _cached_scene_tree_root.get_tree().get_nodes_in_group("test")
		if test_nodes.size() > 0:
			return true
		# Removed expensive all-nodes scan for performance reasons
	
	return false

# For testability: clear the cached scene tree root
static func clear_scene_tree_cache():
	_cached_scene_tree_root = null

# Logging methods
static func error(message: String, context: String = ""):
	if current_log_level >= LogLevel.ERROR:
		var prefix = "[ERROR]"
		if context != "":
			prefix += "[%s]" % context
		print("%s %s" % [prefix, message])

static func warn(message: String, context: String = ""):
	if current_log_level >= LogLevel.WARN:
		var prefix = "[WARN]"
		if context != "":
			prefix += "[%s]" % context
		print("%s %s" % [prefix, message])

static func info(message: String, context: String = ""):
	if current_log_level >= LogLevel.INFO:
		var prefix = "[INFO]"
		if context != "":
			prefix += "[%s]" % context
		print("%s %s" % [prefix, message])

static func debug(message: String, context: String = ""):
	if current_log_level >= LogLevel.DEBUG:
		var prefix = "[DEBUG]"
		if context != "":
			prefix += "[%s]" % context
		print("%s %s" % [prefix, message])

static func verbose(message: String, context: String = ""):
	if current_log_level >= LogLevel.VERBOSE:
		var prefix = "[VERBOSE]"
		if context != "":
			prefix += "[%s]" % context
		print("%s %s" % [prefix, message])

# Convenience methods for specific contexts
static func debug_path(message: String):
	debug(message, "PATH")

static func debug_combat(message: String):
	debug(message, "COMBAT")

static func debug_grid(message: String):
	debug(message, "GRID")

static func debug_ai(message: String):
	debug(message, "AI")

static func debug_economy(message: String):
	debug(message, "ECONOMY")

# Method to check if debug logging is enabled
static func is_debug_enabled() -> bool:
	return current_log_level >= LogLevel.DEBUG

# Method to check if verbose logging is enabled
static func is_verbose_enabled() -> bool:
	return current_log_level >= LogLevel.VERBOSE

# Get current environment info
static func get_environment_info() -> String:
	var env = "UNKNOWN"
	if is_development:
		env = "DEVELOPMENT"
	elif is_testing:
		env = "TESTING"
	elif is_production:
		env = "PRODUCTION"
	
	return "Environment: %s, Log Level: %s" % [env, LogLevel.keys()[current_log_level]] 
