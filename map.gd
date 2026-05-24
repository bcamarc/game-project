extends Node2D

@export var knight_scene: PackedScene = preload("res://knight.tscn")
@export var huntress_scene: PackedScene = preload("res://huntress.tscn")
@export var wizard_scene: PackedScene = preload("res://wizard.tscn")

var player_instance: CharacterBody2D
var persistent_camera: Camera2D
var banner_background: Node2D

func _ready() -> void:
	Stats.player_changed.connect(_on_player_changed)
	player_instance = _find_existing_player()
	if player_instance:
		_capture_persistent_overlay(player_instance)
	_ensure_selected_player_loaded()

func _on_player_changed(_name: String) -> void:
	call_deferred("_ensure_selected_player_loaded")

func _swap_to_selected_player() -> void:
	var selected_scene := _scene_for_player(Stats.current_player)
	if selected_scene == null:
		push_error("No player scene found for: " + Stats.current_player)
		return

	var spawn_position := _get_spawn_position()
	var new_player := selected_scene.instantiate() as CharacterBody2D
	if new_player == null:
		push_error("Selected scene root is not CharacterBody2D: " + selected_scene.resource_path)
		return

	if player_instance and is_instance_valid(player_instance):
		_capture_persistent_overlay(player_instance)
		player_instance.queue_free()

	player_instance = new_player
	add_child(player_instance)
	player_instance.global_position = spawn_position
	_capture_persistent_overlay(player_instance)

func _ensure_selected_player_loaded() -> void:
	var selected_scene := _scene_for_player(Stats.current_player)
	if selected_scene == null:
		push_error("No player scene found for: " + Stats.current_player)
		return

	if player_instance == null or not is_instance_valid(player_instance):
		_swap_to_selected_player()
		return

	if player_instance.scene_file_path != selected_scene.resource_path:
		_swap_to_selected_player()
	else:
		_capture_persistent_overlay(player_instance)

func _scene_for_player(player_name: String) -> PackedScene:
	match player_name:
		"knight":
			return knight_scene
		"huntress":
			return huntress_scene
		"wizard":
			return wizard_scene
		_:
			return knight_scene

func _find_existing_player() -> CharacterBody2D:
	var existing := get_tree().get_first_node_in_group("player")
	if existing is CharacterBody2D:
		return existing as CharacterBody2D

	var knight_node := get_node_or_null("Knight")
	if knight_node is CharacterBody2D:
		return knight_node as CharacterBody2D

	return null

func _get_spawn_position() -> Vector2:
	if player_instance and is_instance_valid(player_instance):
		return player_instance.global_position

	var player_spawn := get_node_or_null("PlayerSpawn")
	if player_spawn is Marker2D:
		return (player_spawn as Marker2D).global_position

	return Vector2.ZERO

func _capture_persistent_overlay(player: CharacterBody2D) -> void:
	if persistent_camera == null or not is_instance_valid(persistent_camera):
		var cam := player.get_node_or_null("Camera2D")
		if cam is Camera2D:
			persistent_camera = cam as Camera2D
			_reparent_preserving_global_transform(persistent_camera, self)

	if banner_background == null or not is_instance_valid(banner_background):
		var background := player.get_node_or_null("Sprite2D")
		if background is Node2D:
			banner_background = background as Node2D

	if persistent_camera and is_instance_valid(persistent_camera):
		if banner_background and is_instance_valid(banner_background):
			_reparent_preserving_global_transform(banner_background, persistent_camera)
			# Keep wooden banner behind HUD widgets like bars/labels.
			persistent_camera.move_child(banner_background, 0)
			banner_background.z_as_relative = false
			banner_background.z_index = -10

		persistent_camera.enabled = true
		persistent_camera.make_current()

func _reparent_preserving_global_transform(node: Node2D, new_parent: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	if node.get_parent() == new_parent:
		return

	var old_global_transform := node.global_transform

	if node.get_parent():
		node.get_parent().remove_child(node)
	new_parent.add_child(node)

	node.global_transform = old_global_transform
