class_name ExplorationTraitData
extends Resource
## An exploration ability of a recruit (e.g. break obstacles, read runes).
## Interactables compare against it to offer optional paths or rewards.

## Stable identifier used by code and data (e.g. &"break_obstacles").
@export var id: StringName = &""
## Name shown to the player.
@export var display_name: String = ""
## Description shown to the player.
@export_multiline var description: String = ""


## Returns a list of structural errors in this trait. Empty means valid.
func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id == &"":
		errors.append("id is empty")
	if display_name.strip_edges().is_empty():
		errors.append("display_name is empty")
	return errors
