class_name StatBlock
extends Resource
## The eight character stats. Used for base stats of recruits and enemies
## and for flat weapon bonuses (which may be negative).

enum Stat {
	MAX_HP,
	MAX_MANA,
	MAX_STAMINA,
	ATTACK,
	MAGIC_ATTACK,
	DEFENSE,
	MAGIC_DEFENSE,
	SPEED,
}

const _PROPERTY_BY_STAT: Dictionary[Stat, StringName] = {
	Stat.MAX_HP: &"max_hp",
	Stat.MAX_MANA: &"max_mana",
	Stat.MAX_STAMINA: &"max_stamina",
	Stat.ATTACK: &"attack",
	Stat.MAGIC_ATTACK: &"magic_attack",
	Stat.DEFENSE: &"defense",
	Stat.MAGIC_DEFENSE: &"magic_defense",
	Stat.SPEED: &"speed",
}

## Maximum health.
@export var max_hp: int = 0
## Maximum mana. Mana does not regenerate on its own.
@export var max_mana: int = 0
## Maximum stamina. Stamina regenerates every turn.
@export var max_stamina: int = 0
## Physical attack.
@export var attack: int = 0
## Magical attack.
@export var magic_attack: int = 0
## Physical defense.
@export var defense: int = 0
## Magical defense.
@export var magic_defense: int = 0
## Speed. Defines turn order.
@export var speed: int = 0


## Returns the value of [param stat].
func get_stat(stat: Stat) -> int:
	return get(_PROPERTY_BY_STAT[stat])


## Sets the value of [param stat].
func set_stat(stat: Stat, value: int) -> void:
	set(_PROPERTY_BY_STAT[stat], value)


## Returns a new block with the sum of this block and [param other].
## A null [param other] counts as all zeros.
func plus(other: StatBlock) -> StatBlock:
	var result := StatBlock.new()
	for stat: Stat in Stat.values():
		var bonus := 0 if other == null else other.get_stat(stat)
		result.set_stat(stat, get_stat(stat) + bonus)
	return result
