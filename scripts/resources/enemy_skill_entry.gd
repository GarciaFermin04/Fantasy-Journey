class_name EnemySkillEntry
extends Resource
## A skill an enemy can use and how often it picks it compared to its
## other skills (weight 3 is picked three times as often as weight 1).

## Skill used by the enemy.
@export var skill: SkillData
## Relative chance of choosing this skill. Must be at least 1.
@export_range(1, 100, 1, "or_greater") var weight: int = 1


## Returns a list of structural errors in this entry. Empty means valid.
func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if skill == null:
		errors.append("skill is missing")
	if weight < 1:
		errors.append("weight must be at least 1")
	return errors
