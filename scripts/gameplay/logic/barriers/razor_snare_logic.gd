class_name RazorSnareLogic
extends CardLogicBase


func on_undefeated(card: CardInstance) -> void:
	super.on_undefeated(card)
	
	if Contexts.encounter_context and Contexts.encounter_context.character:
		var character := Contexts.encounter_context.character
		character.add_scourge(Scourge.ENTANGLED)
		character.add_scourge(Scourge.WOUNDED)
	
	Contexts.turn_context.force_end_turn = true
	TaskManager.push(EndTurnController.new(false))
