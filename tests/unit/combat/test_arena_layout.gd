extends GutTest
## Tests for ArenaLayout.

const TOLERANCE: Vector3 = Vector3(0.0001, 0.0001, 0.0001)
const LEFT: float = -1.0
const RIGHT: float = 1.0


func _slots(side: float, row: CombatRow.Row, count: int) -> Array[Vector3]:
	return ArenaLayout.get_row_slots(Vector3(10.0, 0.0, 5.0), side, row, count, 1.5, 1.5, 1.4)


func test_left_front_row_is_left_of_center() -> void:
	var slots := _slots(LEFT, CombatRow.Row.FRONT, 1)
	assert_almost_eq(slots[0], Vector3(8.5, 0.0, 5.0), TOLERANCE)


func test_right_back_row_is_further_out() -> void:
	var slots := _slots(RIGHT, CombatRow.Row.BACK, 1)
	assert_almost_eq(slots[0], Vector3(13.0, 0.0, 5.0), TOLERANCE)


func test_front_row_is_closer_to_center_than_back_row() -> void:
	var front := _slots(LEFT, CombatRow.Row.FRONT, 1)[0]
	var back := _slots(LEFT, CombatRow.Row.BACK, 1)[0]
	assert_lt(absf(front.x - 10.0), absf(back.x - 10.0))


func test_units_of_a_row_are_spread_and_centered() -> void:
	var slots := _slots(RIGHT, CombatRow.Row.FRONT, 3)
	assert_almost_eq(slots[0].z, 3.6, 0.0001)
	assert_almost_eq(slots[1].z, 5.0, 0.0001)
	assert_almost_eq(slots[2].z, 6.4, 0.0001)


func test_zero_count_gives_no_slots() -> void:
	assert_eq(_slots(LEFT, CombatRow.Row.FRONT, 0).size(), 0)


func test_pov_camera_stands_behind_its_side() -> void:
	var position := ArenaLayout.get_pov_camera_position(Vector3(10.0, 0.0, 5.0), LEFT, 6.5, 2.2, 3.0)
	assert_almost_eq(position, Vector3(3.5, 2.2, 8.0), TOLERANCE)


func test_pov_camera_looks_towards_the_other_side() -> void:
	var target := ArenaLayout.get_pov_look_target(Vector3(10.0, 0.0, 5.0), LEFT, 1.5, 0.8)
	assert_almost_eq(target, Vector3(11.5, 0.8, 5.0), TOLERANCE)


func test_pov_camera_mirrors_for_right_side() -> void:
	var center := Vector3(10.0, 0.0, 5.0)
	assert_almost_eq(ArenaLayout.get_pov_camera_position(center, RIGHT, 6.5, 2.2, 3.0), Vector3(16.5, 2.2, 8.0), TOLERANCE)
	assert_almost_eq(ArenaLayout.get_pov_look_target(center, RIGHT, 1.5, 0.8), Vector3(8.5, 0.8, 5.0), TOLERANCE)


func test_free_slot_is_unchanged() -> void:
	var slot := Vector3(4.0, 0.0, 0.0)
	var result := ArenaLayout.resolve_slot(slot, Vector3.ZERO, 0.25, func(_p: Vector3) -> bool: return true)
	assert_almost_eq(result, slot, TOLERANCE)


func test_blocked_slot_moves_towards_center_until_free() -> void:
	# Everything beyond x = 3 is blocked (a wall).
	var is_free := func(p: Vector3) -> bool: return p.x <= 3.0
	var result := ArenaLayout.resolve_slot(Vector3(4.0, 0.0, 0.0), Vector3.ZERO, 0.25, is_free)
	assert_almost_eq(result, Vector3(3.0, 0.0, 0.0), TOLERANCE)


func test_slot_stops_at_center_if_never_free() -> void:
	var result := ArenaLayout.resolve_slot(Vector3(2.0, 0.0, 0.0), Vector3.ZERO, 0.25, func(_p: Vector3) -> bool: return false)
	assert_almost_eq(result, Vector3.ZERO, TOLERANCE)
