class_name DicePoolBuilder
extends RefCounted

static func build(check_context: CheckContext, actions: Array[StagedAction]) -> DicePool:
	var modifiers: Array[CheckModifier] = []
	
	for action in actions:
		if action is not PlayCardAction: continue
		var modifier := (action as PlayCardAction).check_modifier
		if modifier:
			modifiers.append(modifier)
	
	var dice_pool = DicePool.new()
	
	# 1. Apply any persistent explore effects.
	for effect in check_context.explore_effects:
		effect.apply_to(check_context, dice_pool)
	
	# 2. Find and apply the used skill die and blessings.
	# First, look for a die override.
	var die_overrides := modifiers.filter(func(m): return m.die_override > 0)
	var skill_die = die_overrides[0].die_override if die_overrides.size() > 0 \
		else check_context.character.get_skill(check_context.used_skill).get("die", 4)
	var skill_bonus = check_context.character.get_skill(check_context.used_skill)["bonus"]
	
	var total_skill_dice := 1
	for modifier in modifiers:
		total_skill_dice += modifier.skill_dice_to_add
	
	dice_pool.add_dice(total_skill_dice, skill_die, skill_bonus)
	
	# 3. Apply any other dice modifiers
	for modifier in modifiers:
		for die in modifier.added_dice:
			dice_pool.add_dice(1, die)
		dice_pool.add_bonus(modifier.added_bonus)

	return dice_pool
