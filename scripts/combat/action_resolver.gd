class_name ActionResolver
extends RefCounted
## Applies a CombatAction: the user pays the skill cost (starting its
## cooldown), then every target takes the damage or healing given by
## DamageCalculator. Defeated targets are skipped.


## Resolves [param action] and returns one result per affected target.
static func resolve(action: CombatAction, rules: CombatRules) -> Array[ActionResult]:
	var results: Array[ActionResult] = []
	if not action.user.can_use(action.skill, rules):
		push_error("ActionResolver.resolve: %s cannot use %s" % [action.user.display_name, action.skill.display_name])
		return results
	action.user.pay_for(action.skill, rules)
	for target in action.targets:
		if target.is_defeated:
			continue
		results.append(_apply(action, target, rules))
	return results


static func _apply(action: CombatAction, target: Combatant, rules: CombatRules) -> ActionResult:
	var result := ActionResult.new()
	result.target = target
	var amount := DamageCalculator.get_amount(action.skill, action.user, target, rules)
	if action.skill.effect == SkillData.Effect.HEAL:
		result.is_heal = true
		result.amount = target.heal(amount)
	else:
		result.reaction = target.get_reaction(action.skill.affinity)
		result.amount = target.take_damage(amount)
		result.defeated = target.is_defeated
	return result
