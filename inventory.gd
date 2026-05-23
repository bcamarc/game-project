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

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("inventory"):
		toggle_menu()
		get_viewport().set_input_as_handled()

func toggle_menu() -> void:
	visible = !visible
	get_tree().paused = visible
