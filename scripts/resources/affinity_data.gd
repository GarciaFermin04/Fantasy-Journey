class_name AffinityData
extends Resource
## An affinity (e.g. Fire, Darkness). Recruits and skills that share an
## affinity get a bonus; enemies can be weak or resistant to it.

## Stable identifier used by code and data (e.g. &"fire").
@export var id: StringName = &""
## Name shown to the player.
@export var display_name: String = ""
## Color used by the UI to represent this affinity.
@export var color: Color = Color.WHITE
