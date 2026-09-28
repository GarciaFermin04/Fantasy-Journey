extends GutTest
## Checks the damage formula with the real data files (rules, recruits,
## enemies and skills). Values follow docs/decisiones/013-formula-de-dano.md.

var _rules: CombatRules


func before_all() -> void:
	_rules = load("res://data/combat/combat_rules.tres")


func _recruit(recruit_id: String) -> Combatant:
	var recruit := load("res://data/recruits/%s.tres" % recruit_id) as RecruitData
	return Combatant.from_recruit(recruit, recruit.default_weapon, 0)


func _enemy(enemy_id: String) -> Combatant:
	return Combatant.from_enemy(load("res://data/enemies/common/%s.tres" % enemy_id) as EnemyData, 0)


func _skill(path: String) -> SkillData:
	return load("res://data/skills/%s.tres" % path) as SkillData


func test_rules_file_is_valid() -> void:
	assert_eq(_rules.validate(), PackedStringArray())


func test_warrior_slash_on_resistant_slime() -> void:
	assert_eq(DamageCalculator.calculate_damage(_skill("weapon/slash"), _recruit("warrior"), _enemy("slime"), _rules), 18)


func test_warrior_crushing_blow_on_weak_skeleton() -> void:
	assert_eq(DamageCalculator.calculate_damage(_skill("recruit/crushing_blow"), _recruit("warrior"), _enemy("skeleton"), _rules), 45)


func test_mage_fireball_on_weak_slime() -> void:
	assert_eq(DamageCalculator.calculate_damage(_skill("weapon/fireball"), _recruit("mage"), _enemy("slime"), _rules), 92)


func test_mage_minor_heal() -> void:
	assert_eq(DamageCalculator.calculate_heal(_skill("recruit/minor_heal"), _recruit("mage"), _rules), 33)
