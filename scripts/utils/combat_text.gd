class_name CombatText
extends RefCounted
## Spanish texts that describe combat state for the UI (status lines and
## action results). Pure formatting, shared by combat screens.


## Returns a status line for [param combatant]: health, mana and stamina.
static func describe_resources(combatant: Combatant) -> String:
	if combatant.is_defeated:
		return "%s: derrotado" % combatant.display_name
	return "%s: %d/%d PV · %d/%d PM · %d/%d EST" % [
		combatant.display_name,
		combatant.current_hp, combatant.stats.max_hp,
		combatant.current_mana, combatant.stats.max_mana,
		combatant.current_stamina, combatant.stats.max_stamina,
	]


## Returns a line like "Guerrero usa Tajo → Limo: −18 (resiste)".
static func describe_action(action: CombatAction, results: Array[ActionResult]) -> String:
	return "%s usa %s → %s" % [action.user.display_name, action.skill.display_name, describe_results(results)]


## Returns the results of an action, e.g. "Limo: −92 (débil) · derrotado".
static func describe_results(results: Array[ActionResult]) -> String:
	var parts: PackedStringArray = []
	for result in results:
		var sign := "+" if result.is_heal else "−"
		var text := "%s: %s%d%s" % [result.target.display_name, sign, result.amount, describe_reaction(result.reaction)]
		if result.defeated:
			text += " · derrotado"
		parts.append(text)
	return " · ".join(parts) if not parts.is_empty() else "sin efecto"


## Returns " (débil)", " (resiste)" or "" for [param reaction].
static func describe_reaction(reaction: EnemyData.AffinityReaction) -> String:
	match reaction:
		EnemyData.AffinityReaction.WEAK:
			return " (débil)"
		EnemyData.AffinityReaction.RESISTANT:
			return " (resiste)"
	return ""
