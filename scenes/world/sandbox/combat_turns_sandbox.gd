extends Control
## Debug scene to try the turn queue, the combat state machine, formations,
## valid targets, the turn order bar and the command panel with the starting
## recruits and the test enemies. Shows the calculated damage or healing of
## each action; it is not applied to health yet.

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
## Maximum allied units per row.
@export var ally_row_capacity: int = 3
## Balance numbers for the damage formula.
@export var combat_rules: CombatRules

var _queue := TurnQueue.new()
var _machine := CombatStateMachine.new()
var _combatants: Array[Combatant] = []
var _allies: Formation
var _enemies := Formation.new()

@onready var _bar: TurnOrderBar = %TurnOrderBar
@onready var _round_label: Label = %RoundLabel
@onready var _state_label: Label = %StateLabel
@onready var _speeds_label: Label = %SpeedsLabel
@onready var _formation_label: Label = %FormationLabel
@onready var _targets_label: Label = %TargetsLabel
@onready var _next_turn_button: Button = %NextTurnButton
@onready var _defeat_button: Button = %DefeatButton
@onready var _slow_button: Button = %SlowButton
@onready var _command_panel: CombatCommandPanel = %CombatCommandPanel
@onready var _log_label: Label = %LogLabel


func _ready() -> void:
	assert(combat_rules != null, "CombatTurnsSandbox needs combat_rules")
	_build_combatants()
	_queue.setup(_combatants)
	_machine.state_changed.connect(_on_state_changed)
	_machine.combat_finished.connect(_on_combat_finished)
	_next_turn_button.pressed.connect(_on_next_turn_pressed)
	_defeat_button.pressed.connect(_on_defeat_pressed)
	_slow_button.pressed.connect(_on_slow_pressed)
	_command_panel.action_confirmed.connect(_on_action_confirmed)
	_machine.start()
	_begin_next_turn()


func _build_combatants() -> void:
	_allies = Formation.new(ally_row_capacity)
	for i in RECRUIT_PATHS.size():
		var recruit := load(RECRUIT_PATHS[i]) as RecruitData
		var ally := Combatant.from_recruit(recruit, recruit.default_weapon, i)
		_combatants.append(ally)
		_allies.add(ally)
	for i in ENEMY_PATHS.size():
		var enemy := Combatant.from_enemy(load(ENEMY_PATHS[i]) as EnemyData, i)
		_combatants.append(enemy)
		_enemies.add(enemy)


func _begin_next_turn() -> void:
	if _living_enemies().is_empty():
		_machine.end_combat(CombatStateMachine.Result.VICTORY)
		return
	var actor := _queue.next_actor()
	_machine.begin_turn(actor)
	_next_turn_button.disabled = actor.is_ally
	_refresh()
	_open_commands_if_ally()


func _open_commands_if_ally() -> void:
	var actor := _queue.get_current_actor()
	if actor != null and actor.is_ally and _machine.get_state() == CombatStateMachine.State.AWAITING_ACTION:
		_command_panel.open(actor, _allies, _enemies)


func _on_action_confirmed(action: CombatAction) -> void:
	_log_label.text = "%s usa %s → %s" % [action.user.display_name, action.skill.display_name, _describe_results(action)]
	_finish_turn(action)


func _on_next_turn_pressed() -> void:
	_log_label.text = "%s pasa el turno (la IA llega en la 3.7)" % _queue.get_current_actor().display_name
	_finish_turn(null)


func _finish_turn(action: CombatAction) -> void:
	_machine.submit_action(action)
	_machine.action_resolved()
	_begin_next_turn()


func _on_defeat_pressed() -> void:
	for enemy in _living_enemies():
		if enemy != _queue.get_current_actor():
			enemy.is_defeated = true
			break
	_refresh()
	_open_commands_if_ally()


func _on_slow_pressed() -> void:
	for combatant in _queue.get_remaining_this_round():
		if not combatant.is_ally:
			combatant.stats.speed = maxi(0, combatant.stats.speed - slow_amount)
			break
	_refresh()
	_open_commands_if_ally()


func _on_state_changed(_from: CombatStateMachine.State, to: CombatStateMachine.State) -> void:
	_state_label.text = "Estado: %s" % CombatStateMachine.State.keys()[to]


func _on_combat_finished(result: CombatStateMachine.Result) -> void:
	_state_label.text = "Combate terminado: %s" % CombatStateMachine.Result.keys()[result]
	_command_panel.close()
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
	_formation_label.text = "Aliados — %s
Enemigos — %s" % [_describe_formation(_allies), _describe_formation(_enemies)]
	_targets_label.text = _describe_targets(actor)


func _describe_results(action: CombatAction) -> String:
	var kind := "de curación" if action.skill.effect == SkillData.Effect.HEAL else "de daño"
	var parts: PackedStringArray = []
	for target in action.targets:
		var amount := DamageCalculator.get_amount(action.skill, action.user, target, combat_rules)
		parts.append("%s: %d %s%s" % [target.display_name, amount, kind, _reaction_text(action.skill, target)])
	return " · ".join(parts)


func _reaction_text(skill: SkillData, target: Combatant) -> String:
	if skill.effect == SkillData.Effect.HEAL:
		return ""
	match target.get_reaction(skill.affinity):
		EnemyData.AffinityReaction.WEAK:
			return " (débil)"
		EnemyData.AffinityReaction.RESISTANT:
			return " (resiste)"
	return ""


func _describe_formation(formation: Formation) -> String:
	return "Delantera: %s · Trasera: %s" % [
		_join_names(formation.get_row(CombatRow.Row.FRONT)),
		_join_names(formation.get_row(CombatRow.Row.BACK)),
	]


func _describe_targets(actor: Combatant) -> String:
	if actor == null:
		return ""
	var own_side := _allies if actor.is_ally else _enemies
	var other_side := _enemies if actor.is_ally else _allies
	var lines: PackedStringArray = ["Objetivos válidos de %s:" % actor.display_name]
	for skill in actor.skills:
		var options: PackedStringArray = []
		for option in Targeting.get_target_options(skill, actor, own_side, other_side):
			var group: Array[Combatant] = []
			group.assign(option)
			options.append("[%s]" % _join_names(group) if group.size() > 1 else _join_names(group))
		lines.append("  %s → %s" % [skill.display_name, " | ".join(options) if not options.is_empty() else "(ninguno)"])
	return "
".join(lines)


func _join_names(combatants: Array[Combatant]) -> String:
	if combatants.is_empty():
		return "-"
	var names: PackedStringArray = []
	for combatant in combatants:
		names.append(combatant.display_name)
	return ", ".join(names)


func _living_enemies() -> Array[Combatant]:
	var result: Array[Combatant] = []
	for combatant in _combatants:
		if not combatant.is_ally and not combatant.is_defeated:
			result.append(combatant)
	return result
