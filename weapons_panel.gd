extends Panel
@export var slot_scene: PackedScene
@onready var grid = $GridContainer

var items = []
var slot_count := 20

func _ready():
	build_inventory()

func build_inventory():
	for i in range(slot_count):
		var slot = slot_scene.instantiate()
		grid.add_child(slot)
		if i < items.size():
			slot.set_item(items[i])

func add_item(item_data: Dictionary) -> bool:
	for slot in grid.get_children():
		if slot.has_method("set_item") and slot.get("item") == null:
			slot.set_item(item_data)
			return true
	return false

func consume_first_consumable() -> bool:
	for slot in grid.get_children():
		if consume_slot(slot):
			return true

	return false

func consume_hovered_consumable() -> bool:
	var hovered_slot := _slot_under_mouse()
	if hovered_slot == null:
		return false

	return consume_slot(hovered_slot)

func consume_slot(slot: Node) -> bool:
	if slot == null or not slot.has_method("set_item"):
		return false

	var item = slot.get("item")
	if item == null or not (item is Dictionary):
		return false

	if item.get("type", "") != "consumable":
		return false

	if _use_consumable(item):
		slot.set_item(null)
		return true

	return false

func _use_consumable(item: Dictionary) -> bool:
	var amount := float(item.get("use_amount", 0))
	if amount <= 0.0:
		return false

	var stats = _resolve_stats()
	if stats == null:
		return false

	match str(item.get("use_effect", "")):
		"health":
			if stats.total_health >= stats.max_health:
				return false
			stats.add_hp(amount)
			return true
		"magic", "mana", "mp":
			if stats.total_magic >= stats.max_magic:
				return false
			stats.add_mp(amount)
			return true
		_:
			return false

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

func _slot_under_mouse() -> Node:
	var mouse_position := get_global_mouse_position()
	for slot in grid.get_children():
		if slot is Control and slot.get_global_rect().has_point(mouse_position):
			return slot

	return null
