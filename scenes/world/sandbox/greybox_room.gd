extends Node3D
## Greybox test room. When the party leader touches a visible enemy it
## gathers the nearby enemies, freezes exploration and starts the combat
## around the collision point. On victory the defeated enemies are removed
## and exploration resumes; on defeat the room is reloaded.

## Enemies within this distance (meters) of the touched one join the combat.
@export var encounter_radius: float = 6.0
## Seconds the defeat message stays before the room reloads.
@export var defeat_reload_delay: float = 1.5
## Message shown before reloading after a defeat.
@export var defeat_message: String = "Derrota. Reiniciando la sala..."

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


func _on_combat_finished(result: CombatStateMachine.Result, defeated_enemies: Array[RoomEnemy]) -> void:
	if result == CombatStateMachine.Result.DEFEAT:
		_encounter_label.text = defeat_message
		_encounter_label.show()
		await get_tree().create_timer(defeat_reload_delay).timeout
		get_tree().reload_current_scene()
		return
	for enemy in defeated_enemies:
		enemy.queue_free()
	for enemy in _room_enemies():
		if not defeated_enemies.has(enemy):
			enemy.set_contact_enabled(true)
	_party.set_exploration_enabled(true)
	_in_encounter = false


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
