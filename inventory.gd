extends CanvasLayer
func _ready() -> void:
	hide()
func _process(delta: float) -> void:
	if (Input.is_action_just_released("inventory")):
		if (visible):
			hide()
		else:
			show()
	if (visible):
		get_tree().paused = true
	else:
		get_tree().paused = false
