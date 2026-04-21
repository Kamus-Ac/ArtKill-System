extends CharacterBody2D
@onready var hit_lag: Timer = $HitLag

@export var skins: Array[SpriteFrames]  # 8 skins
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var isDead: bool = false
@onready var launchingArea: Area2D = $LaunchingArea

signal died
const MAX_SPEED = 85
const IMPULSE = 50

#varibles debug
var check
var collision
#var body: Node2D
var body2: Node2D

var hitting : bool = false
var hit_obj_enemy: bool = false
var hit_enemy_enemy: bool = false

var push_obj_enemy : Vector2 = Vector2.ZERO
var mag_obj_enemy : float = 0
var push_enemy_enemy : Vector2 = Vector2.ZERO

var knockback:= Vector2.ZERO
var knockback_decay:= 8.0

enum STATE {
	RUNNING,
	DEAD
}

var current_state: STATE = STATE.RUNNING

func _ready() -> void:
	#SignalManager.isLaunching.connect(islaunching)
	launchingArea.body_entered.connect(islaunching2)
	assign_random_skin()
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# Conectar la señal "died" de esta instancia a la función del player
		self.died.connect(player._on_enemy_killed)


func _physics_process(_delta):
	match current_state:
		STATE.RUNNING:
			anim_sprite.play("idle")
			# --- MOVIMIENTO BÁSICO ---
			if not hitting:
				var direction = get_direction_to_player()
				velocity = direction * MAX_SPEED

			# --- KNOCKBACKS ---
			if hitting:
				if knockback.length() > 10:
					knockback = knockback.move_toward(Vector2.ZERO, knockback_decay)
				else:
					knockback = Vector2.ZERO
				
				velocity+=knockback

			# --- MOVIMIENTO FINAL ---
			move_and_slide()

			# --- COLISIONES ---
			var collision_info = get_last_slide_collision()

			if collision_info:
				var collider = collision_info.get_collider()

				if collider.is_in_group("player"):
					return # que no "rebote" contra el jugador

				if collider.is_in_group("objects") or collider.is_in_group("enemies"):
					collision = collision_info
					SignalManager.isLaunching.emit()

		STATE.DEAD:
			pass



func assign_random_skin():
	if anim_sprite == null:
		push_warning("AnimatedSprite2D not found!")
		return

	if skins.size() > 0:
		randomize()
		var random_skin = skins[randi() % skins.size()]
		anim_sprite.sprite_frames = random_skin



func die(hit):
	if hit is Player_Hitbox:
		print("muerto")
		emit_signal("died")
		isDead = true
		current_state = STATE.DEAD
		queue_free()

func get_direction_to_player():
	var player_node = get_tree().get_first_node_in_group("player") as Node2D
	if player_node != null:
		return (player_node.global_position - global_position).normalized()
	return Vector2.ZERO


func islaunching2(body: Node2D):
	body2 = body
	if body2 and body2.is_in_group("objects"):
		hitting = true
		if hitting:				
			velocity = Vector2.ZERO
			hitting = true
			hit_obj_enemy = true
			hit_lag.start(1.0)
			#print("si le pego")
			#push_obj_enemy = collision.get_normal()
			
			if body2 is RigidBody2D:
				var dir_to_rb = (body2.global_position - global_position).normalized()
				var rb_impulse = dir_to_rb * (IMPULSE) # Escala para que sí se mueva
				body2.linear_velocity = Vector2.ZERO
				body2.angular_velocity = 0
				body2.apply_impulse(rb_impulse * 10)
				knockback = -rb_impulse
				
	if body2 and body2.is_in_group("enemies") and !hitting:
		velocity = Vector2.ZERO
		hitting = true
		hit_enemy_enemy = true
		hit_lag.start(1.0)
		var dir_to_enemy = (body2.global_position - global_position).normalized()
		var enemy_impulse = dir_to_enemy * (IMPULSE)
		knockback = -enemy_impulse
		body.velocity = Vector2.ZERO
		body2.hit_lag.start(1.0)
		body2.hitting=true
		body2.knockback = enemy_impulse
	print("COLISION CON:", body2.name)
	print("DIR:", (body2.global_position - global_position))


func _on_hit_lag_timeout() -> void:
	hitting = false
	
	if hit_obj_enemy:
		hit_obj_enemy=false
	
	if hit_enemy_enemy:
		hit_enemy_enemy=false


func _on_animated_sprite_2d_animation_finished() -> void:
	pass # Replace with function body.
