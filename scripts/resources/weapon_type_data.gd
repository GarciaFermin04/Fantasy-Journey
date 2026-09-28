class_name WeaponTypeData
extends Resource
## A weapon type (e.g. Wand, Sword, Bow). Recruits can use certain types.
## Every weapon of this type grants its base skills.

## Stable identifier used by code and data (e.g. &"wand").
@export var id: StringName = &""
## Name shown to the player.
@export var display_name: String = ""
## Description shown to the player.
@export_multiline var description: String = ""
## Skills granted by every weapon of this type.
@export var base_skills: Array[SkillData] = []


## Returns a list of structural errors in this weapon type. Empty means valid.
func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id == &"":
		errors.append("id is empty")
	if display_name.strip_edges().is_empty():
		errors.append("display_name is empty")
	if base_skills.has(null):
		errors.append("base_skills contains an empty entry")
	return errors
