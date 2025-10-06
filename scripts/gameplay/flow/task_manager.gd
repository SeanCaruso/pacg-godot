# task_manager.gd
extends Node
## Autoload that manages the main game flow stack.

var _task_stack: Array[Task] = []
var _deferred_tasks: Array[Task] = []

var current_resolvable: BaseResolvable:
	get:
		return current_task if current_task is BaseResolvable else null
var current_task: Task:
	get:
		return null if _task_stack.is_empty() else _task_stack.back()


func process() -> void:
	while not _task_stack.is_empty():
		# If the current task isn't ready to be processed yet, return and wait for manual re-entry.
		if not _task_stack.back().is_automatic():
			return
		
		_pop_execute_and_continue()
	
	# If we finish processing all tasks, we're in free play mode.
	push(FreePlayResolvable.new())


func push(task: Task) -> void:
	if current_task:
		current_task.pause()
	
	_task_stack.push_back(task)
	task.on_active()


func push_deferred(task: Task) -> void:
	_deferred_tasks.append(task)


## Adds a queue of tasks to the stack of deferred tasks in reverse order to preserve their correct processing order.
func push_deferred_queue(tasks: Array[Task]) -> void:
	while not tasks.is_empty():
		var task = tasks.pop_back()
		push_deferred(task)


## Adds a queue of tasks to the stack in reverse order to preserve their correct processing order.
func push_queue(tasks: Array[Task]) -> void:
	if current_task:
		current_task.pause()
	
	while not tasks.is_empty():
		var task = tasks.pop_back()
		_task_stack.push_back(task)
	
	if current_task:
		current_task.on_active()


func resolve_current() -> void:
	if _task_stack.is_empty():
		# Always process deferred tasks.
		_process_deferred_tasks()
		return
	
	_pop_execute_and_continue()
	process()


func start_task(task: Task) -> void:
	push(task)
	process()


func _pop_execute_and_continue() -> void:
	assert(not _task_stack.is_empty(), "Stack must not be empty!")
	
	var completed_task: Task = _task_stack.pop_back()
	completed_task.execute()
	
	# Add any deferred tasks created by the execute() call.
	_process_deferred_tasks()
	
	# Continue processing the stack.
	if not _task_stack.is_empty():
		_task_stack.back().resume()


func _process_deferred_tasks() -> void:
	if _deferred_tasks.is_empty():
		return
	
	if current_task:
		current_task.pause()
	
	for task in _deferred_tasks:
		_task_stack.push_back(task)
	_deferred_tasks.clear()
	
	if current_task:
		current_task.on_active()

#=====================================================
# Convenience pass-throughs to the current resolvable.
#=====================================================
func cancel() -> void:
	if current_resolvable:
		current_resolvable.cancel()


func commit() -> void:
	if current_resolvable:
		current_resolvable.commit()


func skip() -> void:
	if current_resolvable:
		current_resolvable.skip()
