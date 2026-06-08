#extends CanvasLayer
#func _ready() -> void:
	#hide()
#func _process(delta: float) -> void:
	#if (Input.is_action_just_released("inventory")):
		#if (visible):
			#hide()
		#else:
			#show()
	#if (visible):
		#get_tree().paused = true
	#else:
		#get_tree().paused = false
extends CanvasLayer

@onready var weapons_panel = $WeaponsPanel

func _ready() -> void:
	add_to_group("inventory")
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("inventory"):
		toggle_menu()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_9:
		consume_first_consumable()
		get_viewport().set_input_as_handled()

func toggle_menu() -> void:
	visible = !visible
	get_tree().paused = visible

func add_item(item_data: Dictionary) -> bool:
	if weapons_panel != null and weapons_panel.has_method("add_item"):
		return weapons_panel.add_item(item_data)
	return false

func consume_first_consumable() -> bool:
	if weapons_panel != null and weapons_panel.has_method("consume_first_consumable"):
		return weapons_panel.consume_first_consumable()
	return false
