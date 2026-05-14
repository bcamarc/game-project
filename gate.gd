extends AnimatedSprite2D

signal gate_entered(tile_x, tile_y)
var stop := false

func _ready() -> void:
	var stats = get_node_or_null("../Stats")
	if stats:
		gate_entered.connect(stats.on_next_level)

func _on_area_2d_body_entered(body: Node2D) -> void:
	stop = true
	if body.is_in_group("player"):
		
		var maps = get_tree().get_nodes_in_group("current_map")
		if maps.size() > 0:
			var map = maps[0]
			var tile_pos = map.local_to_map(map.to_local(global_position))
			gate_entered.emit(tile_pos.x, tile_pos.y)
			if map.has_method("on_next_level"):
				map.on_next_level()

func _process(delta: float) -> void:
	if not stop:
		global_position.y += 6
