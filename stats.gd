extends CanvasLayer
var coins := 0
var exp := 0
var level:=1
var expNeeded := 10

var fireSpellDamage := 10
var thunderSpellDamage:= 37
var iceSpellDamage := 10
var highest_level := 1


var strength := 0
var vitality := 0
var intellegience := 0
var dexterity := 0
var skillPoints := 5

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

var equipment = {
	"weapon": null,
	"helmet": null,
	"chest": null,
	"boots": null
}

func _ready() -> void:
	check_exp()
	hide()
	update_stats()
	total_magic = max_magic
	total_health = max_health
	
	
func _process(delta: float) -> void:
	check_exp()
	if (Input.is_action_just_released("stats")):
		if (visible):
			hide()
		else:
			show()
	update_stats()

	
	

func add_coin(a):
	coins += a
	#print(coins)
func get_coins() -> int:
	return coins
func check_exp():
	if exp>=expNeeded:
		level+=1
		exp = 0
		expNeeded = expNeeded *1.2
		skillPoints += 2
		print("levelup")
func add_exp(a):
	exp += a
func add_hp(a):
	if (total_health+a > max_health):
		total_health = max_health
		return
	total_health+= a
func add_mp(a):
	if (total_magic+a > max_magic):
		total_magic = max_magic
		return
	total_magic += a
func get_strength() -> int:
	return strength

func _on_button_pressed() -> void:
	if (skillPoints > 0):
		strength +=1
		skillPoints -= 1

	


func _on_vit_button_pressed() -> void:
	if (skillPoints > 0):
		vitality +=1
		skillPoints -= 1


func _on_int_button_pressed() -> void:
	if (skillPoints > 0):
		intellegience +=1
		skillPoints -= 1


func _on_int_button_2_pressed() -> void:
	if (skillPoints > 0):
		dexterity +=1
		skillPoints -= 1



func update_stats():
	max_health = base_health + vitality * 10
	total_damage = base_damage + strength * 2
	total_defense = base_defense + vitality * 1
	total_speed = base_speed + dexterity * 2
	max_magic = base_magic + intellegience * 2
	attack_speed = (dexterity/100) +1

	for item in equipment.values():
		if item != null:
			if "damage" in item:
				total_damage += item.damage
			if "defense" in item:
				total_defense += item.defense
			if "speed" in item:
				total_speed += item.speed
			if "magic" in item:
				total_magic += item.magic


func _on_close_button_pressed() -> void:
	hide()
