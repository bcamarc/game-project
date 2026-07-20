extends Node

const BONUS_EXP := 15
const BONUS_LOOT_ROLLS := 1

var enemy: Node2D
var modifier_name := ""
var reward_given := false
var dropped_item_scene: PackedScene = preload("res://dropped_item.tscn")

func _ready() -> void:
	call_deferred("_activate")

func _activate() -> void:
	enemy = get_parent() as Node2D
	if enemy == null:
		queue_free()
		return

	enemy.add_to_group("elite")
	if randf() < 0.5:
		modifier_name = "Frenzied"
		_multiply_property("health", 1.4)
		_multiply_property("speed", 1.35)
		_multiply_property("attack_damage", 1.2)
	else:
		modifier_name = "Juggernaut"
		_multiply_property("health", 2.0)
		_multiply_property("speed", 0.75)
		_multiply_property("attack_damage", 1.35)

	enemy.scale *= Vector2(1.15, 1.15)
	_add_elite_label()
	if enemy.has_signal("death"):
		enemy.connect("death", Callable(self, "_on_enemy_death"))

func _multiply_property(property_name: String, multiplier: float) -> void:
	if property_name in enemy:
		enemy.set(property_name, float(enemy.get(property_name)) * multiplier)

func _add_elite_label() -> void:
	var label := Label.new()
	label.name = "EliteLabel"
	label.text = "ELITE\n" + modifier_name
	label.position = Vector2(-34.0, -78.0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(68.0, 34.0)
	label.add_theme_color_override("font_color", Color("ffd84d"))
	label.add_theme_color_override("font_shadow_color", Color("2a1600"))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	enemy.add_child(label)

func _on_enemy_death(_x: Variant, _y: Variant) -> void:
	if reward_given:
		return
	reward_given = true

	var stats := get_node_or_null("/root/Stats")
	if stats != null and stats.has_method("add_exp"):
		stats.add_exp(BONUS_EXP)

	var map := enemy.get_parent()
	if map == null:
		return

	for index in range(BONUS_LOOT_ROLLS):
		var item_data := ItemDropPool.roll_monster_item()
		if item_data.is_empty():
			continue
		var item_instance := dropped_item_scene.instantiate()
		item_instance.item_data = item_data
		map.add_child(item_instance)
		item_instance.global_position = enemy.global_position + Vector2(float(index * 22), -18.0)
