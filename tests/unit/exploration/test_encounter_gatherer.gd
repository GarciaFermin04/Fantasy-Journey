extends GutTest
## Tests for EncounterGatherer.


func test_touched_enemy_is_always_included() -> void:
	var candidates: Array[Vector3] = [Vector3(2.0, 0.0, 2.0)]
	assert_eq(EncounterGatherer.gather(Vector3(2.0, 0.0, 2.0), candidates, 0.0), [0] as Array[int])


func test_enemies_within_radius_join() -> void:
	var candidates: Array[Vector3] = [Vector3.ZERO, Vector3(3.0, 0.0, 0.0), Vector3(0.0, 0.0, -5.0)]
	assert_eq(EncounterGatherer.gather(Vector3.ZERO, candidates, 6.0), [0, 1, 2] as Array[int])


func test_enemies_outside_radius_stay() -> void:
	var candidates: Array[Vector3] = [Vector3.ZERO, Vector3(10.0, 0.0, 0.0), Vector3(2.0, 0.0, 0.0)]
	assert_eq(EncounterGatherer.gather(Vector3.ZERO, candidates, 6.0), [0, 2] as Array[int])


func test_enemy_exactly_on_radius_joins() -> void:
	var candidates: Array[Vector3] = [Vector3(6.0, 0.0, 0.0)]
	assert_eq(EncounterGatherer.gather(Vector3.ZERO, candidates, 6.0), [0] as Array[int])


func test_height_is_ignored() -> void:
	var candidates: Array[Vector3] = [Vector3(1.0, 50.0, 0.0)]
	assert_eq(EncounterGatherer.gather(Vector3.ZERO, candidates, 2.0), [0] as Array[int])


func test_no_candidates_gives_empty_list() -> void:
	var candidates: Array[Vector3] = []
	assert_eq(EncounterGatherer.gather(Vector3.ZERO, candidates, 6.0), [] as Array[int])
