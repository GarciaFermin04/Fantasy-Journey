extends GutTest
## Tests for ActionResolver.

var _rules: CombatRules
var _fire: AffinityData
var _user: Combatant
var _target_a: Combatant
var _target_b: Combatant


func before_each() -> void:
	_rules = CombatRules.new()
	_fire = AffinityData.new()
	_user = _make(true, 50)
	_target_a = _make(false, 30)
	_target_b = _make(false, 30)


func _make(is_ally: bool, hp: int) -> Combatant:
	var combatant := Combatant.new()
	combatant.display_name = "unidad"
	combatant.is_ally = is_ally
	combatant.stats.max_hp = hp
	combatant.stats.max_mana = 20
	combatant.stats.max_stamina = 20
	combatant.stats.attack = 10
	combatant.stats.magic_attack = 10
	combatant.stats.defense = 10
	combatant.stats.magic_defense = 10
	combatant.start_combat()
	return combatant


func _skill(power: int, effect: SkillData.Effect = SkillData.Effect.DAMAGE) -> SkillData:
	var skill := SkillData.new()
	skill.display_name = "habilidad"
	skill.power = power
	skill.effect = effect
	return skill


func _resolve(skill: SkillData, targets: Array[Combatant]) -> Array[ActionResult]:
	return ActionResolver.resolve(CombatAction.new(_user, skill, targets), _rules)


func test_damage_is_applied_to_every_target() -> void:
	# 20 × 10 / 10 × 0.5 = 10
	var results := _resolve(_skill(20), [_target_a, _target_b])
	assert_eq(results.size(), 2)
	assert_eq(_target_a.current_hp, 20)
	assert_eq(_target_b.current_hp, 20)
	assert_eq(results[0].amount, 10)
	assert_false(results[0].is_heal)


func test_heal_is_applied_and_capped() -> void:
	_user.take_damage(10)
	# 20 + 10 / 2 = 25, capped to the 10 missing
	var results := _resolve(_skill(20, SkillData.Effect.HEAL), [_user])
	assert_eq(_user.current_hp, 50)
	assert_eq(results[0].amount, 10)
	assert_true(results[0].is_heal)


func test_cost_is_paid_and_cooldown_started() -> void:
	var skill := _skill(20)
	skill.mana_cost = 5
	skill.cooldown_turns = 2
	_resolve(skill, [_target_a])
	assert_eq(_user.current_mana, 15)
	assert_eq(_user.get_cooldown_remaining(skill), 2)


func test_lethal_hit_reports_defeat() -> void:
	var results := _resolve(_skill(100), [_target_a])
	assert_true(results[0].defeated)
	assert_true(_target_a.is_defeated)


func test_reaction_is_reported() -> void:
	var skill := _skill(20)
	skill.affinity = _fire
	_target_a.weaknesses = [_fire]
	var results := _resolve(skill, [_target_a])
	assert_eq(results[0].reaction, EnemyData.AffinityReaction.WEAK)


func test_defeated_targets_are_skipped() -> void:
	_target_b.take_damage(100)
	var results := _resolve(_skill(20), [_target_a, _target_b])
	assert_eq(results.size(), 1)
	assert_eq(results[0].target, _target_a)


func test_unusable_skill_is_rejected() -> void:
	var skill := _skill(20)
	skill.mana_cost = 999
	var results := _resolve(skill, [_target_a])
	assert_push_error("cannot use")
	assert_eq(results.size(), 0)
	assert_eq(_target_a.current_hp, 30)
