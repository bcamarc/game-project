extends ProgressBar

func _process(delta: float) -> void:
	value = $"../../../Stats".total_health
	max_value = $"../../../Stats".max_health
