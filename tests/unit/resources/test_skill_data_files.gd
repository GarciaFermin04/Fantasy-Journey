extends GutTest
## Loads every skill resource under data/skills/ and checks it is valid.

const SKILLS_DIR: String = "res://data/skills"


func test_all_skill_files_are_valid() -> void:
	var paths := _find_resource_files(SKILLS_DIR)
	if paths.is_empty():
		pass_test("No skill files yet")
		return
	for path in paths:
		var skill := load(path) as SkillData
		assert_not_null(skill, "%s is not a SkillData" % path)
		if skill != null:
			assert_eq(skill.validate(), PackedStringArray(), "%s has errors" % path)


func _find_resource_files(dir_path: String) -> PackedStringArray:
	var result := PackedStringArray()
	for file in DirAccess.get_files_at(dir_path):
		if file.ends_with(".tres"):
			result.append(dir_path.path_join(file))
	for sub_dir in DirAccess.get_directories_at(dir_path):
		result.append_array(_find_resource_files(dir_path.path_join(sub_dir)))
	return result
