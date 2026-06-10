extends Node2D

const EXIT_GATE_POSITION := Vector2(500.0, 25.0)
const TOWN_PLAYER_SCALE := Vector2.ONE
const TOWN_CAMERA_ZOOM := Vector2(3.0, 3.0)
const NEXT_LEVEL_GATE_SCALE := Vector2(0.45, 0.45)
const NEXT_LEVEL_PROMPT_POSITION := Vector2(5.0, -18.0)
const NEXT_LEVEL_PROMPT_SCALE := Vector2(0.55, 0.55)

var gateScene = preload("res://gate1.tscn")
var town_player: Node2D = null
var adventure_player: Node2D = null
var adventure_player_was_visible := true
var adventure_player_process_mode := Node.PROCESS_MODE_INHERIT
var adventure_player_was_in_player_group := false
var adventure_player_was_in_alien_player_group := false
var town_camera: Camera2D = null
var original_camera_zoom := Vector2.ONE
var has_original_camera_zoom := false

@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var preview_player: Node2D = $Knight

func _ready() -> void:
	var spawn_position := _town_spawn_position()
	_setup_town_player(spawn_position)

	if tile_map != null:
		tile_map.add_to_group("current_map")

	_hide_adventure_player()
	_apply_town_camera()
	_spawn_next_level_gate()

func _process(_delta: float) -> void:
	_apply_town_camera()

func on_next_level() -> void:
	_restore_adventure_player()
	queue_free()

func _town_spawn_position() -> Vector2:
	if preview_player != null:
		return preview_player.global_position

	return to_global(Vector2(70.0, 30.0))

func _setup_town_player(spawn_position: Vector2) -> void:
	if preview_player == null:
		return

	town_player = preview_player
	town_player.scale = TOWN_PLAYER_SCALE
	town_player.global_position = spawn_position
	town_player.visible = true
	town_player.process_mode = Node.PROCESS_MODE_INHERIT
	if not town_player.is_in_group("player"):
		town_player.add_to_group("player")

func _find_current_player() -> Node2D:
	for group_name in ["alien_player", "player"]:
		for node in get_tree().get_nodes_in_group(group_name):
			if node is Node2D and not is_ancestor_of(node):
				return node as Node2D

	return null

func _hide_adventure_player() -> void:
	adventure_player = _find_current_player()
	if adventure_player == null:
		return

	adventure_player_was_visible = adventure_player.visible
	adventure_player_process_mode = adventure_player.process_mode
	adventure_player_was_in_player_group = adventure_player.is_in_group("player")
	adventure_player_was_in_alien_player_group = adventure_player.is_in_group("alien_player")
	adventure_player.visible = false
	adventure_player.process_mode = Node.PROCESS_MODE_DISABLED
	adventure_player.remove_from_group("player")
	adventure_player.remove_from_group("alien_player")

func _spawn_next_level_gate() -> void:
	var gate = gateScene.instantiate()
	gate.name = "NextLevelGate"
	gate.top_level = true
	gate.set("destination", "next_level")
	gate.set("prompt_text", "would you like to go\n to the next level?")
	gate.set("falling", false)
	gate.set("current_map", tile_map)
	add_child(gate)
	gate.scale = NEXT_LEVEL_GATE_SCALE
	gate.global_position = to_global(EXIT_GATE_POSITION)

	var confirmation := gate.get_node_or_null("confirmation") as Node2D
	if confirmation != null:
		confirmation.position = NEXT_LEVEL_PROMPT_POSITION
		confirmation.scale = NEXT_LEVEL_PROMPT_SCALE

func _apply_town_camera() -> void:
	town_camera = get_viewport().get_camera_2d()
	if town_camera == null:
		return

	if not has_original_camera_zoom:
		original_camera_zoom = town_camera.zoom
		has_original_camera_zoom = true
	town_camera.zoom = TOWN_CAMERA_ZOOM
	if "target" in town_camera and town_player != null:
		town_camera.set("target", town_player)

func _restore_adventure_player() -> void:
	if adventure_player == null or not is_instance_valid(adventure_player):
		return

	if town_player != null and is_instance_valid(town_player):
		adventure_player.global_position = town_player.global_position

	adventure_player.visible = adventure_player_was_visible
	adventure_player.process_mode = adventure_player_process_mode
	if adventure_player_was_in_player_group and not adventure_player.is_in_group("player"):
		adventure_player.add_to_group("player")
	if adventure_player_was_in_alien_player_group and not adventure_player.is_in_group("alien_player"):
		adventure_player.add_to_group("alien_player")
	if town_camera != null and is_instance_valid(town_camera):
		town_camera.zoom = original_camera_zoom
		if "target" in town_camera:
			town_camera.set("target", adventure_player)
