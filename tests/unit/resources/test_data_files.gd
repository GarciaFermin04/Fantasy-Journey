extends GutTest
## Loads every resource under data/ that defines validate() and checks it
## has no errors. Catches badly configured data without running the game.

const DATA_DIR: String = "res://data"


func test_all_data_files_are_valid() -> void:
	var paths := _find_resource_files(DATA_DIR)
	var checked := 0
	for path in paths:
		var resource := load(path)
		assert_not_null(resource, "%s could not be loaded" % path)
		if resource != null and resource.has_method(&"validate"):
			assert_eq(resource.validate(), PackedStringArray(), "%s has errors" % path)
			checked += 1
	if checked == 0:
		pass_test("No data files with validate() yet")


func _find_resource_files(dir_path: String) -> PackedStringArray:
	var result := PackedStringArray()
	for file in DirAccess.get_files_at(dir_path):
		if file.ends_with(".tres"):
			result.append(dir_path.path_join(file))
	for sub_dir in DirAccess.get_directories_at(dir_path):
		result.append_array(_find_resource_files(dir_path.path_join(sub_dir)))
	return result
