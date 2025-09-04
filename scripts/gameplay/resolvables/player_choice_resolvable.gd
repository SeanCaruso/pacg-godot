class_name PlayerChoiceResolvable
extends BaseResolvable

var prompt: String
var options: Array[ChoiceOption] = []
var card: ICard

func _init(_prompt: String, _options: Array[ChoiceOption]):
	prompt = _prompt
	options.append_array(_options)
	
	
func initialize():
	GameEvents.player_choice_event.emit(self)
	
	
func get_ui_state(_actions: Array[StagedAction]) -> StagedActionsState:
	# This resolvable handles its own buttons
	return StagedActionsState.new()
