class_name PlayerChoiceResolvable
extends BaseResolvable

var prompt: String
var options: Array[ChoiceOption] = []
var card: ICard

## This gets set when an option is selected.
var chosen_action: Callable

func _init(_prompt: String, _options: Array[ChoiceOption]):
	prompt = _prompt
	options.append_array(_options)


func execute() -> void:
	if chosen_action:
		chosen_action.call()


func on_active():
	GameEvents.player_choice_event.emit(self)
	
	
func get_ui_state(_actions: Array[StagedAction]) -> StagedActionsState:
	# This resolvable handles its own buttons
	return StagedActionsState.new()
