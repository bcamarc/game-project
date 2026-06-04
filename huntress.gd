extends CharacterBody2D

var jump_force := 400.0
var gravity := 1200.0
var jump_count := 0
var jump_ended := false
var alienPos := Vector2.ZERO

var arrows: PackedScene = preload("res://arrow.tscn")

var mana := 100
var knight := load("res://knight.tscn")

var count := 0
var count2 := 0
var count3 := 0
var count4 := 0
var count5 := 500

var is_attacking := false
var pending_shot := false

var attack_cooldown := 0.2
var attack_timer := 0.0

const ANIM_IDLE := "idle"
const ANIM_RUN := "run"
const ANIM_JUMP := "jump"
const ANIM_ATTACK_PRIMARY := "attack"
const ANIM_ATTACK_FALLBACK := "attack1"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var cam: Camera2D = $Camera2D if has_node("Camera2D") else null

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	add_to_group("player")
	add_to_group("alien_player")

	floor_snap_length = 8.0

	if sprite.sprite_frames.has_animation(ANIM_ATTACK_PRIMARY):
		sprite.sprite_frames.set_animation_loop(ANIM_ATTACK_PRIMARY, false)
	if sprite.sprite_frames.has_animation(ANIM_ATTACK_FALLBACK):
		sprite.sprite_frames.set_animation_loop(ANIM_ATTACK_FALLBACK, false)

	if cam:
		cam.make_current()
		cam.enabled = true
		cam.offset = Vector2.ZERO
		cam.anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER
		cam.drag_horizontal_enabled = false
		cam.drag_vertical_enabled = false

func respawn() -> void:
	get_node("../Stats").total_health = 100
	global_position = Vector2.ZERO
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	alienPos = global_position
	count += 1
	count2 += 1
	count3 += 1
	count4 += 1
	count5 += 1

	attack_timer -= delta

	var left_pressed := _is_move_left_pressed()
	var right_pressed := _is_move_right_pressed()

	var direction_x := 0.0
	if left_pressed and not right_pressed:
		direction_x = -1.25
		sprite.flip_h = true
	elif right_pressed and not left_pressed:
		direction_x = 1.25
		sprite.flip_h = false

	velocity.x = direction_x * get_node("../Stats").total_speed

	if is_on_floor():
		jump_count = 0
		jump_ended = false

		if _is_jump_just_pressed():
			velocity.y = -jump_force * 1.25
			jump_count = 1
			jump_ended = false
			if not is_attacking:
				_play_if_exists(ANIM_JUMP)
		elif not is_attacking:
			if direction_x != 0.0:
				_play_if_exists(ANIM_RUN)
			else:
				_play_if_exists(ANIM_IDLE)
	else:
		velocity.y += gravity * delta

		if jump_count == 1 and not jump_ended and velocity.y > 0.0:
			jump_ended = true

		if not is_attacking and direction_x != 0.0 and jump_count == 0:
			_play_if_exists(ANIM_RUN)

	if _is_attack_just_pressed() and not is_attacking and attack_timer <= 0.0:
		is_attacking = true
		pending_shot = true
		attack_timer = attack_cooldown
		_play_attack_anim()

	if get_node("../Stats").total_health <= 0:
		respawn()

	move_and_slide()

func _spawn_arrow() -> void:
	var arrow = arrows.instantiate()
	var spawn_pos: Vector2 = $arrow_spawn.global_position
	var mouse_world: Vector2 = get_global_mouse_position()

	
	arrow.global_position = spawn_pos
	arrow.direction = -1 if mouse_world.x < spawn_pos.x else 1
	if arrow.has_method("set_target_position"):
		arrow.set_target_position(mouse_world)

	get_tree().current_scene.add_child(arrow)

func _play_attack_anim() -> void:
	if sprite.sprite_frames.has_animation(ANIM_ATTACK_PRIMARY):
		sprite.play(ANIM_ATTACK_PRIMARY)
	elif sprite.sprite_frames.has_animation(ANIM_ATTACK_FALLBACK):
		sprite.play(ANIM_ATTACK_FALLBACK)

func _on_animation_finished() -> void:
	if sprite.animation == ANIM_ATTACK_PRIMARY or sprite.animation == ANIM_ATTACK_FALLBACK:
		if pending_shot:
			_spawn_arrow()
			$AudioStreamPlayer2D.play()
			pending_shot = false

		is_attacking = false

		if not is_on_floor():
			_play_if_exists(ANIM_JUMP)
		else:
			if abs(velocity.x) > 0.0:
				_play_if_exists(ANIM_RUN)
			else:
				_play_if_exists(ANIM_IDLE)

func _play_if_exists(anim_name: String) -> void:
	if sprite.sprite_frames.has_animation(anim_name):
		if sprite.animation != anim_name:
			sprite.play(anim_name)

func _action_pressed_if_exists(action_name: StringName) -> bool:
	return InputMap.has_action(action_name) and Input.is_action_pressed(action_name)

func _action_just_pressed_if_exists(action_name: StringName) -> bool:
	return InputMap.has_action(action_name) and Input.is_action_just_pressed(action_name)

func _is_move_left_pressed() -> bool:
	return _action_pressed_if_exists(&"left") or _action_pressed_if_exists(&"Left") or _action_pressed_if_exists(&"ui_left")

func _is_move_right_pressed() -> bool:
	return _action_pressed_if_exists(&"right") or _action_pressed_if_exists(&"Right") or _action_pressed_if_exists(&"ui_right")

func _is_jump_just_pressed() -> bool:
	return _action_just_pressed_if_exists(&"jump") or _action_just_pressed_if_exists(&"ui_accept")

func _is_attack_just_pressed() -> bool:
	return _action_just_pressed_if_exists(&"attack")
