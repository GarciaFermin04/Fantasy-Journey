extends GutTest
## Integration tests for InteractableComponent (scene instance).

const INTERACTABLE_SCENE: PackedScene = preload("res://scenes/components/interactable_component.tscn")

var _component: InteractableComponent


func before_each() -> void:
	_component = INTERACTABLE_SCENE.instantiate()
	add_child_autofree(_component)


func test_prompt_is_hidden_by_default() -> void:
	assert_false(_component.is_prompt_visible())


func test_show_prompt_makes_it_visible() -> void:
	_component.show_prompt()
	assert_true(_component.is_prompt_visible())


func test_hide_prompt_hides_it() -> void:
	_component.show_prompt()
	_component.hide_prompt()
	assert_false(_component.is_prompt_visible())


func test_interact_emits_signal_with_actor() -> void:
	var actor := Node3D.new()
	add_child_autofree(actor)
	watch_signals(_component)
	_component.interact(actor)
	assert_signal_emitted_with_parameters(_component, "interacted", [actor])


func test_prompt_uses_exported_text() -> void:
	var component: InteractableComponent = INTERACTABLE_SCENE.instantiate()
	component.prompt_text = "Abrir"
	add_child_autofree(component)
	var prompt: Label3D = component.get_node("%Prompt")
	assert_eq(prompt.text, "Abrir")
