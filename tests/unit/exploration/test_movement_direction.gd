extends GutTest
## Tests for MovementDirection.

const EPSILON: float = 0.0001


func test_no_input_returns_zero() -> void:
	assert_eq(MovementDirection.from_input(Vector2.ZERO), Vector3.ZERO)


func test_up_moves_towards_negative_z() -> void:
	assert_almost_eq(MovementDirection.from_input(Vector2.UP), Vector3.FORWARD, Vector3.ONE * EPSILON)


func test_down_moves_towards_positive_z() -> void:
	assert_almost_eq(MovementDirection.from_input(Vector2.DOWN), Vector3.BACK, Vector3.ONE * EPSILON)


func test_left_moves_towards_negative_x() -> void:
	assert_almost_eq(MovementDirection.from_input(Vector2.LEFT), Vector3.LEFT, Vector3.ONE * EPSILON)


func test_right_moves_towards_positive_x() -> void:
	assert_almost_eq(MovementDirection.from_input(Vector2.RIGHT), Vector3.RIGHT, Vector3.ONE * EPSILON)


func test_diagonal_has_unit_length() -> void:
	var direction := MovementDirection.from_input(Vector2(1.0, 1.0))
	assert_almost_eq(direction.length(), 1.0, EPSILON)


func test_input_longer_than_one_is_clamped() -> void:
	var direction := MovementDirection.from_input(Vector2(3.0, 0.0))
	assert_almost_eq(direction.length(), 1.0, EPSILON)


func test_partial_analog_input_keeps_magnitude() -> void:
	var direction := MovementDirection.from_input(Vector2(0.5, 0.0))
	assert_almost_eq(direction.length(), 0.5, EPSILON)


func test_result_stays_on_horizontal_plane() -> void:
	var direction := MovementDirection.from_input(Vector2(0.7, -0.7), 1.0)
	assert_eq(direction.y, 0.0)


func test_reference_yaw_rotates_direction() -> void:
	var direction := MovementDirection.from_input(Vector2.UP, deg_to_rad(90.0))
	assert_almost_eq(direction, Vector3.LEFT, Vector3.ONE * EPSILON)
