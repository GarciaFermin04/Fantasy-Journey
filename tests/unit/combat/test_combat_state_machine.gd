extends GutTest
## Tests for CombatStateMachine.

const INVALID_TRANSITION: String = "Invalid combat transition"

var _machine: CombatStateMachine
var _actor_a: RefCounted
var _actor_b: RefCounted


func before_each() -> void:
	_machine = CombatStateMachine.new()
	_actor_a = RefCounted.new()
	_actor_b = RefCounted.new()


func _play_turn(actor: Object, action: Variant) -> void:
	_machine.begin_turn(actor)
	_machine.submit_action(action)
	_machine.action_resolved()


func test_starts_idle() -> void:
	assert_eq(_machine.get_state(), CombatStateMachine.State.IDLE)
	assert_eq(_machine.get_result(), CombatStateMachine.Result.NONE)
	assert_null(_machine.get_current_actor())


func test_start_moves_to_starting() -> void:
	assert_true(_machine.start())
	assert_eq(_machine.get_state(), CombatStateMachine.State.STARTING)


func test_full_turn_goes_through_states_in_order() -> void:
	var visited: Array[CombatStateMachine.State] = []
	_machine.state_changed.connect(func(_from: CombatStateMachine.State, to: CombatStateMachine.State) -> void: visited.append(to))
	_machine.start()
	_play_turn(_actor_a, &"slash")
	assert_eq(visited, [
		CombatStateMachine.State.STARTING,
		CombatStateMachine.State.AWAITING_ACTION,
		CombatStateMachine.State.RESOLVING_ACTION,
		CombatStateMachine.State.TURN_ENDED,
	] as Array[CombatStateMachine.State])


func test_begin_turn_sets_actor_and_emits_signal() -> void:
	watch_signals(_machine)
	_machine.start()
	assert_true(_machine.begin_turn(_actor_a))
	assert_eq(_machine.get_current_actor(), _actor_a)
	assert_signal_emitted_with_parameters(_machine, "turn_started", [_actor_a])


func test_submit_action_stores_action_and_emits_signal() -> void:
	watch_signals(_machine)
	_machine.start()
	_machine.begin_turn(_actor_a)
	assert_true(_machine.submit_action(&"slash"))
	assert_eq(_machine.get_current_action(), &"slash")
	assert_signal_emitted_with_parameters(_machine, "action_submitted", [&"slash"])


func test_several_turns_in_a_row() -> void:
	_machine.start()
	_play_turn(_actor_a, &"slash")
	_play_turn(_actor_b, &"fireball")
	assert_eq(_machine.get_state(), CombatStateMachine.State.TURN_ENDED)
	assert_eq(_machine.get_current_actor(), _actor_b)


func test_new_turn_clears_previous_action() -> void:
	_machine.start()
	_play_turn(_actor_a, &"slash")
	_machine.begin_turn(_actor_b)
	assert_null(_machine.get_current_action())


func test_end_combat_with_victory() -> void:
	watch_signals(_machine)
	_machine.start()
	_play_turn(_actor_a, &"slash")
	assert_true(_machine.end_combat(CombatStateMachine.Result.VICTORY))
	assert_eq(_machine.get_state(), CombatStateMachine.State.FINISHED)
	assert_eq(_machine.get_result(), CombatStateMachine.Result.VICTORY)
	assert_signal_emitted_with_parameters(_machine, "combat_finished", [CombatStateMachine.Result.VICTORY])


func test_end_combat_with_defeat() -> void:
	_machine.start()
	_play_turn(_actor_a, &"slash")
	assert_true(_machine.end_combat(CombatStateMachine.Result.DEFEAT))
	assert_eq(_machine.get_result(), CombatStateMachine.Result.DEFEAT)


func test_cannot_start_twice() -> void:
	_machine.start()
	assert_false(_machine.start())
	assert_push_error(INVALID_TRANSITION)
	assert_eq(_machine.get_state(), CombatStateMachine.State.STARTING)


func test_cannot_begin_turn_before_start() -> void:
	assert_false(_machine.begin_turn(_actor_a))
	assert_push_error(INVALID_TRANSITION)
	assert_eq(_machine.get_state(), CombatStateMachine.State.IDLE)
	assert_null(_machine.get_current_actor())


func test_cannot_submit_action_before_turn() -> void:
	_machine.start()
	assert_false(_machine.submit_action(&"slash"))
	assert_push_error(INVALID_TRANSITION)
	assert_eq(_machine.get_state(), CombatStateMachine.State.STARTING)


func test_cannot_begin_turn_while_resolving() -> void:
	_machine.start()
	_machine.begin_turn(_actor_a)
	_machine.submit_action(&"slash")
	assert_false(_machine.begin_turn(_actor_b))
	assert_push_error(INVALID_TRANSITION)
	assert_eq(_machine.get_state(), CombatStateMachine.State.RESOLVING_ACTION)
	assert_eq(_machine.get_current_actor(), _actor_a)


func test_cannot_resolve_without_action() -> void:
	_machine.start()
	_machine.begin_turn(_actor_a)
	assert_false(_machine.action_resolved())
	assert_push_error(INVALID_TRANSITION)
	assert_eq(_machine.get_state(), CombatStateMachine.State.AWAITING_ACTION)


func test_cannot_end_combat_mid_turn() -> void:
	_machine.start()
	_machine.begin_turn(_actor_a)
	assert_false(_machine.end_combat(CombatStateMachine.Result.VICTORY))
	assert_push_error(INVALID_TRANSITION)
	assert_eq(_machine.get_result(), CombatStateMachine.Result.NONE)


func test_null_actor_is_rejected() -> void:
	_machine.start()
	assert_false(_machine.begin_turn(null))
	assert_push_error("actor is null")
	assert_eq(_machine.get_state(), CombatStateMachine.State.STARTING)


func test_end_combat_with_none_is_rejected() -> void:
	_machine.start()
	_play_turn(_actor_a, &"slash")
	assert_false(_machine.end_combat(CombatStateMachine.Result.NONE))
	assert_push_error("result must be VICTORY or DEFEAT")
	assert_eq(_machine.get_state(), CombatStateMachine.State.TURN_ENDED)


func test_finished_combat_accepts_nothing() -> void:
	_machine.start()
	_play_turn(_actor_a, &"slash")
	_machine.end_combat(CombatStateMachine.Result.VICTORY)
	assert_false(_machine.begin_turn(_actor_b))
	assert_false(_machine.start())
	assert_push_error_count(2)
	assert_eq(_machine.get_state(), CombatStateMachine.State.FINISHED)


func test_invalid_transition_emits_no_state_change() -> void:
	watch_signals(_machine)
	_machine.submit_action(&"slash")
	assert_push_error(INVALID_TRANSITION)
	assert_signal_not_emitted(_machine, "state_changed")
