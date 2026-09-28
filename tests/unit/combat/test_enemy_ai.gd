extends GutTest
## Tests for EnemyAI.

const DRAWS: int = 2000
const TOLERANCE: float = 0.05

var _rules: CombatRules
var _rng: RandomNumberGenerator
var _allies: Formation
var _enemies: Formation
var _warrior: Combatant
var _mage: Combatant
var _archer: Combatant
var _enemy: Combatant


func before_each() -> void:
	_rules = CombatRules.new()
	_rng = RandomNumberGenerator.new()
	_rng.seed = 777
	_allies = Formation.new(3)
	_enemies = Formation.new()
	_warrior = _add(_allies, "Guerrero", CombatRow.Row.FRONT, 0, 120)
	_mage = _add(_allies, "Mago", CombatRow.Row.BACK, 1, 70)
	_archer = _add(_allies, "Arquero", CombatRow.Row.BACK, 2, 85)
	_enemy = _add(_enemies, "Diablillo", CombatRow.Row.BACK, 0, 45)


func _add(formation: Formation, unit_name: String, row: CombatRow.Row, index: int, hp: int) -> Combatant:
	var combatant := Combatant.new()
	combatant.display_name = unit_name
	combatant.row = row
	combatant.formation_index = index
	combatant.stats.max_hp = hp
	combatant.start_combat()
	formation.add(combatant)
	return combatant


func _skill(skill_name: String, reach: SkillData.TargetReach = SkillData.TargetReach.ANY_ROW, area: SkillData.TargetArea = SkillData.TargetArea.SINGLE) -> SkillData:
	var skill := SkillData.new()
	skill.display_name = skill_name
	skill.target_side = SkillData.TargetSide.ENEMY
	skill.target_reach = reach
	skill.target_area = area
	return skill


func _choose() -> CombatAction:
	return EnemyAI.choose_action(_enemy, _enemies, _allies, _rules, _rng)


func test_action_has_user_skill_and_targets() -> void:
	var skill := _skill("Mordisco", SkillData.TargetReach.FRONT_ROW)
	_enemy.skills = [skill]
	var action := _choose()
	assert_eq(action.user, _enemy)
	assert_eq(action.skill, skill)
	assert_eq(action.targets, [_warrior] as Array[Combatant])


func test_skill_on_cooldown_is_not_chosen() -> void:
	var blocked := _skill("Bloqueada")
	blocked.cooldown_turns = 2
	var free := _skill("Libre")
	_enemy.skills = [blocked, free]
	_enemy.pay_for(blocked, _rules)
	for i in 50:
		assert_eq(_choose().skill, free)


func test_skill_without_targets_is_not_chosen() -> void:
	var heal := _skill("Curar")
	heal.target_side = SkillData.TargetSide.ALLY
	_enemy.is_defeated = false
	var attack := _skill("Ataque")
	_enemy.skills = [attack, heal]
	for ally: Combatant in [_warrior, _mage, _archer]:
		ally.take_damage(999)
	for i in 20:
		assert_eq(_choose().skill, heal)


func test_returns_null_when_nothing_is_possible() -> void:
	_enemy.skills = [_skill("Ataque")]
	for ally: Combatant in [_warrior, _mage, _archer]:
		ally.take_damage(999)
	assert_null(_choose())


func test_skill_weights_are_respected() -> void:
	var common := _skill("Común")
	var rare := _skill("Rara")
	_enemy.skills = [common, rare]
	_enemy.skill_weights = {common: 3, rare: 1}
	var hits := 0
	for i in DRAWS:
		if _choose().skill == common:
			hits += 1
	assert_almost_eq(float(hits) / DRAWS, 0.75, TOLERANCE)


func test_lowest_hp_picks_lowest_current_health() -> void:
	_enemy.skills = [_skill("Ascua")]
	_enemy.target_preference = EnemyData.TargetPreference.LOWEST_HP
	_warrior.take_damage(80)
	assert_eq(_choose().targets, [_warrior] as Array[Combatant])


func test_lowest_hp_tie_goes_to_formation_order() -> void:
	_enemy.skills = [_skill("Ascua")]
	_enemy.target_preference = EnemyData.TargetPreference.LOWEST_HP
	_mage.take_damage(10)
	_archer.take_damage(25)
	assert_eq(_choose().targets, [_mage] as Array[Combatant])


func test_random_preference_favours_front_row() -> void:
	_enemy.skills = [_skill("Ascua")]
	var front_hits := 0
	for i in DRAWS:
		if _choose().targets[0] == _warrior:
			front_hits += 1
	# Weights 2 : 1 : 1 → the front row unit gets half of the attacks.
	assert_almost_eq(float(front_hits) / DRAWS, 0.5, TOLERANCE)


func test_row_skill_favours_front_row_option() -> void:
	_enemy.skills = [_skill("Llamarada", SkillData.TargetReach.ANY_ROW, SkillData.TargetArea.ROW)]
	var front_hits := 0
	for i in DRAWS:
		if _choose().targets.has(_warrior):
			front_hits += 1
	# Options: front row (weight 2) and back row (weight 1).
	assert_almost_eq(float(front_hits) / DRAWS, 2.0 / 3.0, TOLERANCE)
