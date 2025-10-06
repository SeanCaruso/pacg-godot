class_name NewResolvableProcessor
extends BaseProcessor

var _next_resolvable: BaseResolvable

func _init(next_resolvable: BaseResolvable):
	_next_resolvable = next_resolvable
	
	
func execute() -> void:
	if not _next_resolvable:
		printerr("[%s] Created with a null resolvable!")
		return
	
	print("[%s] Creating next resolvable: %s" % [self, _next_resolvable])
	TaskManager.push(_next_resolvable)
