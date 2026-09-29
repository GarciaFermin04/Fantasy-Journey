extends GutTest
## Integration tests for CombatHud.

const HUD_SCENE: PackedScene = preload("res://scenes/ui/combat/combat_hud.tscn")

var _hud: CombatHud


func before_each() -> void:
	_hud = HUD_SCENE.instantiate()
	add_child_autofree(_hud)


func test_starts_hidden() -> void:
	assert_false(_hud.visible)


func test_refresh_lists_every_living_unit() -> void:
	var session := CombatSession.new(CombatRules.new())
	var ally := _unit("Guerrero", true)
	var enemy := _unit("Limo", false)
	session.start([ally] as Array[Combatant], [enemy] as Array[Combatant])
	_hud.refresh(session)
	var status: Label = _hud.get_node("%StatusLabel")
	assert_string_contains(status.text, "Guerrero")
	assert_string_contains(status.text, "Limo")


func test_show_log_sets_text() -> void:
	_hud.show_log("¡Comienza el combate!")
	var log_label: Label = _hud.get_node("%LogLabel")
	assert_eq(log_label.text, "¡Comienza el combate!")


func _unit(unit_name: String, is_ally: bool) -> Combatant:
	var combatant := Combatant.new()
	combatant.display_name = unit_name
	combatant.is_ally = is_ally
	combatant.stats.max_hp = 50
	combatant.stats.speed = 10 if is_ally else 5
	combatant.start_combat()
	return combatant
