class_name Targeting
extends RefCounted
## Resolves which units a skill can target. Each option is the group of
## units affected if that option is chosen (one unit, a row or a whole side).
##
## Reach: FRONT_ROW only reaches the front row, unless it is empty, in which
## case the back row is exposed. ANY_ROW reaches both rows. Area ALL ignores
## reach. Defeated units are never targets.


## Returns the target options of [param skill] used by [param user].
## [param own_side] is the user's formation; [param other_side] the opponents'.
static func get_target_options(skill: SkillData, user: Combatant, own_side: Formation, other_side: Formation) -> Array[Array]:
	var options: Array[Array] = []
	if skill.target_side == SkillData.TargetSide.SELF:
		if not user.is_defeated:
			var self_group: Array[Combatant] = [user]
			options.append(self_group)
		return options
	var side := other_side if skill.target_side == SkillData.TargetSide.ENEMY else own_side
	match skill.target_area:
		SkillData.TargetArea.ALL:
			var everyone := side.get_living()
			if not everyone.is_empty():
				options.append(everyone)
		SkillData.TargetArea.ROW:
			for row in _reachable_rows(skill.target_reach, side):
				var units := side.get_row(row)
				if not units.is_empty():
					options.append(units)
		SkillData.TargetArea.SINGLE:
			for row in _reachable_rows(skill.target_reach, side):
				for unit in side.get_row(row):
					var single: Array[Combatant] = [unit]
					options.append(single)
	return options


static func _reachable_rows(reach: SkillData.TargetReach, side: Formation) -> Array[CombatRow.Row]:
	if reach == SkillData.TargetReach.ANY_ROW or side.is_back_row_exposed():
		return [CombatRow.Row.FRONT, CombatRow.Row.BACK]
	return [CombatRow.Row.FRONT]
