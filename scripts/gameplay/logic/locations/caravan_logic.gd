class_name CaravanLogic
extends LocationLogicBase

const Skill := preload("res://scripts/core/enums/skill.gd").Skill


func caravan_at_location():
	DialogEvents.move_clicked_event.emit(Contexts.game_context.active_character)


func get_card_to_close_resolvable(loc: Location, pc: PlayerCharacter) -> BaseResolvable:
	var dc := 5 + Contexts.game_context.adventure_number
	
	var resolvable := CheckResolvable.new(
		loc,
		pc,
		CardUtils.skill_check(dc, [Skill.WISDOM, Skill.PERCEPTION])
	)
	return resolvable
