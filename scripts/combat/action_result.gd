class_name ActionResult
extends RefCounted
## What an action did to one target. Used by the combat log now and by
## on-screen damage numbers later.

## Combatant affected.
var target: Combatant
## Health actually lost or recovered.
var amount: int = 0
## Whether the amount is healing instead of damage.
var is_heal: bool = false
## Reaction of the target to the skill's affinity.
var reaction: EnemyData.AffinityReaction = EnemyData.AffinityReaction.NEUTRAL
## Whether the target was defeated by this action.
var defeated: bool = false
