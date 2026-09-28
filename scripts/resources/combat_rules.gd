class_name CombatRules
extends Resource
## Balance numbers of the combat formulas. Kept as data so they can be tuned
## without touching code.

## Multiplier applied to Power × Attack / Defense.
@export var base_damage_factor: float = 0.5
## Damage/heal bonus, in percent, when a skill shares the user's affinity.
@export_range(0, 100, 1, "or_greater") var affinity_bonus_percent: int = 15
## Damage multiplier against a target weak to the skill's affinity.
@export var weak_multiplier: float = 1.25
## Damage multiplier against a target resistant to the skill's affinity.
@export var resist_multiplier: float = 0.75
## Minimum damage of any hit.
@export_range(0, 10, 1, "or_greater") var min_damage: int = 1
## Healing adds the user's attack stat divided by this value.
@export var heal_stat_divisor: float = 2.0


## Returns a list of structural errors in these rules. Empty means valid.
func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if base_damage_factor <= 0.0:
		errors.append("base_damage_factor must be positive")
	if affinity_bonus_percent < 0:
		errors.append("affinity_bonus_percent is negative")
	if weak_multiplier <= 0.0:
		errors.append("weak_multiplier must be positive")
	if resist_multiplier <= 0.0:
		errors.append("resist_multiplier must be positive")
	if min_damage < 0:
		errors.append("min_damage is negative")
	if heal_stat_divisor <= 0.0:
		errors.append("heal_stat_divisor must be positive")
	return errors
