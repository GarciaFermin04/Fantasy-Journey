extends GutTest
## Tests for StatBlock.


func _make_block(value: int) -> StatBlock:
	var block := StatBlock.new()
	for stat: StatBlock.Stat in StatBlock.Stat.values():
		block.set_stat(stat, value)
	return block


func test_get_stat_reads_matching_property() -> void:
	var block := StatBlock.new()
	block.magic_attack = 7
	assert_eq(block.get_stat(StatBlock.Stat.MAGIC_ATTACK), 7)


func test_set_stat_writes_matching_property() -> void:
	var block := StatBlock.new()
	block.set_stat(StatBlock.Stat.SPEED, 12)
	assert_eq(block.speed, 12)


func test_every_stat_maps_to_its_own_property() -> void:
	var block := StatBlock.new()
	var stats := StatBlock.Stat.values()
	for i in stats.size():
		block.set_stat(stats[i], i + 1)
	for i in stats.size():
		assert_eq(block.get_stat(stats[i]), i + 1)


func test_plus_adds_every_stat() -> void:
	var result := _make_block(10).plus(_make_block(3))
	for stat: StatBlock.Stat in StatBlock.Stat.values():
		assert_eq(result.get_stat(stat), 13)


func test_plus_supports_negative_bonuses() -> void:
	var bonus := StatBlock.new()
	bonus.speed = -2
	var result := _make_block(10).plus(bonus)
	assert_eq(result.speed, 8)
	assert_eq(result.attack, 10)


func test_plus_with_null_keeps_values() -> void:
	var result := _make_block(5).plus(null)
	assert_eq(result.max_hp, 5)


func test_plus_does_not_modify_operands() -> void:
	var base := _make_block(10)
	var bonus := _make_block(3)
	base.plus(bonus)
	assert_eq(base.attack, 10)
	assert_eq(bonus.attack, 3)


func test_positive_base_stats_are_valid() -> void:
	assert_eq(_make_block(5).validate_as_base_stats(), PackedStringArray())


func test_base_stats_with_zero_hp_are_invalid() -> void:
	var block := _make_block(5)
	block.max_hp = 0
	assert_has(block.validate_as_base_stats(), "max_hp must be positive")


func test_base_stats_with_negative_stat_are_invalid() -> void:
	var block := _make_block(5)
	block.defense = -1
	assert_has(block.validate_as_base_stats(), "stat DEFENSE is negative")
