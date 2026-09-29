extends GutTest
## Tests for CombatText.


func _unit(unit_name: String) -> Combatant:
	var combatant := Combatant.new()
	combatant.display_name = unit_name
	combatant.stats.max_hp = 60
	combatant.stats.max_mana = 10
	combatant.stats.max_stamina = 20
	combatant.start_combat()
	return combatant


func test_resources_line() -> void:
	var unit := _unit("Limo")
	unit.take_damage(14)
	assert_eq(CombatText.describe_resources(unit), "Limo: 46/60 PV · 10/10 PM · 20/20 EST")


func test_defeated_line() -> void:
	var unit := _unit("Limo")
	unit.take_damage(99)
	assert_eq(CombatText.describe_resources(unit), "Limo: derrotado")


func test_action_line_with_reaction_and_defeat() -> void:
	var skill := SkillData.new()
	skill.display_name = "Bola de Fuego"
	var result := ActionResult.new()
	result.target = _unit("Limo")
	result.amount = 60
	result.reaction = EnemyData.AffinityReaction.WEAK
	result.defeated = true
	var action := CombatAction.new(_unit("Mago"), skill, [result.target])
	assert_eq(CombatText.describe_action(action, [result]), "Mago usa Bola de Fuego → Limo: −60 (débil) · derrotado")


func test_heal_uses_plus_sign() -> void:
	var result := ActionResult.new()
	result.target = _unit("Guerrero")
	result.amount = 27
	result.is_heal = true
	assert_eq(CombatText.describe_results([result]), "Guerrero: +27")


func test_no_results() -> void:
	assert_eq(CombatText.describe_results([]), "sin efecto")
