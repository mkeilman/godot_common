class_name DebugUtils

@abstract
class IDebugLogger:
	@abstract func debug_print(txt: String) -> void
	@abstract func debug_println(txt: String, rich: bool = false) -> void

# NOT a singleton - we need the ability to change the logger
# after initial load
static var the_logger: IDebugLogger #= get_logger()

static var loggers: Dictionary = {}
static var is_loaded := false

static func _static_init() -> void:
	init_the_logger()
	
static func debug_print(txt: String) -> void:
	the_logger.debug_print(txt)

static func debug_println(txt: String, rich: bool = false) -> void:
	the_logger.debug_println(txt, rich)

static func get_logger(class_path: String = "godot_common/src/console_logger.gd") -> IDebugLogger:
	if class_path in loggers.keys():
		return loggers[class_path]
	loggers[class_path] = load(class_path).new() as DebugUtils.IDebugLogger
	return loggers[class_path]

static func init_the_logger(class_path: String = "godot_common/src/console_logger.gd") -> void:
	the_logger = load(class_path).new() as DebugUtils.IDebugLogger

#
static func noop() -> void:
	pass
