class_name InteractableComponent
extends Area3D
## Makes its owner interactable. Shows a prompt while selected by an
## InteractorComponent and emits [signal interacted] when activated.
## The owner decides what happens by listening to the signal.

## Emitted when [param actor] interacts with this component.
signal interacted(actor: Node3D)

## Text shown in the prompt.
@export var prompt_text: String = "[E] Interactuar"
## Height of the prompt above the component origin, in meters.
@export var prompt_height: float = 2.0

@onready var _prompt: Label3D = %Prompt


func _ready() -> void:
	_prompt.text = prompt_text
	_prompt.position.y = prompt_height
	_prompt.hide()


## Shows the interaction prompt.
func show_prompt() -> void:
	_prompt.show()


## Hides the interaction prompt.
func hide_prompt() -> void:
	_prompt.hide()


## Returns whether the interaction prompt is visible.
func is_prompt_visible() -> bool:
	return _prompt.visible


## Triggers the interaction on behalf of [param actor].
func interact(actor: Node3D) -> void:
	interacted.emit(actor)
