class_name TurnOrderEntry
extends PanelContainer
## One combatant in the turn order bar: portrait (or its side color when it
## has no art), name, and a border that shows its side and whether it acts now.

## Border and placeholder color for allies.
@export var ally_color: Color = Color(0.3, 0.55, 0.95)
## Border and placeholder color for enemies.
@export var enemy_color: Color = Color(0.9, 0.3, 0.3)
## Border color of the combatant acting now.
@export var current_color: Color = Color(1.0, 0.85, 0.3)
## Border width of the combatant acting now, in pixels.
@export var current_border_width: int = 4
## Border width of the other combatants, in pixels.
@export var normal_border_width: int = 2
## Opacity of next-round preview entries.
@export_range(0.0, 1.0) var preview_alpha: float = 0.45

@onready var _portrait: TextureRect = %Portrait
@onready var _placeholder: ColorRect = %Placeholder
@onready var _name_label: Label = %NameLabel


## Shows [param combatant]. [param is_current] highlights it and
## [param is_preview] dims it as part of the next round.
func display(combatant: Combatant, is_current: bool, is_preview: bool) -> void:
	var side_color := ally_color if combatant.is_ally else enemy_color
	_name_label.text = combatant.display_name
	_portrait.texture = combatant.portrait
	_placeholder.visible = combatant.portrait == null
	_placeholder.color = side_color
	var style := get_theme_stylebox(&"panel").duplicate() as StyleBoxFlat
	style.border_color = current_color if is_current else side_color
	style.set_border_width_all(current_border_width if is_current else normal_border_width)
	add_theme_stylebox_override(&"panel", style)
	modulate.a = preview_alpha if is_preview else 1.0
