extends Control
## Debug scene to try the turn queue, the combat state machine and the turn
## order bar with the starting recruits and the test enemies.

const RECRUIT_PATHS: Array[String] = [
	"res://data/recruits/warrior.tres",
	"res://data/recruits/mage.tres",
	"res://data/recruits/archer.tres",
]
const ENEMY_PATHS: Array[String] = [
	"res://data/enemies/common/slime.tres",
	"res://data/enemies/common/skeleton.tres",
	"res://data/enemies/common/imp.tres",
]

## Speed removed by the "Bajar velocidad" button.
@export var slow_amount: int = 5

var _queue := TurnQueue.new()
var _machine := CombatStateMachine.new()
var _combatants: Array[Combatant] = []

@onready var _bar: TurnOrderBar = %TurnOrderBar
@onready var _round_label: Label = %RoundLabel
@onready var _state_label: Label = %StateLabel
@onready var _speeds_label: Label = %SpeedsLabel
@onready var _next_turn_button: Button = %NextTurnButton
@onready var _defeat_button: Button = %DefeatButton
@onready var _slow_button: Button = %SlowButton


func _ready() -> void:
	_build_combatants()
	_queue.setup(_combatants)
	_machine.state_changed.connect(_on_state_changed)
	_machine.combat_finished.connect(_on_combat_finished)
	_next_turn_button.pressed.connect(_on_next_turn_pressed)
	_defeat_button.pressed.connect(_on_defeat_pressed)
	_slow_button.pressed.connect(_on_slow_pressed)
	_machine.start()
	_begin_next_turn()


func _build_combatants() -> void:
	for i in RECRUIT_PATHS.size():
		var recruit := load(RECRUIT_PATHS[i]) as RecruitData
		_combatants.append(Combatant.from_recruit(recruit, recruit.default_weapon, i))
	for i in ENEMY_PATHS.size():
		_combatants.append(Combatant.from_enemy(load(ENEMY_PATHS[i]) as EnemyData, i))


func _begin_next_turn() -> void:
	if _living_enemies().is_empty():
		_machine.end_combat(CombatStateMachine.Result.VICTORY)
		return
	_machine.begin_turn(_queue.next_actor())
	_refresh()


func _on_next_turn_pressed() -> void:
	_machine.submit_action(null)
	_machine.action_resolved()
	_begin_next_turn()


func _on_defeat_pressed() -> void:
	for enemy in _living_enemies():
		if enemy != _queue.get_current_actor():
			enemy.is_defeated = true
			break
	_refresh()


func _on_slow_pressed() -> void:
	for combatant in _queue.get_remaining_this_round():
		if not combatant.is_ally:
			combatant.stats.speed = maxi(0, combatant.stats.speed - slow_amount)
			break
	_refresh()


func _on_state_changed(_from: CombatStateMachine.State, to: CombatStateMachine.State) -> void:
	_state_label.text = "Estado: %s" % CombatStateMachine.State.keys()[to]


func _on_combat_finished(result: CombatStateMachine.Result) -> void:
	_state_label.text = "Combate terminado: %s" % CombatStateMachine.Result.keys()[result]
	for button: Button in [_next_turn_button, _defeat_button, _slow_button]:
		button.disabled = true
	_refresh()


func _refresh() -> void:
	_bar.display(_queue.get_current_actor(), _queue.get_remaining_this_round(), _queue.get_next_round_preview())
	var actor := _queue.get_current_actor()
	_round_label.text = "Ronda %d · Turno de %s" % [_queue.get_round_number(), actor.display_name if actor else "-"]
	var parts: PackedStringArray = []
	for combatant in _combatants:
		var status := " (derrotado)" if combatant.is_defeated else ""
		parts.append("%s vel %d%s" % [combatant.display_name, combatant.get_speed(), status])
	_speeds_label.text = " · ".join(parts)


func _living_enemies() -> Array[Combatant]:
	var result: Array[Combatant] = []
	for combatant in _combatants:
		if not combatant.is_ally and not combatant.is_defeated:
			result.append(combatant)
	return result
