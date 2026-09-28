extends GutTest
## Tests for ExplorationTraitData validation.


func _make_valid_trait() -> ExplorationTraitData:
	var exploration_trait := ExplorationTraitData.new()
	exploration_trait.id = &"break_obstacles"
	exploration_trait.display_name = "Romper obstáculos"
	return exploration_trait


func test_valid_trait_has_no_errors() -> void:
	assert_eq(_make_valid_trait().validate().size(), 0)


func test_empty_id_is_invalid() -> void:
	var exploration_trait := _make_valid_trait()
	exploration_trait.id = &""
	assert_has(exploration_trait.validate(), "id is empty")


func test_blank_display_name_is_invalid() -> void:
	var exploration_trait := _make_valid_trait()
	exploration_trait.display_name = " "
	assert_has(exploration_trait.validate(), "display_name is empty")
