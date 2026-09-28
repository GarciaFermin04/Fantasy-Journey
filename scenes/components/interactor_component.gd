class_name InteractorComponent
extends Area3D
## Detects nearby InteractableComponents, selects the closest one, shows its
## prompt and activates it when the "interact" action is pressed.

## Node reported as the actor of the interactions (usually the party leader).
@export var actor: Node3D

var _candidates: Array[InteractableComponent] = []
var _current: InteractableComponent = null


func _ready() -> void:
	assert(actor != null, "InteractorComponent needs an actor")
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _physics_process(_delta: float) -> void:
	if _candidates.is_empty():
		return
	_select(_find_nearest())


func _unhandled_input(event: InputEvent) -> void:
	if _current != null and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_current.interact(actor)


func _on_area_entered(area: Area3D) -> void:
	if area is InteractableComponent:
		_candidates.append(area)


func _on_area_exited(area: Area3D) -> void:
	if area is InteractableComponent:
		_candidates.erase(area)
		if area == _current:
			_select(null)


func _find_nearest() -> InteractableComponent:
	var positions: Array[Vector3] = []
	for candidate in _candidates:
		positions.append(candidate.global_position)
	var index := NearestTarget.index_of_nearest(global_position, positions)
	if index < 0:
		return null
	return _candidates[index]


func _select(target: InteractableComponent) -> void:
	if target == _current:
		return
	if _current != null:
		_current.hide_prompt()
	_current = target
	if _current != null:
		_current.show_prompt()
