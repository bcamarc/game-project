extends CanvasLayer
@onready var button: BaseButton = %Resume

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	button.pressed.connect(func(): toggle_menu())
	
func toggle_menu() -> void:
	visible = !visible
	get_tree().paused = visible

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		toggle_menu()
		get_viewport().set_input_as_handled()
