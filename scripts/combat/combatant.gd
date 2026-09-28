class_name Combatant
extends RefCounted
## A unit taking part in a combat (recruit or enemy). Holds the state that
## changes during the fight, so the static data resources stay untouched:
## current health, mana, stamina, cooldowns and defeat.

## Value for [method start_combat] meaning "start at maximum".
const FULL: int = -1

## Name shown in combat UI.
var display_name: String = ""
## Optional art for UI such as the turn order bar.
var portrait: Texture2D = null
## Whether the unit fights on the player's side.
var is_ally: bool = false
## Position inside its side's formation. Breaks speed ties within a side.
var formation_index: int = 0
## Row the unit currently occupies.
var row: CombatRow.Row = CombatRow.Row.FRONT
## Current stats (base stats plus weapon bonuses for recruits).
var stats: StatBlock = StatBlock.new()
## Skills the unit can use in this combat.
var skills: Array[SkillData] = []
## Affinity of the unit. Skills of the same affinity get a bonus.
var affinity: AffinityData = null
## Weapon wielded by the unit (read only). Null for enemies.
var weapon: WeaponData = null
## Affinities the unit is weak to.
var weaknesses: Array[AffinityData] = []
## Affinities the unit resists.
var resistances: Array[AffinityData] = []
## Relative weight of each skill for the enemy AI. Missing skills weigh 1.
var skill_weights: Dictionary[SkillData, int] = {}
## How the enemy AI chooses among valid targets.
var target_preference: EnemyData.TargetPreference = EnemyData.TargetPreference.RANDOM
## Whether the unit was defeated. Defeated units lose their turns.
var is_defeated: bool = false
## Current health.
var current_hp: int = 0
## Current mana. It does not regenerate on its own.
var current_mana: int = 0
## Current stamina. It regenerates at the start of the unit's turns.
var current_stamina: int = 0

var _cooldowns: Dictionary[SkillData, int] = {}
var _used_this_turn: Array[SkillData] = []


## Creates an allied combatant from [param recruit] wielding [param weapon].
static func from_recruit(recruit: RecruitData, weapon: WeaponData, index: int) -> Combatant:
	assert(recruit != null, "Combatant.from_recruit: recruit is null")
	var combatant := Combatant.new()
	combatant.display_name = recruit.display_name
	combatant.portrait = recruit.sprite
	combatant.is_ally = true
	combatant.formation_index = index
	combatant.row = recruit.preferred_row
	combatant.stats = recruit.get_stats_with(weapon)
	combatant.skills = recruit.default_equipped_skills.duplicate()
	combatant.affinity = recruit.affinity
	combatant.weapon = weapon
	combatant.start_combat()
	return combatant


## Creates an enemy combatant from [param enemy].
static func from_enemy(enemy: EnemyData, index: int) -> Combatant:
	assert(enemy != null, "Combatant.from_enemy: enemy is null")
	var combatant := Combatant.new()
	combatant.display_name = enemy.display_name
	combatant.portrait = enemy.sprite
	combatant.is_ally = false
	combatant.formation_index = index
	combatant.row = enemy.preferred_row
	combatant.stats = enemy.base_stats.plus(null)
	combatant.skills = enemy.get_skills()
	combatant.affinity = enemy.affinity
	combatant.weaknesses = enemy.weaknesses.duplicate()
	combatant.resistances = enemy.resistances.duplicate()
	combatant.target_preference = enemy.target_preference
	for entry in enemy.skills:
		if entry != null and entry.skill != null:
			combatant.skill_weights[entry.skill] = entry.weight
	combatant.start_combat()
	return combatant


## Prepares the unit for a new combat: stamina full, no cooldowns, and
## health/mana carried over from the run ([constant FULL] means maximum).
func start_combat(hp: int = FULL, mana: int = FULL) -> void:
	current_hp = stats.max_hp if hp == FULL else clampi(hp, 0, stats.max_hp)
	current_mana = stats.max_mana if mana == FULL else clampi(mana, 0, stats.max_mana)
	current_stamina = stats.max_stamina
	is_defeated = current_hp == 0
	_cooldowns.clear()
	_used_this_turn.clear()


## Returns the current speed, which defines turn order.
func get_speed() -> int:
	return stats.speed


## Returns how this unit reacts to [param skill_affinity].
func get_reaction(skill_affinity: AffinityData) -> EnemyData.AffinityReaction:
	return EnemyData.reaction_for(skill_affinity, weaknesses, resistances)


## Lowers health by [param amount]. At 0 the unit is defeated.
## Returns the health actually lost.
func take_damage(amount: int) -> int:
	var lost := mini(maxi(amount, 0), current_hp)
	current_hp -= lost
	if current_hp == 0:
		is_defeated = true
	return lost


## Raises health by [param amount] up to the maximum. Defeated units are not
## revived. Returns the health actually recovered.
func heal(amount: int) -> int:
	if is_defeated:
		return 0
	var recovered := mini(maxi(amount, 0), stats.max_hp - current_hp)
	current_hp += recovered
	return recovered


## Returns the mana this unit pays for [param skill]: base cost plus weapon
## modifier, never below zero. Enemies pay nothing unless the rules say so.
func get_mana_cost(skill: SkillData, rules: CombatRules) -> int:
	if not _pays_costs(rules):
		return 0
	var modifier := 0 if weapon == null else weapon.mana_cost_modifier
	return maxi(skill.mana_cost + modifier, 0)


## Returns the stamina this unit pays for [param skill]: base cost plus weapon
## modifier, never below zero. Enemies pay nothing unless the rules say so.
func get_stamina_cost(skill: SkillData, rules: CombatRules) -> int:
	if not _pays_costs(rules):
		return 0
	var modifier := 0 if weapon == null else weapon.stamina_cost_modifier
	return maxi(skill.stamina_cost + modifier, 0)


## Returns the own turns [param skill] still has to wait before being used.
func get_cooldown_remaining(skill: SkillData) -> int:
	return _cooldowns.get(skill, 0)


## Returns whether [param skill] can be used now: not on cooldown and with
## enough mana and stamina.
func can_use(skill: SkillData, rules: CombatRules) -> bool:
	return get_cooldown_remaining(skill) == 0 \
		and current_mana >= get_mana_cost(skill, rules) \
		and current_stamina >= get_stamina_cost(skill, rules)


## Pays the cost of [param skill] and starts its cooldown.
func pay_for(skill: SkillData, rules: CombatRules) -> void:
	assert(can_use(skill, rules), "Combatant.pay_for: %s cannot use %s" % [display_name, skill.display_name])
	current_mana -= get_mana_cost(skill, rules)
	current_stamina -= get_stamina_cost(skill, rules)
	if skill.cooldown_turns > 0:
		_cooldowns[skill] = skill.cooldown_turns
		_used_this_turn.append(skill)


## Called when the unit's turn starts: regenerates stamina.
func start_turn(rules: CombatRules) -> void:
	var regen := roundi(stats.max_stamina * rules.stamina_regen_percent / 100.0)
	current_stamina = mini(current_stamina + regen, stats.max_stamina)


## Called when the unit's turn ends: cooldowns advance, except for skills
## used this turn (a cooldown of N blocks the next N own turns).
func end_turn() -> void:
	for skill in _cooldowns.keys():
		if not _used_this_turn.has(skill):
			_cooldowns[skill] = maxi(_cooldowns[skill] - 1, 0)
	_used_this_turn.clear()


func _pays_costs(rules: CombatRules) -> bool:
	return is_ally or rules.enemies_pay_costs
