extends GutTest
## Tests for SkillData validation.


func _make_valid_skill() -> SkillData:
	var skill := SkillData.new()
	skill.id = &"slash"
	skill.display_name = "Tajo"
	skill.power = 10
	return skill


func test_valid_skill_has_no_errors() -> void:
	assert_eq(_make_valid_skill().validate().size(), 0)


func test_empty_id_is_invalid() -> void:
	var skill := _make_valid_skill()
	skill.id = &""
	assert_has(skill.validate(), "id is empty")


func test_blank_display_name_is_invalid() -> void:
	var skill := _make_valid_skill()
	skill.display_name = "   "
	assert_has(skill.validate(), "display_name is empty")


func test_negative_power_is_invalid() -> void:
	var skill := _make_valid_skill()
	skill.power = -1
	assert_has(skill.validate(), "power is negative")


func test_negative_mana_cost_is_invalid() -> void:
	var skill := _make_valid_skill()
	skill.mana_cost = -1
	assert_has(skill.validate(), "mana_cost is negative")


func test_negative_stamina_cost_is_invalid() -> void:
	var skill := _make_valid_skill()
	skill.stamina_cost = -1
	assert_has(skill.validate(), "stamina_cost is negative")


func test_negative_cooldown_is_invalid() -> void:
	var skill := _make_valid_skill()
	skill.cooldown_turns = -1
	assert_has(skill.validate(), "cooldown_turns is negative")


func test_self_skill_with_area_is_invalid() -> void:
	var skill := _make_valid_skill()
	skill.target_side = SkillData.TargetSide.SELF
	skill.target_area = SkillData.TargetArea.ALL
	assert_has(skill.validate(), "SELF skills must use SINGLE area")


func test_self_skill_with_single_area_is_valid() -> void:
	var skill := _make_valid_skill()
	skill.target_side = SkillData.TargetSide.SELF
	assert_eq(skill.validate().size(), 0)


func test_costing_mana_and_stamina_is_valid() -> void:
	var skill := _make_valid_skill()
	skill.mana_cost = 5
	skill.stamina_cost = 3
	assert_eq(skill.validate().size(), 0)


func test_zero_cooldown_is_valid() -> void:
	var skill := _make_valid_skill()
	skill.cooldown_turns = 0
	assert_eq(skill.validate().size(), 0)


func test_heal_on_all_allies_is_valid() -> void:
	var skill := _make_valid_skill()
	skill.effect = SkillData.Effect.HEAL
	skill.target_side = SkillData.TargetSide.ALLY
	skill.target_area = SkillData.TargetArea.ALL
	assert_eq(skill.validate().size(), 0)


func test_default_skill_has_no_affinity() -> void:
	assert_null(SkillData.new().affinity)
