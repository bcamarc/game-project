extends CanvasLayer

var coins := 0
var exp := 0
var level := 1
var expNeeded := 10.0
var fireSpellDamage := 10
var thunderSpellDamage := 37
var iceSpellDamage := 10
var highest_level := 1
var world_level := 1
var strength := 0
var vitality := 0
var intellegience := 0
var dexterity := 0
var total_strength := 0
var total_vitality := 0
var total_intellegience := 0
var total_dexterity := 0
var skillPoints := 50
var base_health := 100
var base_damage := 17
var base_defense := 5
var base_speed := 250
var base_magic := 50.0
var total_health := 1.0
var max_health := 1.0
var total_damage := 0
var total_defense := 0
var total_speed := 0
var total_magic := 0.0
var max_magic := 0.0
var attack_speed := 1.0
var health_regen_per_second := 0.4
#var wizard_mana_regen_per_second := 0.15*max_magic
var wizard_mana_regen_per_second := 7.5
var testMapScene = preload("res://testmap.tscn")
var townScene = preload("res://town.tscn")
var equipment = {"weapon": null, "helmet": null, "chestplate": null, "boots": null}
signal player_changed(player_name: String)

var current_player: String = "knight"
@onready var skill_unlock_label: Label = $Control/Panel/SkillUnlockLabel

func set_player(player_name: String) -> void:
	current_player = player_name
	print("Stats changed to:", current_player) 
	_update_skill_unlock_label()
	player_changed.emit(player_name)

func _ready() -> void:
	add_to_group("stats")
	check_exp()
	hide()
	update_stats()
	total_magic = max_magic
	total_health = max_health
	_update_skill_unlock_label()

func on_next_level(tile_x, tile_y):
	world_level = min(world_level + 1, 4)
	var new_map = testMapScene.instantiate()
	get_parent().add_child(new_map)
	if new_map.has_method("set_gate_data"):
		new_map.set_gate_data(tile_x, tile_y, world_level)

func enter_town(_tile_x, _tile_y):
	var parent := get_parent()
	if parent == null:
		return

	var existing_town := parent.get_node_or_null("Town")
	if existing_town != null:
		return

	var town = townScene.instantiate()
	town.name = "Town"
	parent.add_child(town)

func _process(_delta):
	if Input.is_action_just_released("stats"):
		visible = !visible
	_update_skill_unlock_label()
	_apply_passive_regen(_delta)

func add_coin(a):
	coins += a

func get_coins() -> int:
	return coins

func can_afford(cost: int) -> bool:
	return coins >= cost

func spend_coins(cost: int) -> bool:
	if not can_afford(cost):
		return false

	coins -= cost
	return true

func check_exp():
	if exp >= expNeeded:
		level += 1
		exp = 0
		expNeeded = expNeeded * 1.2
		skillPoints += 2
		_update_skill_unlock_label()

func add_exp(a):
	exp += a
	check_exp()

func add_hp(a):
	total_health = clamp(total_health + a, 0, max_health)

func add_mp(a):
	total_magic = clamp(total_magic + a, 0, max_magic)

func get_strength() -> int:
	return strength

func _on_button_pressed():
	if skillPoints > 0:
		strength += 1
		skillPoints -= 1
		update_stats()

func _on_vit_button_pressed():
	if skillPoints > 0:
		vitality += 1
		skillPoints -= 1
		update_stats()

func _on_int_button_pressed():
	if skillPoints > 0:
		intellegience += 1
		skillPoints -= 1
		update_stats()

func _on_int_button_2_pressed():
	if skillPoints > 0:
		dexterity += 1
		skillPoints -= 1
		update_stats()

func update_stats():
	var bonus_strength := 0
	var bonus_vitality := 0
	var bonus_intellegience := 0
	var bonus_dexterity := 0
	var bonus_magic := 0

	for item in equipment.values():
		if item != null:
			if not ItemDropPool.can_player_use_item(current_player, item):
				continue
			bonus_strength += int(item.get("strength", 0))
			bonus_vitality += int(item.get("vitality", 0))
			bonus_intellegience += int(item.get("intellegience", item.get("intelligence", 0)))
			bonus_dexterity += int(item.get("dexterity", 0))

	var effective_strength := strength + bonus_strength
	var effective_vitality := vitality + bonus_vitality
	var effective_intellegience := intellegience + bonus_intellegience
	var effective_dexterity := dexterity + bonus_dexterity
	total_strength = effective_strength
	total_vitality = effective_vitality
	total_intellegience = effective_intellegience
	total_dexterity = effective_dexterity

	max_health = base_health + effective_vitality * 10
	total_damage = base_damage + effective_strength * 2
	total_defense = base_defense + effective_vitality * 1
	total_speed = base_speed + effective_dexterity * 5
	max_magic = base_magic + effective_intellegience * 2
	attack_speed = (effective_dexterity / 100.0) + 1.0

	for item in equipment.values():
		if item != null:
			if not ItemDropPool.can_player_use_item(current_player, item):
				continue
			if item.has("damage"):
				total_damage += int(item["damage"])
			if item.has("defense"):
				total_defense += int(item["defense"])
			if item.has("speed"):
				total_speed += int(item["speed"])
			if item.has("magic"):
				bonus_magic += int(item["magic"])
	max_magic += bonus_magic
	wizard_mana_regen_per_second = 0.15*(max_magic)
	total_health = clamp(total_health, 0, max_health)
	total_magic = clamp(total_magic, 0, max_magic)
	_update_skill_unlock_label()

func _update_skill_unlock_label() -> void:
	if skill_unlock_label == null:
		return

	if level < 5:
		skill_unlock_label.text = ""
		return

	match current_player:
		"huntress":
			skill_unlock_label.text = "Skill Unlocked:\nTriple Shot"
		"wizard":
			skill_unlock_label.text = "Skill Unlocked:\nHoly Spell"
		_:
			skill_unlock_label.text = "Skill Unlocked:\nShield"

func _apply_passive_regen(delta: float) -> void:
	if total_health > 0.0 and total_health < max_health:
		add_hp(health_regen_per_second * delta)

	if get_tree().get_first_node_in_group("wizard") != null and total_magic < max_magic:
		add_mp(wizard_mana_regen_per_second * delta)


func _on_close_button_pressed() -> void:
	hide()
