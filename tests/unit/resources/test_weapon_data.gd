extends GutTest
## Tests for WeaponData validation and skill list.

var _skill_a: SkillData
var _skill_b: SkillData
var _skill_c: SkillData
var _wand_type: WeaponTypeData


func before_each() -> void:
	_skill_a = _make_skill(&"a")
	_skill_b = _make_skill(&"b")
	_skill_c = _make_skill(&"c")
	_wand_type = WeaponTypeData.new()
	_wand_type.id = &"wand"
	_wand_type.display_name = "Varita"
	_wand_type.base_skills = [_skill_a, _skill_b]


func _make_skill(skill_id: StringName) -> SkillData:
	var skill := SkillData.new()
	skill.id = skill_id
	skill.display_name = String(skill_id)
	return skill


func _make_valid_weapon() -> WeaponData:
	var weapon := WeaponData.new()
	weapon.id = &"wand"
	weapon.display_name = "Varita"
	weapon.weapon_type = _wand_type
	return weapon


func test_valid_weapon_has_no_errors() -> void:
	assert_eq(_make_valid_weapon().validate().size(), 0)


func test_missing_type_is_invalid() -> void:
	var weapon := _make_valid_weapon()
	weapon.weapon_type = null
	assert_has(weapon.validate(), "weapon_type is missing")


func test_empty_id_is_invalid() -> void:
	var weapon := _make_valid_weapon()
	weapon.id = &""
	assert_has(weapon.validate(), "id is empty")


func test_affinity_bonus_without_affinity_is_invalid() -> void:
	var weapon := _make_valid_weapon()
	weapon.affinity_bonus_percent = 10
	assert_has(weapon.validate(), "affinity_bonus_percent requires an affinity")


func test_affinity_bonus_with_affinity_is_valid() -> void:
	var weapon := _make_valid_weapon()
	weapon.affinity = AffinityData.new()
	weapon.affinity_bonus_percent = 10
	assert_eq(weapon.validate().size(), 0)


func test_negative_affinity_bonus_is_invalid() -> void:
	var weapon := _make_valid_weapon()
	weapon.affinity_bonus_percent = -5
	assert_has(weapon.validate(), "affinity_bonus_percent is negative")


func test_empty_extra_skill_entry_is_invalid() -> void:
	var weapon := _make_valid_weapon()
	weapon.extra_skills = [null]
	assert_has(weapon.validate(), "extra_skills contains an empty entry")


func test_negative_cost_modifiers_are_valid() -> void:
	var weapon := _make_valid_weapon()
	weapon.mana_cost_modifier = -2
	weapon.stamina_cost_modifier = -1
	assert_eq(weapon.validate().size(), 0)


func test_all_skills_without_extras_are_base_skills() -> void:
	assert_eq(_make_valid_weapon().get_all_skills(), [_skill_a, _skill_b] as Array[SkillData])


func test_all_skills_lists_base_then_extra() -> void:
	var weapon := _make_valid_weapon()
	weapon.extra_skills = [_skill_c]
	assert_eq(weapon.get_all_skills(), [_skill_a, _skill_b, _skill_c] as Array[SkillData])


func test_all_skills_has_no_duplicates() -> void:
	var weapon := _make_valid_weapon()
	weapon.extra_skills = [_skill_b, _skill_c]
	assert_eq(weapon.get_all_skills(), [_skill_a, _skill_b, _skill_c] as Array[SkillData])


func test_all_skills_with_empty_type_uses_only_extras() -> void:
	var weapon := _make_valid_weapon()
	weapon.weapon_type = WeaponTypeData.new()
	weapon.extra_skills = [_skill_c]
	assert_eq(weapon.get_all_skills(), [_skill_c] as Array[SkillData])


func test_default_weapon_is_base_rarity() -> void:
	assert_eq(WeaponData.new().rarity, WeaponData.Rarity.BASE)
