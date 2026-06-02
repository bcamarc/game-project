extends Label
@onready var stats = get_node("../../..")

func _process(delta: float) -> void:
	var mana = snapped(stats.total_magic, 0.1)
	text = str(mana)
