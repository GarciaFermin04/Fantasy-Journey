class_name FollowMotion
extends RefCounted
## Helpers to move a follower towards a target point.


## Returns the horizontal velocity (XZ plane) that moves from [param from]
## towards [param to] at most [param max_speed], without overshooting the
## target within [param delta] seconds.
static func velocity_towards(from: Vector3, to: Vector3, max_speed: float, delta: float) -> Vector3:
	if delta <= 0.0:
		return Vector3.ZERO
	var offset := Vector3(to.x - from.x, 0.0, to.z - from.z)
	return offset.limit_length(max_speed * delta) / delta
