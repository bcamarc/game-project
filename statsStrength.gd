extends Label


func _process(delta: float) -> void:
	text = str(get_node("../../..").strength)
