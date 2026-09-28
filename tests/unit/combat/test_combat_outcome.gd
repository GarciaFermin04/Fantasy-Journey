extends GutTest
## Tests for CombatOutcome.

var _allies: Formation
var _enemies: Formation
var _ally: Combatant
var _enemy: Combatant


func before_each() -> void:
	_allies = Formation.new(3)
	_enemies = Formation.new()
	_ally = Combatant.new()
	_enemy = Combatant.new()
	_allies.add(_ally)
	_enemies.add(_enemy)


func test_combat_goes_on_while_both_sides_live() -> void:
	assert_eq(CombatOutcome.evaluate(_allies, _enemies), CombatStateMachine.Result.NONE)


func test_victory_when_all_enemies_are_defeated() -> void:
	_enemy.is_defeated = true
	assert_eq(CombatOutcome.evaluate(_allies, _enemies), CombatStateMachine.Result.VICTORY)


func test_defeat_when_all_allies_are_defeated() -> void:
	_ally.is_defeated = true
	assert_eq(CombatOutcome.evaluate(_allies, _enemies), CombatStateMachine.Result.DEFEAT)


func test_wiped_out_formation() -> void:
	assert_false(_enemies.is_wiped_out())
	_enemy.is_defeated = true
	assert_true(_enemies.is_wiped_out())
