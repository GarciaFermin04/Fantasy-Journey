extends GutTest
## Tests for EnemyData validation, affinity reactions and skills.

var _fire: AffinityData
var _water: AffinityData
var _earth: AffinityData
var _bite: SkillData
var _roar: SkillData


func before_each() -> void:
	_fire = _make_affinity(&"fire")
	_water = _make_affinity(&"water")
	_earth = _make_affinity(&"earth")
	_bite = _make_skill(&"bite")
	_roar = _make_skill(&"roar")


func _make_affinity(affinity_id: StringName) -> AffinityData:
	var affinity := AffinityData.new()
	affinity.id = affinity_id
	return affinity


func _make_skill(skill_id: StringName) -> SkillData:
	var skill := SkillData.new()
	skill.id = skill_id
	skill.display_name = String(skill_id)
	return skill


func _make_entry(skill: SkillData, weight: int) -> EnemySkillEntry:
	var entry := EnemySkillEntry.new()
	entry.skill = skill
	entry.weight = weight
	return entry


func _make_valid_enemy() -> EnemyData:
	var enemy := EnemyData.new()
	enemy.id = &"wolf"
	enemy.display_name = "Lobo"
	enemy.base_stats = StatBlock.new()
	enemy.base_stats.max_hp = 40
	enemy.weaknesses = [_fire]
	enemy.resistances = [_water]
	enemy.skills = [_make_entry(_bite, 3), _make_entry(_roar, 1)]
	return enemy


func test_valid_enemy_has_no_errors() -> void:
	assert_eq(_make_valid_enemy().validate(), PackedStringArray())


func test_empty_id_is_invalid() -> void:
	var enemy := _make_valid_enemy()
	enemy.id = &""
	assert_has(enemy.validate(), "id is empty")


func test_missing_stats_is_invalid() -> void:
	var enemy := _make_valid_enemy()
	enemy.base_stats = null
	assert_has(enemy.validate(), "base_stats is missing")


func test_zero_hp_is_invalid() -> void:
	var enemy := _make_valid_enemy()
	enemy.base_stats.max_hp = 0
	assert_has(enemy.validate(), "max_hp must be positive")


func test_no_skills_is_invalid() -> void:
	var enemy := _make_valid_enemy()
	enemy.skills = []
	assert_has(enemy.validate(), "skills is empty")


func test_empty_skill_entry_is_invalid() -> void:
	var enemy := _make_valid_enemy()
	enemy.skills = [null]
	assert_has(enemy.validate(), "skills contains an empty entry")


func test_invalid_skill_entry_is_reported() -> void:
	var enemy := _make_valid_enemy()
	enemy.skills = [_make_entry(_bite, 0)]
	assert_has(enemy.validate(), "weight must be at least 1")


func test_affinity_both_weak_and_resistant_is_invalid() -> void:
	var enemy := _make_valid_enemy()
	enemy.resistances = [_fire]
	assert_has(enemy.validate(), "affinity fire is both weakness and resistance")


func test_duplicate_weakness_is_invalid() -> void:
	var enemy := _make_valid_enemy()
	enemy.weaknesses = [_fire, _fire]
	assert_has(enemy.validate(), "weaknesses has duplicates")


func test_empty_resistance_entry_is_invalid() -> void:
	var enemy := _make_valid_enemy()
	enemy.resistances = [null]
	assert_has(enemy.validate(), "resistances contains an empty entry")


func test_weak_affinity_reaction() -> void:
	assert_eq(_make_valid_enemy().get_reaction(_fire), EnemyData.AffinityReaction.WEAK)


func test_resistant_affinity_reaction() -> void:
	assert_eq(_make_valid_enemy().get_reaction(_water), EnemyData.AffinityReaction.RESISTANT)


func test_unlisted_affinity_is_neutral() -> void:
	assert_eq(_make_valid_enemy().get_reaction(_earth), EnemyData.AffinityReaction.NEUTRAL)


func test_neutral_skill_is_neutral() -> void:
	assert_eq(_make_valid_enemy().get_reaction(null), EnemyData.AffinityReaction.NEUTRAL)


func test_get_skills_keeps_order_without_weights() -> void:
	assert_eq(_make_valid_enemy().get_skills(), [_bite, _roar] as Array[SkillData])


func test_boss_flag_defaults_to_false() -> void:
	assert_false(EnemyData.new().is_boss)
