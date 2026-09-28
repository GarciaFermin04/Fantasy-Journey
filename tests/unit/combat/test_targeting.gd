extends GutTest
## Tests for Targeting.

const FRONT := CombatRow.Row.FRONT
const BACK := CombatRow.Row.BACK

var _allies: Formation
var _enemies: Formation
var _warrior: Combatant
var _mage: Combatant
var _slime: Combatant
var _skeleton: Combatant
var _imp: Combatant


func before_each() -> void:
	_allies = Formation.new(3)
	_enemies = Formation.new()
	_warrior = _add(_allies, "Guerrero", FRONT, 0)
	_mage = _add(_allies, "Mago", BACK, 1)
	_slime = _add(_enemies, "Limo", FRONT, 0)
	_skeleton = _add(_enemies, "Esqueleto", FRONT, 1)
	_imp = _add(_enemies, "Diablillo", BACK, 2)


func _add(formation: Formation, unit_name: String, row: CombatRow.Row, index: int) -> Combatant:
	var combatant := Combatant.new()
	combatant.display_name = unit_name
	combatant.row = row
	combatant.formation_index = index
	formation.add(combatant)
	return combatant


func _skill(side: SkillData.TargetSide, reach: SkillData.TargetReach, area: SkillData.TargetArea) -> SkillData:
	var skill := SkillData.new()
	skill.target_side = side
	skill.target_reach = reach
	skill.target_area = area
	return skill


func _options(skill: SkillData, user: Combatant) -> Array[Array]:
	return Targeting.get_target_options(skill, user, _allies, _enemies)


func test_front_row_single_reaches_only_front() -> void:
	var skill := _skill(SkillData.TargetSide.ENEMY, SkillData.TargetReach.FRONT_ROW, SkillData.TargetArea.SINGLE)
	assert_eq(_options(skill, _warrior), [[_slime], [_skeleton]])


func test_front_row_single_exposes_back_when_front_is_empty() -> void:
	_slime.is_defeated = true
	_skeleton.is_defeated = true
	var skill := _skill(SkillData.TargetSide.ENEMY, SkillData.TargetReach.FRONT_ROW, SkillData.TargetArea.SINGLE)
	assert_eq(_options(skill, _warrior), [[_imp]])


func test_any_row_single_reaches_both_rows() -> void:
	var skill := _skill(SkillData.TargetSide.ENEMY, SkillData.TargetReach.ANY_ROW, SkillData.TargetArea.SINGLE)
	assert_eq(_options(skill, _mage), [[_slime], [_skeleton], [_imp]])


func test_row_area_gives_one_option_per_reachable_row() -> void:
	var skill := _skill(SkillData.TargetSide.ENEMY, SkillData.TargetReach.ANY_ROW, SkillData.TargetArea.ROW)
	assert_eq(_options(skill, _mage), [[_slime, _skeleton], [_imp]])


func test_front_row_area_hits_only_front_row() -> void:
	var skill := _skill(SkillData.TargetSide.ENEMY, SkillData.TargetReach.FRONT_ROW, SkillData.TargetArea.ROW)
	assert_eq(_options(skill, _warrior), [[_slime, _skeleton]])


func test_row_area_skips_empty_rows() -> void:
	_imp.is_defeated = true
	var skill := _skill(SkillData.TargetSide.ENEMY, SkillData.TargetReach.ANY_ROW, SkillData.TargetArea.ROW)
	assert_eq(_options(skill, _mage), [[_slime, _skeleton]])


func test_all_area_ignores_reach() -> void:
	var skill := _skill(SkillData.TargetSide.ENEMY, SkillData.TargetReach.FRONT_ROW, SkillData.TargetArea.ALL)
	assert_eq(_options(skill, _warrior), [[_slime, _skeleton, _imp]])


func test_ally_skill_targets_own_side() -> void:
	var skill := _skill(SkillData.TargetSide.ALLY, SkillData.TargetReach.ANY_ROW, SkillData.TargetArea.SINGLE)
	assert_eq(_options(skill, _mage), [[_warrior], [_mage]])


func test_self_skill_targets_only_user() -> void:
	var skill := _skill(SkillData.TargetSide.SELF, SkillData.TargetReach.FRONT_ROW, SkillData.TargetArea.SINGLE)
	assert_eq(_options(skill, _warrior), [[_warrior]])


func test_enemy_user_targets_allies() -> void:
	var skill := _skill(SkillData.TargetSide.ENEMY, SkillData.TargetReach.FRONT_ROW, SkillData.TargetArea.SINGLE)
	var options := Targeting.get_target_options(skill, _slime, _enemies, _allies)
	assert_eq(options, [[_warrior]])


func test_defeated_units_are_never_targets() -> void:
	_skeleton.is_defeated = true
	var skill := _skill(SkillData.TargetSide.ENEMY, SkillData.TargetReach.ANY_ROW, SkillData.TargetArea.SINGLE)
	assert_eq(_options(skill, _mage), [[_slime], [_imp]])


func test_no_living_targets_gives_no_options() -> void:
	for enemy: Combatant in [_slime, _skeleton, _imp]:
		enemy.is_defeated = true
	var skill := _skill(SkillData.TargetSide.ENEMY, SkillData.TargetReach.ANY_ROW, SkillData.TargetArea.ALL)
	assert_eq(_options(skill, _mage), [] as Array[Array])
