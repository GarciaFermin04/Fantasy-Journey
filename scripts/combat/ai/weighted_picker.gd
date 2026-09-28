class_name WeightedPicker
extends RefCounted
## Weighted random choice. An entry with weight 3 is picked three times as
## often as one with weight 1; weights of 0 or less are never picked.


## Returns a random index of [param weights] chosen proportionally to its
## weight, using [param rng]. Returns -1 if no weight is positive.
static func pick_index(weights: Array[int], rng: RandomNumberGenerator) -> int:
	var total := 0
	for weight in weights:
		total += maxi(weight, 0)
	if total <= 0:
		return -1
	var roll := rng.randi_range(1, total)
	var accumulated := 0
	for i in weights.size():
		accumulated += maxi(weights[i], 0)
		if roll <= accumulated:
			return i
	return -1
