extends Label

@onready var stats = get_node("../../..")

func _process(delta: float) -> void:
	text = str(stats.total_damage)
