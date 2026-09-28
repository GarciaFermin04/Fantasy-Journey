extends GutTest
## Tests for EnemySkillEntry validation.


func _make_valid_entry() -> EnemySkillEntry:
	var entry := EnemySkillEntry.new()
	entry.skill = SkillData.new()
	entry.weight = 2
	return entry


func test_valid_entry_has_no_errors() -> void:
	assert_eq(_make_valid_entry().validate().size(), 0)


func test_missing_skill_is_invalid() -> void:
	var entry := _make_valid_entry()
	entry.skill = null
	assert_has(entry.validate(), "skill is missing")


func test_zero_weight_is_invalid() -> void:
	var entry := _make_valid_entry()
	entry.weight = 0
	assert_has(entry.validate(), "weight must be at least 1")


func test_default_weight_is_one() -> void:
	assert_eq(EnemySkillEntry.new().weight, 1)
