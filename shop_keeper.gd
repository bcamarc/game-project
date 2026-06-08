extends AnimatedSprite2D

const ICON_PICK_RADIUS := 22.0
const INTERACTION_DISTANCE := 150.0  # ~3 tiles away

var shop_items: Array = []
var shop_ui: Node = null
var player: Node = null
var stats: Node = null
var is_shop_open := false

func _ready() -> void:
	shop_items = ItemDropPool.shop_items()
	find_shop_ui()

func _process(_delta: float) -> void:
	# Check if player is in range
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	
	# Toggle shop with G key if in range
	if player != null and Input.is_key_just_pressed(KEY_G):
		var distance = global_position.distance_to(player.global_position)
		if distance <= INTERACTION_DISTANCE:
			toggle_shop()

func toggle_shop() -> void:
	is_shop_open = !is_shop_open
	if shop_ui != null:
		if is_shop_open:
			shop_ui.show()
			get_tree().paused = true
		else:
			shop_ui.hide()
			get_tree().paused = false

func find_shop_ui() -> void:
	# Try to find the shop UI in the scene
	shop_ui = get_tree().get_first_node_in_group("shop_ui")
	if shop_ui == null:
		shop_ui = get_parent().get_node_or_null("Shop")

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return

	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return

	var clicked_item: Dictionary = _item_for_click(get_global_mouse_position())
	if clicked_item.is_empty():
		return

	# Get player stats and inventory
	if stats == null:
		stats = get_tree().get_first_node_in_group("stats")
	
	var inventory: Node = get_tree().get_first_node_in_group("inventory")
	
	# Check if player can afford the item
	var item_cost: int = clicked_item.get("cost", 0)
	if stats != null and stats.get_coins() < item_cost:
		print("Cannot afford item! Need %d coins, have %d" % [item_cost, stats.get_coins()])
		get_viewport().set_input_as_handled()
		return
	
	# Attempt to add item to inventory
	if inventory != null and inventory.has_method("add_item") and inventory.add_item(clicked_item):
		# Item added successfully, deduct coins
		if stats != null:
			stats.add_coin(-item_cost)
			print("Purchased item for %d coins" % item_cost)
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
		"Icon115"
	]

	for i in range(icon_names.size()):
		if i >= shop_items.size():
			break

		var icon := get_node_or_null(icon_names[i]) as Sprite2D
		if icon != null and icon.global_position.distance_to(click_position) <= ICON_PICK_RADIUS:
			return shop_items[i]

	return {}
