class_name Combatant
extends RefCounted
## A unit taking part in a combat (recruit or enemy). Holds the state that
## changes during the fight, so the static data resources stay untouched.

## Name shown in combat UI.
var display_name: String = ""
## Optional art for UI such as the turn order bar.
var portrait: Texture2D = null
## Whether the unit fights on the player's side.
var is_ally: bool = false
## Position inside its side's formation. Breaks speed ties within a side.
var formation_index: int = 0
## Current stats (base stats plus weapon bonuses for recruits).
var stats: StatBlock = StatBlock.new()
## Whether the unit was defeated. Defeated units lose their turns.
var is_defeated: bool = false


## Creates an allied combatant from [param recruit] wielding [param weapon].
static func from_recruit(recruit: RecruitData, weapon: WeaponData, index: int) -> Combatant:
	assert(recruit != null, "Combatant.from_recruit: recruit is null")
	var combatant := Combatant.new()
	combatant.display_name = recruit.display_name
	combatant.portrait = recruit.sprite
	combatant.is_ally = true
	combatant.formation_index = index
	combatant.stats = recruit.get_stats_with(weapon)
	return combatant


## Creates an enemy combatant from [param enemy].
static func from_enemy(enemy: EnemyData, index: int) -> Combatant:
	assert(enemy != null, "Combatant.from_enemy: enemy is null")
	var combatant := Combatant.new()
	combatant.display_name = enemy.display_name
	combatant.portrait = enemy.sprite
	combatant.is_ally = false
	combatant.formation_index = index
	combatant.stats = enemy.base_stats.plus(null)
	return combatant


## Returns the current speed, which defines turn order.
func get_speed() -> int:
	return stats.speed
