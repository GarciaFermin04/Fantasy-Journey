extends GutTest
## Tests for WeightedPicker.

const DRAWS: int = 2000
const TOLERANCE: float = 0.05

var _rng: RandomNumberGenerator


func before_each() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.seed = 12345


func _frequency_of(index: int, weights: Array[int]) -> float:
	var hits := 0
	for i in DRAWS:
		if WeightedPicker.pick_index(weights, _rng) == index:
			hits += 1
	return float(hits) / DRAWS


func test_empty_list_returns_minus_one() -> void:
	assert_eq(WeightedPicker.pick_index([], _rng), -1)


func test_all_zero_weights_return_minus_one() -> void:
	assert_eq(WeightedPicker.pick_index([0, 0], _rng), -1)


func test_single_positive_weight_is_always_picked() -> void:
	for i in 50:
		assert_eq(WeightedPicker.pick_index([0, 5, 0], _rng), 1)


func test_zero_weight_is_never_picked() -> void:
	assert_eq(_frequency_of(0, [0, 1, 1]), 0.0)


func test_three_to_one_ratio() -> void:
	assert_almost_eq(_frequency_of(0, [3, 1]), 0.75, TOLERANCE)


func test_same_seed_gives_same_sequence() -> void:
	var first: Array[int] = []
	for i in 10:
		first.append(WeightedPicker.pick_index([1, 1, 1], _rng))
	_rng.seed = 12345
	var second: Array[int] = []
	for i in 10:
		second.append(WeightedPicker.pick_index([1, 1, 1], _rng))
	assert_eq(first, second)
