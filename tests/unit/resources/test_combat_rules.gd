extends GutTest
## Tests for CombatRules validation.


func test_default_rules_are_valid() -> void:
	assert_eq(CombatRules.new().validate(), PackedStringArray())


func test_non_positive_factor_is_invalid() -> void:
	var rules := CombatRules.new()
	rules.base_damage_factor = 0.0
	assert_has(rules.validate(), "base_damage_factor must be positive")


func test_non_positive_multipliers_are_invalid() -> void:
	var rules := CombatRules.new()
	rules.weak_multiplier = 0.0
	rules.resist_multiplier = -1.0
	var errors := rules.validate()
	assert_has(errors, "weak_multiplier must be positive")
	assert_has(errors, "resist_multiplier must be positive")


func test_zero_heal_divisor_is_invalid() -> void:
	var rules := CombatRules.new()
	rules.heal_stat_divisor = 0.0
	assert_has(rules.validate(), "heal_stat_divisor must be positive")


func test_negative_min_damage_is_invalid() -> void:
	var rules := CombatRules.new()
	rules.min_damage = -1
	assert_has(rules.validate(), "min_damage is negative")
