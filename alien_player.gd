extends CharacterBody2D

var jump_force := 400
var gravity := 600
var jumpCount := 0
var jumpEnded := false
var alienPos := Vector2.ZERO

var mana := 100
var knight := load("res://knight.tscn")
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
var is_attacking := false
var is_defending := false
var has_hit := false

var attack_cooldown := 0.2
var attack_timer := 0.0
var defense_cooldown := 1.5
var defense_timer := 0.0

const DEFENSE_LEVEL_REQUIREMENT := 5
const DEFENSE_ANIMATIONS := [
	&"defend",
	&"defense",
	&"defend",
	&"shield",
	&"block",
	&"guard",
	&"Defence",
	&"Defense",
	&"Defend",
	&"Shield",
	&"Block",
	&"Guard",
]

@onready var sprite = $KnightSprite
@onready var hitbox = $Area2D

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	add_to_group("player")
	add_to_group("alien_player")
	
func respawn():
	get_node("../Stats").total_health = 100
	global_position = Vector2(0, 0)
	#queue_free()
	
func _physics_process(delta):

	alienPos = global_position
	count += 1
	count2 += 1
	count3 += 1
	count4 += 1
	count5 += 1

	attack_timer -= delta
	defense_timer -= delta

	

	var direction := Vector2.ZERO
	if (sprite.animation == "attack1"):
		sprite.speed_scale = get_node("../Stats").attack_speed
	else:
		sprite.speed_scale = 1.0
	if Input.is_action_pressed("Left"):
		direction.x -= 1
		sprite.flip_h = true
	if Input.is_action_pressed("right"):
		direction.x += 1
		sprite.flip_h = false
	if sprite.flip_h:
		hitbox.position.x = -abs(hitbox.position.x)
	else:
		hitbox.position.x = abs(hitbox.position.x)

	velocity.x = direction.x * get_node("../Stats").total_speed

	if is_on_floor():
		velocity.y = 0
		jumpCount = 0
		jumpEnded = false

		if Input.is_action_just_pressed("jump"):
			velocity.y = -jump_force
			jumpCount = 1
			jumpEnded = false
			if not _is_busy():
				sprite.play("jump_start")

		elif direction.x != 0:
			if not _is_busy():
				sprite.play("Run")
		else:
			if not _is_busy():
				sprite.play("Idle")

	else:
		velocity.y += gravity * delta

		if jumpCount == 1 and not jumpEnded and velocity.y > 0:
			if not _is_busy():
				sprite.play("jump_end")
			jumpEnded = true

		elif direction.x != 0 and jumpCount == 0:
			if not _is_busy():
				sprite.play("Run")

	if Input.is_action_just_pressed("attack") and not _is_busy() and attack_timer <= 0:
		is_attacking = true
		$AudioStreamPlayer2D.play()
		has_hit = false
		sprite.play("attack1")
		attack_timer = attack_cooldown

	if _is_defense_just_pressed() and _can_start_defense():
		_start_defense()

	if is_attacking and not has_hit:
		var bodies = hitbox.get_overlapping_bodies()

		for body in bodies:
			if body.is_in_group("enemy") or body.is_in_group("slime") or body.is_in_group("golem"):
				if body.has_method("take_damage"):
					body.take_damage(get_node("../Stats").total_damage)
					has_hit = true
					break


	if get_node("../Stats").total_health <= 0:
		respawn()
		

	move_and_slide()


func _on_animation_finished():
	if sprite.animation == "attack1":
		is_attacking = false
		has_hit = false

		if not is_on_floor():
			if velocity.y < 0:
				sprite.play("jump_start")
			else:
				sprite.play("jump_end")
		else:
			if velocity.x != 0:
				sprite.play("Run")
			else:
				sprite.play("Idle")

	elif is_defending and sprite.animation == _get_defense_animation():
		_finish_defense()

func is_immune_to_damage() -> bool:
	return is_defending

func _is_busy() -> bool:
	return is_attacking or is_defending

func _is_defense_just_pressed() -> bool:
	return InputMap.has_action(&"attack_burst") and Input.is_action_just_pressed(&"attack_burst")

func _can_start_defense() -> bool:
	return not is_attacking and not is_defending and defense_timer <= 0.0 and _get_level() >= DEFENSE_LEVEL_REQUIREMENT and _get_defense_animation() != &""

func _start_defense() -> void:
	is_defending = true
	defense_timer = defense_cooldown
	sprite.speed_scale = 1.0
	sprite.play(_get_defense_animation())

func _finish_defense() -> void:
	is_defending = false

	if not is_on_floor():
		if velocity.y < 0:
			sprite.play("jump_start")
		else:
			sprite.play("jump_end")
	else:
		if velocity.x != 0:
			sprite.play("Run")
		else:
			sprite.play("Idle")

func _get_level() -> int:
	var stats := _resolve_stats()
	if stats != null:
		return int(stats.level)
	return 1

func _get_defense_animation() -> StringName:
	for animation_name in DEFENSE_ANIMATIONS:
		if sprite.sprite_frames.has_animation(animation_name):
			return animation_name

	return &""

func _resolve_stats() -> Node:
	var parent_stats := get_node_or_null("../Stats")
	if parent_stats != null:
		return parent_stats

	var scene := get_tree().current_scene
	if scene != null:
		var scene_stats := scene.get_node_or_null("Stats")
		if scene_stats != null:
			return scene_stats

	var singleton_stats := get_node_or_null("/root/Stats")
	if singleton_stats != null:
		return singleton_stats

	return null
