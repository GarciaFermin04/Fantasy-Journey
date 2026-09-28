extends GutTest
## Tests for Combatant factories.


func _make_recruit(speed: int) -> RecruitData:
	var recruit := RecruitData.new()
	recruit.display_name = "Arquero"
	recruit.base_stats = StatBlock.new()
	recruit.base_stats.max_hp = 80
	recruit.base_stats.speed = speed
	return recruit


func _make_enemy(speed: int) -> EnemyData:
	var enemy := EnemyData.new()
	enemy.display_name = "Limo"
	enemy.base_stats = StatBlock.new()
	enemy.base_stats.max_hp = 60
	enemy.base_stats.speed = speed
	return enemy


func test_from_recruit_is_ally_with_formation_index() -> void:
	var combatant := Combatant.from_recruit(_make_recruit(10), null, 2)
	assert_true(combatant.is_ally)
	assert_eq(combatant.formation_index, 2)
	assert_eq(combatant.display_name, "Arquero")


func test_from_recruit_adds_weapon_bonus() -> void:
	var weapon := WeaponData.new()
	weapon.stat_bonus = StatBlock.new()
	weapon.stat_bonus.speed = 3
	var combatant := Combatant.from_recruit(_make_recruit(10), weapon, 0)
	assert_eq(combatant.get_speed(), 13)


func test_from_enemy_is_not_ally() -> void:
	var combatant := Combatant.from_enemy(_make_enemy(6), 1)
	assert_false(combatant.is_ally)
	assert_eq(combatant.formation_index, 1)
	assert_eq(combatant.get_speed(), 6)


func test_changing_combatant_stats_does_not_touch_data() -> void:
	var enemy := _make_enemy(6)
	var combatant := Combatant.from_enemy(enemy, 0)
	combatant.stats.speed = 1
	assert_eq(enemy.base_stats.speed, 6)


func test_new_combatant_is_not_defeated() -> void:
	assert_false(Combatant.from_enemy(_make_enemy(6), 0).is_defeated)
