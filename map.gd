extends Node2D

@export var knight_scene: PackedScene
@export var huntress_scene: PackedScene
@export var wizard_scene: PackedScene
@onready var spawn_point: Marker2D = $PlayerSpawn

var player_instance: CharacterBody2D

func _ready() -> void:
	print("Map ready, current player =", Stats.current_player)
	Stats.player_changed.connect(_on_player_changed)
	spawn_selected_player()

func _on_player_changed(name: String) -> void:
	print("Map received player_changed:", name)
	call_deferred("spawn_selected_player")

func spawn_selected_player() -> void:
	if player_instance:
		player_instance.queue_free()

	var selected_scene: PackedScene
	match Stats.current_player:
		"knight":
			selected_scene = knight_scene
		"huntress":
			selected_scene = huntress_scene
		"wizard":
			selected_scene = wizard_scene
		_:
			selected_scene = knight_scene

	if selected_scene == null:
		push_error("Selected scene is null for " + Stats.current_player)
		return

	player_instance = selected_scene.instantiate() as CharacterBody2D
	player_instance.global_position = spawn_point.global_position
	add_child(player_instance)
