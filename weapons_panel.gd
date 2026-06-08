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
		if not slot.has_method("set_item"):
			continue

		var item = slot.get("item")
		if item == null or not (item is Dictionary):
			continue

		if item.get("type", "") != "consumable":
			continue

		if _use_consumable(item):
			slot.set_item(null)
			return true

	return false

func _use_consumable(item: Dictionary) -> bool:
	var amount := float(item.get("use_amount", 0))
	if amount <= 0.0:
		return false

	match str(item.get("use_effect", "")):
		"health":
			if Stats.total_health >= Stats.max_health:
				return false
			Stats.add_hp(amount)
			return true
		"magic", "mana", "mp":
			if Stats.total_magic >= Stats.max_magic:
				return false
			Stats.add_mp(amount)
			return true
		_:
			return false
