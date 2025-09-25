class_name EncounterController
extends BaseProcessor

var _pc: PlayerCharacter
var _card: CardInstance


func _init(pc: PlayerCharacter, card: CardInstance):	
	_pc = pc
	_card = card
	
	
func on_execute() -> void:
	Contexts.new_encounter(EncounterContext.new(_pc, _card))
	GameEvents.encounter_started.emit(_card)
	
	GameServices.game_flow.queue_next_processor(OnEncounterProcessor.new())
	GameServices.game_flow.queue_next_processor(EvasionEncounterProcessor.new())
	GameServices.game_flow.queue_next_processor(BeforeActingEncounterProcessor.new())
	GameServices.game_flow.queue_next_processor(AttemptChecksEncounterProcessor.new())
	GameServices.game_flow.queue_next_processor(AfterActingEncounterProcessor.new())
	GameServices.game_flow.queue_next_processor(ResolveEncounterProcessor.new())
	GameServices.game_flow.queue_next_processor(AvengeEncounterProcessor.new())
	GameServices.game_flow.queue_next_processor(EndEncounterProcessor.new())
