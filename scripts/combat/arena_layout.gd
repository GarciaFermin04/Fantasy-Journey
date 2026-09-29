class_name ArenaLayout
extends RefCounted
## Positions of a combat arena built around a center point. Each side stands
## on one side of the center along the world X axis (horizontal on screen
## with the fixed camera): the front row closer to the center, the back row
## further out, and units of the same row spread along Z.


## Returns [param count] positions for [param row] of the side at
## [param side] (-1 left, +1 right). The front row is [param front_offset]
## meters from the center, the back row [param row_gap] meters further, and
## units are [param spacing] meters apart, centered on the center's Z.
static func get_row_slots(center: Vector3, side: float, row: CombatRow.Row, count: int, front_offset: float, row_gap: float, spacing: float) -> Array[Vector3]:
	var distance := front_offset + (row_gap if row == CombatRow.Row.BACK else 0.0)
	var x := center.x + side * distance
	var start_z := center.z - spacing * (count - 1) / 2.0
	var result: Array[Vector3] = []
	for i in count:
		result.append(Vector3(x, center.y, start_z + spacing * i))
	return result


## Returns the position of a low "over the shoulder" camera behind the side at
## [param side] (-1 left, +1 right): [param distance] meters from the center on
## that side, [param height] meters up and [param lateral] meters towards +Z
## (the viewer), so it looks across the arena diagonally.
static func get_pov_camera_position(center: Vector3, side: float, distance: float, height: float, lateral: float) -> Vector3:
	return center + Vector3(side * distance, height, lateral)


## Returns the point that camera looks at: [param lead] meters from the center
## towards the opposite side, at [param height] meters.
static func get_pov_look_target(center: Vector3, side: float, lead: float, height: float) -> Vector3:
	return center + Vector3(-side * lead, height, 0.0)


## Returns [param slot] if [param is_free] says it is free; otherwise moves it
## towards [param center] in steps of [param step] meters until a free
## position is found or the center is reached. [param is_free] receives a
## Vector3 and returns a bool.
static func resolve_slot(slot: Vector3, center: Vector3, step: float, is_free: Callable) -> Vector3:
	assert(step > 0.0, "ArenaLayout.resolve_slot: step must be positive")
	var to_center := Vector3(center.x - slot.x, 0.0, center.z - slot.z)
	var distance := to_center.length()
	var direction := to_center / distance if distance > 0.0 else Vector3.ZERO
	var position := slot
	var travelled := 0.0
	while not is_free.call(position) and travelled < distance:
		travelled = minf(travelled + step, distance)
		position = slot + direction * travelled
	return position
