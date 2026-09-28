extends GutTest
## Tests for NearestTarget.


func test_empty_list_returns_minus_one() -> void:
	var points: Array[Vector3] = []
	assert_eq(NearestTarget.index_of_nearest(Vector3.ZERO, points), -1)


func test_single_point_returns_zero() -> void:
	var points: Array[Vector3] = [Vector3(5.0, 0.0, 5.0)]
	assert_eq(NearestTarget.index_of_nearest(Vector3.ZERO, points), 0)


func test_returns_closest_point() -> void:
	var points: Array[Vector3] = [Vector3(3.0, 0.0, 0.0), Vector3(1.0, 0.0, 0.0), Vector3(0.0, 0.0, 2.0)]
	assert_eq(NearestTarget.index_of_nearest(Vector3.ZERO, points), 1)


func test_ignores_height() -> void:
	var points: Array[Vector3] = [Vector3(0.0, 10.0, 1.0), Vector3(2.0, 0.0, 0.0)]
	assert_eq(NearestTarget.index_of_nearest(Vector3.ZERO, points), 0)


func test_tie_returns_first_point() -> void:
	var points: Array[Vector3] = [Vector3(1.0, 0.0, 0.0), Vector3(-1.0, 0.0, 0.0)]
	assert_eq(NearestTarget.index_of_nearest(Vector3.ZERO, points), 0)
