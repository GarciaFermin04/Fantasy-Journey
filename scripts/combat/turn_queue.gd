class_name TurnQueue
extends RefCounted
## Turn order by speed. Every living combatant acts once per round. The
## combatants still waiting are re-sorted before each turn, so speed changes
## apply to them immediately. Ties: allies first, then formation order.
## Defeated combatants are skipped automatically.

## Emitted when a new round starts.
signal round_started(round_number: int)

var _combatants: Array[Combatant] = []
var _pending: Array[Combatant] = []
var _current: Combatant = null
var _round_number: int = 0


## Returns a copy of [param combatants] sorted by initiative: higher speed
## first, allies before enemies on ties, then lower formation index.
static func sort_by_initiative(combatants: Array[Combatant]) -> Array[Combatant]:
	var sorted := combatants.duplicate()
	sorted.sort_custom(_goes_before)
	return sorted


## Loads the combatants of a new combat and resets rounds.
func setup(combatants: Array[Combatant]) -> void:
	_combatants = combatants.duplicate()
	_pending.clear()
	_current = null
	_round_number = 0


## Returns the next combatant to act, starting a new round when the current
## one is over. Returns null when no combatant is left alive.
func next_actor() -> Combatant:
	_current = null
	var remaining := get_remaining_this_round()
	if remaining.is_empty():
		if _alive(_combatants).is_empty():
			return null
		_start_round()
		remaining = get_remaining_this_round()
	_current = remaining[0]
	_pending.erase(_current)
	return _current


## Returns the combatant acting now, or null.
func get_current_actor() -> Combatant:
	return _current


## Returns the living combatants that still have to act this round, in order.
func get_remaining_this_round() -> Array[Combatant]:
	return sort_by_initiative(_alive(_pending))


## Returns the order of the next round with the current speeds.
func get_next_round_preview() -> Array[Combatant]:
	return sort_by_initiative(_alive(_combatants))


## Returns the current round number (0 before the first turn).
func get_round_number() -> int:
	return _round_number


static func _goes_before(a: Combatant, b: Combatant) -> bool:
	if a.get_speed() != b.get_speed():
		return a.get_speed() > b.get_speed()
	if a.is_ally != b.is_ally:
		return a.is_ally
	return a.formation_index < b.formation_index


func _start_round() -> void:
	_round_number += 1
	_pending = _alive(_combatants)
	round_started.emit(_round_number)


func _alive(combatants: Array[Combatant]) -> Array[Combatant]:
	var result: Array[Combatant] = []
	for combatant in combatants:
		if not combatant.is_defeated:
			result.append(combatant)
	return result
