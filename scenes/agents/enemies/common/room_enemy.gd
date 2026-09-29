class_name RoomEnemy
extends Node3D
## An enemy visible in the room. When the party leader touches it, it emits
## [signal touched] so the room can start an encounter.

## Emitted when the party leader touches this enemy.
signal touched(enemy: RoomEnemy)

## Data of the enemy this visible unit represents in combat.
@export var enemy_data: EnemyData

@onready var _visual: RecruitVisual = %RecruitVisual
@onready var _name_label: Label3D = %NameLabel
@onready var _contact_area: Area3D = %ContactArea


func _ready() -> void:
	assert(enemy_data != null, "RoomEnemy needs enemy_data")
	if enemy_data.sprite != null:
		_visual.texture = enemy_data.sprite
	_name_label.text = enemy_data.display_name
	_contact_area.body_entered.connect(_on_body_entered)


## Enables or disables starting encounters by touch.
func set_contact_enabled(enabled: bool) -> void:
	_contact_area.set_deferred(&"monitoring", enabled)


func _on_body_entered(_body: Node3D) -> void:
	touched.emit(self)
