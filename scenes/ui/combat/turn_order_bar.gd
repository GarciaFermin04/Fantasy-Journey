class_name TurnOrderBar
extends PanelContainer
## Shows the turn order: the combatant acting now, the ones left this round
## and a dimmed preview of the next round. It only displays what it is given;
## it knows nothing about the turn queue or the combat state machine.

## Scene used for each combatant entry.
@export var entry_scene: PackedScene
## Text of the separator before the next round preview.
@export var next_round_text: String = "Próxima ronda"

@onready var _entries: HBoxContainer = %Entries


func _ready() -> void:
	assert(entry_scene != null, "TurnOrderBar needs an entry_scene")


## Rebuilds the bar with [param current] (may be null), the [param remaining]
## combatants of this round and the [param next_round] preview.
func display(current: Combatant, remaining: Array[Combatant], next_round: Array[Combatant]) -> void:
	_clear()
	if current != null:
		_add_entry(current, true, false)
	for combatant in remaining:
		_add_entry(combatant, false, false)
	_add_separator()
	for combatant in next_round:
		_add_entry(combatant, false, true)


func _clear() -> void:
	for child in _entries.get_children():
		_entries.remove_child(child)
		child.queue_free()


func _add_entry(combatant: Combatant, is_current: bool, is_preview: bool) -> void:
	var entry := entry_scene.instantiate() as TurnOrderEntry
	_entries.add_child(entry)
	entry.display(combatant, is_current, is_preview)


func _add_separator() -> void:
	_entries.add_child(VSeparator.new())
	var label := Label.new()
	label.text = next_round_text
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_entries.add_child(label)
