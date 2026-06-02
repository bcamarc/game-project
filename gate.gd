extends AnimatedSprite2D

signal gate_entered(tile_x, tile_y)
@export var fall_speed := 220.0
var falling := true
var current_map = null
@onready var collision_shape = $Area2D/CollisionShape2D

func _ready() -> void:
	$confirmation/Sprite2D.frame = 0
	$confirmation.hide()
	current_map = _current_map()
	var stats = get_node_or_null("../../Stats")
	if stats:
		gate_entered.connect(stats.on_next_level)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if falling:
		return
	if body.is_in_group("player") or body.is_in_group("alien_player"):
		$confirmation.show()
		
func nx_level() -> void:
	var maps = get_tree().get_nodes_in_group("current_map")
	if maps.size() > 0:
		var map = maps[0]
		var tile_pos = map.local_to_map(map.to_local(global_position))
		gate_entered.emit(tile_pos.x, tile_pos.y)
		if map.has_method("on_next_level"):
			map.on_next_level()

func _process(delta: float) -> void:
	if not falling:
		return

	global_position.y += fall_speed * delta
	if _is_touching_ground():
		falling = false

func _is_touching_ground() -> bool:
	var map = _current_map()
	if map == null:
		return false

	var probe_pos := _ground_probe_position()
	var tile_pos = map.local_to_map(map.to_local(probe_pos))
	return map.get_cell_source_id(tile_pos) != -1

func _ground_probe_position() -> Vector2:
	if collision_shape != null and collision_shape.shape is CapsuleShape2D:
		var capsule := collision_shape.shape as CapsuleShape2D
		return collision_shape.global_position + Vector2(0, capsule.height * absf(global_scale.y) * 0.5 + 4.0)

	return global_position + Vector2(0, 88.0)

func _current_map():
	if current_map != null and is_instance_valid(current_map):
		return current_map

	var maps = get_tree().get_nodes_in_group("current_map")
	if maps.size() > 0:
		current_map = maps[0]
		return current_map
	return null

func _on_yes_button_pressed() -> void:
	pass

func _on_no_button_pressed() -> void:
	$confirmation.hide()

func _on_yes_button_button_down() -> void:
	$confirmation/Sprite2D.frame = 1

func _on_yes_button_button_up() -> void:
	$confirmation/Sprite2D.frame = 0
	nx_level()

func _on_no_button_button_down() -> void:
	$confirmation/Sprite2D2.frame = 1

func _on_no_button_button_up() -> void:
	$confirmation/Sprite2D2.frame = 0
