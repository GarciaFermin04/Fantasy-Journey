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
## Stamina recovered at the start of each own turn, in percent of the maximum.
@export_range(0, 100, 1) var stamina_regen_percent: int = 20
## Whether enemies pay mana and stamina for their skills.
@export var enemies_pay_costs: bool = false
## Maximum allied units per row.
@export_range(1, 3, 1) var ally_row_capacity: int = 3
## Weight of front row targets for enemies that pick targets at random
## (back row targets weigh 1). The front row receives more attacks.
@export_range(1, 10, 1, "or_greater") var ai_front_row_weight: int = 2


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
	if stamina_regen_percent < 0:
		errors.append("stamina_regen_percent is negative")
	if ally_row_capacity < 1:
		errors.append("ally_row_capacity must be at least 1")
	if ai_front_row_weight < 1:
		errors.append("ai_front_row_weight must be at least 1")
	return errors
