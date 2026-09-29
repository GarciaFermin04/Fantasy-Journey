@tool
class_name RecruitVisual
extends Node3D
## Visual representation of a unit (recruit or enemy). The origin is at the feet.
## Swap [member texture] to change the art without touching other scenes.

## Texture shown by the billboard sprite.
@export var texture: Texture2D:
	set = set_texture

var _fade_tween: Tween = null


func _ready() -> void:
	_apply_texture()


## Sets the texture displayed by the sprite.
func set_texture(value: Texture2D) -> void:
	texture = value
	if is_node_ready():
		_apply_texture()


## Fades the sprite to [param alpha] over [param duration] seconds. While
## not fully opaque the sprite uses alpha blending instead of alpha cut.
func fade_to(alpha: float, duration: float) -> void:
	var sprite := _get_sprite()
	if _fade_tween != null:
		_fade_tween.kill()
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	_fade_tween = create_tween()
	_fade_tween.tween_property(sprite, "modulate:a", alpha, duration)
	if is_equal_approx(alpha, 1.0):
		_fade_tween.tween_callback(func() -> void: sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD)


## Restores the sprite to fully opaque immediately.
func reset_fade() -> void:
	if _fade_tween != null:
		_fade_tween.kill()
	var sprite := _get_sprite()
	sprite.modulate.a = 1.0
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD


func _apply_texture() -> void:
	_get_sprite().texture = texture


func _get_sprite() -> Sprite3D:
	return %Sprite3D as Sprite3D
