class_name TargetSelector
extends PanelContainer
## Lists the target options of a skill. Each option is the group of units it
## affects. ui_cancel goes back without choosing.

## Emitted when the player picks an option.
signal target_chosen(targets: Array[Combatant])
## Emitted when the player backs out without choosing.
signal cancelled

## Title format; %s is the skill name.
@export var title_format: String = "Objetivo de %s"

var _option_buttons: Array[Button] = []

@onready var _title: Label = %Title
@onready var _buttons: VBoxContainer = %Buttons


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		cancel()


## Shows the [param options] of [param skill] and focuses the first one.
func open(skill: SkillData, options: Array[Array]) -> void:
	_clear()
	_title.text = title_format % skill.display_name
	for option in options:
		var group: Array[Combatant] = []
		group.assign(option)
		var button := Button.new()
		button.text = _describe_group(group)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(target_chosen.emit.bind(group))
		_buttons.add_child(button)
		_option_buttons.append(button)
	show()
	if not _option_buttons.is_empty():
		_option_buttons[0].grab_focus()


## Hides the selector and removes its options.
func close() -> void:
	hide()
	_clear()


## Backs out without choosing a target.
func cancel() -> void:
	cancelled.emit()


## Returns the buttons of the current options, in order.
func get_option_buttons() -> Array[Button]:
	return _option_buttons


func _describe_group(group: Array[Combatant]) -> String:
	var names: PackedStringArray = []
	for combatant in group:
		names.append(combatant.display_name)
	var text := ", ".join(names)
	return "[%s]" % text if group.size() > 1 else text


func _clear() -> void:
	_option_buttons.clear()
	for child in _buttons.get_children():
		_buttons.remove_child(child)
		child.queue_free()
