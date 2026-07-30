extends CharacterBody2D

enum BossState {
	IDLE,
	PHASE1,
	PHASE2,
	CHARGING,
	TELEGRAPH,
	AOE,
	SUMMON,
	HURT,
	DEAD,
}

@export var max_health := 1200.0
@export var phase_two_threshold := 0.35 # fraction of max_health to enter phase 2
@export var walk_speed := 80.0
@export var charge_speed := 520.0
@export var retreat_speed := 140.0
@export var aggro_range := 1400.0
@export var charge_duration := 1.1
@export var telegraph_duration := 0.7
@export var aoe_windup := 0.9
@export var aoe_damage := 40
@export var slam_damage := 22
@export var charge_damage := 30
@export var damage_cooldown := 0.5
@export var exp_reward := 2500
@export var summon_scene: PackedScene = preload("res://zombie.tscn")
@export var max_summons := 3
@export var summon_cooldown := 12.0

@onready var sprite: AnimatedSprite2D = $animation
@onready var attack_area: Area2D = $attack_hitbox
@onready var attack_shape: CollisionShape2D = $attack_hitbox/CollisionShape2D
@onready var body_area: Area2D = $body_area
@onready var body_shape: CollisionShape2D = $body_area/CollisionShape2D
@onready var explosion_area: Area2D = get_node_or_null("explosion_ability") as Area2D
@onready var health_bar: ProgressBar = get_node_or_null("ProgressBar") as ProgressBar

signal death(x, y)
signal phase_changed(new_phase)

var health := max_health
var state := BossState.IDLE
var facing_direction := 1.0
var state_timer := 0.0
var damage_timer := 0.0
var target_player: Node2D = null
var players_in_attack: Array[Node2D] = []
var stats: Node = null
var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as float
var summons := []
var summon_timer := 0.0
var invulnerable := false

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("shadow_knight")
	# Physics layers/masks -- keep consistent with project
	collision_layer = 4
	collision_mask = 1

	health = max_health
	_update_health_bar()
	_play_animation("idle")

	# Connect signals
	if not attack_area.body_entered.is_connected(_on_attack_hitbox_body_entered):
		attack_area.body_entered.connect(_on_attack_hitbox_body_entered)
	if not attack_area.body_exited.is_connected(_on_attack_hitbox_body_exited):
		attack_area.body_exited.connect(_on_attack_hitbox_body_exited)
	if not sprite.animation_finished.is_connected(_on_animation_finished):
		sprite.animation_finished.connect(_on_animation_finished)
	if body_area != null:
		# allow players' Area2D to detect this hurtbox as a target
		body_area.monitoring = true
		body_area.collision_layer = 4
		body_area.collision_mask = 1

	stats = resolve_stats()
	summon_timer = summon_cooldown

func _physics_process(delta: float) -> void:
	if state == BossState.DEAD:
		move_and_slide()
		return

	# death check
	if health <= 0.0:
		_start_death()
		move_and_slide()
		return

	# gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	elif velocity.y > 0.0:
		velocity.y = 0.0

	_update_health_bar()
	_add_player_collision_exceptions()

	if damage_timer > 0.0:
		damage_timer -= delta

	target_player = _nearest_player()
	if target_player == null:
		# idle patrol / breathe
		velocity.x = move_toward(velocity.x, 0.0, walk_speed)
		_play_animation("idle")
		move_and_slide()
		return

	var distance := global_position.distance_to(target_player.global_position)
	_update_facing(target_player.global_position.x - global_position.x)

	# phase transition
	var health_frac := health / max_health
	if health_frac <= phase_two_threshold and state != BossState.PHASE2:
		_enter_phase2()

	# summon timer
	if summons.size() < max_summons:
		summon_timer -= delta
	else:
		summon_timer = summon_cooldown

	# simple AI state machine
	state_timer -= delta
	match state:
		BossState.IDLE:
			velocity.x = move_toward(velocity.x, 0.0, walk_speed)
			_play_animation("idle")
			if state_timer <= 0.0:
				# decide action
				_choose_action(distance)
		BossState.CHARGING:
			_process_charge(delta, distance)
		BossState.TELEGRAPH:
			_play_animation("telegraph")
			if state_timer <= 0.0:
				state = BossState.AOE
				state_timer = 0.6
		BossState.AOE:
			_process_aoe()
		BossState.SUMMON:
			_process_summon()
		BossState.PHASE1, BossState.PHASE2:
			# in-phase idle / short moves
			velocity.x = move_toward(velocity.x, 0.0, walk_speed)
			_play_animation("idle")
			if state_timer <= 0.0:
				_choose_action(distance)
		BossState.HURT:
			# brief stun
			velocity.x = move_toward(velocity.x, 0.0, walk_speed)
			if state_timer <= 0.0:
				state = BossState.IDLE

	move_and_slide()

func _choose_action(distance: float) -> void:
	# prefer charge when player is mid-range, AOE when close, summon if many areas
	if summons.size() < max_summons and summon_timer <= 0.0 and randf() < 0.5:
		state = BossState.SUMMON
		state_timer = 0.6
		return

	if distance > 160.0 and randf() < 0.6:
		state = BossState.CHARGING
		state_timer = charge_duration
		_play_animation("attack")
		return

	# telegraph slam/AOE
	state = BossState.TELEGRAPH
	state_timer = telegraph_duration
	_play_animation("explosion")

func _process_charge(delta: float, distance: float) -> void:
	if is_on_floor():
		velocity.x = charge_speed * facing_direction
	else:
		velocity.x = 0.0
	_play_animation("run")
	# damage players encountered
	_for_each_player_in_attack(func(p):
		if damage_timer <= 0.0:
			damage_player(charge_damage)
			damage_timer = damage_cooldown
	)
	if state_timer <= 0.0 or distance < 30.0:
		state = BossState.IDLE
		state_timer = 0.8

func _process_aoe() -> void:
	# slam/AOE during this state
	_play_animation("explosion")
	if state_timer <= aoe_windup and not invulnerable:
		# apply damage once
		_for_each_body_in_area(explosion_area, func(b):
			if b.is_in_group("alien_player"):
				damage_player(aoe_damage)
		)
		invulnerable = true
	if state_timer <= 0.0:
		invulnerable = false
		state = BossState.IDLE
		state_timer = 1.0

func _process_summon() -> void:
	_play_animation("ability")
	if state_timer <= 0.0:
		# spawn a small minion near the boss
		if summon_scene != null:
			var s = summon_scene.instantiate()
			get_parent().add_child(s)
			s.global_position = global_position + Vector2(80 * facing_direction, 0)
			summons.append(s)
			summon_timer = summon_cooldown
		state = BossState.IDLE
		state_timer = 1.0

func _enter_phase2() -> void:
	state = BossState.PHASE2
	state_timer = 1.0
	# buff stats
	charge_speed *= 1.18
	walk_speed *= 1.25
	aoe_damage = int(aoe_damage * 1.25)
	expand_damage = int(charge_damage * 1.25) if false else charge_damage
	emit_signal("phase_changed", 2)

func _nearest_player() -> Node2D:
	var players := get_tree().get_nodes_in_group("alien_player")
	if players.is_empty():
		return null
	var nearest: Node2D = null
	var nearest_distance := INF
	for p in players:
		if p is Node2D:
			var d = global_position.distance_to(p.global_position)
			if d < nearest_distance:
				nearest_distance = d
				nearest = p
	return nearest

func _add_player_collision_exceptions() -> void:
	for player in get_tree().get_nodes_in_group("alien_player"):
		if player is PhysicsBody2D:
			add_collision_exception_with(player as PhysicsBody2D)

func _update_facing(delta_x: float) -> void:
	if delta_x == 0.0:
		return
	facing_direction = signf(delta_x)
	sprite.flip_h = facing_direction < 0.0
	# reposition attack shape relative to sprite
	if attack_shape != null:
		attack_shape.position.x = absf(attack_shape.position.x) * facing_direction
	if body_shape != null:
		body_shape.position.x = absf(body_shape.position.x) * facing_direction

func _for_each_player_in_attack(callback: Callable) -> void:
	for body in attack_area.get_overlapping_bodies():
		if is_instance_valid(body) and body.is_in_group("alien_player"):
			callback.call(body)

func _for_each_body_in_area(area: Area2D, callback: Callable) -> void:
	if area == null:
		return
	for body in area.get_overlapping_bodies():
		if is_instance_valid(body):
			callback.call(body)

func _on_attack_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("alien_player") and not players_in_attack.has(body):
		players_in_attack.append(body)

func _on_attack_hitbox_body_exited(body: Node) -> void:
	if body.is_in_group("alien_player"):
		players_in_attack.erase(body)

func damage_player(amount: int) -> void:
	# damage the current nearest player in range
	_for_each_player_in_attack(func(p):
		if not _is_player_immune(p):
			var rs = resolve_stats(p)
			if rs != null:
				if rs.has_method("add_hp"):
					rs.add_hp(-amount)
				else:
					rs.total_health -= amount
		)

func _is_player_immune(player: Node2D) -> bool:
	return player != null and is_instance_valid(player) and player.has_method("is_immune_to_damage") and bool(player.call("is_immune_to_damage"))

func resolve_stats(player: Node2D = null) -> Node:
	if player != null and is_instance_valid(player):
		var player_stats := player.get_node_or_null("../Stats")
		if player_stats != null:
			return player_stats
	var scene := get_tree().current_scene
	if scene != null:
		var scene_stats := scene.get_node_or_null("Stats")
		if scene_stats != null:
			return scene_stats
	var singleton_stats := get_node_or_null("/root/Stats")
	if singleton_stats != null:
		return singleton_stats
	return null

func take_damage(amount: int) -> void:
	if state == BossState.DEAD or invulnerable:
		return
	# simple damage reduction in phase2
	if state == BossState.PHASE2:
		amount = int(amount * 0.9)
	health -= amount
	_update_health_bar()
	if health <= 0:
		_start_death()
		return
	# react to damage
	state = BossState.HURT
	state_timer = 0.45
	_play_animation("hurt")

func _start_death() -> void:
	if state == BossState.DEAD:
		return
	state = BossState.DEAD
	velocity = Vector2.ZERO
	attack_area.monitoring = false
	body_area.monitoring = false
	_play_animation("death")
	var rs := resolve_stats(target_player)
	if rs != null and rs.has_method("add_exp"):
		rs.add_exp(exp_reward)
	emit_signal("death", position.x, position.y)

func _update_health_bar() -> void:
	if health_bar == null:
		return
	health_bar.max_value = max_health
	health_bar.value = maxf(health, 0.0)

func _play_animation(anim: StringName) -> void:
	if sprite.animation != anim or not sprite.is_playing():
		sprite.play(anim)

func _on_animation_finished() -> void:
	if state == BossState.DEAD and sprite.animation == "death":
		queue_free()

# cleanup summons when they die
func _on_summon_removed(node):
	if summons.has(node):
		summons.erase(node)

# optional: expose debug function to force phase2
func force_phase2():
	_enter_phase2()
