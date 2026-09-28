class_name CombatCommandPanel
extends HBoxContainer
## Player command input for an ally's turn: choose a skill, then a target,
## and emit the resulting CombatAction. Explicit phases:
## HIDDEN -> CHOOSING_SKILL -> CHOOSING_TARGET -> HIDDEN (action confirmed),
## and CHOOSING_TARGET -> CHOOSING_SKILL when the player cancels.

## Emitted when the player confirms an action.
signal action_confirmed(action: CombatAction)

enum Phase { HIDDEN, CHOOSING_SKILL, CHOOSING_TARGET }

var _phase: Phase = Phase.HIDDEN
var _actor: Combatant = null
var _own_side: Formation = null
var _other_side: Formation = null
var _chosen_skill: SkillData = null

@onready var _menu: ActionMenu = %ActionMenu
@onready var _selector: TargetSelector = %TargetSelector


func _ready() -> void:
	_menu.skill_chosen.connect(_on_skill_chosen)
	_selector.target_chosen.connect(_on_target_chosen)
	_selector.cancelled.connect(_on_selector_cancelled)
	_close()


## Starts the command input for [param actor]. [param own_side] is its
## formation and [param other_side] the opponents'.
func open(actor: Combatant, own_side: Formation, other_side: Formation) -> void:
	assert(actor != null and own_side != null and other_side != null, "CombatCommandPanel.open: missing arguments")
	_actor = actor
	_own_side = own_side
	_other_side = other_side
	_chosen_skill = null
	_enter_choosing_skill(null)


## Closes the panel without confirming an action.
func close() -> void:
	_close()


## Returns the current phase.
func get_phase() -> Phase:
	return _phase


func _on_skill_chosen(skill: SkillData) -> void:
	if _phase != Phase.CHOOSING_SKILL:
		return
	_chosen_skill = skill
	_phase = Phase.CHOOSING_TARGET
	_menu.close()
	_selector.open(skill, _options_for(skill))


func _on_target_chosen(targets: Array[Combatant]) -> void:
	if _phase != Phase.CHOOSING_TARGET:
		return
	var action := CombatAction.new(_actor, _chosen_skill, targets)
	_close()
	action_confirmed.emit(action)


func _on_selector_cancelled() -> void:
	if _phase == Phase.CHOOSING_TARGET:
		_enter_choosing_skill(_chosen_skill)


func _enter_choosing_skill(focus_skill: SkillData) -> void:
	_phase = Phase.CHOOSING_SKILL
	show()
	_selector.close()
	_menu.open(_actor.skills, _skills_without_targets(), focus_skill)


func _close() -> void:
	_phase = Phase.HIDDEN
	_menu.close()
	_selector.close()
	hide()


func _options_for(skill: SkillData) -> Array[Array]:
	return Targeting.get_target_options(skill, _actor, _own_side, _other_side)


func _skills_without_targets() -> Array[SkillData]:
	var result: Array[SkillData] = []
	for skill in _actor.skills:
		if _options_for(skill).is_empty():
			result.append(skill)
	return result
