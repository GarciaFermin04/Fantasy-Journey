extends GutTest
## Tests for PositionTrail.

const EPSILON: float = 0.0001
const TOLERANCE: Vector3 = Vector3(EPSILON, EPSILON, EPSILON)


func test_first_record_stores_a_point() -> void:
	var trail := PositionTrail.new(1.0, 10)
	trail.record(Vector3.ZERO)
	assert_eq(trail.get_point_count(), 1)


func test_small_movement_does_not_store_a_point() -> void:
	var trail := PositionTrail.new(1.0, 10)
	trail.record(Vector3.ZERO)
	trail.record(Vector3(0.5, 0.0, 0.0))
	assert_eq(trail.get_point_count(), 1)


func test_movement_past_spacing_stores_a_point() -> void:
	var trail := PositionTrail.new(1.0, 10)
	trail.record(Vector3.ZERO)
	trail.record(Vector3(1.0, 0.0, 0.0))
	assert_eq(trail.get_point_count(), 2)


func test_distance_zero_returns_head() -> void:
	var trail := PositionTrail.new(1.0, 10)
	trail.record(Vector3.ZERO)
	trail.record(Vector3(0.5, 0.0, 0.0))
	assert_almost_eq(trail.sample_at_distance(0.0), Vector3(0.5, 0.0, 0.0), TOLERANCE)


func test_sample_interpolates_between_points() -> void:
	var trail := PositionTrail.new(1.0, 10)
	trail.record(Vector3.ZERO)
	trail.record(Vector3(2.0, 0.0, 0.0))
	assert_almost_eq(trail.sample_at_distance(0.5), Vector3(1.5, 0.0, 0.0), TOLERANCE)


func test_sample_follows_the_path_around_corners() -> void:
	var trail := PositionTrail.new(1.0, 10)
	trail.record(Vector3.ZERO)
	trail.record(Vector3(2.0, 0.0, 0.0))
	trail.record(Vector3(2.0, 0.0, 2.0))
	assert_almost_eq(trail.sample_at_distance(3.0), Vector3(1.0, 0.0, 0.0), TOLERANCE)


func test_distance_beyond_trail_returns_oldest_point() -> void:
	var trail := PositionTrail.new(1.0, 10)
	trail.record(Vector3.ZERO)
	trail.record(Vector3(2.0, 0.0, 0.0))
	assert_almost_eq(trail.sample_at_distance(10.0), Vector3.ZERO, TOLERANCE)


func test_trail_never_exceeds_max_points() -> void:
	var trail := PositionTrail.new(1.0, 3)
	for i in 10:
		trail.record(Vector3(float(i), 0.0, 0.0))
	assert_eq(trail.get_point_count(), 3)


func test_reset_builds_straight_line_behind_start() -> void:
	var trail := PositionTrail.new(0.5, 20)
	trail.reset(Vector3(1.0, 0.0, 1.0), Vector3.BACK, 2.0)
	assert_almost_eq(trail.sample_at_distance(0.0), Vector3(1.0, 0.0, 1.0), TOLERANCE)
	assert_almost_eq(trail.sample_at_distance(1.2), Vector3(1.0, 0.0, 2.2), TOLERANCE)
	assert_almost_eq(trail.sample_at_distance(2.0), Vector3(1.0, 0.0, 3.0), TOLERANCE)
