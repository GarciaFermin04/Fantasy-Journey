class_name PartyFollower
extends CharacterBody3D
## Party member that walks towards a point given by its parent Party.

## Maximum movement speed in meters per second. Higher than the leader's
## so the follower never falls behind.
@export var move_speed: float = 6.0

var _follow_target: Vector3 = Vector3.ZERO


func _ready() -> void:
	_follow_target = global_position


func _physics_process(delta: float) -> void:
	var horizontal := FollowMotion.velocity_towards(global_position, _follow_target, move_speed, delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


## Sets the world position this follower walks towards.
func set_follow_target(point: Vector3) -> void:
	_follow_target = point
