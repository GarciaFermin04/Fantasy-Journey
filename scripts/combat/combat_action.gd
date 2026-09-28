class_name CombatAction
extends RefCounted
## An action chosen for a turn: who acts, which skill and on which targets.
## Other combat systems resolve it (damage, healing...).

## Combatant performing the action.
var user: Combatant
## Skill being used.
var skill: SkillData
## Combatants affected by the action.
var targets: Array[Combatant] = []


func _init(p_user: Combatant = null, p_skill: SkillData = null, p_targets: Array[Combatant] = []) -> void:
	user = p_user
	skill = p_skill
	targets = p_targets.duplicate()
