class_name DrowningMudLogic
extends CardLogicBase


func on_undefeated(card: CardInstance) -> void:
	super.on_undefeated(card)
	
	if Contexts.encounter_context and Contexts.encounter_context.character:
		var character := Contexts.encounter_context.character
		character.add_scourge(Scourge.ENTANGLED)
		character.add_scourge(Scourge.EXHAUSTED)
		
		var top_card := character.draw_from_deck()
		if top_card:
			Cards.move_card_to(top_card, CardLocation.BURIED)