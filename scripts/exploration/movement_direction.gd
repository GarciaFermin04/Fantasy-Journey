class_name MovementDirection
extends RefCounted
## Converts 2D movement input (as returned by Input.get_vector) into a
## horizontal world direction on the XZ plane.


## Returns a world direction on the XZ plane for [param input], rotated around
## the Y axis by [param reference_yaw] (radians). The result never exceeds
## length 1, so diagonals are not faster and analog input keeps its magnitude.
static func from_input(input: Vector2, reference_yaw: float = 0.0) -> Vector3:
	var direction := Vector3(input.x, 0.0, input.y).limit_length(1.0)
	return direction.rotated(Vector3.UP, reference_yaw)
