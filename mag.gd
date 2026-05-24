extends Label
func _process(delta: float) -> void:
	var mana = snapped(get_node("../../..").total_magic, 0.1)
	text = str(mana)
