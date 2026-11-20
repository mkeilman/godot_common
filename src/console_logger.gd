class_name ConsoleLogger extends DebugUtils.IDebugLogger

#func _init() -> void:
#	print("CL LOADED: " + self.get_class())

func debug_print(txt: String) -> void:
	printraw(txt)

func debug_println(txt: String, rich: bool = false) -> void:
	if rich:
		print_rich(txt)
	else:
		print(txt)
