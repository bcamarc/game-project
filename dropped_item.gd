extends Sprite2D

@export var hover_height := 6.0
@export var hover_speed := 2.5
@export var ground_offset := -10.0

var _item_data: Dictionary
var _base_position := Vector2.ZERO
var _hover_time := 0.0
var _hover_ready := false

var item_data: Dictionary:
	get:
		return _item_data
	set(value):
		_item_data = value
		_apply_item_icon()

func _ready() -> void:
	_hover_time = randf() * TAU
	_apply_item_icon()
	call_deferred("_finalize_drop")

func _process(delta: float) -> void:
	if not _hover_ready:
		return

	_hover_time += delta * hover_speed
	position = _base_position + Vector2(0.0, sin(_hover_time) * hover_height)

func _finalize_drop() -> void:
	global_position = _snap_to_ground(global_position)
	_base_position = position
	_hover_ready = true

func _snap_to_ground(world_pos: Vector2) -> Vector2:
	var map := _get_current_map()
	if map == null:
		return world_pos

	var tile_size := map.tile_set.tile_size if map.tile_set else Vector2i(48, 48)
	var block_height := float(tile_size.y) * absf(map.global_scale.y)
	var block_width := float(tile_size.x) * absf(map.global_scale.x)

	for step in range(24):
		var probe := Vector2(world_pos.x, world_pos.y + block_height * 0.15 + float(step) * block_height * 0.5)
		if not _has_solid_tile(map, probe):
			continue

		var cell := map.local_to_map(map.to_local(probe))
		var tile_top_local := map.map_to_local(cell)
		var ground_local := Vector2(tile_top_local.x + block_width * 0.5, tile_top_local.y + ground_offset)
		return map.to_global(ground_local)

	return world_pos

func _get_current_map() -> TileMapLayer:
	var maps := get_tree().get_nodes_in_group("current_map")
	if maps.is_empty():
		return null
	return maps[0] as TileMapLayer

func _has_solid_tile(tile_layer: TileMapLayer, world_pos: Vector2) -> bool:
	var cell := tile_layer.local_to_map(tile_layer.to_local(world_pos))
	return tile_layer.get_cell_source_id(cell) != -1

func _apply_item_icon() -> void:
	if not _item_data.is_empty() and _item_data.has("icon"):
		texture = _item_data["icon"]
	else:
		texture = null

func _on_area_2d_body_entered(body: Node2D) -> void:
	if item_data.is_empty():
		return

	if not body.is_in_group("player") and not body.is_in_group("alien_player"):
		return

	var inventory := get_tree().get_first_node_in_group("inventory")
	if inventory == null or not inventory.has_method("add_item"):
		return

	if inventory.add_item(item_data):
		queue_free()
