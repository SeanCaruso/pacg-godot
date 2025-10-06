class_name Task
extends RefCounted


## Called once when this task becomes the active task for the first time.
func on_active() -> void:
	pass


## Called AFTER this task is removed from the stack.
func execute() -> void:
	pass


## Called when a new task is pushed on top of this one.
func pause() -> void:
	pass


## Called when this becomes the active task after being paused.
func resume() -> void:
	pass


## Returns 'true' for tasks that don't require user input (e.g. processors)
func is_automatic() -> bool:
	return false
