extends CharacterBody2D

signal animation_done
var player_hitbox_col: CollisionShape2D 
var ulti_area: CollisionShape2D
var damage_area: Area2D
var ulti_script: Node2D
var areas: Node2D 
@onready var anim: AnimatedSprite2D = $Flip/AnimatedSprite2D
@onready var flip: Node2D = $Flip
@onready var marker_2d: Marker2D = $Marker2D
@onready var character_holder: Node2D = $CharacterScene
@export var character_data: CharacterData
var character_loaded : Node2D

#Ulti
var isUltiActive : bool = false

#---VIDA---#
#var hearts_list: Array[TextureRect]
var health
var invulnerable := false
const DAMAGE_COOLDOWN := 0.8   # tiempo en segundos



#Ideas a mejorar:
#Cooldown para ataque básico, checar animacion de ataque (en general todas las animaciones)
#ia enemigos
enum STATE {
	IDLE,
	RUNNING,
	ATTACKING,
	ATTACKING_ULTI,
	HURTED,
	DEAD
}

var MAX_SPEED: int
const ACCELERATION_SMOOTHING := 18
var current_state: STATE = STATE.IDLE
var normal_veloocity := Vector2.ZERO
var knockback := Vector2.ZERO
var knockback_decay := 8.0 # qué tan rápido se detiene el empujón

#flip sprite
var mouse_position: Vector2 = Vector2.ZERO
var flip_position: Vector2 = Vector2.ZERO

#throw and grab object
var lastClickState: bool = false
var isClickBeingPressed: bool = false
var factor: float = 1.0 # Factor de velocidad conforme mantienes el click
var objectPosition: Vector2 = Vector2.ZERO
var object: RigidBody2D = null
var grabbing: bool = false


func _ready() -> void:

	if GameManager.selected_character:
		MAX_SPEED = GameManager.selected_character.max_speed
		health = GameManager.selected_character.max_health
		anim.sprite_frames = GameManager.selected_character.sprite
		
		load_character(GameManager.selected_character.character_scene)

	# asegurar que la animación ataque no esté en loop desde el editor
	# conectar la señal para volver a idle al terminar
	if anim:
		anim.animation_finished.connect(_on_anim_finished)

	
	
func load_character(module_scene: PackedScene):
	character_loaded = module_scene.instantiate()
	character_holder.add_child(character_loaded)
	ulti_script = character_loaded.get_node("UltiScript")
	player_hitbox_col = character_loaded.get_node("Areas/Player_Hitbox/CollisionShape2D")
	ulti_area = character_loaded.get_node("Areas/Ulti_Area/CollisionShape2D")
	damage_area = character_loaded.get_node("Areas/Daño")
	areas = character_loaded.get_node("Areas")
	damage_area.body_entered.connect(_on_daño_body_entered)


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
# knockback siempre suma fuerza, no cancela movimiento
	if knockback.length() > 10:
		knockback = knockback.move_toward(Vector2.ZERO, knockback_decay)
	else:
		knockback = Vector2.ZERO

# movimiento normal
	if !isUltiActive:
		normal_veloocity = input_dir * MAX_SPEED
		velocity = velocity.lerp(normal_veloocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))

# suma knockback
	velocity += knockback


	move_and_slide()
	match_states(input_dir, delta)
	grab_and_throw()
	flip_sprite()
	rotate_object()


	
	


func match_states(input_dir: Vector2, delta: float):
	match current_state:
		STATE.IDLE:
			anim.play("idle")
			
			if input_dir != Vector2.ZERO:
				current_state = STATE.RUNNING
			
			elif Input.is_action_just_pressed("BasicAttack"):
				current_state = STATE.ATTACKING
			
			elif Input.is_action_just_pressed("Ulti"):
				current_state = STATE.ATTACKING_ULTI
				
		STATE.RUNNING:
			anim.play("run")
			
			if input_dir == Vector2.ZERO:
				current_state = STATE.IDLE
				
			elif Input.is_action_just_pressed("BasicAttack"):
				current_state = STATE.ATTACKING
			
			elif Input.is_action_just_pressed("Ulti"):
				current_state = STATE.ATTACKING_ULTI
			
		STATE.ATTACKING:
			anim.play("basicAttack")
			player_hitbox_col.disabled = false
			
		STATE.ATTACKING_ULTI:
			if !isUltiActive:
				isUltiActive = true
				ulti_script.start(self)
				
			ulti_script.ulti_move(delta)
			anim.play("ulti")
			ulti_area.disabled = false
				
		STATE.HURTED:
			anim.play("hurt")
			
		STATE.DEAD:
			anim.play("death")
			velocity = Vector2.ZERO

func take_damage(from_position: Vector2):
	if invulnerable or current_state == STATE.DEAD:
		return  # No recibe daño si está en cooldown

	invulnerable = true
	$DamageTimer.start()
	
	health -= 1
	SignalManager.took_damage.emit(health)
	current_state = STATE.HURTED
	apply_knockback(from_position)
	
	if health <= 0:
		current_state = STATE.DEAD
		await animation_done
		queue_free()



func ulti_attack() -> void:
	pass

func grab_and_throw():
	isClickBeingPressed = false
	if object:
		if !grabbing:
			grab_objects()
			print("agarra")
		if Input.is_action_pressed("Grab") and grabbing:
			isClickBeingPressed = true
			lastClickState = isClickBeingPressed
			if factor < 5: # El valor maximo del factor es 5
				factor += 0.1 # Se suma 0.1 al factor cada frame
			
		if lastClickState == true and isClickBeingPressed == false:
			grabbing = false
			throw_object()
			lastClickState = false

func grab_objects():
	if Input.is_action_just_pressed("Grab"):
		grabbing = true
		object.get_parent().remove_child(object)
		marker_2d.add_child(object)
		var col = object.get_node("CollisionTF")
		col.disabled = true
		object.linear_velocity = Vector2.ZERO
		object.position = Vector2(25, 0)

func throw_object():
	var root = get_tree().current_scene
	var pos = object.global_position

	object.get_parent().remove_child(object)
	root.add_child(object)
	object.get_node("CollisionTF").disabled = false
	object.position = pos
	object.apply_impulse(flip_position * -factor)

	object = null
	grabbing = false
	lastClickState = false
	factor = 1.0

func flip_sprite():
	mouse_position = get_global_mouse_position()
	flip_position = position - mouse_position
	areas.scale.x = 1 if flip_position.x < 0 else -1
	flip.scale.x = 1 if flip_position.x < 0 else -1

func rotate_object():
	marker_2d.look_at(get_global_mouse_position())

func apply_knockback(from_position: Vector2, force := 180.0):
	var direction = (global_position - from_position).normalized()
	knockback = direction * force

#---SEÑALES---#
func _on_anim_finished():
	emit_signal("animation_done")
	
	if current_state == STATE.ATTACKING_ULTI:
		isUltiActive = false
		ulti_area.disabled = true
		current_state = STATE.IDLE
		
	elif current_state in [STATE.ATTACKING, STATE.HURTED]:
		player_hitbox_col.disabled = true
		current_state = STATE.IDLE

func _on_daño_body_entered(body: Node2D) -> void:
	if isUltiActive:
		return
	if body.is_in_group("enemies") and not body.isDead:
		take_damage(body.global_position)

func _on_damage_timer_timeout() -> void:
	invulnerable = false

func _on_recolect_body_entered(body: Node2D) -> void:
	if body.is_in_group("objects"):
		object = body
