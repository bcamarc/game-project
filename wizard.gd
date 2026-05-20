extends CharacterBody2D 

var jump_force := 400.0
var gravity := 1200.0
var jump_count := 0
var jump_ended := false
var alienPos := Vector2.ZERO

var spell: PackedScene = preload("res://fire_spell.tscn")
var thunderSpell: PackedScene = preload("res://thunder_spell.tscn")
var iceSpell: PackedScene = preload("res://ice_spell.tscn")
var holySpell: PackedScene = preload("res://holySpell.tscn")
var mana: float = 100.0
var knight := load("res://knight.tscn")

var count := 0
var count2 := 0
var count3 := 0
var count4 := 0
var count5 := 500

var is_attacking := false
var pending_shot := false
var pending_spell: PackedScene = null

var fire_key_was_down := false
var thunder_key_was_down := false
var ice_key_was_down := false
var holy_key_was_down := false

var attack_cooldown := 0.2
var attack_timer := 0.0

# Holy buffs
var holy_speed_multiplier := 1.35
var holy_speed_duration := 4.0
var holy_speed_timer := 0.0
var holy_regen_enabled := false
var holy_regen_per_second := 3.0
var holy_instant_heal := 8.0

const ANIM_IDLE := "idle"
const ANIM_RUN := "run"
const ANIM_JUMP := "jump"
const ANIM_ATTACK_PRIMARY := "attack1"
const ANIM_ATTACK_FALLBACK := "attack2"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var cam: Camera2D = $Camera2D if has_node("Camera2D") else null

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	add_to_group("player")
	add_to_group("alien_player")
	add_to_group("wizard")

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
	holy_speed_timer = 0.0

func _physics_process(delta: float) -> void:
	print("mana: ", mana)
	if mana < 100.0:
		mana = min(mana + 0.1, 100.0)

	alienPos = global_position
	count += 1
	count2 += 1
	count3 += 1
	count4 += 1
	count5 += 1

	attack_timer -= delta
	if holy_speed_timer > 0.0:
		holy_speed_timer -= delta

	var stats = get_node("../Stats")
	_apply_holy_regen(delta, stats)

	var left_pressed := _is_move_left_pressed()
	var right_pressed := _is_move_right_pressed()

	var direction_x := 0.0
	if left_pressed and not right_pressed:
		direction_x = -1.1
		sprite.flip_h = true
	elif right_pressed and not left_pressed:
		direction_x = 1.1
		sprite.flip_h = false

	var move_speed: float = float(stats.total_speed)
	if holy_speed_timer > 0.0:
		move_speed *= holy_speed_multiplier
	velocity.x = direction_x * move_speed

	if is_on_floor():
		jump_count = 0
		jump_ended = false

		if _is_jump_just_pressed():
			velocity.y = -jump_force * 1.1
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

	if not is_attacking and attack_timer <= 0.0:
		if _is_attack_just_pressed():
			_start_attack_with_spell(spell)
		elif _is_thunder_just_pressed():
			_start_attack_with_spell(thunderSpell)
		elif _is_ice_just_pressed():
			_start_attack_with_spell(iceSpell)
		elif _is_holy_just_pressed():
			_start_attack_with_spell(holySpell)

	if stats.total_health <= 0:
		respawn()

	move_and_slide()

func _get_spell_mana_cost(spell_scene: PackedScene) -> float:
	if spell_scene == holySpell:
		return 75.0
	if spell_scene == thunderSpell:
		return 40.0
	if spell_scene == iceSpell:
		return 30.0
	return 20.0

func _try_spend_mana(spell_scene: PackedScene) -> bool:
	var cost := _get_spell_mana_cost(spell_scene)
	if mana < cost:
		return false
	mana -= cost
	return true

func _start_attack_with_spell(spell_scene: PackedScene) -> void:
	if not _try_spend_mana(spell_scene):
		return

	is_attacking = true
	pending_shot = true
	pending_spell = spell_scene
	attack_timer = attack_cooldown
	_play_attack_anim()

func _spawn_spell(spell_scene: PackedScene) -> void:
	if spell_scene == null:
		return

	var arrow = spell_scene.instantiate()
	var spawn_pos: Vector2 = $arrow_spawn.global_position
	var mouse_world: Vector2 = get_global_mouse_position()

	arrow.global_position = spawn_pos
	arrow.direction = -1 if mouse_world.x < spawn_pos.x else 1
	if arrow.has_method("set_target_position"):
		arrow.set_target_position(mouse_world)

	get_tree().current_scene.add_child(arrow)

func _play_holy_effect() -> void:
	if holySpell == null:
		return

	var effect = holySpell.instantiate()
	get_tree().current_scene.add_child(effect)

	if effect is Node2D:
		effect.global_position = global_position

	var holy_anim: AnimatedSprite2D = null
	if effect is AnimatedSprite2D:
		holy_anim = effect
	elif effect.has_node("AnimatedSprite2D"):
		holy_anim = effect.get_node("AnimatedSprite2D")

	if holy_anim:
		if holy_anim.sprite_frames and holy_anim.sprite_frames.has_animation(holy_anim.animation):
			holy_anim.sprite_frames.set_animation_loop(holy_anim.animation, false)
		holy_anim.play()
		holy_anim.animation_finished.connect(func():
			if is_instance_valid(effect):
				effect.queue_free()
		)
	else:
		var t := get_tree().create_timer(0.6)
		t.timeout.connect(func():
			if is_instance_valid(effect):
				effect.queue_free()
		)

func _apply_holy_buffs() -> void:
	var stats = get_node("../Stats")
	var max_health := _get_max_health(stats)

	holy_speed_timer = holy_speed_duration
	holy_regen_enabled = true
	stats.total_health = min(stats.total_health + holy_instant_heal, max_health)

func _apply_holy_regen(delta: float, stats) -> void:
	if not holy_regen_enabled:
		return
	if stats.total_health <= 0:
		return

	var max_health := _get_max_health(stats)
	stats.total_health = min(stats.total_health + holy_regen_per_second * delta, max_health)

func _get_max_health(stats) -> float:
	if "total_max_health" in stats:
		return float(stats.total_max_health)
	if "max_health" in stats:
		return float(stats.max_health)
	if "health_max" in stats:
		return float(stats.health_max)
	return 100.0

func _spawn_arrow() -> void:
	_spawn_spell(spell)

func _spawn_thunder() -> void:
	_spawn_spell(thunderSpell)

func _spawn_ice() -> void:
	_spawn_spell(iceSpell)

func _play_attack_anim() -> void:
	if pending_spell == holySpell:
		if sprite.sprite_frames.has_animation(ANIM_ATTACK_FALLBACK):
			sprite.play(ANIM_ATTACK_FALLBACK)
		elif sprite.sprite_frames.has_animation(ANIM_ATTACK_PRIMARY):
			sprite.play(ANIM_ATTACK_PRIMARY)
	else:
		if sprite.sprite_frames.has_animation(ANIM_ATTACK_PRIMARY):
			sprite.play(ANIM_ATTACK_PRIMARY)
		elif sprite.sprite_frames.has_animation(ANIM_ATTACK_FALLBACK):
			sprite.play(ANIM_ATTACK_FALLBACK)

func _on_animation_finished() -> void:
	if sprite.animation == ANIM_ATTACK_PRIMARY or sprite.animation == ANIM_ATTACK_FALLBACK:
		if pending_shot:
			if pending_spell == holySpell:
				_play_holy_effect()
				_apply_holy_buffs()
			else:
				_spawn_spell(pending_spell)

			pending_shot = false
			pending_spell = null

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
	var key_down := Input.is_key_pressed(KEY_1) or Input.is_key_pressed(KEY_KP_1)
	var just_pressed := key_down and not fire_key_was_down
	fire_key_was_down = key_down
	return just_pressed

func _is_thunder_just_pressed() -> bool:
	var key_down := Input.is_key_pressed(KEY_2) or Input.is_key_pressed(KEY_KP_2)
	var just_pressed := key_down and not thunder_key_was_down
	thunder_key_was_down = key_down
	return just_pressed

func _is_ice_just_pressed() -> bool:
	var key_down := Input.is_key_pressed(KEY_3) or Input.is_key_pressed(KEY_KP_3)
	var just_pressed := key_down and not ice_key_was_down
	ice_key_was_down = key_down
	return just_pressed

func _is_holy_just_pressed() -> bool:
	var key_down := Input.is_key_pressed(KEY_4) or Input.is_key_pressed(KEY_KP_4)
	var just_pressed := key_down and not holy_key_was_down
	holy_key_was_down = key_down
	return just_pressed
