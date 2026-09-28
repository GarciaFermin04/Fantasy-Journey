class_name WeaponData
extends Resource
## An equippable weapon: the common base version of a type, a variant or a
## unique weapon. Grants its type's base skills plus its own extra skills,
## flat stat bonuses, an optional affinity bonus and skill cost modifiers.
## A unique weapon with its own type points to an exclusive WeaponTypeData.

enum Rarity { BASE, VARIANT, UNIQUE }

@export_group("Identity")
## Stable identifier used by code and data (e.g. &"holy_wand").
@export var id: StringName = &""
## Name shown to the player.
@export var display_name: String = ""
## Description shown to the player.
@export_multiline var description: String = ""
## Optional icon for menus.
@export var icon: Texture2D
## Whether this is the base version, a variant or a unique weapon.
@export var rarity: Rarity = Rarity.BASE
## Type of the weapon. Defines who can use it and its base skills.
@export var weapon_type: WeaponTypeData

@export_group("Modifiers")
## Flat stat bonuses added to the wielder. May be negative. Null means none.
@export var stat_bonus: StatBlock
## Affinity of the weapon. Boosts skills of the same affinity. Null means none.
@export var affinity: AffinityData
## Damage bonus, in percent, for skills that share the weapon's affinity.
@export_range(0, 100, 1, "or_greater") var affinity_bonus_percent: int = 0
## Flat change to the mana cost of every skill (negative reduces it).
## Final costs never go below zero.
@export var mana_cost_modifier: int = 0
## Flat change to the stamina cost of every skill (negative reduces it).
## Final costs never go below zero.
@export var stamina_cost_modifier: int = 0

@export_group("Skills")
## Skills added by this weapon on top of its type's base skills.
@export var extra_skills: Array[SkillData] = []


## Returns the type's base skills followed by the extra skills, without
## duplicates. The wielder chooses which ones to equip from this list.
func get_all_skills() -> Array[SkillData]:
	var result: Array[SkillData] = []
	if weapon_type != null:
		_append_unique(result, weapon_type.base_skills)
	_append_unique(result, extra_skills)
	return result


## Returns a list of structural errors in this weapon. Empty means valid.
func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id == &"":
		errors.append("id is empty")
	if display_name.strip_edges().is_empty():
		errors.append("display_name is empty")
	if weapon_type == null:
		errors.append("weapon_type is missing")
	if affinity_bonus_percent < 0:
		errors.append("affinity_bonus_percent is negative")
	if affinity_bonus_percent > 0 and affinity == null:
		errors.append("affinity_bonus_percent requires an affinity")
	if extra_skills.has(null):
		errors.append("extra_skills contains an empty entry")
	return errors


func _append_unique(target: Array[SkillData], skills: Array[SkillData]) -> void:
	for skill in skills:
		if skill != null and not target.has(skill):
			target.append(skill)
