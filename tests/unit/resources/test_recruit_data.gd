extends GutTest
## Tests for RecruitData validation, weapons, skills and stats.

var _sword_type: WeaponTypeData
var _bow_type: WeaponTypeData
var _slash: SkillData
var _thrust: SkillData
var _war_cry: SkillData
var _sword: WeaponData
var _bow: WeaponData


func before_each() -> void:
	_slash = _make_skill(&"slash")
	_thrust = _make_skill(&"thrust")
	_war_cry = _make_skill(&"war_cry")
	_sword_type = _make_type(&"sword", [_slash, _thrust])
	_bow_type = _make_type(&"bow", [])
	_sword = _make_weapon(&"sword", _sword_type)
	_bow = _make_weapon(&"bow", _bow_type)


func _make_skill(skill_id: StringName) -> SkillData:
	var skill := SkillData.new()
	skill.id = skill_id
	skill.display_name = String(skill_id)
	return skill


func _make_type(type_id: StringName, skills: Array[SkillData]) -> WeaponTypeData:
	var weapon_type := WeaponTypeData.new()
	weapon_type.id = type_id
	weapon_type.display_name = String(type_id)
	weapon_type.base_skills = skills
	return weapon_type


func _make_weapon(weapon_id: StringName, weapon_type: WeaponTypeData) -> WeaponData:
	var weapon := WeaponData.new()
	weapon.id = weapon_id
	weapon.display_name = String(weapon_id)
	weapon.weapon_type = weapon_type
	return weapon


func _make_valid_recruit() -> RecruitData:
	var recruit := RecruitData.new()
	recruit.id = &"warrior"
	recruit.display_name = "Guerrero"
	recruit.base_stats = StatBlock.new()
	recruit.base_stats.max_hp = 100
	recruit.base_stats.attack = 12
	recruit.allowed_weapon_types = [_sword_type]
	recruit.own_skills = [_war_cry]
	recruit.default_weapon = _sword
	recruit.default_equipped_skills = [_slash, _war_cry]
	return recruit


func test_valid_recruit_has_no_errors() -> void:
	assert_eq(_make_valid_recruit().validate(), PackedStringArray())


func test_empty_id_is_invalid() -> void:
	var recruit := _make_valid_recruit()
	recruit.id = &""
	assert_has(recruit.validate(), "id is empty")


func test_missing_stats_is_invalid() -> void:
	var recruit := _make_valid_recruit()
	recruit.base_stats = null
	assert_has(recruit.validate(), "base_stats is missing")


func test_zero_hp_is_invalid() -> void:
	var recruit := _make_valid_recruit()
	recruit.base_stats.max_hp = 0
	assert_has(recruit.validate(), "max_hp must be positive")


func test_negative_stat_is_invalid() -> void:
	var recruit := _make_valid_recruit()
	recruit.base_stats.speed = -1
	assert_has(recruit.validate(), "stat SPEED is negative")


func test_no_allowed_weapon_types_is_invalid() -> void:
	var recruit := _make_valid_recruit()
	recruit.allowed_weapon_types = []
	assert_has(recruit.validate(), "allowed_weapon_types is empty")


func test_missing_default_weapon_is_invalid() -> void:
	var recruit := _make_valid_recruit()
	recruit.default_weapon = null
	recruit.default_equipped_skills = [_war_cry]
	assert_has(recruit.validate(), "default_weapon is missing")


func test_default_weapon_of_forbidden_type_is_invalid() -> void:
	var recruit := _make_valid_recruit()
	recruit.default_weapon = _bow
	recruit.default_equipped_skills = [_war_cry]
	assert_has(recruit.validate(), "default_weapon type is not allowed")


func test_more_than_four_equipped_skills_is_invalid() -> void:
	var recruit := _make_valid_recruit()
	var extra_a := _make_skill(&"extra_a")
	var extra_b := _make_skill(&"extra_b")
	recruit.own_skills = [_war_cry, extra_a, extra_b]
	recruit.default_equipped_skills = [_slash, _thrust, _war_cry, extra_a, extra_b]
	assert_has(recruit.validate(), "too many default_equipped_skills")


func test_four_equipped_skills_is_valid() -> void:
	var recruit := _make_valid_recruit()
	var extra := _make_skill(&"extra")
	recruit.own_skills = [_war_cry, extra]
	recruit.default_equipped_skills = [_slash, _thrust, _war_cry, extra]
	assert_eq(recruit.validate(), PackedStringArray())


func test_duplicate_equipped_skill_is_invalid() -> void:
	var recruit := _make_valid_recruit()
	recruit.default_equipped_skills = [_slash, _slash]
	assert_has(recruit.validate(), "default_equipped_skills has duplicates")


func test_unavailable_equipped_skill_is_invalid() -> void:
	var recruit := _make_valid_recruit()
	recruit.default_equipped_skills = [_make_skill(&"fireball")]
	assert_has(recruit.validate(), "equipped skill fireball is not available")


func test_can_use_allowed_weapon() -> void:
	assert_true(_make_valid_recruit().can_use_weapon(_sword))


func test_cannot_use_forbidden_weapon() -> void:
	assert_false(_make_valid_recruit().can_use_weapon(_bow))


func test_cannot_use_null_weapon() -> void:
	assert_false(_make_valid_recruit().can_use_weapon(null))


func test_available_skills_lists_weapon_then_own() -> void:
	var skills := _make_valid_recruit().get_available_skills(_sword)
	assert_eq(skills, [_slash, _thrust, _war_cry] as Array[SkillData])


func test_available_skills_has_no_duplicates() -> void:
	var recruit := _make_valid_recruit()
	recruit.own_skills = [_slash, _war_cry]
	assert_eq(recruit.get_available_skills(_sword), [_slash, _thrust, _war_cry] as Array[SkillData])


func test_available_skills_without_weapon_are_own_skills() -> void:
	assert_eq(_make_valid_recruit().get_available_skills(null), [_war_cry] as Array[SkillData])


func test_stats_with_weapon_without_bonus_are_base_stats() -> void:
	var stats := _make_valid_recruit().get_stats_with(_sword)
	assert_eq(stats.attack, 12)
	assert_eq(stats.max_hp, 100)


func test_stats_with_weapon_add_bonus() -> void:
	var recruit := _make_valid_recruit()
	_sword.stat_bonus = StatBlock.new()
	_sword.stat_bonus.attack = 5
	_sword.stat_bonus.speed = -2
	var stats := recruit.get_stats_with(_sword)
	assert_eq(stats.attack, 17)
	assert_eq(stats.speed, -2)


func test_default_preferred_row_is_front() -> void:
	assert_eq(RecruitData.new().preferred_row, CombatRow.Row.FRONT)
