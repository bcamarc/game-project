extends Panel
@export var slot_scene: PackedScene
@onready var grid = $GridContainer

var items = [
	{"name": "Sword", "icon": preload("res://art/golem_chastplate.png"), "type": "weapon"},
	{"name": "Shield", "icon": preload("res://art/copper_chestplate.png"), "type": "chestplate"},
	{"name": "Potion", "icon": preload("res://art/golem_helmet.png"), "type": "helmet"}
]

func _ready():
	build_inventory()

func build_inventory():
	for i in range(items.size()):
		var slot = slot_scene.instantiate()
		slot.set_item(items[i])
		grid.add_child(slot)
