extends CharacterBody2D

enum BossState {
	IDLE,
	CHARGING,
	RETREATING,
	EXPLODING,
	HURT,
	DEAD,
}

@export var max_health := 650.0
@export var charge_speed := 300.0
@export var retreat_speed := 90.0
@export var aggro_range := 1200.0
@export var charge_duration := 1.15
@export var retreat_duration := 0.85
@export var windup_duration := 0.45
@export var attack_damage := 18
@export var damage_cooldown := 0.55
@export var explosion_damage := 24
@export var explosion_duration := 1.25
@export var explosion_chance := 0.28
@export var idle_retreat_chance := 0.27
@export var exp_reward := 900

@onready var sprite: AnimatedSprite2D = $animation
@onready var attack_hitbox: Area2D = $attack_hitbox
@onready var attack_shape: CollisionShape2D = $attack_hitbox/CollisionShape2D
@onready var explosion_area: Area2D = get_node_or_null("explosion_ability") as Area2D
@onready var health_bar: ProgressBar = get_node_or_null("ProgressBar") as ProgressBar

var health := max_health
var state := BossState.IDLE
var state_timer := 0.0
var damage_timer := 0.0
var facing_direction := 1.0
var target_player: Node2D = null
var players_in_attack: Array[Node2D] = []
var stats: Node = null
var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as float
var initial_attack_shape_position := Vector2.ZERO
var explosion_has_damaged := false

signal death(x, y)

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("shadow_knight")
	collision_layer = 4
	collision_mask = 1

	stats = resolve_stats()
	health = max_health
	initial_attack_shape_position = attack_shape.position
	_update_health_bar()
	_play_animation("idle")

	if not attack_hitbox.body_entered.is_connected(_on_attack_hitbox_body_entered):
		attack_hitbox.body_entered.connect(_on_attack_hitbox_body_entered)
	if not attack_hitbox.body_exited.is_connected(_on_attack_hitbox_body_exited):
		attack_hitbox.body_exited.connect(_on_attack_hitbox_body_exited)
	if not sprite.animation_finished.is_connected(_on_animation_finished):
		sprite.animation_finished.connect(_on_animation_finished)
	if explosion_area != null:
		explosion_area.monitoring = true
		explosion_area.collision_mask = 3

func _physics_process(delta: float) -> void:
	if state == BossState.DEAD:
		move_and_slide()
		return

	if health <= 0.0:
		_start_death()
		move_and_slide()
		return

	_apply_gravity(delta)
	_update_health_bar()
	_add_player_collision_exceptions()
	if not is_on_floor():
		velocity.x = 0.0

	if damage_timer > 0.0:
		damage_timer -= delta

	target_player = _nearest_player()
	if target_player == null:
		velocity.x = move_toward(velocity.x, 0.0, retreat_speed)
		_play_animation("idle")
		move_and_slide()
		return

	var distance := global_position.distance_to(target_player.global_position)
	_update_facing(target_player.global_position.x - global_position.x)

	if distance > aggro_range:
		velocity.x = move_toward(velocity.x, 0.0, retreat_speed)
		state = BossState.IDLE
		state_timer = windup_duration
		_play_animation("idle")
		move_and_slide()
		return

	state_timer -= delta

	match state:
		BossState.IDLE:
			_process_idle()
		BossState.CHARGING:
			_process_charge(delta, distance)
		BossState.RETREATING:
			_process_retreat()
		BossState.EXPLODING:
			_process_explosion()
		BossState.HURT:
			_process_hurt()

	move_and_slide()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	elif velocity.y > 0.0:
		velocity.y = 0.0

func _process_idle() -> void:
	velocity.x = move_toward(velocity.x, 0.0, charge_speed)
	_play_animation("idle")

	if state_timer <= 0.0:
		_choose_next_action()

func _choose_next_action() -> void:
	var roll := randf()
	if explosion_area != null and roll < explosion_chance:
		state = BossState.EXPLODING
		state_timer = explosion_duration
		explosion_has_damaged = false
		velocity.x = 0.0
		_play_animation("explosion")
	elif roll < explosion_chance + idle_retreat_chance:
		state = BossState.RETREATING
		state_timer = retreat_duration
	else:
		state = BossState.CHARGING
		state_timer = charge_duration

func _process_charge(_delta: float, distance: float) -> void:
	if is_on_floor():
		velocity.x = charge_speed * facing_direction
	else:
		velocity.x = 0.0
	_play_animation("attack")
	_damage_players_in_attack()

	if state_timer <= 0.0 or distance < 26.0:
		state = BossState.RETREATING
		state_timer = retreat_duration

func _process_retreat() -> void:
	if is_on_floor():
		velocity.x = -retreat_speed * facing_direction
	else:
		velocity.x = 0.0
	_play_animation("run")

	if state_timer <= 0.0:
		state = BossState.IDLE
		state_timer = windup_duration

func _process_explosion() -> void:
	velocity.x = 0.0
	_play_animation("explosion")

	if not explosion_has_damaged and state_timer <= explosion_duration * 0.65:
		_damage_players_in_explosion()
		explosion_has_damaged = true

	if state_timer <= 0.0:
		state = BossState.IDLE
		state_timer = windup_duration

func _process_hurt() -> void:
	velocity.x = move_toward(velocity.x, 0.0, charge_speed)
	if state_timer <= 0.0:
		state = BossState.IDLE
		state_timer = windup_duration

func _nearest_player() -> Node2D:
	var players := get_tree().get_nodes_in_group("alien_player")
	if players.is_empty():
		return null

	var nearest: Node2D = null
	var nearest_distance := INF
	for player in players:
		if player is Node2D:
			var player_node := player as Node2D
			var distance := global_position.distance_to(player_node.global_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest = player_node

	return nearest

func _add_player_collision_exceptions() -> void:
	for player in get_tree().get_nodes_in_group("alien_player"):
		if player is PhysicsBody2D:
			var player_body := player as PhysicsBody2D
			add_collision_exception_with(player_body)
			player_body.add_collision_exception_with(self)

func _update_facing(delta_x: float) -> void:
	if delta_x == 0.0:
		return

	facing_direction = signf(delta_x)
	sprite.flip_h = facing_direction < 0.0
	var attack_offset := absf(initial_attack_shape_position.x - sprite.position.x)
	attack_shape.position.x = sprite.position.x + attack_offset * facing_direction

func _damage_players_in_attack() -> void:
	if damage_timer > 0.0:
		return

	for body in players_in_attack:
		if is_instance_valid(body) and body.is_in_group("alien_player"):
			target_player = body
			damage_player(attack_damage)
			damage_timer = damage_cooldown
			return

func _damage_players_in_explosion() -> void:
	if explosion_area == null:
		return

	for body in explosion_area.get_overlapping_bodies():
		if body is Node2D and body.is_in_group("alien_player"):
			target_player = body as Node2D
			damage_player(explosion_damage)

	for body in attack_hitbox.get_overlapping_bodies():
		if body is Node2D and body.is_in_group("alien_player"):
			target_player = body as Node2D
			damage_player(attack_damage)
			damage_timer = damage_cooldown
			return

func damage_player(amount: int) -> void:
	var resolved_stats := resolve_stats(target_player)
	if resolved_stats == null:
		print("Stats not found: cannot damage player")
		return

	if resolved_stats.has_method("add_hp"):
		resolved_stats.add_hp(-amount)
	else:
		resolved_stats.total_health -= amount

func resolve_stats(player: Node2D = null) -> Node:
	if player != null and is_instance_valid(player):
		var player_stats := player.get_node_or_null("../Stats")
		if player_stats != null:
			stats = player_stats
			return stats

	var scene := get_tree().current_scene
	if scene != null:
		var scene_stats := scene.get_node_or_null("Stats")
		if scene_stats != null:
			stats = scene_stats
			return stats

	var singleton_stats := get_node_or_null("/root/Stats")
	if singleton_stats != null:
		stats = singleton_stats
		return stats

	return null

func take_damage(amount: int) -> void:
	if state == BossState.DEAD:
		return

	health -= amount
	_update_health_bar()

	if health <= 0.0:
		_start_death()
		return

	if state != BossState.CHARGING:
		state = BossState.HURT
		state_timer = 0.25
		_play_animation("hurt")

func _start_death() -> void:
	if state == BossState.DEAD:
		return

	state = BossState.DEAD
	velocity = Vector2.ZERO
	attack_hitbox.monitoring = false
	_play_animation("death")

	var resolved_stats := resolve_stats(target_player)
	if resolved_stats != null and resolved_stats.has_method("add_exp"):
		resolved_stats.add_exp(exp_reward)

	death.emit(position.x, position.y)

func _update_health_bar() -> void:
	if health_bar == null:
		return

	health_bar.max_value = max_health
	health_bar.value = maxf(health, 0.0)

func _play_animation(animation_name: StringName) -> void:
	if sprite.animation != animation_name or not sprite.is_playing():
		sprite.play(animation_name)

func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("alien_player") and not players_in_attack.has(body):
		players_in_attack.append(body)
		target_player = body

func _on_attack_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("alien_player"):
		players_in_attack.erase(body)
		if body == target_player:
			target_player = _nearest_player()

func _on_animation_finished() -> void:
	if state == BossState.DEAD and sprite.animation == "death":
		queue_free()
