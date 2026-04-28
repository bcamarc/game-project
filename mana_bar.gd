extends ProgressBar  

func _process(delta: float) -> void:
	value = $"../../../Stats".total_magic
	max_value = $"../../../Stats".max_magic
