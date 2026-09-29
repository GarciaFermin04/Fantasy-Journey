extends GutTest
## Tests for CombatSession.

var _rules: CombatRules
var _session: CombatSession
var _hero: Combatant
var _foe: Combatant
var _strike: SkillData


func before_each() -> void:
	_rules = CombatRules.new()
	_session = CombatSession.new(_rules)
	_strike = SkillData.new()
	_strike.display_name = "Golpe"
	_strike.power = 20
	_hero = _make("Héroe", true, 10, 100)
	_foe = _make("Rival", false, 5, 30)


func _make(unit_name: String, is_ally: bool, speed: int, hp: int) -> Combatant:
	var combatant := Combatant.new()
	combatant.display_name = unit_name
	combatant.is_ally = is_ally
	combatant.stats.max_hp = hp
	combatant.stats.max_stamina = 20
	combatant.stats.attack = 10
	combatant.stats.defense = 10
	combatant.stats.speed = speed
	combatant.skills = [_strike]
	combatant.start_combat()
	return combatant


func _start() -> void:
	_session.start([_hero] as Array[Combatant], [_foe] as Array[Combatant])


func _hit(user: Combatant, target: Combatant) -> Array[ActionResult]:
	return _session.perform(CombatAction.new(user, _strike, [target]))


func test_first_turn_goes_to_fastest() -> void:
	watch_signals(_session)
	_start()
	assert_eq(_session.get_current_actor(), _hero)
	assert_true(_session.is_awaiting_action())
	assert_signal_emitted_with_parameters(_session, "turn_started", [_hero])


func test_perform_applies_damage_and_advances_turn() -> void:
	watch_signals(_session)
	_start()
	var results := _hit(_hero, _foe)
	# 20 × 10 / 10 × 0.5 = 10
	assert_eq(results[0].amount, 10)
	assert_eq(_foe.current_hp, 20)
	assert_eq(_session.get_current_actor(), _foe)
	assert_signal_emitted(_session, "action_performed")


func test_defeating_all_enemies_is_victory() -> void:
	watch_signals(_session)
	_foe.take_damage(25)
	_start()
	_hit(_hero, _foe)
	assert_eq(_session.get_result(), CombatStateMachine.Result.VICTORY)
	assert_signal_emitted_with_parameters(_session, "combat_finished", [CombatStateMachine.Result.VICTORY])
	assert_false(_session.is_awaiting_action())


func test_defeating_all_allies_is_defeat() -> void:
	_hero.take_damage(95)
	_start()
	_session.pass_turn()
	_hit(_foe, _hero)
	assert_eq(_session.get_result(), CombatStateMachine.Result.DEFEAT)


func test_pass_turn_moves_to_next_actor() -> void:
	_start()
	_session.pass_turn()
	assert_eq(_session.get_current_actor(), _foe)


func test_stamina_regenerates_when_turn_starts() -> void:
	_start()
	_hero.current_stamina = 0
	_session.pass_turn()
	_session.pass_turn()
	# 20% of 20 = 4, regenerated at the start of the hero's second turn.
	assert_eq(_hero.current_stamina, 4)


func test_cooldowns_advance_at_end_of_turn() -> void:
	var slow_skill := SkillData.new()
	slow_skill.display_name = "Lenta"
	slow_skill.cooldown_turns = 1
	_hero.skills = [slow_skill]
	_start()
	_session.perform(CombatAction.new(_hero, slow_skill, [_foe]))
	_session.pass_turn()
	assert_false(_hero.can_use(slow_skill, _rules))
	_session.pass_turn()
	_session.pass_turn()
	assert_true(_hero.can_use(slow_skill, _rules))


func test_action_from_wrong_actor_is_rejected() -> void:
	_start()
	var results := _hit(_foe, _hero)
	assert_push_error("does not belong to the current actor")
	assert_eq(results.size(), 0)
	assert_eq(_hero.current_hp, 100)


func test_formations_are_built() -> void:
	_start()
	assert_eq(_session.get_allies().get_living(), [_hero] as Array[Combatant])
	assert_eq(_session.get_enemies().get_living(), [_foe] as Array[Combatant])
