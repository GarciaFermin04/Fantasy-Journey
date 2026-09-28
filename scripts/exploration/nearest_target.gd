class_name NearestTarget
extends RefCounted
## Helpers to choose the point closest to an origin.


## Returns the index of the point in [param points] closest to [param origin]
## on the horizontal plane (height is ignored), or -1 if [param points] is empty.
## On a tie, the first point wins.
static func index_of_nearest(origin: Vector3, points: Array[Vector3]) -> int:
	var best_index := -1
	var best_distance := INF
	for i in points.size():
		var offset := points[i] - origin
		offset.y = 0.0
		var distance := offset.length_squared()
		if distance < best_distance:
			best_distance = distance
			best_index = i
	return best_index
