extends Node2D

@export var spawn_offset := Vector2(160, 0)

var mobs := []

var zombie_scene: PackedScene = preload("res://zombie.tscn")
var golem_scene: PackedScene = preload("res://golem.tscn")
var shadow_scene: PackedScene = preload("res://shadow_knight.tscn")

onready var spawn_point: Node2D = $SpawnPoint
onready var info_label: Label = $CanvasLayer/Label

func _ready() -> void:
	update_label()

func _input(event) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var k := event.keycode
		# keys: '1'..'5' ASCII 49..53
		if k == 49:
			spawn_mob(zombie_scene)
		elif k == 50:
			spawn_mob(golem_scene)
		elif k == 51:
			spawn_mob(shadow_scene)
		elif k == 52:
			clear_mobs()
		elif k == 53:
			for i in range(5):
				spawn_mob(zombie_scene, Vector2(32 * i, 0))
		update_label()

func _unhandled_input(event) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# spawn a zombie at mouse position
		var mouse_pos := get_global_mouse_position()
		spawn_mob(zombie_scene, mouse_pos - spawn_point.global_position)
		update_label()

func spawn_mob(scene: PackedScene, offset: Vector2 = Vector2.ZERO) -> void:
	if scene == null:
		return
	var inst = scene.instantiate()
	var parent = get_tree().current_scene
	parent.add_child(inst)
	inst.global_position = spawn_point.global_position + offset
	mobs.append(inst)
	# Connect a cleanup handler so we remove it from mobs when it leaves the tree.
	if inst.has_method("connect"):
		# bind the instance so we know which node was removed
		inst.connect("tree_exited", Callable(self, "_on_mob_removed"), [inst])

func _on_mob_removed(node) -> void:
	if mobs.has(node):
		mobs.erase(node)
	update_label()

func clear_mobs() -> void:
	for m in mobs.duplicate():
		if is_instance_valid(m):
			m.queue_free()
	mobs.clear()
	update_label()

func update_label() -> void:
	var text := "Test Area - Spawn Controls\n"
	text += "1 - spawn zombie\n"
	text += "2 - spawn golem\n"
	text += "3 - spawn shadow knight\n"
	text += "4 - clear mobs\n"
	text += "5 - spawn 5 zombies\n"
	text += "Left click - spawn zombie at mouse\n\n"
	text += "Active mobs: %d" % mobs.size()
	info_label.text = text
