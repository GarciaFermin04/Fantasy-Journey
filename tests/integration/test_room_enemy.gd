extends GutTest
## Integration tests for RoomEnemy contact detection with the physics engine.

const ENEMY_SCENE: PackedScene = preload("res://scenes/agents/enemies/common/room_enemy.tscn")
const PLAYER_LAYER: int = 2
const FAR_AWAY: Vector3 = Vector3(100.0, 0.0, 100.0)

var _enemy: RoomEnemy


func before_each() -> void:
	_enemy = ENEMY_SCENE.instantiate()
	_enemy.enemy_data = load("res://data/enemies/common/slime.tres")
	add_child_autofree(_enemy)


func _make_body(layer: int, at: Vector3) -> CharacterBody3D:
	var body := CharacterBody3D.new()
	body.collision_layer = layer
	body.collision_mask = 0
	var shape := CollisionShape3D.new()
	shape.shape = CapsuleShape3D.new()
	shape.position.y = 0.8
	body.add_child(shape)
	body.position = at
	add_child_autofree(body)
	return body


func test_shows_enemy_name() -> void:
	var label: Label3D = _enemy.get_node("%NameLabel")
	assert_eq(label.text, "Limo")


func test_player_body_touching_emits_touched() -> void:
	watch_signals(_enemy)
	var body := _make_body(PLAYER_LAYER, FAR_AWAY)
	await wait_physics_frames(2)
	body.position = Vector3.ZERO
	await wait_physics_frames(3)
	assert_signal_emitted_with_parameters(_enemy, "touched", [_enemy])


func test_other_layers_are_ignored() -> void:
	watch_signals(_enemy)
	_make_body(1, Vector3.ZERO)
	await wait_physics_frames(3)
	assert_signal_not_emitted(_enemy, "touched")


func test_disabled_contact_does_not_emit() -> void:
	watch_signals(_enemy)
	_enemy.set_contact_enabled(false)
	var body := _make_body(PLAYER_LAYER, FAR_AWAY)
	await wait_physics_frames(2)
	body.position = Vector3.ZERO
	await wait_physics_frames(3)
	assert_signal_not_emitted(_enemy, "touched")
