#extends CanvasLayer
#func _ready() -> void:
	#hide()
#func _process(delta: float) -> void:
	#if (Input.is_action_just_released("inventory")):
		#if (visible):
			#hide()
		#else:
			#show()
	#if (visible):
		#get_tree().paused = true
	#else:
		#get_tree().paused = false
extends CanvasLayer

const PLAYER_SCENES = {
	"knight": preload("res://knight.tscn"),
	"huntress": preload("res://huntress.tscn"),
	"wizard": preload("res://wizard.tscn"),
}

const PLAYER_PREVIEW_SCALES = {
	"knight": Vector2(6.6071424, 6.3513513),
	"huntress": Vector2(3.2, 3.2),
	"wizard": Vector2(3.2, 3.2),
}

@onready var weapons_panel = $WeaponsPanel
@onready var preview_player: Node2D = $Knight

var preview_player_name := ""

func _ready() -> void:
	add_to_group("inventory")
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	Stats.player_changed.connect(_on_player_changed)
	_refresh_player_preview()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("inventory"):
		toggle_menu()
		get_viewport().set_input_as_handled()
	elif visible and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_SPACE:
		consume_hovered_consumable()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_9:
		consume_first_consumable()
		get_viewport().set_input_as_handled()

func toggle_menu() -> void:
	visible = !visible
	if visible:
		_refresh_player_preview()
		_refresh_equipment_slots()
	get_tree().paused = visible

func add_item(item_data: Dictionary) -> bool:
	if weapons_panel != null and weapons_panel.has_method("add_item"):
		return weapons_panel.add_item(item_data)
	return false

func consume_first_consumable() -> bool:
	if weapons_panel != null and weapons_panel.has_method("consume_first_consumable"):
		return weapons_panel.consume_first_consumable()
	return false

func consume_hovered_consumable() -> bool:
	if weapons_panel != null and weapons_panel.has_method("consume_hovered_consumable"):
		return weapons_panel.consume_hovered_consumable()
	return false

func _on_player_changed(_player_name: String) -> void:
	_refresh_player_preview()
	_refresh_equipment_slots()

func _refresh_player_preview() -> void:
	if preview_player_name == Stats.current_player and preview_player != null and is_instance_valid(preview_player):
		return

	var player_scene: PackedScene = PLAYER_SCENES.get(Stats.current_player, PLAYER_SCENES["knight"])
	var new_preview := player_scene.instantiate() as Node2D
	if new_preview == null:
		return

	new_preview.name = "PlayerPreview"
	new_preview.position = Vector2(252, 331)
	new_preview.scale = PLAYER_PREVIEW_SCALES.get(Stats.current_player, PLAYER_PREVIEW_SCALES["knight"])
	if new_preview is CollisionObject2D:
		(new_preview as CollisionObject2D).collision_layer = 0
		(new_preview as CollisionObject2D).collision_mask = 0
	new_preview.set_script(null)
	_prepare_preview_node(new_preview)

	if preview_player != null and is_instance_valid(preview_player):
		preview_player.queue_free()

	preview_player = new_preview
	preview_player_name = Stats.current_player
	add_child(preview_player)
	move_child(preview_player, get_node("WeaponsPanel").get_index())

func _prepare_preview_node(node: Node) -> void:
	if node is CollisionObject2D:
		(node as CollisionObject2D).collision_layer = 0
		(node as CollisionObject2D).collision_mask = 0
	elif node is CollisionShape2D:
		(node as CollisionShape2D).disabled = true
	elif node is Timer:
		(node as Timer).stop()
		(node as Timer).autostart = false
	elif node is AudioStreamPlayer2D:
		(node as AudioStreamPlayer2D).stop()
	elif node is AnimatedSprite2D:
		_play_idle_animation(node as AnimatedSprite2D)

	for child in node.get_children():
		_prepare_preview_node(child)

func _play_idle_animation(sprite: AnimatedSprite2D) -> void:
	if sprite.sprite_frames == null:
		return

	var idle_names := ["idle", "Idle", "menu"]
	for idle_name in idle_names:
		if sprite.sprite_frames.has_animation(idle_name):
			sprite.play(idle_name)
			return

func _refresh_equipment_slots() -> void:
	_refresh_equipment_slots_in(self)

func _refresh_equipment_slots_in(node: Node) -> void:
	if node.has_method("refresh_from_stats"):
		node.refresh_from_stats()

	for child in node.get_children():
		_refresh_equipment_slots_in(child)
