class_name DrowningMudLogic
extends CardLogicBase


func on_undefeated(card: CardInstance) -> void:
	super.on_undefeated(card)
	
	if _contexts.encounter_context and _contexts.encounter_context.character:
		var character := _contexts.encounter_context.character
		character.add_scourge(Scourge.ENTANGLED)
		character.add_scourge(Scourge.EXHAUSTED)
		
		var top_card := character.draw_from_deck()
		if top_card:
			GameServices.cards.move_card_to(top_card, CardLocation.BURIED)