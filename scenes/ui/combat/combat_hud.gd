class_name CombatHud
extends CanvasLayer
## Combat HUD shown over the room: turn order bar, units' status, last action
## log and the command panel. It only displays what it is given.

## Emitted when the player confirms an action in the command panel.
signal action_confirmed(action: CombatAction)

@onready var _bar: TurnOrderBar = %TurnOrderBar
@onready var _status_label: Label = %StatusLabel
@onready var _log_label: Label = %LogLabel
@onready var _command_panel: CombatCommandPanel = %CombatCommandPanel


func _ready() -> void:
	_command_panel.action_confirmed.connect(action_confirmed.emit)
	hide()


## Updates the turn order bar and status lines from [param session].
func refresh(session: CombatSession) -> void:
	var queue := session.get_queue()
	_bar.display(queue.get_current_actor(), queue.get_remaining_this_round(), queue.get_next_round_preview())
	var lines: PackedStringArray = []
	for unit in _all_units(session):
		lines.append(CombatText.describe_resources(unit))
	_status_label.text = "\n".join(lines)


## Shows [param text] as the last combat event.
func show_log(text: String) -> void:
	_log_label.text = text


## Opens the command panel for [param actor].
func open_commands(actor: Combatant, session: CombatSession) -> void:
	_command_panel.open(actor, session.get_allies(), session.get_enemies(), session.rules)


## Closes the command panel.
func close_commands() -> void:
	_command_panel.close()


func _all_units(session: CombatSession) -> Array[Combatant]:
	var units: Array[Combatant] = []
	for formation: Formation in [session.get_allies(), session.get_enemies()]:
		for row: CombatRow.Row in [CombatRow.Row.FRONT, CombatRow.Row.BACK]:
			units.append_array(formation.get_row(row))
	return units
