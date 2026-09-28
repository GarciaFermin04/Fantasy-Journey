extends GutTest
## Tests for FollowMotion.

const EPSILON: float = 0.0001
const DELTA: float = 1.0 / 60.0


func test_returns_zero_when_already_at_target() -> void:
	var velocity := FollowMotion.velocity_towards(Vector3.ONE, Vector3.ONE, 5.0, DELTA)
	assert_eq(velocity, Vector3.ZERO)


func test_speed_is_capped_at_max_speed() -> void:
	var velocity := FollowMotion.velocity_towards(Vector3.ZERO, Vector3(10.0, 0.0, 0.0), 5.0, DELTA)
	assert_almost_eq(velocity.length(), 5.0, EPSILON)


func test_does_not_overshoot_close_target() -> void:
	var target := Vector3(0.01, 0.0, 0.0)
	var velocity := FollowMotion.velocity_towards(Vector3.ZERO, target, 5.0, DELTA)
	assert_almost_eq(velocity.x * DELTA, target.x, EPSILON)


func test_ignores_height_difference() -> void:
	var velocity := FollowMotion.velocity_towards(Vector3.ZERO, Vector3(0.0, 3.0, 1.0), 5.0, DELTA)
	assert_eq(velocity.y, 0.0)


func test_zero_delta_returns_zero() -> void:
	var velocity := FollowMotion.velocity_towards(Vector3.ZERO, Vector3.ONE, 5.0, 0.0)
	assert_eq(velocity, Vector3.ZERO)
