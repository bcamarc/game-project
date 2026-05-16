extends AnimatedSprite2D

func _process(delta: float) -> void:
	var wizard := get_tree().get_first_node_in_group("wizard") as Node2D
	if wizard:
		global_position = wizard.global_position
