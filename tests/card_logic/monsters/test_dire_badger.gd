# test_dire_badger.gd
extends BaseTest

func before_each():
	super()


func test_dire_badger_valid_skills():
	# Set up encounter with Dire Badger
	TestUtils.setup_encounter("Valeros", "Dire Badger")
	
	var check = Contexts.check_context
	assert_true(check.is_combat_valid, "Combat should be valid")
	assert_true(check.is_skill_valid, "Skill checks should be valid")
	assert_eq(check.get_current_valid_skills().size(), 4, "Should have 4 valid skills")
	assert_eq(check.get_dc_for_skill(Skill.STRENGTH), 11, "Strength DC should be 11")
	assert_eq(check.get_dc_for_skill(Skill.MELEE), 11, "Melee DC should be 11")
	assert_eq(check.get_dc_for_skill(Skill.PERCEPTION), 6, "Perception DC should be 6")
	assert_eq(check.get_dc_for_skill(Skill.SURVIVAL), 6, "Survival DC should be 6")


func test_dire_badger_damage_on_combat_defeat():
	# Set up encounter with Dire Badger
	TestUtils.setup_encounter("Valeros", "Dire Badger")
	
	var check = Contexts.check_context
	check.resolvable.check_steps[0].base_dc = 1  # Make it easy to succeed
	
	GameServices.asm.commit()
	
	assert_true(check.check_result.was_success, "Check should succeed")
	assert_true(Contexts.current_resolvable is DamageResolvable, "Should have damage resolvable")
	
	var resolvable = Contexts.current_resolvable as DamageResolvable
	assert_true(resolvable.amount > 0 and resolvable.amount < 5, "Damage should be between 1-4")


func test_dire_badger_no_damage_on_skill_defeat():
	# Set up encounter with Dire Badger
	TestUtils.setup_encounter("Valeros", "Dire Badger")
	
	var check = Contexts.check_context
	check.resolvable.check_steps[1].base_dc = 1  # Make skill check easy to succeed
	check.used_skill = Skill.PERCEPTION
	
	GameServices.asm.commit()
	
	assert_true(check.check_result.was_success, "Check should succeed")
	assert_null(Contexts.current_resolvable, "Should have no current resolvable")
	assert_null(Contexts.check_context, "Check context should be cleared")
	assert_null(Contexts.encounter_context, "Encounter context should be cleared")
