class_name CloseOptionResolvable
extends PlayerChoiceResolvable


## Creates a PlayerChoiceResolvable with the given options.
##
## options should be a Dictionary in the format {String: Resolvable}
func _init(options_dict: Dictionary) -> void:
	cancel_aborts_phase = true
	
	var choice_options: Array[ChoiceOption] = []
	for option_text in options_dict:
		choice_options.append(ChoiceOption.new(
			option_text,
			func():
				TaskManager.push(options_dict[option_text])
		))
	
	choice_options.append(ChoiceOption.new("Cancel", cancel))
	
	super("Close Location?", choice_options)
