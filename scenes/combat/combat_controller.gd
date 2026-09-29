class_name CombatController
extends Node3D
## Runs a combat inside the room: builds the combatants from the party and the
## touched enemies, moves every unit to its arena slot around the collision
## point, switches to the combat camera and shows the HUD. The rules live in
## CombatSession; this node only presents them. When the combat ends it
## shows the result, restores the exploration camera and reports which room
## enemies were defeated so the room can remove them.

## Emitted after the combat ends and its presentation is cleaned up.
signal combat_finished(result: CombatStateMachine.Result, defeated_enemies: Array[RoomEnemy])

const _UNIT_HEIGHT: float = 1.4
const _WORLD_LAYER: int = 1
const _SIDE_LEFT: float = -1.0
const _SIDE_RIGHT: float = 1.0
const _IDLE_CAMERA_PRIORITY: int = 0

## Balance numbers of the combat.
@export var combat_rules: CombatRules
## Distance from the arena center to the front rows, in meters.
@export var front_row_offset: float = 1.5
## Distance between the front and back rows, in meters.
@export var row_gap: float = 1.5
## Distance between units of the same row, in meters.
@export var slot_spacing: float = 2.0
## Step used to move a blocked slot towards the center, in meters.
@export var slot_step: float = 0.25
## Radius of the space a unit needs in its slot, in meters.
@export var unit_radius: float = 0.3
## Seconds units take to walk to their slots.
@export var move_duration: float = 0.5
## Combat camera position relative to the arena center.
@export var camera_offset: Vector3 = Vector3(0.0, 9.0, 10.7)
## Priority of the combat camera while fighting (above the exploration one).
@export var combat_camera_priority: int = 20
## Seconds an enemy waits before acting, so its turn can be followed.
@export var enemy_turn_delay: float = 0.8
## Scene of the floating damage numbers.
@export var damage_number_scene: PackedScene
## Height over a unit's feet where damage numbers appear, in meters.
@export var damage_number_height: float = 2.0
## Seconds the result message stays before leaving the combat.
@export var end_delay: float = 1.2
## Message shown on victory.
@export var victory_text: String = "¡Victoria!"
## Message shown on defeat.
@export var defeat_text: String = "Derrota..."

var _session: CombatSession = null
var _nodes: Dictionary[Combatant, Node3D] = {}
var _rng := RandomNumberGenerator.new()

@onready var _camera: PhantomCamera3D = %CombatCamera
@onready var _hud: CombatHud = %CombatHud
@onready var _enemy_turn_timer: Timer = %EnemyTurnTimer


func _ready() -> void:
	assert(combat_rules != null, "CombatController needs combat_rules")
	assert(damage_number_scene != null, "CombatController needs damage_number_scene")
	_rng.randomize()
	_hud.action_confirmed.connect(_on_action_confirmed)
	_enemy_turn_timer.timeout.connect(_on_enemy_turn_timer_timeout)


## Starts a combat between [param party] and [param room_enemies] around
## [param center]. Allies stand on the left when [param allies_on_left].
func start_combat(party: Party, room_enemies: Array[RoomEnemy], center: Vector3, allies_on_left: bool) -> void:
	assert(_session == null, "CombatController.start_combat: a combat is already running")
	_nodes.clear()
	var allies := _build_allies(party)
	var enemies := _build_enemies(room_enemies)
	var ally_side := _SIDE_LEFT if allies_on_left else _SIDE_RIGHT
	_place_side(allies, center, ally_side)
	_place_side(enemies, center, -ally_side)
	_camera.global_position = center + camera_offset
	_camera.priority = combat_camera_priority
	_session = CombatSession.new(combat_rules)
	_session.turn_started.connect(_on_turn_started)
	_session.action_performed.connect(_on_action_performed)
	_session.combat_finished.connect(_on_combat_finished)
	_hud.show_log("¡Comienza el combate!")
	_hud.show()
	_session.start(allies, enemies)


func _build_allies(party: Party) -> Array[Combatant]:
	var members := party.get_members()
	var recruits := party.get_member_recruits()
	var allies: Array[Combatant] = []
	for i in members.size():
		var ally := Combatant.from_recruit(recruits[i], recruits[i].default_weapon, i)
		allies.append(ally)
		_nodes[ally] = members[i]
	return allies


func _build_enemies(room_enemies: Array[RoomEnemy]) -> Array[Combatant]:
	var enemies: Array[Combatant] = []
	for i in room_enemies.size():
		var enemy := Combatant.from_enemy(room_enemies[i].enemy_data, i)
		enemies.append(enemy)
		_nodes[enemy] = room_enemies[i]
	return enemies


func _place_side(combatants: Array[Combatant], center: Vector3, side: float) -> void:
	for row: CombatRow.Row in [CombatRow.Row.FRONT, CombatRow.Row.BACK]:
		var in_row: Array[Combatant] = []
		for combatant in combatants:
			if combatant.row == row:
				in_row.append(combatant)
		var slots := ArenaLayout.get_row_slots(center, side, row, in_row.size(), front_row_offset, row_gap, slot_spacing)
		for i in in_row.size():
			var slot := ArenaLayout.resolve_slot(slots[i], center, slot_step, _is_free)
			_move_to(_nodes[in_row[i]], slot)


func _move_to(node: Node3D, target: Vector3) -> void:
	var tween := create_tween()
	tween.tween_property(node, "global_position", target, move_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _is_free(position: Vector3) -> bool:
	var shape := CapsuleShape3D.new()
	shape.radius = unit_radius
	shape.height = _UNIT_HEIGHT
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.collision_mask = _WORLD_LAYER
	query.transform = Transform3D(Basis.IDENTITY, position + Vector3.UP * (_UNIT_HEIGHT / 2.0 + unit_radius))
	return get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()


func _on_turn_started(actor: Combatant) -> void:
	_hud.refresh(_session)
	if actor.is_ally:
		_hud.open_commands(actor, _session)
	else:
		_enemy_turn_timer.start(enemy_turn_delay)


func _on_action_confirmed(action: CombatAction) -> void:
	_session.perform(action)


func _on_enemy_turn_timer_timeout() -> void:
	if _session == null or not _session.is_awaiting_action():
		return
	var actor := _session.get_current_actor()
	var action := EnemyAI.choose_action(actor, _session.get_enemies(), _session.get_allies(), combat_rules, _rng)
	if action == null:
		_hud.show_log("%s no puede actuar" % actor.display_name)
		_session.pass_turn()
	else:
		_session.perform(action)


func _on_action_performed(action: CombatAction, results: Array[ActionResult]) -> void:
	_hud.show_log(CombatText.describe_action(action, results))
	for result in results:
		var node := _nodes[result.target]
		_spawn_damage_number(result, node.global_position)
		if result.defeated:
			_set_defeated_look(node, true)


func _spawn_damage_number(result: ActionResult, at: Vector3) -> void:
	var number := damage_number_scene.instantiate() as DamageNumber
	add_child(number)
	number.global_position = at + Vector3.UP * damage_number_height
	number.show_result(result)


func _set_defeated_look(node: Node3D, defeated: bool) -> void:
	assert(node.has_method(&"set_defeated_look"), "%s has no set_defeated_look()" % node.name)
	node.call(&"set_defeated_look", defeated)


func _on_combat_finished(result: CombatStateMachine.Result) -> void:
	_enemy_turn_timer.stop()
	_hud.close_commands()
	_hud.refresh(_session)
	_hud.show_log(victory_text if result == CombatStateMachine.Result.VICTORY else defeat_text)
	await get_tree().create_timer(end_delay).timeout
	_hud.hide()
	_camera.priority = _IDLE_CAMERA_PRIORITY
	var defeated_enemies: Array[RoomEnemy] = []
	for combatant in _nodes:
		var node := _nodes[combatant]
		if combatant.is_ally:
			_set_defeated_look(node, false)
		elif combatant.is_defeated:
			defeated_enemies.append(node as RoomEnemy)
	_session = null
	_nodes.clear()
	combat_finished.emit(result, defeated_enemies)
