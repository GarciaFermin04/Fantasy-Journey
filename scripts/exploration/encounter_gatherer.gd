class_name EncounterGatherer
extends RefCounted
## Chooses which visible enemies join a combat: the touched one and every
## enemy within a radius of it. Distance is measured on the horizontal plane.


## Returns the indices of [param candidates] (enemy positions) within
## [param radius] meters of [param touched_position], in their original order.
## The touched enemy (distance 0) is always included when it is a candidate.
static func gather(touched_position: Vector3, candidates: Array[Vector3], radius: float) -> Array[int]:
	var result: Array[int] = []
	for i in candidates.size():
		var offset := candidates[i] - touched_position
		offset.y = 0.0
		if offset.length() <= radius:
			result.append(i)
	return result
