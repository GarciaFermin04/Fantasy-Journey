class_name SkillData
extends Resource
## Definition of a combat skill: effect, cost, affinity and targeting.
## Only holds data; combat systems read it. Costs are base values that
## recruit passives or weapon variants may modify during combat.
##
## Targeting combines three axes:
## - [member target_side]: whose units can be targeted.
## - [member target_reach]: which rows can be chosen. Applies to
##   [constant TargetArea.SINGLE] and [constant TargetArea.ROW];
##   [constant TargetArea.ALL] ignores it.
## - [member target_area]: how many units are affected.

enum Effect { DAMAGE, HEAL }
enum Category { PHYSICAL, MAGICAL }
enum TargetSide { ENEMY, ALLY, SELF }
enum TargetReach { FRONT_ROW, ANY_ROW }
enum TargetArea { SINGLE, ROW, ALL }

@export_group("Identity")
## Stable identifier used by code and data (e.g. &"slash").
@export var id: StringName = &""
## Name shown to the player.
@export var display_name: String = ""
## Description shown to the player.
@export_multiline var description: String = ""
## Optional icon for menus.
@export var icon: Texture2D

@export_group("Effect")
## What the skill does to its targets.
@export var effect: Effect = Effect.DAMAGE
## Which attack and defense stats the damage formula uses.
@export var category: Category = Category.PHYSICAL
## Base strength of the effect.
@export_range(0, 999, 1, "or_greater") var power: int = 0
## Affinity of the skill. Null means neutral (no bonus, no weakness).
@export var affinity: AffinityData

@export_group("Cost")
## Base mana cost. Mana does not regenerate on its own.
@export_range(0, 999, 1, "or_greater") var mana_cost: int = 0
## Base stamina cost. Stamina regenerates every turn.
@export_range(0, 999, 1, "or_greater") var stamina_cost: int = 0
## Turns to wait before using the skill again. 0 means no cooldown.
@export_range(0, 99, 1, "or_greater") var cooldown_turns: int = 0

@export_group("Targeting")
## Whose units can be targeted.
@export var target_side: TargetSide = TargetSide.ENEMY
## Which rows can be chosen.
@export var target_reach: TargetReach = TargetReach.FRONT_ROW
## How many units are affected.
@export var target_area: TargetArea = TargetArea.SINGLE


## Returns a list of structural errors in this skill. Empty means valid.
func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id == &"":
		errors.append("id is empty")
	if display_name.strip_edges().is_empty():
		errors.append("display_name is empty")
	if power < 0:
		errors.append("power is negative")
	if mana_cost < 0:
		errors.append("mana_cost is negative")
	if stamina_cost < 0:
		errors.append("stamina_cost is negative")
	if cooldown_turns < 0:
		errors.append("cooldown_turns is negative")
	if target_side == TargetSide.SELF and target_area != TargetArea.SINGLE:
		errors.append("SELF skills must use SINGLE area")
	return errors
