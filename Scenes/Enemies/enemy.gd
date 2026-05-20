extends CharacterBody2D

@onready var hit_lag: Timer = $HitLag
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var launchingArea: Area2D = $LaunchingArea
@onready var hitParticles: CPUParticles2D = $HitParticles
@onready var nav = $NavigationAgent2D

@export var skins: Array[SpriteFrames]

signal died

const MAX_SPEED = 85
const SPEED = 20
const IMPULSE = 300

var body2: Node2D

var hitting: bool = false
var knockback := Vector2.ZERO
var knockback_decay := 8.0

var player
var isDead := false

enum STATE {
	RUNNING,
	DEAD
}

var current_state: STATE = STATE.RUNNING


func _ready() -> void:
	launchingArea.body_entered.connect(islaunching2)

	assign_random_skin()

	player = get_tree().get_first_node_in_group("player")

	if player:
		self.died.connect(player._on_enemy_killed)




func _physics_process(delta):

	match current_state:

		STATE.RUNNING:

			if anim_sprite.animation != "idle" or !anim_sprite.is_playing():
				anim_sprite.play("idle")

			var direction = get_direction_to_player()
			if anim_sprite.sprite_frames:	
				anim_sprite.scale.x = 1 if direction.x > 0 else -1
			# MOVIMIENTO
			if not hitting:
				velocity += direction * SPEED

				if velocity.length_squared() > MAX_SPEED * MAX_SPEED:
					velocity = direction * MAX_SPEED

			# KNOCKBACK
			if hitting:

				if knockback.length_squared() > 128:
					knockback = knockback.lerp(Vector2.ZERO, delta)
					velocity = knockback

				else:
					hitting = false
					velocity = Vector2.ZERO

			move_and_slide()

			# COLISIONES
			var collision_info = get_last_slide_collision()

			if collision_info:

				var collider = collision_info.get_collider()

				if collider.is_in_group("player"):
					return

				if collider.is_in_group("objects") or collider.is_in_group("enemies"):
					SignalManager.isLaunching.emit()

		STATE.DEAD:
			return


func assign_random_skin():

	if skins.size() > 0:

		randomize()

		var random_skin = skins[randi() % skins.size()]

		anim_sprite.sprite_frames = random_skin


func die(hit):

	if isDead:
		return

	if hit is Player_Hitbox or hit.is_in_group("notas"):

		isDead = true
		current_state = STATE.DEAD

		emit_signal("died")

		SignalManager.kill_count.emit()

		velocity = Vector2.ZERO

		hitParticles.emitting = true

		if anim_sprite.sprite_frames.has_animation("death"):

			anim_sprite.play("death")

			await anim_sprite.animation_finished

		else:
			print("La skin no tiene animacion death")

		queue_free()


func get_direction_to_player():

	var player_node = get_tree().get_first_node_in_group("player") as Node2D

	if player_node != null:
		return to_local(nav.get_next_path_position()).normalized()

	return Vector2.ZERO


func islaunching2(body: Node2D):

	body2 = body

	if body2 and body2.is_in_group("objects"):

		hitting = true
		velocity = Vector2.ZERO

		if body2 is RigidBody2D:

			var dir_to_rb = (body2.global_position - global_position).normalized()

			var rb_impulse = dir_to_rb * IMPULSE

			body2.linear_velocity = Vector2.ZERO
			body2.angular_velocity = 0

			body2.apply_impulse(rb_impulse / 5)

			knockback = -rb_impulse


	if body2 and body2.is_in_group("enemies"):

		velocity = Vector2.ZERO

		hitting = true

		var dir_to_enemy = (body2.global_position - global_position).normalized()

		var enemy_impulse = dir_to_enemy * IMPULSE

		knockback = -enemy_impulse

		body2.hit_lag.start(1.0)
		body2.hitting = true
		body2.knockback = enemy_impulse


	if body2 and body2.is_in_group("notas"):

		die(body2)

		body2.queue_free()


func _on_hit_lag_timeout() -> void:

	hitting = false


func _on_timer_timeout() -> void:

	if player:
		nav.target_position = player.global_position
