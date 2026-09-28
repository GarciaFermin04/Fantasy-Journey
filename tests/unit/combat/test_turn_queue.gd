extends GutTest
## Tests for TurnQueue.

var _queue: TurnQueue


func before_each() -> void:
	_queue = TurnQueue.new()


func _make(unit_name: String, speed: int, is_ally: bool, index: int = 0) -> Combatant:
	var combatant := Combatant.new()
	combatant.display_name = unit_name
	combatant.stats.speed = speed
	combatant.is_ally = is_ally
	combatant.formation_index = index
	return combatant


func _names(combatants: Array[Combatant]) -> Array[String]:
	var result: Array[String] = []
	for combatant in combatants:
		result.append(combatant.display_name)
	return result


func _take_turns(count: int) -> Array[String]:
	var result: Array[String] = []
	for i in count:
		var actor := _queue.next_actor()
		result.append(actor.display_name if actor != null else "")
	return result


func test_orders_by_speed() -> void:
	_queue.setup([_make("lento", 5, true), _make("rapido", 15, false), _make("medio", 10, true)])
	assert_eq(_take_turns(3), ["rapido", "medio", "lento"] as Array[String])


func test_tie_goes_to_ally() -> void:
	_queue.setup([_make("enemigo", 10, false), _make("aliado", 10, true)])
	assert_eq(_take_turns(2), ["aliado", "enemigo"] as Array[String])


func test_tie_within_side_uses_formation_order() -> void:
	_queue.setup([_make("segundo", 10, true, 1), _make("primero", 10, true, 0)])
	assert_eq(_take_turns(2), ["primero", "segundo"] as Array[String])


func test_each_combatant_acts_once_per_round() -> void:
	_queue.setup([_make("a", 20, true), _make("b", 10, false)])
	assert_eq(_take_turns(4), ["a", "b", "a", "b"] as Array[String])


func test_new_round_emits_signal_and_increments_number() -> void:
	watch_signals(_queue)
	_queue.setup([_make("a", 20, true), _make("b", 10, false)])
	_take_turns(3)
	assert_eq(_queue.get_round_number(), 2)
	assert_signal_emit_count(_queue, "round_started", 2)
	assert_signal_emitted_with_parameters(_queue, "round_started", [2])


func test_round_number_is_zero_before_first_turn() -> void:
	_queue.setup([_make("a", 20, true)])
	assert_eq(_queue.get_round_number(), 0)


func test_slowing_a_pending_unit_reorders_it() -> void:
	var fast := _make("rapido", 30, true)
	var mid := _make("medio", 20, false)
	var slow := _make("lento", 10, false)
	_queue.setup([fast, mid, slow])
	_queue.next_actor()
	mid.stats.speed = 5
	assert_eq(_take_turns(2), ["lento", "medio"] as Array[String])


func test_speeding_up_after_acting_gives_no_extra_turn() -> void:
	var a := _make("a", 20, true)
	var b := _make("b", 10, false)
	var c := _make("c", 5, false)
	_queue.setup([a, b, c])
	_queue.next_actor()
	a.stats.speed = 100
	assert_eq(_take_turns(2), ["b", "c"] as Array[String])


func test_defeated_unit_loses_its_turn() -> void:
	var a := _make("a", 20, true)
	var b := _make("b", 10, false)
	var c := _make("c", 5, false)
	_queue.setup([a, b, c])
	_queue.next_actor()
	b.is_defeated = true
	assert_eq(_take_turns(2), ["c", "a"] as Array[String])


func test_defeated_unit_leaves_order_and_preview() -> void:
	var a := _make("a", 20, true)
	var b := _make("b", 10, false)
	_queue.setup([a, b])
	_queue.next_actor()
	b.is_defeated = true
	assert_eq(_queue.get_remaining_this_round(), [] as Array[Combatant])
	assert_eq(_names(_queue.get_next_round_preview()), ["a"] as Array[String])


func test_all_defeated_returns_null() -> void:
	var a := _make("a", 20, true)
	_queue.setup([a])
	_queue.next_actor()
	a.is_defeated = true
	assert_null(_queue.next_actor())


func test_empty_queue_returns_null() -> void:
	_queue.setup([])
	assert_null(_queue.next_actor())


func test_current_actor_and_remaining() -> void:
	var a := _make("a", 20, true)
	_queue.setup([a, _make("b", 10, false), _make("c", 5, false)])
	_queue.next_actor()
	assert_eq(_queue.get_current_actor(), a)
	assert_eq(_names(_queue.get_remaining_this_round()), ["b", "c"] as Array[String])


func test_preview_includes_units_that_already_acted() -> void:
	_queue.setup([_make("a", 20, true), _make("b", 10, false)])
	_queue.next_actor()
	assert_eq(_names(_queue.get_next_round_preview()), ["a", "b"] as Array[String])


func test_sort_by_initiative_does_not_modify_input() -> void:
	var slow := _make("lento", 5, true)
	var fast := _make("rapido", 15, true)
	var input: Array[Combatant] = [slow, fast]
	TurnQueue.sort_by_initiative(input)
	assert_eq(input, [slow, fast] as Array[Combatant])
