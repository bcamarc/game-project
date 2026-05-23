extends CanvasLayer

var coins := 0
var exp := 0
var level := 1
var expNeeded := 10.0
var fireSpellDamage := 10
var thunderSpellDamage := 37
var iceSpellDamage := 10
var highest_level := 1
var strength := 0
var vitality := 0
var intellegience := 0
var dexterity := 0
var skillPoints := 50
var base_health := 100
var base_damage := 10
var base_defense := 5
var base_speed := 250
var base_magic := 50
var total_health := 1
var max_health := 1
var total_damage := 0
var total_defense := 0
var total_speed := 0
var total_magic := 0
var max_magic := 0
var attack_speed := 1.0
var testMapScene = preload("res://testmap.tscn")
var equipment = {"weapon": null, "helmet": null, "chest": null, "boots": null}
signal player_changed(player_name: String)

var current_player: String = "knight"

func set_player(player_name: String) -> void:
	current_player = player_name
	print("Stats changed to:", current_player) 
	player_changed.emit(player_name)

func _ready() -> void:
	add_to_group("stats")
	check_exp()
	hide()
	update_stats()
	total_magic = max_magic
	total_health = max_health

func on_next_level(tile_x, tile_y):
	var new_map = testMapScene.instantiate()
	get_parent().add_child(new_map)
	if new_map.has_method("set_gate_data"):
		new_map.set_gate_data(tile_x, tile_y)

func _process(_delta):
	check_exp()
	if Input.is_action_just_released("stats"):
		visible = !visible
	update_stats()

func add_coin(a):
	coins += a

func get_coins() -> int:
	return coins

func check_exp():
	if exp >= expNeeded:
		level += 1
		exp = 0
		expNeeded = expNeeded * 1.2
		skillPoints += 2

func add_exp(a):
	exp += a

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

func _on_vit_button_pressed():
	if skillPoints > 0:
		vitality += 1
		skillPoints -= 1

func _on_int_button_pressed():
	if skillPoints > 0:
		intellegience += 1
		skillPoints -= 1

func _on_int_button_2_pressed():
	if skillPoints > 0:
		dexterity += 1
		skillPoints -= 1

func update_stats():
	max_health = base_health + vitality * 10
	total_damage = base_damage + strength * 2
	total_defense = base_defense + vitality * 1
	total_speed = base_speed + dexterity * 2
	max_magic = base_magic + intellegience * 2
	attack_speed = (dexterity / 100.0) + 1.0
	var bonus_magic := 0
	for item in equipment.values():
		if item != null:
			if "damage" in item: total_damage += item.damage
			if "defense" in item: total_defense += item.defense
			if "speed" in item: total_speed += item.speed
			if "magic" in item: bonus_magic += item.magic
	max_magic += bonus_magic
	total_health = clamp(total_health, 0, max_health)
	total_magic = clamp(total_magic, 0, max_magic)


func _on_close_button_pressed() -> void:
	hide()
