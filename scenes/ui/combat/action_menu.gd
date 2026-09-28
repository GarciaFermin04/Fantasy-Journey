class_name ActionMenu
extends PanelContainer
## Flat list with the actor's skills plus the item command, and a panel with
## the details of the focused skill. Keyboard navigation uses the built-in
## ui_* actions through Godot's focus system.

## Emitted when the player picks an enabled skill.
signal skill_chosen(skill: SkillData)

const _SIDE_SINGLE: Dictionary[SkillData.TargetSide, String] = {
	SkillData.TargetSide.ENEMY: "1 enemigo",
	SkillData.TargetSide.ALLY: "1 aliado",
}
const _SIDE_ROW: Dictionary[SkillData.TargetSide, String] = {
	SkillData.TargetSide.ENEMY: "Una fila enemiga",
	SkillData.TargetSide.ALLY: "Una fila aliada",
}
const _SIDE_ALL: Dictionary[SkillData.TargetSide, String] = {
	SkillData.TargetSide.ENEMY: "Todos los enemigos",
	SkillData.TargetSide.ALLY: "Todos los aliados",
}
const _REACH_TEXT: Dictionary[SkillData.TargetReach, String] = {
	SkillData.TargetReach.FRONT_ROW: "fila delantera",
	SkillData.TargetReach.ANY_ROW: "cualquier fila",
}

## Text of the item command.
@export var item_text: String = "Objeto"
## Details shown when the item command is focused.
@export var item_unavailable_text: String = "Todavía no hay objetos."

var _skill_buttons: Dictionary[SkillData, Button] = {}
var _item_button: Button = null
var _actor: Combatant = null
var _rules: CombatRules = null

@onready var _buttons: VBoxContainer = %Buttons
@onready var _details: Label = %Details


## Shows the skills of [param actor]. Those in [param disabled_skills] are shown
## but cannot be chosen. Focus goes to [param focus_skill] or the first enabled
## skill. [param rules] are used to show the actor's real costs.
func open(actor: Combatant, disabled_skills: Array[SkillData], rules: CombatRules, focus_skill: SkillData = null) -> void:
	_clear()
	_actor = actor
	_rules = rules
	var skills := actor.skills
	for skill in skills:
		var button := _add_button(skill.display_name, disabled_skills.has(skill))
		button.pressed.connect(skill_chosen.emit.bind(skill))
		button.focus_entered.connect(_show_skill_details.bind(skill))
		_skill_buttons[skill] = button
	_item_button = _add_button(item_text, true)
	_item_button.focus_entered.connect(func() -> void: _details.text = item_unavailable_text)
	show()
	_focus_initial(skills, disabled_skills, focus_skill)


## Hides the menu and removes its buttons.
func close() -> void:
	hide()
	_clear()


## Returns the button of [param skill], or null.
func get_skill_button(skill: SkillData) -> Button:
	return _skill_buttons.get(skill)


## Returns the item command button.
func get_item_button() -> Button:
	return _item_button


## Returns a short description of who [param skill] targets.
static func describe_target(skill: SkillData) -> String:
	if skill.target_side == SkillData.TargetSide.SELF:
		return "Uno mismo"
	match skill.target_area:
		SkillData.TargetArea.ALL:
			return _SIDE_ALL[skill.target_side]
		SkillData.TargetArea.ROW:
			return "%s, %s" % [_SIDE_ROW[skill.target_side], _REACH_TEXT[skill.target_reach]]
	return "%s, %s" % [_SIDE_SINGLE[skill.target_side], _REACH_TEXT[skill.target_reach]]


## Returns a short description of a skill cost and cooldown. When
## [param cooldown_remaining] is above zero it shows the turns left instead.
static func describe_cost(mana_cost: int, stamina_cost: int, cooldown_turns: int, cooldown_remaining: int = 0) -> String:
	var parts: PackedStringArray = []
	if mana_cost > 0:
		parts.append("%d maná" % mana_cost)
	if stamina_cost > 0:
		parts.append("%d estamina" % stamina_cost)
	var cost := "Coste: %s" % " + ".join(parts) if not parts.is_empty() else "Sin coste"
	if cooldown_remaining > 0:
		cost += " · Enfriamiento: faltan %d turnos" % cooldown_remaining
	elif cooldown_turns > 0:
		cost += " · Enfriamiento: %d turnos" % cooldown_turns
	return cost


func _add_button(text: String, disabled: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.disabled = disabled
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_buttons.add_child(button)
	return button


func _focus_initial(skills: Array[SkillData], disabled_skills: Array[SkillData], focus_skill: SkillData) -> void:
	var target: Button = _skill_buttons.get(focus_skill)
	if target == null or target.disabled:
		target = _item_button
		for skill in skills:
			if not disabled_skills.has(skill):
				target = _skill_buttons[skill]
				break
	target.grab_focus()


func _show_skill_details(skill: SkillData) -> void:
	var cost := describe_cost(
		_actor.get_mana_cost(skill, _rules),
		_actor.get_stamina_cost(skill, _rules),
		skill.cooldown_turns,
		_actor.get_cooldown_remaining(skill))
	_details.text = "%s\n%s\n%s" % [cost, describe_target(skill), skill.description]


func _clear() -> void:
	_actor = null
	_rules = null
	_skill_buttons.clear()
	_item_button = null
	for child in _buttons.get_children():
		_buttons.remove_child(child)
		child.queue_free()
	_details.text = ""
