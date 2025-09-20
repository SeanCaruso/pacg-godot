class_name GameFlowManager
extends RefCounted

var _queue_stack: Array[PhaseQueue] = []
var current: PhaseQueue:
	get: return _queue_stack.back()


func _to_string() -> String:
	return get_script().get_global_name()

# ========================================================================================
# PUBLIC API FOR PROCESSORS
# ========================================================================================
## Adds a processor to the current phase queue.
func queue_next_processor(processor: BaseProcessor) -> void:
	if _queue_stack.is_empty():
		_queue_stack.append(PhaseQueue.new(str(processor)))
		
	current.enqueue(processor)
	
	
## Adds a processor to the FRONT of the current phase queue to be processed next.
func interrupt(processor: BaseProcessor) -> void:
	if _queue_stack.is_empty():
		_queue_stack.append(PhaseQueue.new(str(processor)))
		
	current.interrupt(processor)
	
	
## Called when a processor is finished processing.
func complete_current_phase() -> void:
	# The processor already dequeued itself in Process
	print("[%s] Processor completed." % self)
	process() # Process whatever's next.
	
	
## Entry point for immediately starting a new phase (like a turn)
func start_phase(phase_processor: BaseProcessor, name: String):
	print("[%s] start_phase called with %s" % [self, phase_processor])
	
	var queue = PhaseQueue.new(name)
	queue.enqueue(phase_processor)
	_queue_stack.append(queue)
	process()
	
	
############################################################################################

func process() -> void:
	# Pause if we have a pending resolvable.
	if Contexts.current_resolvable:
		print("[%s] Process paused - found %s" % [self, Contexts.current_resolvable])
		return
		
	# Clean up empty queues (pop back to parent phase)
	while !_queue_stack.is_empty() and current.is_empty():
		print("[%s] Finished phase queue %s, popping stack." % [self, current.name])
		_queue_stack.pop_back()
		
	# Execute the next processor in the current queue.
	if !_queue_stack.is_empty() and !current.is_empty():
		var processor := current.dequeue()
		print("[%s] Executing phase %s processor: %s" % [self, current.name, processor])
		processor.execute()
		
		
func abort_phase() -> void:
	if !_queue_stack.is_empty():
		_queue_stack.pop_back()
	
