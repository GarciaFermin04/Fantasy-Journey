extends GutTest
## Integration tests for combat feedback: damage numbers, unit fades and
## pausing/resuming the party around a combat.

const NUMBER_SCENE: PackedScene = preload("res://scenes/ui/combat/damage_number.tscn")
const VISUAL_SCENE: PackedScene = preload("res://scenes/agents/recruits/recruit_visual.tscn")
const PARTY_SCENE: PackedScene = preload("res://scenes/agents/party/party.tscn")


func _result(amount: int, is_heal: bool, reaction: EnemyData.AffinityReaction) -> ActionResult:
	var result := ActionResult.new()
	result.amount = amount
	result.is_heal = is_heal
	result.reaction = reaction
	return result


func test_number_texts() -> void:
	assert_eq(DamageNumber.format_result(_result(18, false, EnemyData.AffinityReaction.NEUTRAL)), "18")
	assert_eq(DamageNumber.format_result(_result(45, false, EnemyData.AffinityReaction.WEAK)), "45!")
	assert_eq(DamageNumber.format_result(_result(27, true, EnemyData.AffinityReaction.NEUTRAL)), "+27")


func test_number_frees_itself_after_animation() -> void:
	var number: DamageNumber = NUMBER_SCENE.instantiate()
	number.duration = 0.05
	add_child(number)
	number.show_result(_result(10, false, EnemyData.AffinityReaction.NEUTRAL))
	assert_eq(number.text, "10")
	await wait_seconds(0.2)
	assert_false(is_instance_valid(number))


func test_visual_fades_and_resets() -> void:
	var visual: RecruitVisual = VISUAL_SCENE.instantiate()
	add_child_autofree(visual)
	var sprite: Sprite3D = visual.get_node("%Sprite3D")
	visual.fade_to(0.35, 0.05)
	await wait_seconds(0.15)
	assert_almost_eq(sprite.modulate.a, 0.35, 0.01)
	assert_eq(sprite.alpha_cut, SpriteBase3D.ALPHA_CUT_DISABLED)
	visual.reset_fade()
	assert_eq(sprite.modulate.a, 1.0)
	assert_eq(sprite.alpha_cut, SpriteBase3D.ALPHA_CUT_DISCARD)


func test_party_pauses_and_resumes_its_members() -> void:
	var party: Party = PARTY_SCENE.instantiate()
	add_child_autofree(party)
	party.set_exploration_enabled(false)
	for member in party.get_members():
		assert_false(member.is_physics_processing(), "%s should be paused" % member.name)
	party.set_exploration_enabled(true)
	for member in party.get_members():
		assert_true(member.is_physics_processing(), "%s should be resumed" % member.name)


func test_party_members_have_recruits() -> void:
	var party: Party = PARTY_SCENE.instantiate()
	add_child_autofree(party)
	var ids: Array[StringName] = []
	for recruit in party.get_member_recruits():
		ids.append(recruit.id)
	assert_eq(ids, [&"warrior", &"archer", &"mage"] as Array[StringName])
