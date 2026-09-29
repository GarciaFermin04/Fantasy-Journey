class_name PartyLeader
extends CharacterBody3D
## Party leader controlled by the player during exploration.
## Moves in 8 directions relative to the world axes or to a reference node.

## Recruit this party member represents in combat.
@export var recruit: RecruitData
## Movement speed in meters per second.
@export var move_speed: float = 4.0
## Optional node whose Y rotation defines "up" for movement (e.g. the camera).
## When empty, movement follows the world axes.
@export var movement_reference: Node3D = null

var _controls_enabled: bool = true

@onready var _interactor: InteractorComponent = %InteractorComponent


func _physics_process(delta: float) -> void:
	var input := Vector2.ZERO
	if _controls_enabled:
		input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := MovementDirection.from_input(input, _get_reference_yaw())
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


## Enables or disables player control (movement and interaction).
func set_controls_enabled(enabled: bool) -> void:
	_controls_enabled = enabled
	_interactor.set_enabled(enabled)


func _get_reference_yaw() -> float:
	if movement_reference == null:
		return 0.0
	return movement_reference.global_rotation.y
