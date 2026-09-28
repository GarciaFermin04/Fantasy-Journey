class_name EnemyAI
extends RefCounted
## Simple enemy decision for one turn. Pure logic: randomness comes from the
## RandomNumberGenerator passed in, so tests can use a fixed seed.
##
## 1. Pick a skill among the usable ones (enough resources, off cooldown and
##    with valid targets), proportionally to its weight.
## 2. Pick a target option by preference:
##    - RANDOM: weighted draw where options with front row units weigh
##      CombatRules.ai_front_row_weight (the front row receives more attacks).
##    - LOWEST_HP: the option holding the unit with the lowest current health;
##      ties go to the first option in formation order.


## Returns the action [param actor] takes this turn, or null if it cannot
## act. [param own_side] is its formation and [param other_side] the opponents'.
static func choose_action(actor: Combatant, own_side: Formation, other_side: Formation, rules: CombatRules, rng: RandomNumberGenerator) -> CombatAction:
	var usable: Array[SkillData] = []
	var weights: Array[int] = []
	for skill in actor.skills:
		if actor.can_use(skill, rules) and not Targeting.get_target_options(skill, actor, own_side, other_side).is_empty():
			usable.append(skill)
			weights.append(actor.skill_weights.get(skill, 1))
	var skill_index := WeightedPicker.pick_index(weights, rng)
	if skill_index < 0:
		return null
	var skill := usable[skill_index]
	var options := Targeting.get_target_options(skill, actor, own_side, other_side)
	return CombatAction.new(actor, skill, _choose_option(options, actor.target_preference, rules, rng))


static func _choose_option(options: Array[Array], preference: EnemyData.TargetPreference, rules: CombatRules, rng: RandomNumberGenerator) -> Array[Combatant]:
	var index := 0
	if preference == EnemyData.TargetPreference.LOWEST_HP:
		index = _lowest_hp_index(options)
	else:
		index = WeightedPicker.pick_index(_front_row_weights(options, rules), rng)
	var group: Array[Combatant] = []
	group.assign(options[index])
	return group


static func _front_row_weights(options: Array[Array], rules: CombatRules) -> Array[int]:
	var weights: Array[int] = []
	for option in options:
		var has_front := false
		for unit: Combatant in option:
			if unit.row == CombatRow.Row.FRONT:
				has_front = true
		weights.append(rules.ai_front_row_weight if has_front else 1)
	return weights


static func _lowest_hp_index(options: Array[Array]) -> int:
	var best_index := 0
	var best_hp := INF
	for i in options.size():
		for unit: Combatant in options[i]:
			if unit.current_hp < best_hp:
				best_hp = unit.current_hp
				best_index = i
	return best_index
