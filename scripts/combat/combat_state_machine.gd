class_name CombatStateMachine
extends RefCounted
## Flow of a turn-based combat: start, turns, action resolution and end.
## Only enforces the order of the steps. Who acts, what an action does and
## who wins are decided by other combat systems. Pure logic, no nodes.
##
## Flow: IDLE -> STARTING -> AWAITING_ACTION -> RESOLVING_ACTION -> TURN_ENDED,
## then TURN_ENDED goes back to AWAITING_ACTION for the next turn or to FINISHED.

## Emitted on every state change.
signal state_changed(from: State, to: State)
## Emitted when [param actor] starts its turn.
signal turn_started(actor: Object)
## Emitted when the current actor submits [param action].
signal action_submitted(action: Variant)
## Emitted when the combat ends with [param result].
signal combat_finished(result: Result)

enum State { IDLE, STARTING, AWAITING_ACTION, RESOLVING_ACTION, TURN_ENDED, FINISHED }
enum Result { NONE, VICTORY, DEFEAT }

const _TRANSITIONS: Dictionary[State, Array] = {
	State.IDLE: [State.STARTING],
	State.STARTING: [State.AWAITING_ACTION],
	State.AWAITING_ACTION: [State.RESOLVING_ACTION],
	State.RESOLVING_ACTION: [State.TURN_ENDED],
	State.TURN_ENDED: [State.AWAITING_ACTION, State.FINISHED],
	State.FINISHED: [],
}

var _state: State = State.IDLE
var _result: Result = Result.NONE
var _current_actor: Object = null
var _current_action: Variant = null


## Starts the combat. Units get placed in their rows during STARTING.
func start() -> bool:
	return _transition_to(State.STARTING, "start")


## Starts the turn of [param actor], which must then choose an action.
func begin_turn(actor: Object) -> bool:
	if actor == null:
		push_error("CombatStateMachine.begin_turn: actor is null")
		return false
	if not _transition_to(State.AWAITING_ACTION, "begin_turn"):
		return false
	_current_actor = actor
	_current_action = null
	turn_started.emit(actor)
	return true


## Submits the action chosen by the current actor and starts resolving it.
func submit_action(action: Variant) -> bool:
	if not _transition_to(State.RESOLVING_ACTION, "submit_action"):
		return false
	_current_action = action
	action_submitted.emit(action)
	return true


## Signals that the current action finished resolving (effects and animations).
func action_resolved() -> bool:
	return _transition_to(State.TURN_ENDED, "action_resolved")


## Ends the combat with [param result] (VICTORY or DEFEAT).
func end_combat(result: Result) -> bool:
	if result == Result.NONE:
		push_error("CombatStateMachine.end_combat: result must be VICTORY or DEFEAT")
		return false
	if not _transition_to(State.FINISHED, "end_combat"):
		return false
	_result = result
	combat_finished.emit(result)
	return true


## Returns the current state.
func get_state() -> State:
	return _state


## Returns the combat result, or NONE while the combat is running.
func get_result() -> Result:
	return _result


## Returns the unit whose turn it is, or null before the first turn.
func get_current_actor() -> Object:
	return _current_actor


## Returns the action being resolved in the current turn, or null.
func get_current_action() -> Variant:
	return _current_action


func _transition_to(target: State, method_name: String) -> bool:
	if not _TRANSITIONS[_state].has(target):
		push_error("Invalid combat transition in %s: %s -> %s" % [
			method_name, State.keys()[_state], State.keys()[target]])
		return false
	var from := _state
	_state = target
	state_changed.emit(from, target)
	return true
