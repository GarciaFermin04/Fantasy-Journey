class_name DamageCalculator
extends RefCounted
## Damage and healing formulas. Pure functions; the balance numbers come
## from CombatRules.
##
## Damage = round(Power × Attack / Defense × base_factor
##          × (1 + affinity bonus) × weakness/resistance multiplier), min min_damage.
## Healing = round((Power + Attack / heal_stat_divisor) × (1 + affinity bonus)).
## Attack and Defense are physical or magical depending on the skill category.
## The back row does not reduce damage: it is protected only by reach.


## Returns the damage or healing of [param skill] from [param user] on
## [param target], depending on the skill effect.
static func get_amount(skill: SkillData, user: Combatant, target: Combatant, rules: CombatRules) -> int:
	if skill.effect == SkillData.Effect.HEAL:
		return calculate_heal(skill, user, rules)
	return calculate_damage(skill, user, target, rules)


## Returns the damage of [param skill] from [param user] on [param target].
static func calculate_damage(skill: SkillData, user: Combatant, target: Combatant, rules: CombatRules) -> int:
	var attack := _attack_stat(skill, user)
	var defense := maxi(_defense_stat(skill, target), 1)
	var base := float(skill.power) * attack / defense * rules.base_damage_factor
	var bonus := 1.0 + get_affinity_bonus_percent(skill, user, rules) / 100.0
	var reaction := _reaction_multiplier(skill, target, rules)
	return maxi(roundi(base * bonus * reaction), rules.min_damage)


## Returns the healing of [param skill] used by [param user].
static func calculate_heal(skill: SkillData, user: Combatant, rules: CombatRules) -> int:
	var amount := skill.power + _attack_stat(skill, user) / rules.heal_stat_divisor
	var bonus := 1.0 + get_affinity_bonus_percent(skill, user, rules) / 100.0
	return roundi(amount * bonus)


## Returns the affinity bonus, in percent, of [param skill] for [param user]:
## the user's affinity bonus plus its weapon's, when they match the skill.
static func get_affinity_bonus_percent(skill: SkillData, user: Combatant, rules: CombatRules) -> int:
	if skill.affinity == null:
		return 0
	var total := 0
	if user.affinity == skill.affinity:
		total += rules.affinity_bonus_percent
	if user.weapon != null and user.weapon.affinity == skill.affinity:
		total += user.weapon.affinity_bonus_percent
	return total


static func _attack_stat(skill: SkillData, user: Combatant) -> int:
	if skill.category == SkillData.Category.MAGICAL:
		return user.stats.magic_attack
	return user.stats.attack


static func _defense_stat(skill: SkillData, target: Combatant) -> int:
	if skill.category == SkillData.Category.MAGICAL:
		return target.stats.magic_defense
	return target.stats.defense


static func _reaction_multiplier(skill: SkillData, target: Combatant, rules: CombatRules) -> float:
	match target.get_reaction(skill.affinity):
		EnemyData.AffinityReaction.WEAK:
			return rules.weak_multiplier
		EnemyData.AffinityReaction.RESISTANT:
			return rules.resist_multiplier
	return 1.0
