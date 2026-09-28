extends GutTest
## Tests for Combatant health, mana, stamina and cooldowns.

var _rules: CombatRules
var _unit: Combatant


func before_each() -> void:
	_rules = CombatRules.new()
	_unit = _make(true)


func _make(is_ally: bool) -> Combatant:
	var combatant := Combatant.new()
	combatant.is_ally = is_ally
	combatant.stats.max_hp = 100
	combatant.stats.max_mana = 30
	combatant.stats.max_stamina = 40
	combatant.start_combat()
	return combatant


func _skill(mana: int = 0, stamina: int = 0, cooldown: int = 0) -> SkillData:
	var skill := SkillData.new()
	skill.display_name = "habilidad"
	skill.mana_cost = mana
	skill.stamina_cost = stamina
	skill.cooldown_turns = cooldown
	return skill


func test_start_combat_fills_resources() -> void:
	assert_eq(_unit.current_hp, 100)
	assert_eq(_unit.current_mana, 30)
	assert_eq(_unit.current_stamina, 40)


func test_start_combat_carries_health_and_mana() -> void:
	_unit.current_stamina = 0
	_unit.start_combat(55, 12)
	assert_eq(_unit.current_hp, 55)
	assert_eq(_unit.current_mana, 12)
	assert_eq(_unit.current_stamina, 40)


func test_take_damage_lowers_health() -> void:
	assert_eq(_unit.take_damage(30), 30)
	assert_eq(_unit.current_hp, 70)
	assert_false(_unit.is_defeated)


func test_lethal_damage_defeats_and_stops_at_zero() -> void:
	assert_eq(_unit.take_damage(150), 100)
	assert_eq(_unit.current_hp, 0)
	assert_true(_unit.is_defeated)


func test_heal_is_capped_at_max_health() -> void:
	_unit.take_damage(10)
	assert_eq(_unit.heal(50), 10)
	assert_eq(_unit.current_hp, 100)


func test_heal_does_not_revive() -> void:
	_unit.take_damage(100)
	assert_eq(_unit.heal(50), 0)
	assert_true(_unit.is_defeated)


func test_cost_includes_weapon_modifier() -> void:
	_unit.weapon = WeaponData.new()
	_unit.weapon.mana_cost_modifier = -2
	assert_eq(_unit.get_mana_cost(_skill(6), _rules), 4)


func test_cost_never_goes_below_zero() -> void:
	_unit.weapon = WeaponData.new()
	_unit.weapon.stamina_cost_modifier = -10
	assert_eq(_unit.get_stamina_cost(_skill(0, 8), _rules), 0)


func test_enemies_use_skills_for_free() -> void:
	var enemy := _make(false)
	assert_eq(enemy.get_mana_cost(_skill(50), _rules), 0)
	assert_true(enemy.can_use(_skill(50, 50), _rules))


func test_enemies_pay_when_rules_say_so() -> void:
	_rules.enemies_pay_costs = true
	var enemy := _make(false)
	assert_eq(enemy.get_mana_cost(_skill(6), _rules), 6)


func test_cannot_use_without_enough_mana() -> void:
	assert_false(_unit.can_use(_skill(31), _rules))
	assert_true(_unit.can_use(_skill(30), _rules))


func test_cannot_use_without_enough_stamina() -> void:
	assert_false(_unit.can_use(_skill(0, 41), _rules))


func test_pay_for_spends_resources() -> void:
	_unit.pay_for(_skill(6, 8), _rules)
	assert_eq(_unit.current_mana, 24)
	assert_eq(_unit.current_stamina, 32)


func test_start_turn_regenerates_twenty_percent_of_stamina() -> void:
	_unit.current_stamina = 10
	_unit.start_turn(_rules)
	assert_eq(_unit.current_stamina, 18)


func test_stamina_regen_is_capped() -> void:
	_unit.current_stamina = 38
	_unit.start_turn(_rules)
	assert_eq(_unit.current_stamina, 40)


func test_mana_does_not_regenerate() -> void:
	_unit.current_mana = 5
	_unit.start_turn(_rules)
	_unit.end_turn()
	assert_eq(_unit.current_mana, 5)


func test_cooldown_blocks_the_next_n_own_turns() -> void:
	var skill := _skill(0, 0, 2)
	# Turn N: use it.
	_unit.start_turn(_rules)
	_unit.pay_for(skill, _rules)
	_unit.end_turn()
	# Turn N+1: blocked.
	_unit.start_turn(_rules)
	assert_false(_unit.can_use(skill, _rules))
	assert_eq(_unit.get_cooldown_remaining(skill), 2)
	_unit.end_turn()
	# Turn N+2: blocked.
	_unit.start_turn(_rules)
	assert_false(_unit.can_use(skill, _rules))
	assert_eq(_unit.get_cooldown_remaining(skill), 1)
	_unit.end_turn()
	# Turn N+3: available again.
	_unit.start_turn(_rules)
	assert_true(_unit.can_use(skill, _rules))


func test_skill_without_cooldown_is_always_available() -> void:
	var skill := _skill()
	_unit.pay_for(skill, _rules)
	assert_true(_unit.can_use(skill, _rules))


func test_start_combat_clears_cooldowns() -> void:
	var skill := _skill(0, 0, 3)
	_unit.pay_for(skill, _rules)
	_unit.start_combat()
	assert_true(_unit.can_use(skill, _rules))
