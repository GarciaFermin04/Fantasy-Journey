@tool
class_name RecruitVisual
extends Node3D
## Visual representation of a recruit. The origin is at the feet.
## Swap [member texture] to change the art without touching other scenes.

## Texture shown by the billboard sprite.
@export var texture: Texture2D:
	set = set_texture


func _ready() -> void:
	_apply_texture()


## Sets the texture displayed by the sprite.
func set_texture(value: Texture2D) -> void:
	texture = value
	if is_node_ready():
		_apply_texture()


func _apply_texture() -> void:
	var sprite := %Sprite3D as Sprite3D
	sprite.texture = texture
