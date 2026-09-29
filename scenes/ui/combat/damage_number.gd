class_name DamageNumber
extends Label3D
## Floating number shown over a unit when it takes damage or healing. It rises,
## fades out and frees itself.

## Color of normal damage.
@export var damage_color: Color = Color(1.0, 1.0, 1.0)
## Color of damage against a weakness.
@export var weak_color: Color = Color(1.0, 0.6, 0.2)
## Color of damage against a resistance.
@export var resisted_color: Color = Color(0.65, 0.65, 0.75)
## Color of healing.
@export var heal_color: Color = Color(0.45, 1.0, 0.5)
## Meters the number rises while it fades.
@export var rise_height: float = 0.8
## Seconds the number stays on screen.
@export var duration: float = 0.9


## Shows [param result] (amount, healing and reaction) and starts the animation.
func show_result(result: ActionResult) -> void:
	text = format_result(result)
	modulate = _color_for(result)
	var tween := create_tween().set_parallel()
	tween.tween_property(self, "position:y", position.y + rise_height, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, duration).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)


## Returns the text for [param result]: "+27" for healing, "18" for damage
## and "45!" for damage against a weakness.
static func format_result(result: ActionResult) -> String:
	if result.is_heal:
		return "+%d" % result.amount
	if result.reaction == EnemyData.AffinityReaction.WEAK:
		return "%d!" % result.amount
	return str(result.amount)


func _color_for(result: ActionResult) -> Color:
	if result.is_heal:
		return heal_color
	match result.reaction:
		EnemyData.AffinityReaction.WEAK:
			return weak_color
		EnemyData.AffinityReaction.RESISTANT:
			return resisted_color
	return damage_color
