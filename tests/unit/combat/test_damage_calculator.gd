extends GutTest
## Tests for DamageCalculator.

var _rules: CombatRules
var _fire: AffinityData
var _wind: AffinityData
var _user: Combatant
var _target: Combatant


func before_each() -> void:
	_rules = CombatRules.new()
	_fire = AffinityData.new()
	_wind = AffinityData.new()
	_user = _make(14, 16, 5, 5)
	_target = _make(10, 10, 6, 4)


func _make(attack: int, magic_attack: int, defense: int, magic_defense: int) -> Combatant:
	var combatant := Combatant.new()
	combatant.stats.max_hp = 100
	combatant.stats.attack = attack
	combatant.stats.magic_attack = magic_attack
	combatant.stats.defense = defense
	combatant.stats.magic_defense = magic_defense
	return combatant


func _skill(power: int, category: SkillData.Category = SkillData.Category.PHYSICAL, affinity: AffinityData = null) -> SkillData:
	var skill := SkillData.new()
	skill.power = power
	skill.category = category
	skill.affinity = affinity
	return skill


func _heal_skill(power: int, category: SkillData.Category, affinity: AffinityData = null) -> SkillData:
	var skill := _skill(power, category, affinity)
	skill.effect = SkillData.Effect.HEAL
	return skill


func test_physical_damage_uses_attack_and_defense() -> void:
	# 20 × 14 / 6 × 0.5 = 23.33
	assert_eq(DamageCalculator.calculate_damage(_skill(20), _user, _target, _rules), 23)


func test_magical_damage_uses_magic_stats() -> void:
	# 20 × 16 / 4 × 0.5 = 40
	assert_eq(DamageCalculator.calculate_damage(_skill(20, SkillData.Category.MAGICAL), _user, _target, _rules), 40)


func test_user_affinity_adds_bonus() -> void:
	_user.affinity = _fire
	# 40 × 1.15 = 46
	assert_eq(DamageCalculator.calculate_damage(_skill(20, SkillData.Category.MAGICAL, _fire), _user, _target, _rules), 46)


func test_weapon_affinity_adds_bonus() -> void:
	_user.weapon = WeaponData.new()
	_user.weapon.affinity = _fire
	_user.weapon.affinity_bonus_percent = 10
	# 40 × 1.10 = 44
	assert_eq(DamageCalculator.calculate_damage(_skill(20, SkillData.Category.MAGICAL, _fire), _user, _target, _rules), 44)


func test_user_and_weapon_bonuses_are_added() -> void:
	_user.affinity = _fire
	_user.weapon = WeaponData.new()
	_user.weapon.affinity = _fire
	_user.weapon.affinity_bonus_percent = 10
	var skill := _skill(20, SkillData.Category.MAGICAL, _fire)
	assert_eq(DamageCalculator.get_affinity_bonus_percent(skill, _user, _rules), 25)
	# 40 × 1.25 = 50
	assert_eq(DamageCalculator.calculate_damage(skill, _user, _target, _rules), 50)


func test_other_affinity_gives_no_bonus() -> void:
	_user.affinity = _fire
	assert_eq(DamageCalculator.get_affinity_bonus_percent(_skill(20, SkillData.Category.MAGICAL, _wind), _user, _rules), 0)


func test_neutral_skill_gives_no_bonus() -> void:
	_user.affinity = _fire
	assert_eq(DamageCalculator.get_affinity_bonus_percent(_skill(20), _user, _rules), 0)


func test_weak_target_takes_more_damage() -> void:
	_target.weaknesses = [_fire]
	# 40 × 1.25 = 50
	assert_eq(DamageCalculator.calculate_damage(_skill(20, SkillData.Category.MAGICAL, _fire), _user, _target, _rules), 50)


func test_resistant_target_takes_less_damage() -> void:
	_target.resistances = [_fire]
	# 40 × 0.75 = 30
	assert_eq(DamageCalculator.calculate_damage(_skill(20, SkillData.Category.MAGICAL, _fire), _user, _target, _rules), 30)


func test_neutral_skill_ignores_weaknesses() -> void:
	_target.weaknesses = [_fire]
	assert_eq(DamageCalculator.calculate_damage(_skill(20, SkillData.Category.MAGICAL), _user, _target, _rules), 40)


func test_damage_is_at_least_min_damage() -> void:
	_target.stats.defense = 9999
	assert_eq(DamageCalculator.calculate_damage(_skill(1), _user, _target, _rules), 1)


func test_zero_defense_does_not_divide_by_zero() -> void:
	_target.stats.defense = 0
	# treated as defense 1: 20 × 14 / 1 × 0.5 = 140
	assert_eq(DamageCalculator.calculate_damage(_skill(20), _user, _target, _rules), 140)


func test_back_row_does_not_reduce_damage() -> void:
	var front := DamageCalculator.calculate_damage(_skill(20), _user, _target, _rules)
	_target.row = CombatRow.Row.BACK
	assert_eq(DamageCalculator.calculate_damage(_skill(20), _user, _target, _rules), front)


func test_heal_adds_half_the_attack_stat() -> void:
	# 25 + 16 / 2 = 33
	assert_eq(DamageCalculator.calculate_heal(_heal_skill(25, SkillData.Category.MAGICAL), _user, _rules), 33)


func test_physical_heal_uses_attack() -> void:
	# 20 + 14 / 2 = 27
	assert_eq(DamageCalculator.calculate_heal(_heal_skill(20, SkillData.Category.PHYSICAL), _user, _rules), 27)


func test_heal_gets_affinity_bonus() -> void:
	_user.affinity = _fire
	# 33 × 1.15 = 37.95
	assert_eq(DamageCalculator.calculate_heal(_heal_skill(25, SkillData.Category.MAGICAL, _fire), _user, _rules), 38)


func test_get_amount_picks_damage_or_heal() -> void:
	assert_eq(DamageCalculator.get_amount(_skill(20), _user, _target, _rules), 23)
	assert_eq(DamageCalculator.get_amount(_heal_skill(25, SkillData.Category.MAGICAL), _user, _target, _rules), 33)


func test_rules_change_the_result() -> void:
	_rules.base_damage_factor = 1.0
	# 20 × 14 / 6 × 1.0 = 46.67
	assert_eq(DamageCalculator.calculate_damage(_skill(20), _user, _target, _rules), 47)
