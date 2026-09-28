extends GutTest
## Tests for WeaponTypeData validation.


func _make_valid_type() -> WeaponTypeData:
	var weapon_type := WeaponTypeData.new()
	weapon_type.id = &"wand"
	weapon_type.display_name = "Varita"
	return weapon_type


func test_valid_type_has_no_errors() -> void:
	assert_eq(_make_valid_type().validate().size(), 0)


func test_empty_id_is_invalid() -> void:
	var weapon_type := _make_valid_type()
	weapon_type.id = &""
	assert_has(weapon_type.validate(), "id is empty")


func test_blank_display_name_is_invalid() -> void:
	var weapon_type := _make_valid_type()
	weapon_type.display_name = ""
	assert_has(weapon_type.validate(), "display_name is empty")


func test_empty_skill_entry_is_invalid() -> void:
	var weapon_type := _make_valid_type()
	weapon_type.base_skills = [null]
	assert_has(weapon_type.validate(), "base_skills contains an empty entry")
