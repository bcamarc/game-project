extends ProgressBar

func _process(_delta: float) -> void:
	var stats = _stats()
	value = stats.total_health
	max_value = stats.max_health

func _stats():
	var scene := get_tree().current_scene
	if scene != null:
		var scene_stats := scene.get_node_or_null("Stats")
		if scene_stats != null:
			return scene_stats

	var stats_node := get_tree().get_first_node_in_group("stats")
	if stats_node != null:
		return stats_node
	return Stats
