extends StaticBody3D
## Placeholder object to test interactions: prints a message and shows a
## response label for a while.

## Text shown when someone interacts.
@export var response_text: String = "¡Funciona!"
## Seconds the response stays visible.
@export var response_duration: float = 2.0

@onready var _interactable: InteractableComponent = %InteractableComponent
@onready var _response_label: Label3D = %ResponseLabel
@onready var _response_timer: Timer = %ResponseTimer


func _ready() -> void:
	_response_label.text = response_text
	_response_label.hide()
	_response_timer.wait_time = response_duration
	_response_timer.timeout.connect(_response_label.hide)
	_interactable.interacted.connect(_on_interacted)


func _on_interacted(actor: Node3D) -> void:
	print("Interacción con %s por %s" % [name, actor.name])
	_response_label.show()
	_response_timer.start()
