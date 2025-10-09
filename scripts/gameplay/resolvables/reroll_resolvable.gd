class_name RerollResolvable
extends BaseResolvable

var dice_pool: DicePool

func _init(_pc: PlayerCharacter, _dice_pool: DicePool, check_context: CheckContext):
	pc = _pc
	dice_pool = _dice_pool
	
	# Default option is to not reroll.
	check_context.context_data["doReroll"] = false


func execute() -> void:
	# If something set the "doReroll" context data to true, process the roll again.
	if !Contexts.check_context.context_data.get("doReroll", false):
		return
	
	print("[%s] User chose to reroll - creating a processor." % self)
	TaskManager.push(RollCheckDiceProcessor.new())
