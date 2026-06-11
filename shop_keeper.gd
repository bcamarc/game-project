extends AnimatedSprite2D

const ICON_PICK_RADIUS := 22.0
const SHOP_INTERACT_RADIUS := 130.0
const SHOP_CONTENT_NAMES := [
	"Sprite2D",
	"Mediavel",
	"Icon301",
	"Icon306",
	"Icon307",
	"Icon302",
	"Icon305",
	"Icon310",
	"Icon95",
	"Icon115",
	"1Px",
	"Icon175",
	"Icon195",
	"Icon235",
	"Label",
	"Coin",
	"Coin2",
	"Mediavel2",
	"Label2",
	"Label3",
	"Label4",
	"Label5",
	"Label6",
	"Label7",
	"Label8",
	"Label9",
	"Label10",
	"Label11",
	"Label12",
	"Label13"
]

var shop_items: Array = []
var shop_open := false
var coins_label: Label = null

func _ready() -> void:
	shop_items = ItemDropPool.shop_items()
	_ensure_coins_label()
	_set_shop_open(false)

func _process(_delta: float) -> void:
	if shop_open and not _is_player_near():
		_set_shop_open(false)
	if shop_open:
		_update_coins_label()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_G:
		if _is_player_near():
			_set_shop_open(not shop_open)
			get_viewport().set_input_as_handled()
		return

	if not (event is InputEventMouseButton):
		return

	if not shop_open:
		return

	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return

	var clicked_item: Dictionary = _item_for_click(get_global_mouse_position())
	if clicked_item.is_empty():
		return

	var stats := _resolve_stats()
	if stats == null:
		return

	var cost := int(clicked_item.get("cost", 0))
	if stats.has_method("can_afford") and not stats.can_afford(cost):
		get_viewport().set_input_as_handled()
		return

	var inventory: Node = get_tree().get_first_node_in_group("inventory")
	if inventory != null and inventory.has_method("add_item") and inventory.add_item(clicked_item):
		if stats.has_method("spend_coins"):
			stats.spend_coins(cost)
		get_viewport().set_input_as_handled()

func _item_for_click(click_position: Vector2) -> Dictionary:
	var icon_names: Array = [
		"Icon301",
		"Icon302",
		"Icon305",
		"Icon306",
		"Icon307",
		"Icon310",
		"Icon95",
		"Icon115",
		"Icon175",
		"Icon195",
		"Icon235"
	]

	for i in range(icon_names.size()):
		if i >= shop_items.size():
			break

		var icon := get_node_or_null(icon_names[i]) as Sprite2D
		if icon != null and icon.global_position.distance_to(click_position) <= ICON_PICK_RADIUS:
			return shop_items[i]

	return {}

func _set_shop_open(is_open: bool) -> void:
	shop_open = is_open
	_ensure_coins_label()
	_update_coins_label()
	for child_name in SHOP_CONTENT_NAMES:
		var child := get_node_or_null(child_name) as CanvasItem
		if child != null:
			child.visible = shop_open
	if coins_label != null:
		coins_label.visible = shop_open

func _is_player_near() -> bool:
	var player := get_tree().get_first_node_in_group("alien_player") as Node2D
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return false

	return global_position.distance_to(player.global_position) <= SHOP_INTERACT_RADIUS

func _resolve_stats() -> Node:
	var scene := get_tree().current_scene
	if scene != null:
		var scene_stats := scene.get_node_or_null("Stats")
		if scene_stats != null:
			return scene_stats

	var stats_node := get_tree().get_first_node_in_group("stats")
	if stats_node != null:
		return stats_node

	return get_node_or_null("/root/Stats")

func _ensure_coins_label() -> void:
	if coins_label != null and is_instance_valid(coins_label):
		return

	coins_label = get_node_or_null("PlayerCoinsLabel") as Label
	if coins_label != null:
		return

	coins_label = Label.new()
	coins_label.name = "PlayerCoinsLabel"
	coins_label.offset_left = 51.0
	coins_label.offset_top = -142.0
	coins_label.offset_right = 177.0
	coins_label.offset_bottom = -119.0
	coins_label.scale = Vector2(1.25, 1.25)

	var title_label := get_node_or_null("Label") as Label
	if title_label != null:
		coins_label.add_theme_font_override("font", title_label.get_theme_font("font"))

	add_child(coins_label)

func _update_coins_label() -> void:
	if coins_label == null:
		return

	var stats := _resolve_stats()
	if stats != null and stats.has_method("get_coins"):
		coins_label.text = "Coins: " + str(stats.get_coins())
	else:
		coins_label.text = "Coins: 0"
