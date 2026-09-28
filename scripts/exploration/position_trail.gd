class_name PositionTrail
extends RefCounted
## History of positions left by a moving target (newest first).
## Followers sample it by distance so they walk the exact same path.

## Minimum distance between two stored points, in meters.
var point_spacing: float
## Maximum number of stored points. Older points are discarded.
var max_points: int

var _head: Vector3 = Vector3.ZERO
var _points: Array[Vector3] = []


func _init(p_point_spacing: float = 0.2, p_max_points: int = 64) -> void:
	assert(p_point_spacing > 0.0, "point_spacing must be positive")
	assert(p_max_points >= 2, "max_points must be at least 2")
	point_spacing = p_point_spacing
	max_points = p_max_points


## Updates the head of the trail with [param position]. A new point is stored
## only when the head moved at least [member point_spacing] from the last one.
func record(position: Vector3) -> void:
	_head = position
	if _points.is_empty() or _points[0].distance_to(position) >= point_spacing:
		_points.push_front(position)
		if _points.size() > max_points:
			_points.resize(max_points)


## Returns the point of the trail that is [param distance] meters behind the
## head, measured along the path. Returns the oldest point if the trail is shorter.
func sample_at_distance(distance: float) -> Vector3:
	var remaining := distance
	var previous := _head
	for point in _points:
		var segment := previous.distance_to(point)
		if segment > 0.0 and segment >= remaining:
			return previous.lerp(point, remaining / segment)
		remaining -= segment
		previous = point
	return previous


## Clears the trail and fills it with a straight line that starts at
## [param start] and extends [param length] meters towards [param back_direction].
func reset(start: Vector3, back_direction: Vector3, length: float) -> void:
	var direction := back_direction.normalized()
	var count := mini(ceili(length / point_spacing) + 1, max_points)
	_head = start
	_points.clear()
	for i in count:
		_points.append(start + direction * point_spacing * i)


## Returns how many points are stored.
func get_point_count() -> int:
	return _points.size()
