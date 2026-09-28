extends GutTest
## Checks the Stage 2 goal: warrior, mage and archer exist as data files
## with their weapons and equipped skills.

const RECRUIT_PATHS: Dictionary[StringName, String] = {
	&"warrior": "res://data/recruits/warrior.tres",
	&"mage": "res://data/recruits/mage.tres",
	&"archer": "res://data/recruits/archer.tres",
}
const WEAPON_TYPE_BY_RECRUIT: Dictionary[StringName, StringName] = {
	&"warrior": &"sword",
	&"mage": &"wand",
	&"archer": &"bow",
}


func _load_recruit(recruit_id: StringName) -> RecruitData:
	return load(RECRUIT_PATHS[recruit_id]) as RecruitData


func test_starting_recruits_exist() -> void:
	for recruit_id in RECRUIT_PATHS:
		assert_not_null(_load_recruit(recruit_id), "%s is missing" % recruit_id)


func test_starting_recruits_are_valid() -> void:
	for recruit_id in RECRUIT_PATHS:
		assert_eq(_load_recruit(recruit_id).validate(), PackedStringArray(), "%s has errors" % recruit_id)


func test_ids_match_file_names() -> void:
	for recruit_id in RECRUIT_PATHS:
		assert_eq(_load_recruit(recruit_id).id, recruit_id)


func test_each_recruit_uses_its_weapon_type() -> void:
	for recruit_id in RECRUIT_PATHS:
		var recruit := _load_recruit(recruit_id)
		assert_eq(recruit.default_weapon.weapon_type.id, WEAPON_TYPE_BY_RECRUIT[recruit_id], "%s weapon" % recruit_id)


func test_each_recruit_has_max_equipped_skills() -> void:
	for recruit_id in RECRUIT_PATHS:
		var recruit := _load_recruit(recruit_id)
		assert_eq(recruit.default_equipped_skills.size(), RecruitData.MAX_EQUIPPED_SKILLS, "%s skills" % recruit_id)


func test_each_recruit_has_an_exploration_trait() -> void:
	for recruit_id in RECRUIT_PATHS:
		assert_not_null(_load_recruit(recruit_id).exploration_trait, "%s trait" % recruit_id)


func test_each_recruit_has_one_spare_skill() -> void:
	for recruit_id in RECRUIT_PATHS:
		var recruit := _load_recruit(recruit_id)
		var available := recruit.get_available_skills(recruit.default_weapon)
		assert_eq(available.size(), RecruitData.MAX_EQUIPPED_SKILLS + 1, "%s available skills" % recruit_id)
