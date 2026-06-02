extends ProgressBar  

var stats = null

func _ready() -> void:
	stats = _stats()

func _process(_delta: float) -> void:
	if stats == null or not is_instance_valid(stats):
		stats = _stats()
	value = stats.total_magic
	max_value = stats.max_magic

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
