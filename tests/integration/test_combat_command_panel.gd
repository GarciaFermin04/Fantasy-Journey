extends GutTest
## Integration tests for CombatCommandPanel with its real scenes.

const PANEL_SCENE: PackedScene = preload("res://scenes/ui/combat/combat_command_panel.tscn")

var _panel: CombatCommandPanel
var _menu: ActionMenu
var _selector: TargetSelector
var _allies: Formation
var _enemies: Formation
var _warrior: Combatant
var _slime: Combatant
var _imp: Combatant
var _slash: SkillData
var _sweep: SkillData
var _heal: SkillData
var _rain: SkillData


func before_each() -> void:
	_panel = PANEL_SCENE.instantiate()
	add_child_autofree(_panel)
	_menu = _panel.get_node("%ActionMenu")
	_selector = _panel.get_node("%TargetSelector")
	_slash = _skill("Tajo", SkillData.TargetSide.ENEMY, SkillData.TargetArea.SINGLE)
	_sweep = _skill("Barrido", SkillData.TargetSide.ENEMY, SkillData.TargetArea.ROW)
	_heal = _skill("Curar", SkillData.TargetSide.ALLY, SkillData.TargetArea.SINGLE)
	_rain = _skill("Lluvia", SkillData.TargetSide.ENEMY, SkillData.TargetArea.ALL)
	_allies = Formation.new(3)
	_enemies = Formation.new()
	_warrior = _add(_allies, "Guerrero", CombatRow.Row.FRONT)
	_warrior.skills = [_slash, _sweep, _heal, _rain]
	_slime = _add(_enemies, "Limo", CombatRow.Row.FRONT)
	_imp = _add(_enemies, "Diablillo", CombatRow.Row.BACK)


func _skill(skill_name: String, side: SkillData.TargetSide, area: SkillData.TargetArea) -> SkillData:
	var skill := SkillData.new()
	skill.display_name = skill_name
	skill.target_side = side
	skill.target_area = area
	return skill


func _add(formation: Formation, unit_name: String, row: CombatRow.Row) -> Combatant:
	var combatant := Combatant.new()
	combatant.display_name = unit_name
	combatant.row = row
	formation.add(combatant)
	return combatant


func _open() -> void:
	_panel.open(_warrior, _allies, _enemies)


func test_starts_hidden() -> void:
	assert_eq(_panel.get_phase(), CombatCommandPanel.Phase.HIDDEN)
	assert_false(_panel.visible)


func test_open_shows_skills_and_disabled_item() -> void:
	_open()
	assert_eq(_panel.get_phase(), CombatCommandPanel.Phase.CHOOSING_SKILL)
	for skill: SkillData in [_slash, _sweep, _heal, _rain]:
		assert_not_null(_menu.get_skill_button(skill), skill.display_name)
	assert_true(_menu.get_item_button().disabled)


func test_choosing_skill_lists_its_targets() -> void:
	_open()
	_menu.get_skill_button(_slash).pressed.emit()
	assert_eq(_panel.get_phase(), CombatCommandPanel.Phase.CHOOSING_TARGET)
	var buttons := _selector.get_option_buttons()
	assert_eq(buttons.size(), 1)
	assert_eq(buttons[0].text, "Limo")


func test_choosing_target_confirms_action() -> void:
	watch_signals(_panel)
	_open()
	_menu.get_skill_button(_slash).pressed.emit()
	_selector.get_option_buttons()[0].pressed.emit()
	assert_signal_emitted(_panel, "action_confirmed")
	var action: CombatAction = get_signal_parameters(_panel, "action_confirmed")[0]
	assert_eq(action.user, _warrior)
	assert_eq(action.skill, _slash)
	assert_eq(action.targets, [_slime] as Array[Combatant])
	assert_eq(_panel.get_phase(), CombatCommandPanel.Phase.HIDDEN)


func test_row_skill_targets_whole_row() -> void:
	watch_signals(_panel)
	_imp.row = CombatRow.Row.FRONT
	_open()
	_menu.get_skill_button(_sweep).pressed.emit()
	assert_eq(_selector.get_option_buttons()[0].text, "[Limo, Diablillo]")
	_selector.get_option_buttons()[0].pressed.emit()
	var action: CombatAction = get_signal_parameters(_panel, "action_confirmed")[0]
	assert_eq(action.targets, [_slime, _imp] as Array[Combatant])


func test_cancel_returns_to_skill_list() -> void:
	watch_signals(_panel)
	_open()
	_menu.get_skill_button(_slash).pressed.emit()
	_selector.cancel()
	assert_eq(_panel.get_phase(), CombatCommandPanel.Phase.CHOOSING_SKILL)
	assert_not_null(_menu.get_skill_button(_slash))
	assert_signal_not_emitted(_panel, "action_confirmed")


func test_skill_without_targets_is_disabled() -> void:
	_slime.is_defeated = true
	_imp.is_defeated = true
	_open()
	assert_true(_menu.get_skill_button(_slash).disabled)
	assert_true(_menu.get_skill_button(_rain).disabled)
	assert_false(_menu.get_skill_button(_heal).disabled)


func test_close_hides_panel() -> void:
	_open()
	_panel.close()
	assert_eq(_panel.get_phase(), CombatCommandPanel.Phase.HIDDEN)
	assert_false(_panel.visible)


func test_describe_target_texts() -> void:
	assert_eq(ActionMenu.describe_target(_slash), "1 enemigo, fila delantera")
	assert_eq(ActionMenu.describe_target(_rain), "Todos los enemigos")


func test_describe_cost_texts() -> void:
	var skill := SkillData.new()
	assert_eq(ActionMenu.describe_cost(skill), "Sin coste")
	skill.mana_cost = 6
	skill.stamina_cost = 3
	skill.cooldown_turns = 2
	assert_eq(ActionMenu.describe_cost(skill), "Coste: 6 maná + 3 estamina · Enfriamiento: 2 turnos")
