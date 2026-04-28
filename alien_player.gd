extends CharacterBody2D

var jump_force := 400
var gravity := 600
var jumpCount := 0
var jumpEnded := false
var alienPos := Vector2.ZERO

var mana := 100
var fireSpell := load("res://fire_spell.tscn")
var thunderSpell := load("res://thunder_spell.tscn")
var iceSpell := load("res://ice_spell.tscn")
var holySpell := load("res://holySpell.tscn")
var count = 0
var count2 = 0
var count3 = 0
var count4 = 0
var count5 = 500

var boosted = false
var able_to_attack := false
@onready var sprite = get_node("./KnightSprite")

func _ready() -> void:
	print("aoiefawoifn")
	pass


func _physics_process(delta):

	alienPos = global_position
	count += 1
	count2 += 1
	count3 += 1
	count4 += 1
	count5 += 1
	add_to_group("player")
	add_to_group("alien_player")
	var direction := Vector2.ZERO
	if Input.is_action_pressed("Left"):
		direction.x -= 1
		sprite.flip_h = true
	if Input.is_action_pressed("right"):
		direction.x += 1
		sprite.flip_h = false
	velocity.x = direction.x * get_node("../Stats").total_speed

	if is_on_floor():
		velocity.y = 0
		jumpCount = 0
		jumpEnded = false
		if Input.is_action_just_pressed("jump"):
			velocity.y = -jump_force
			jumpCount = 1
			jumpEnded = false
			if ( not sprite.animation == "attack1"):
				sprite.play("jump_start")
		elif direction.x != 0:
			if not sprite.is_playing():
				sprite.play("Run")
		else:
			if not sprite.is_playing():
				sprite.play("Idle")
	else:
		velocity.y += gravity * delta
		if jumpCount == 1 and not jumpEnded and velocity.y > 0:
			if ( not sprite.animation == "attack1"):
				sprite.play("jump_end")
			jumpEnded = true
		elif direction.x != 0 and jumpCount == 0:
			sprite.play("Run")

	if count > 40 and get_node("../Stats").total_magic >= 10 and Input.is_action_just_pressed("fireSpell"):
		var spell = fireSpell.instantiate()
		spell.global_position = global_position
		get_tree().current_scene.add_child(spell)
		count = 0
		get_node("../Stats").total_magic -= 10

	if count2 > 60 and get_node("../Stats").total_magic >= 40 and Input.is_action_just_pressed("thunderSpell"):
		var spell2 = thunderSpell.instantiate()
		spell2.global_position = global_position
		get_tree().current_scene.add_child(spell2)
		count2 = 0
		get_node("../Stats").total_magic -= 40

	if count4 > 40 and get_node("../Stats").total_magic >= 20 and Input.is_action_just_pressed("iceSpell"):
		var spell3 = iceSpell.instantiate()
		spell3.global_position = global_position
		get_tree().current_scene.add_child(spell3)
		count4 = 0
		get_node("../Stats").total_magic -= 20

	if count3 % 35 == 0 and get_node("../Stats").total_magic < get_node("../Stats").max_magic:
		if boosted:
			get_node("../Stats").total_magic += 4.5
		else:
			get_node("../Stats").total_magic += 3

	if count5 > 400 and mana >= 70 and Input.is_action_just_pressed("holySpell"):
		var spell4 = holySpell.instantiate()
		spell4.global_position = global_position
		get_tree().current_scene.add_child(spell4)
		count5 = 0
		get_node("../Stats").total_magic -= 70
		get_node("../Stats").add_hp(15)
		boosted = true
		get_node("../Stats").total_speed += 100

	if count5 > 200 and boosted:
		get_node("../Stats").total_speed -= 100
		boosted = false
	if Input.is_action_just_pressed("attack"):
		$KnightSprite.play("attack1")

	if get_node("../Stats").total_health <= 0:
		queue_free()

	#if not is_on_floor() and sprite.animation == "attack1" and not sprite.is_playing():
		#if velocity.y < 0:
			#sprite.play("jump_start")
		#else:
			#sprite.play("jump_end")

	move_and_slide()
	
