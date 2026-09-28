class_name CombatOutcome
extends RefCounted
## Decides whether a combat is over: victory when every enemy is defeated,
## defeat when every ally is.


## Returns the result of a combat between [param allies] and [param enemies]:
## NONE while both sides have living units.
static func evaluate(allies: Formation, enemies: Formation) -> CombatStateMachine.Result:
	if allies.is_wiped_out():
		return CombatStateMachine.Result.DEFEAT
	if enemies.is_wiped_out():
		return CombatStateMachine.Result.VICTORY
	return CombatStateMachine.Result.NONE
