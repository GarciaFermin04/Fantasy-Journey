class_name Formation
extends RefCounted
## One side of a combat arranged in front and back rows. The front row
## protects the back row: when nobody is left in front, the back row is
## exposed. Defeated units do not count as occupying a row.

## Maximum living units per row. 0 means unlimited.
var max_per_row: int = 0

var _members: Array[Combatant] = []


func _init(p_max_per_row: int = 0) -> void:
	assert(p_max_per_row >= 0, "max_per_row cannot be negative")
	max_per_row = p_max_per_row


## Adds [param combatant] to the row it occupies. Fails if it is already a
## member or its row is full.
func add(combatant: Combatant) -> bool:
	if _members.has(combatant):
		push_error("Formation.add: %s is already a member" % combatant.display_name)
		return false
	if not _has_room(combatant.row):
		push_error("Formation.add: row %s is full" % CombatRow.Row.keys()[combatant.row])
		return false
	_members.append(combatant)
	return true


## Moves [param combatant] to [param row]. Used by skills that change rows.
## Fails if it is not a member or the target row is full.
func move_to_row(combatant: Combatant, row: CombatRow.Row) -> bool:
	if not _members.has(combatant):
		push_error("Formation.move_to_row: %s is not a member" % combatant.display_name)
		return false
	if combatant.row == row:
		return true
	if not _has_room(row):
		push_error("Formation.move_to_row: row %s is full" % CombatRow.Row.keys()[row])
		return false
	combatant.row = row
	return true


## Returns the living units in [param row], in formation order.
func get_row(row: CombatRow.Row) -> Array[Combatant]:
	var result: Array[Combatant] = []
	for member in _members:
		if member.row == row and not member.is_defeated:
			result.append(member)
	result.sort_custom(func(a: Combatant, b: Combatant) -> bool: return a.formation_index < b.formation_index)
	return result


## Returns every living unit: front row first, then back row.
func get_living() -> Array[Combatant]:
	var result := get_row(CombatRow.Row.FRONT)
	result.append_array(get_row(CombatRow.Row.BACK))
	return result


## Returns whether the back row is exposed because nobody is left in front.
func is_back_row_exposed() -> bool:
	return get_row(CombatRow.Row.FRONT).is_empty()


## Returns whether every unit of this side is defeated.
func is_wiped_out() -> bool:
	return get_living().is_empty()


## Returns whether [param combatant] belongs to this side.
func has(combatant: Combatant) -> bool:
	return _members.has(combatant)


func _has_room(row: CombatRow.Row) -> bool:
	return max_per_row == 0 or get_row(row).size() < max_per_row
