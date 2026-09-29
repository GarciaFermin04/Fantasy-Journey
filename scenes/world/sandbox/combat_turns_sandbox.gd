extends Control
## Debug scene to try the combat logic (CombatSession) without 3D, with the
## starting recruits and the test enemies: turn order bar, command panel,
## enemy AI after a short delay, resources, targets and debug buttons.

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
## Balance numbers for the combat formulas.
@export var combat_rules: CombatRules
## Seconds an enemy waits before acting, so its turn can be followed.
@export var enemy_turn_delay: float = 0.8

var _session: CombatSession
var _combatants: Array[Combatant] = []
var _rng := RandomNumberGenerator.new()

@onready var _bar: TurnOrderBar = %TurnOrderBar
@onready var _round_label: Label = %RoundLabel
@onready var _state_label: Label = %StateLabel
@onready var _speeds_label: Label = %SpeedsLabel
@onready var _formation_label: Label = %FormationLabel
@onready var _targets_label: Label = %TargetsLabel
@onready var _defeat_button: Button = %DefeatButton
@onready var _slow_button: Button = %SlowButton
@onready var _command_panel: CombatCommandPanel = %CombatCommandPanel
@onready var _log_label: Label = %LogLabel
@onready var _enemy_turn_timer: Timer = %EnemyTurnTimer


func _ready() -> void:
	assert(combat_rules != null, "CombatTurnsSandbox needs combat_rules")
	_rng.randomize()
	_session = CombatSession.new(combat_rules)
	_session.turn_started.connect(_on_turn_started)
	_session.action_performed.connect(_on_action_performed)
	_session.combat_finished.connect(_on_combat_finished)
	_defeat_button.pressed.connect(_on_defeat_pressed)
	_slow_button.pressed.connect(_on_slow_pressed)
	_command_panel.action_confirmed.connect(_session.perform)
	_enemy_turn_timer.timeout.connect(_on_enemy_turn_timer_timeout)
	var allies: Array[Combatant] = []
	for i in RECRUIT_PATHS.size():
		var recruit := load(RECRUIT_PATHS[i]) as RecruitData
		allies.append(Combatant.from_recruit(recruit, recruit.default_weapon, i))
	var enemies: Array[Combatant] = []
	for i in ENEMY_PATHS.size():
		enemies.append(Combatant.from_enemy(load(ENEMY_PATHS[i]) as EnemyData, i))
	_combatants = allies.duplicate()
	_combatants.append_array(enemies)
	_state_label.text = "Combate en curso"
	_session.start(allies, enemies)


func _on_turn_started(actor: Combatant) -> void:
	_refresh()
	if actor.is_ally:
		_command_panel.open(actor, _session.get_allies(), _session.get_enemies(), combat_rules)
	else:
		_enemy_turn_timer.start(enemy_turn_delay)


func _on_enemy_turn_timer_timeout() -> void:
	if not _session.is_awaiting_action():
		return
	var actor := _session.get_current_actor()
	var action := EnemyAI.choose_action(actor, _session.get_enemies(), _session.get_allies(), combat_rules, _rng)
	if action == null:
		_log_label.text = "%s no puede actuar y pasa el turno" % actor.display_name
		_session.pass_turn()
	else:
		_session.perform(action)


func _on_action_performed(action: CombatAction, results: Array[ActionResult]) -> void:
	_log_label.text = CombatText.describe_action(action, results)


func _on_defeat_pressed() -> void:
	for enemy in _session.get_enemies().get_living():
		if enemy != _session.get_current_actor():
			enemy.take_damage(enemy.current_hp)
			break
	if CombatOutcome.evaluate(_session.get_allies(), _session.get_enemies()) != CombatStateMachine.Result.NONE:
		_command_panel.close()
		_log_label.text = "Último enemigo derrotado con el botón de depuración"
		_session.pass_turn()
		return
	_refresh()
	_reopen_commands()


func _on_slow_pressed() -> void:
	for combatant in _session.get_queue().get_remaining_this_round():
		if not combatant.is_ally:
			combatant.stats.speed = maxi(0, combatant.stats.speed - slow_amount)
			break
	_refresh()
	_reopen_commands()


func _reopen_commands() -> void:
	var actor := _session.get_current_actor()
	if actor != null and actor.is_ally and _session.is_awaiting_action():
		_command_panel.open(actor, _session.get_allies(), _session.get_enemies(), combat_rules)


func _on_combat_finished(result: CombatStateMachine.Result) -> void:
	_state_label.text = "Combate terminado: %s" % CombatStateMachine.Result.keys()[result]
	_command_panel.close()
	_enemy_turn_timer.stop()
	for button: Button in [_defeat_button, _slow_button]:
		button.disabled = true
	_refresh()


func _refresh() -> void:
	var queue := _session.get_queue()
	_bar.display(queue.get_current_actor(), queue.get_remaining_this_round(), queue.get_next_round_preview())
	var actor := queue.get_current_actor()
	_round_label.text = "Ronda %d · Turno de %s" % [queue.get_round_number(), actor.display_name if actor else "-"]
	var lines: PackedStringArray = []
	for combatant in _combatants:
		lines.append(_describe_resources(combatant))
	_speeds_label.text = "\n".join(lines)
	_formation_label.text = "Aliados — %s\nEnemigos — %s" % [
		_describe_formation(_session.get_allies()), _describe_formation(_session.get_enemies())]
	_targets_label.text = _describe_targets(actor)


func _describe_resources(combatant: Combatant) -> String:
	var text := CombatText.describe_resources(combatant)
	return text if combatant.is_defeated else "%s · vel %d" % [text, combatant.get_speed()]


func _describe_formation(formation: Formation) -> String:
	return "Delantera: %s · Trasera: %s" % [
		_join_names(formation.get_row(CombatRow.Row.FRONT)),
		_join_names(formation.get_row(CombatRow.Row.BACK)),
	]


func _describe_targets(actor: Combatant) -> String:
	if actor == null:
		return ""
	var own_side := _session.get_allies() if actor.is_ally else _session.get_enemies()
	var other_side := _session.get_enemies() if actor.is_ally else _session.get_allies()
	var lines: PackedStringArray = ["Objetivos válidos de %s:" % actor.display_name]
	for skill in actor.skills:
		var options: PackedStringArray = []
		for option in Targeting.get_target_options(skill, actor, own_side, other_side):
			var group: Array[Combatant] = []
			group.assign(option)
			options.append("[%s]" % _join_names(group) if group.size() > 1 else _join_names(group))
		lines.append("  %s → %s" % [skill.display_name, " | ".join(options) if not options.is_empty() else "(ninguno)"])
	return "\n".join(lines)


func _join_names(combatants: Array[Combatant]) -> String:
	if combatants.is_empty():
		return "-"
	var names: PackedStringArray = []
	for combatant in combatants:
		names.append(combatant.display_name)
	return ", ".join(names)
