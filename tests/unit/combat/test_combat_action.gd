extends GutTest
## Tests for CombatAction.


func test_stores_user_skill_and_targets() -> void:
	var user := Combatant.new()
	var target := Combatant.new()
	var skill := SkillData.new()
	var action := CombatAction.new(user, skill, [target])
	assert_eq(action.user, user)
	assert_eq(action.skill, skill)
	assert_eq(action.targets, [target] as Array[Combatant])


func test_targets_are_copied() -> void:
	var targets: Array[Combatant] = [Combatant.new()]
	var action := CombatAction.new(Combatant.new(), SkillData.new(), targets)
	targets.append(Combatant.new())
	assert_eq(action.targets.size(), 1)


func test_default_action_has_no_targets() -> void:
	assert_eq(CombatAction.new().targets.size(), 0)
