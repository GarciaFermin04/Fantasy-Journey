class_name EnemyData
extends Resource
## Static definition of an enemy or boss: stats, affinity, weaknesses,
## resistances and a simple AI pattern (weighted skills and a target
## preference). The AI logic that reads this data lives in scripts/combat/.

enum AffinityReaction { NEUTRAL, WEAK, RESISTANT }
enum TargetPreference { RANDOM, LOWEST_HP }

@export_group("Identity")
## Stable identifier used by code and data (e.g. &"goblin").
@export var id: StringName = &""
## Name shown to the player.
@export var display_name: String = ""
## Description shown to the player.
@export_multiline var description: String = ""
## Optional art used by the enemy's visual.
@export var sprite: Texture2D
## Whether this enemy is a floor boss.
@export var is_boss: bool = false

@export_group("Combat")
## Base stats of the enemy.
@export var base_stats: StatBlock
## Affinity of the enemy. Skills of the same affinity get a bonus. Null means none.
@export var affinity: AffinityData
## Row the enemy takes at the start of combat.
@export var preferred_row: CombatRow.Row = CombatRow.Row.FRONT
## Affinities this enemy is weak to.
@export var weaknesses: Array[AffinityData] = []
## Affinities this enemy resists.
@export var resistances: Array[AffinityData] = []

@export_group("AI")
## Skills the enemy can use, with their relative weights.
@export var skills: Array[EnemySkillEntry] = []
## How the enemy chooses among valid targets.
@export var target_preference: TargetPreference = TargetPreference.RANDOM


## Returns how this enemy reacts to [param skill_affinity].
## A null affinity (neutral skill) is always [constant AffinityReaction.NEUTRAL].
func get_reaction(skill_affinity: AffinityData) -> AffinityReaction:
	if skill_affinity == null:
		return AffinityReaction.NEUTRAL
	if weaknesses.has(skill_affinity):
		return AffinityReaction.WEAK
	if resistances.has(skill_affinity):
		return AffinityReaction.RESISTANT
	return AffinityReaction.NEUTRAL


## Returns the enemy's skills in order, without weights.
func get_skills() -> Array[SkillData]:
	var result: Array[SkillData] = []
	for entry in skills:
		if entry != null and entry.skill != null:
			result.append(entry.skill)
	return result


## Returns a list of structural errors in this enemy. Empty means valid.
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
	errors.append_array(_validate_affinity_lists())
	errors.append_array(_validate_skills())
	return errors


func _validate_affinity_lists() -> PackedStringArray:
	var errors := PackedStringArray()
	if weaknesses.has(null):
		errors.append("weaknesses contains an empty entry")
	if resistances.has(null):
		errors.append("resistances contains an empty entry")
	if _has_duplicates(weaknesses):
		errors.append("weaknesses has duplicates")
	if _has_duplicates(resistances):
		errors.append("resistances has duplicates")
	for affinity_entry in weaknesses:
		if affinity_entry != null and resistances.has(affinity_entry):
			errors.append("affinity %s is both weakness and resistance" % affinity_entry.id)
	return errors


func _validate_skills() -> PackedStringArray:
	var errors := PackedStringArray()
	if skills.is_empty():
		errors.append("skills is empty")
	for entry in skills:
		if entry == null:
			errors.append("skills contains an empty entry")
		else:
			errors.append_array(entry.validate())
	return errors


func _has_duplicates(list: Array[AffinityData]) -> bool:
	var seen: Array[AffinityData] = []
	for item in list:
		if item != null and seen.has(item):
			return true
		seen.append(item)
	return false
