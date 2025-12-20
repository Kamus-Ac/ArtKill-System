extends CharacterBody2D


signal player_attack(dir: Vector2)
signal player_ulti()
signal animation_done
@onready var attack_area: Area2D = $Flip/Areas/AttackArea
@onready var anim: AnimatedSprite2D = $Flip/AnimatedSprite2D
@onready var ulti_area: Area2D = $Flip/Areas/UltiArea

#---VIDA---#
#var hearts_list: Array[TextureRect]
var health = 3

enum STATE {
	IDLE,
	RUNNING,
	ATTACKING,
	ATTACKING_ULTI,
	HURTED,
	DEAD
}
const MAX_SPEED := 250
const ACCELERATION_SMOOTHING := 18
var current_state: STATE = STATE.IDLE
var normal_veloocity := Vector2.ZERO
var knockback := Vector2.ZERO
var knockback_decay := 8.0 # qué tan rápido se detiene el empujón
var invulnerable := false
const DAMAGE_COOLDOWN := 0.8   # tiempo en segundos


func _ready() -> void:
	# asegurar que la animación ataque no esté en loop desde el editor
	# conectar la señal para volver a idle al terminar
	if anim:
		anim.animation_finished.connect(_on_anim_finished)
	# por defecto el area no "monitorea" (no es requerido si usamos get_overlapping_bodies())
	attack_area.monitoring = true 
	#ulti_area.monitoring = false
	
	#habria que agregar los corazones

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")

# knockback siempre suma fuerza, no cancela movimiento
	if knockback.length() > 10:
		knockback = knockback.move_toward(Vector2.ZERO, knockback_decay)
	else:
		knockback = Vector2.ZERO

# movimiento normal
	normal_veloocity = input_dir * MAX_SPEED
	velocity = velocity.lerp(normal_veloocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))

# suma knockback
	velocity += knockback

	move_and_slide()

	#print("PLAYER STATE:" + str(current_state))
	match current_state:
		STATE.IDLE:
			anim.play("idle")
			
			if input_dir != Vector2.ZERO:
				current_state = STATE.RUNNING
			
			if Input.is_action_just_pressed("BasicAttack"):
				current_state = STATE.ATTACKING
			
			if Input.is_action_just_pressed("Ulti"):
				current_state = STATE.ATTACKING_ULTI
		STATE.RUNNING:
			anim.play("run")
			
			if Input.is_action_just_pressed("BasicAttack"):
				current_state = STATE.ATTACKING
			
			if Input.is_action_just_pressed("Ulti"):
				current_state = STATE.ATTACKING_ULTI
			
			if input_dir == Vector2.ZERO:
				current_state = STATE.IDLE
		STATE.ATTACKING:
			anim.play("basicAttack")
			basic_attack()
			await animation_done
			
			if Input.is_action_just_pressed("Ulti"):
				current_state = STATE.ATTACKING_ULTI
			
			if input_dir == Vector2.ZERO:
				current_state = STATE.IDLE
			else:
				current_state = STATE.RUNNING
		STATE.ATTACKING_ULTI:
			anim.play("ulti")
			ulti_attack()
			await animation_done
			
			if Input.is_action_just_pressed("BasicAttack"):
				current_state = STATE.ATTACKING
			
			if input_dir == Vector2.ZERO:
				current_state = STATE.IDLE
			else:
				current_state = STATE.RUNNING
		STATE.HURTED:
			anim.play("hurt")
			await animation_done
			
			if Input.is_action_just_pressed("BasicAttack"):
				current_state = STATE.ATTACKING
			
			if Input.is_action_just_pressed("Ulti"):
				current_state = STATE.ATTACKING_ULTI
			
			if input_dir == Vector2.ZERO:
				current_state = STATE.IDLE
			else:
				current_state = STATE.RUNNING
		STATE.DEAD:
			anim.play("death")
			velocity = Vector2.ZERO


func take_damage():
	if invulnerable:
		return  # No recibe daño si está en cooldown

	invulnerable = true
	$DamageTimer.start()

	if health > 0:
		health -= 1
		SignalManager.took_damage.emit(health)
		current_state = STATE.HURTED

	if health <= 0:
		current_state = STATE.DEAD
		await animation_done
		queue_free()


func basic_attack() -> void:
	var dir := get_attack_direction()
	#emit_signal("player_attack", dir)
	#anim.play("BasicAttack")

		# DEBUG: posición y tamaño del area
	#print("AttackArea global_pos:", attack_area.global_position, "shape:", attack_area.get_node("CollisionShape2D").shape)

		# Opción robusta: tomar cuerpos superpuestos AHORA mismo
	var bodies := attack_area.get_overlapping_bodies()
	print("Bodies overlapped (count):", bodies.size())
	for b in bodies:
		print(" - found:", b, " groups:", b.get_groups())
		if b and b.is_in_group("enemies"):
			if b.has_method("die"):
				b.die()

func ulti_attack() -> void:
	var dir := get_attack_direction()
	#emit_signal("player_attack", dir)
	#anim.play("BasicAttack")

		# DEBUG: posición y tamaño del area
	#print("AttackArea global_pos:", attack_area.global_position, "shape:", attack_area.get_node("CollisionShape2D").shape)

		# Opción robusta: tomar cuerpos superpuestos AHORA mismo
	var bodies := ulti_area.get_overlapping_bodies()
	print("Bodies overlapped ULTI(count):", bodies.size())
	for b in bodies:
		print(" - found:", b, " groups:", b.get_groups())
		if b and b.is_in_group("enemies"):
			if b.has_method("die"):
				b.die()

func get_attack_direction() -> Vector2:
	return (get_global_mouse_position() - global_position).normalized()

func _on_anim_finished() -> void:
	# cuando termina attack o ulti, volver a idle
	if anim.animation == "BasicAttack": #or anim.animation == "ulti":
		pass#anim.play("walk")


func _on_daño_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		apply_knockback(body.global_position)
		if body.isDead == false:
			take_damage()

func apply_knockback(from_position: Vector2, force := 180.0):
	current_state = STATE.HURTED
	var direction = (global_position - from_position).normalized()
	knockback = direction * force


func _on_damage_timer_timeout() -> void:
	invulnerable = false
