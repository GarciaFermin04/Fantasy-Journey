extends Node3D
## Greybox test room. Starts an encounter when the party leader touches a
## visible enemy: gathers the nearby enemies and freezes exploration.
## The combat itself is started here in the next step (3.8b).

## Enemies within this distance (meters) of the touched one join the combat.
@export var encounter_radius: float = 6.0

var _in_encounter: bool = false

@onready var _party: Party = %Party
@onready var _enemies: Node3D = %Enemies
@onready var _encounter_label: Label = %EncounterLabel


func _ready() -> void:
	_encounter_label.hide()
	for enemy in _room_enemies():
		enemy.touched.connect(_on_enemy_touched)


func _on_enemy_touched(touched_enemy: RoomEnemy) -> void:
	if _in_encounter:
		return
	_in_encounter = true
	var participants := _gather_participants(touched_enemy)
	_party.set_exploration_enabled(false)
	for enemy in _room_enemies():
		enemy.set_contact_enabled(false)
	_show_encounter(participants)


func _gather_participants(touched_enemy: RoomEnemy) -> Array[RoomEnemy]:
	var candidates := _room_enemies()
	var positions: Array[Vector3] = []
	for enemy in candidates:
		positions.append(enemy.global_position)
	var participants: Array[RoomEnemy] = []
	for index in EncounterGatherer.gather(touched_enemy.global_position, positions, encounter_radius):
		participants.append(candidates[index])
	return participants


func _show_encounter(participants: Array[RoomEnemy]) -> void:
	var names: PackedStringArray = []
	for enemy in participants:
		names.append(enemy.enemy_data.display_name)
	_encounter_label.text = "Encuentro: %s" % ", ".join(names)
	_encounter_label.show()


func _room_enemies() -> Array[RoomEnemy]:
	var result: Array[RoomEnemy] = []
	for child in _enemies.get_children():
		if child is RoomEnemy:
			result.append(child)
	return result
