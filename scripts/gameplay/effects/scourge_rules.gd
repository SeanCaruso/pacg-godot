class_name ScourgeRules
extends Node

enum Scourge {
	DAZED,
	DRAINED,
	ENTANGLED,
	EXHAUSTED,
	FRIGHTENED,
	POISONED,
	WOUNDED
}


static func prompt_for_wounded_removal(pc: PlayerCharacter, game_services: GameServices) -> void:
	var resolvable := PlayerChoiceResolvable.new("Remove Wounded?",
		[ChoiceOption.new("Yes", func(): pc.remove_scourge(Scourge.WOUNDED)),
		ChoiceOption.new("No", func(): pass)]
	)
	
	var processor = NewResolvableProcessor.new(resolvable, game_services)
	game_services.game_flow.start_phase(processor, "Wound Removal")
