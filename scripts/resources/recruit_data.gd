class_name RecruitData
extends Resource
## Static definition of a recruit: stats, affinity, allowed weapon types,
## personal skills, exploration trait and default loadout. What the player
## chooses in the Kingdom is saved progress, not part of this data.

## Maximum number of skills a recruit can have equipped.
const MAX_EQUIPPED_SKILLS: int = 4

@export_group("Identity")
## Stable identifier used by code and data (e.g. &"warrior").
@export var id: StringName = &""
## Name shown to the player.
@export var display_name: String = ""
## Description shown to the player.
@export_multiline var description: String = ""
## Optional art used by the recruit's visual.
@export var sprite: Texture2D

@export_group("Combat")
## Base stats, without weapon bonuses.
@export var base_stats: StatBlock
## Affinity of the recruit. Skills of the same affinity get a bonus.
@export var affinity: AffinityData
## Row the recruit prefers at the start of combat.
@export var preferred_row: CombatRow.Row = CombatRow.Row.FRONT
## Weapon types this recruit can use.
@export var allowed_weapon_types: Array[WeaponTypeData] = []
## Personal skills, available with any weapon.
@export var own_skills: Array[SkillData] = []

@export_group("Exploration")
## Exploration ability of the recruit. Null means none.
@export var exploration_trait: ExplorationTraitData

@export_group("Default Loadout")
## Weapon equipped by default.
@export var default_weapon: WeaponData
## Skills equipped by default, chosen from the available skills.
@export var default_equipped_skills: Array[SkillData] = []


## Returns whether this recruit can use [param weapon].
func can_use_weapon(weapon: WeaponData) -> bool:
	return weapon != null and allowed_weapon_types.has(weapon.weapon_type)


## Returns the skills available with [param weapon]: the weapon's skills
## followed by the recruit's own skills, without duplicates.
func get_available_skills(weapon: WeaponData) -> Array[SkillData]:
	var result: Array[SkillData] = []
	if weapon != null:
		result.append_array(weapon.get_all_skills())
	for skill in own_skills:
		if skill != null and not result.has(skill):
			result.append(skill)
	return result


## Returns the base stats plus the flat bonuses of [param weapon].
func get_stats_with(weapon: WeaponData) -> StatBlock:
	assert(base_stats != null, "RecruitData %s has no base_stats" % id)
	var bonus: StatBlock = null if weapon == null else weapon.stat_bonus
	return base_stats.plus(bonus)


## Returns a list of structural errors in this recruit. Empty means valid.
func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id == &"":
		errors.append("id is empty")
	if display_name.strip_edges().is_empty():
		errors.append("display_name is empty")
	if base_stats == null:
		errors.append("base_stats is missing")
	else:
		errors.append_array(base_stats.validate_as_base_stats())
	if allowed_weapon_types.is_empty():
		errors.append("allowed_weapon_types is empty")
	if allowed_weapon_types.has(null):
		errors.append("allowed_weapon_types contains an empty entry")
	if own_skills.has(null):
		errors.append("own_skills contains an empty entry")
	errors.append_array(_validate_default_loadout())
	return errors


func _validate_default_loadout() -> PackedStringArray:
	var errors := PackedStringArray()
	if default_weapon == null:
		errors.append("default_weapon is missing")
	elif not can_use_weapon(default_weapon):
		errors.append("default_weapon type is not allowed")
	if default_equipped_skills.size() > MAX_EQUIPPED_SKILLS:
		errors.append("too many default_equipped_skills")
	var available := get_available_skills(default_weapon)
	var seen: Array[SkillData] = []
	for skill in default_equipped_skills:
		if skill == null:
			errors.append("default_equipped_skills contains an empty entry")
		elif seen.has(skill):
			errors.append("default_equipped_skills has duplicates")
		elif not available.has(skill):
			errors.append("equipped skill %s is not available" % skill.id)
		seen.append(skill)
	return errors
