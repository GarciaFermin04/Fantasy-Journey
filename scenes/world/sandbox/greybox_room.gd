extends Node3D
## Greybox test room. When the party leader touches a visible enemy it
## gathers the nearby enemies, freezes exploration and starts the combat
## around the collision point. Returning to exploration comes in 3.8c.

## Enemies within this distance (meters) of the touched one join the combat.
@export var encounter_radius: float = 6.0

var _in_encounter: bool = false

@onready var _party: Party = %Party
@onready var _enemies: Node3D = %Enemies
@onready var _encounter_label: Label = %EncounterLabel
@onready var _combat_controller: CombatController = %CombatController


func _ready() -> void:
	_encounter_label.hide()
	_combat_controller.combat_finished.connect(_on_combat_finished)
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
	var leader_position := _party.leader.global_position
	var touched_position := touched_enemy.global_position
	var center := (leader_position + touched_position) / 2.0
	center.y = 0.0
	_combat_controller.start_combat(_party, participants, center, leader_position.x <= touched_position.x)


func _on_combat_finished(result: CombatStateMachine.Result) -> void:
	_encounter_label.text = "Combate terminado: %s" % CombatStateMachine.Result.keys()[result]
	_encounter_label.show()


func _gather_participants(touched_enemy: RoomEnemy) -> Array[RoomEnemy]:
	var candidates := _room_enemies()
	var positions: Array[Vector3] = []
	for enemy in candidates:
		positions.append(enemy.global_position)
	var participants: Array[RoomEnemy] = []
	for index in EncounterGatherer.gather(touched_enemy.global_position, positions, encounter_radius):
		participants.append(candidates[index])
	return participants


func _room_enemies() -> Array[RoomEnemy]:
	var result: Array[RoomEnemy] = []
	for child in _enemies.get_children():
		if child is RoomEnemy:
			result.append(child)
	return result
