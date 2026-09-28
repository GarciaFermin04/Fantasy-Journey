extends GutTest
## Tests for Formation.

const FRONT := CombatRow.Row.FRONT
const BACK := CombatRow.Row.BACK


func _make(unit_name: String, row: CombatRow.Row, index: int = 0) -> Combatant:
	var combatant := Combatant.new()
	combatant.display_name = unit_name
	combatant.row = row
	combatant.formation_index = index
	return combatant


func test_units_go_to_their_row() -> void:
	var formation := Formation.new(3)
	var warrior := _make("Guerrero", FRONT)
	var mage := _make("Mago", BACK)
	formation.add(warrior)
	formation.add(mage)
	assert_eq(formation.get_row(FRONT), [warrior] as Array[Combatant])
	assert_eq(formation.get_row(BACK), [mage] as Array[Combatant])


func test_row_is_sorted_by_formation_index() -> void:
	var formation := Formation.new()
	var second := _make("b", FRONT, 1)
	var first := _make("a", FRONT, 0)
	formation.add(second)
	formation.add(first)
	assert_eq(formation.get_row(FRONT), [first, second] as Array[Combatant])


func test_full_row_rejects_unit() -> void:
	var formation := Formation.new(3)
	for i in 3:
		formation.add(_make("u%d" % i, FRONT, i))
	assert_false(formation.add(_make("extra", FRONT, 3)))
	assert_push_error("row FRONT is full")
	assert_eq(formation.get_row(FRONT).size(), 3)


func test_unlimited_formation_accepts_many_units() -> void:
	var formation := Formation.new()
	for i in 5:
		assert_true(formation.add(_make("u%d" % i, FRONT, i)))
	assert_eq(formation.get_row(FRONT).size(), 5)


func test_adding_twice_is_rejected() -> void:
	var formation := Formation.new()
	var unit := _make("a", FRONT)
	formation.add(unit)
	assert_false(formation.add(unit))
	assert_push_error("already a member")


func test_defeated_units_are_excluded() -> void:
	var formation := Formation.new()
	var alive := _make("vivo", FRONT, 0)
	var dead := _make("caido", FRONT, 1)
	formation.add(alive)
	formation.add(dead)
	dead.is_defeated = true
	assert_eq(formation.get_row(FRONT), [alive] as Array[Combatant])
	assert_eq(formation.get_living(), [alive] as Array[Combatant])


func test_living_lists_front_then_back() -> void:
	var formation := Formation.new()
	var back := _make("atras", BACK)
	var front := _make("adelante", FRONT)
	formation.add(back)
	formation.add(front)
	assert_eq(formation.get_living(), [front, back] as Array[Combatant])


func test_back_row_exposed_when_front_is_empty() -> void:
	var formation := Formation.new()
	var front := _make("adelante", FRONT)
	formation.add(front)
	formation.add(_make("atras", BACK))
	assert_false(formation.is_back_row_exposed())
	front.is_defeated = true
	assert_true(formation.is_back_row_exposed())


func test_defeated_units_free_room_in_row() -> void:
	var formation := Formation.new(1)
	var fallen := _make("caido", FRONT)
	formation.add(fallen)
	fallen.is_defeated = true
	assert_true(formation.add(_make("nuevo", FRONT)))


func test_move_to_row_changes_row() -> void:
	var formation := Formation.new(3)
	var unit := _make("a", FRONT)
	formation.add(unit)
	assert_true(formation.move_to_row(unit, BACK))
	assert_eq(unit.row, BACK)
	assert_eq(formation.get_row(BACK), [unit] as Array[Combatant])


func test_move_to_full_row_is_rejected() -> void:
	var formation := Formation.new(1)
	var front := _make("a", FRONT)
	formation.add(front)
	formation.add(_make("b", BACK))
	assert_false(formation.move_to_row(front, BACK))
	assert_push_error("row BACK is full")
	assert_eq(front.row, FRONT)


func test_move_non_member_is_rejected() -> void:
	var formation := Formation.new()
	assert_false(formation.move_to_row(_make("a", FRONT), BACK))
	assert_push_error("is not a member")
