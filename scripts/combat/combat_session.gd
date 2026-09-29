class_name CombatSession
extends RefCounted
## One combat as pure logic: formations, turn queue, state machine, action
## resolution, stamina regen, cooldowns and victory/defeat. Scenes only
## present it: they listen to its signals and call perform() or pass_turn().

## Emitted when [param actor] starts its turn and must act.
signal turn_started(actor: Combatant)
## Emitted after [param action] was resolved, with one result per target.
signal action_performed(action: CombatAction, results: Array[ActionResult])
## Emitted when the combat ends.
signal combat_finished(result: CombatStateMachine.Result)

## Balance numbers of the combat.
var rules: CombatRules

var _machine := CombatStateMachine.new()
var _queue := TurnQueue.new()
var _allies: Formation
var _enemies: Formation


func _init(p_rules: CombatRules) -> void:
	assert(p_rules != null, "CombatSession needs rules")
	rules = p_rules
	_machine.combat_finished.connect(func(result: CombatStateMachine.Result) -> void: combat_finished.emit(result))


## Starts the combat between [param allies] and [param enemies] and begins
## the first turn. Connect to the signals before calling it.
func start(allies: Array[Combatant], enemies: Array[Combatant]) -> void:
	_allies = Formation.new(rules.ally_row_capacity)
	_enemies = Formation.new()
	for ally in allies:
		_allies.add(ally)
	for enemy in enemies:
		_enemies.add(enemy)
	var everyone := allies.duplicate()
	everyone.append_array(enemies)
	_queue.setup(everyone)
	_machine.start()
	_begin_next_turn()


## Resolves [param action] for the current actor, ends its turn and starts
## the next one (or ends the combat). Returns the results.
func perform(action: CombatAction) -> Array[ActionResult]:
	if action == null or action.user != get_current_actor():
		push_error("CombatSession.perform: the action does not belong to the current actor")
		return []
	if not _machine.submit_action(action):
		return []
	var results := ActionResolver.resolve(action, rules)
	action_performed.emit(action, results)
	_finish_turn()
	return results


## Ends the current turn without acting (e.g. an enemy with no valid action).
func pass_turn() -> void:
	if not _machine.submit_action(null):
		return
	_finish_turn()


## Returns the combatant whose turn it is, or null.
func get_current_actor() -> Combatant:
	return _queue.get_current_actor()


## Returns the allied formation.
func get_allies() -> Formation:
	return _allies


## Returns the enemy formation.
func get_enemies() -> Formation:
	return _enemies


## Returns the turn queue (read it to display the turn order).
func get_queue() -> TurnQueue:
	return _queue


## Returns whether the combat is waiting for the current actor's action.
func is_awaiting_action() -> bool:
	return _machine.get_state() == CombatStateMachine.State.AWAITING_ACTION


## Returns the combat result, or NONE while it is running.
func get_result() -> CombatStateMachine.Result:
	return _machine.get_result()


func _finish_turn() -> void:
	_machine.action_resolved()
	get_current_actor().end_turn()
	_begin_next_turn()


func _begin_next_turn() -> void:
	var outcome := CombatOutcome.evaluate(_allies, _enemies)
	if outcome != CombatStateMachine.Result.NONE:
		_machine.end_combat(outcome)
		return
	var actor := _queue.next_actor()
	actor.start_turn(rules)
	_machine.begin_turn(actor)
	turn_started.emit(actor)
