class_name EncounterController
extends BaseProcessor

var _pc: PlayerCharacter
var _card: CardInstance


func _init(pc: PlayerCharacter, card: CardInstance, game_services: GameServices):
	super(game_services)
	
	_pc = pc
	_card = card
	
	
func on_execute() -> void:
	_game_services.contexts.new_encounter(EncounterContext.new(_pc, _card))
	GameEvents.encounter_started.emit(_card)
	
	_game_flow.queue_next_processor(OnEncounterProcessor.new(_game_services))
	_game_flow.queue_next_processor(EvasionEncounterProcessor.new(_game_services))
	_game_flow.queue_next_processor(BeforeActingEncounterProcessor.new(_game_services))
	_game_flow.queue_next_processor(AttemptChecksEncounterProcessor.new(_game_services))
	_game_flow.queue_next_processor(AfterActingEncounterProcessor.new(_game_services))
	_game_flow.queue_next_processor(ResolveEncounterProcessor.new(_game_services))
	_game_flow.queue_next_processor(EndEncounterProcessor.new(_game_services))
