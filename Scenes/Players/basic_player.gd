extends CharacterBody2D

signal animation_done

var player_hitbox_col: CollisionShape2D 
var ulti_area: CollisionShape2D
var damage_area: Area2D
var areas: Node2D 
var recolect: Area2D


@onready var anim: AnimatedSprite2D = $Flip/AnimatedSprite2D
@onready var flip: Node2D = $Flip
@onready var marker_2d: Marker2D = $Marker2D
@onready var character_holder: Node2D = $CharacterScene
@export var character_data: CharacterData
var character_loaded : Node2D

var rotation_dir : Vector2
var current_dir : DIRECTION

#Ulti
var ulti_script: Node2D
var isUltiActive : bool = false
var isUltiAvailable : bool = false
var kill_count : int = 0
var ulti_kills_required : int = 7

#---VIDA---#
#var hearts_list: Array[TextureRect]
var max_health
var health
var invulnerable := false
const DAMAGE_COOLDOWN := 0.8   # tiempo en segundos
const ULT_COOLDOWN := 10.0 #tiempo en segundos

#No estoy de acuerdo con esto que voy a hacer, pero es lo más rápido.
var up : bool = false
var down : bool = false
var left : bool = false
var right : bool = false

enum DIRECTION{
	UP,
	UP_LEFT,
	UP_RIGHT,
	DOWN,
	DOWN_LEFT,
	DOWN_RIGHT,
	LEFT,
	RIGHT,
	STILL
}

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
var normal_velocity := Vector2.ZERO
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
var lastobject: RigidBody2D = null
var grabbing: bool = false


func _ready() -> void:
	if GameManager.selected_character:
		MAX_SPEED = GameManager.selected_character.max_speed
		max_health = GameManager.selected_character.max_health
		health = max_health
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
	recolect = character_loaded.get_node("Areas/Recolect")
	recolect.body_entered.connect(_on_recolect_body_entered)
	damage_area.body_entered.connect(_on_daño_body_entered)


func _physics_process(delta: float) -> void:
	#var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	#var iso_dir = cartesian_to_isometric(input_dir)
	
# knockback siempre suma fuerza, no cancela movimiento
	if knockback.length() > 10:
		knockback = knockback.move_toward(Vector2.ZERO, knockback_decay)
	else:
		knockback = Vector2.ZERO




	get_input()
	set_direction()
	match_states(delta)
	grab_and_throw()
	flip_sprite()
	rotate_object()

func cartesian_to_isometric(cartesian):
	return Vector2(cartesian.x - cartesian.y, (cartesian.x+cartesian.y) / 2)
	

func get_input():
	up = Input.is_action_pressed("Up")
	down = Input.is_action_pressed("Down")
	left = Input.is_action_pressed("Left")
	right = Input.is_action_pressed("Right")

func set_direction():
	if up:
		if left:
			current_dir = DIRECTION.UP_LEFT
		elif right:
			current_dir = DIRECTION.UP_RIGHT
		else: current_dir = DIRECTION.UP
	elif down:
		if left:
			current_dir = DIRECTION.DOWN_LEFT
		elif right:
			current_dir = DIRECTION.DOWN_RIGHT
		else: current_dir = DIRECTION.DOWN
	elif left:
		current_dir = DIRECTION.LEFT
	elif right:
		current_dir = DIRECTION.RIGHT
	else: current_dir = DIRECTION.STILL

func move(delta: float):
	if !isUltiActive:
		match current_dir:
			DIRECTION.UP:
				normal_velocity = Vector2(0,-MAX_SPEED)
				#anim.play
			DIRECTION.DOWN:
				normal_velocity = Vector2(0,MAX_SPEED)
				anim.play("down")
			DIRECTION.LEFT:
				normal_velocity = Vector2(-MAX_SPEED, 0)
				anim.play("horizontal")
			DIRECTION.RIGHT:
				normal_velocity = Vector2(MAX_SPEED, 0)
				anim.play("horizontal")
			DIRECTION.UP_LEFT:
				normal_velocity = cartesian_to_isometric(Vector2(-MAX_SPEED, 0))
			DIRECTION.UP_RIGHT:
				normal_velocity = cartesian_to_isometric(Vector2(0, -MAX_SPEED))
			DIRECTION.DOWN_LEFT:
				normal_velocity = cartesian_to_isometric(Vector2(0, MAX_SPEED))
			DIRECTION.DOWN_RIGHT:
				normal_velocity = cartesian_to_isometric(Vector2(MAX_SPEED, 0))
			DIRECTION.STILL:
				normal_velocity = Vector2(0,0)
	
	velocity = velocity.lerp(normal_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
	# suma knockback
	velocity += knockback
	move_and_slide()

func match_states(delta: float):
	match current_state:
		STATE.IDLE:
			anim.play("idle")
			
			if current_dir != DIRECTION.STILL:
				current_state = STATE.RUNNING
			
			elif Input.is_action_just_pressed("BasicAttack"):
				current_state = STATE.ATTACKING
			
			elif Input.is_action_just_pressed("Ulti") and isUltiAvailable:
				current_state = STATE.ATTACKING_ULTI
				
		STATE.RUNNING:
			
			move(delta)
			
			if normal_velocity == Vector2.ZERO:
				current_state = STATE.IDLE
			
			elif Input.is_action_just_pressed("BasicAttack"):
				current_state = STATE.ATTACKING
			
			elif Input.is_action_just_pressed("Ulti") and isUltiAvailable:
				current_state = STATE.ATTACKING_ULTI
			

				
		STATE.ATTACKING:
			move(delta)
			anim.play("basicAttack")
			player_hitbox_col.disabled = false
			
		STATE.ATTACKING_ULTI:
			if !isUltiActive:
				isUltiActive = true
				isUltiAvailable = false
				ulti_script.start(self)
			ulti_script.ulti_move(delta)
			SignalManager.ult_used.emit()
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
	SignalManager.took_damage.emit(health, max_health)
	current_state = STATE.HURTED
	apply_knockback(from_position)
	
	if health <= 0:
		current_state = STATE.DEAD
		await animation_done
		queue_free()

func grab_and_throw():
	isClickBeingPressed = false
	if object:
		if !grabbing:
			grab_objects()
			#print("agarra")
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

	lastobject= object
	object = null
	"""print("objeto puesto nulo") sucedia que el objeto volvia a entrar por ciertos frames al area2d 
	haciendo que otra vez se añadiera al jugador porque aun se detectaba el input antes del lastclickstate"""
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
		isUltiAvailable = false
		ulti_area.disabled = true
		kill_count = 0
		current_state = STATE.IDLE
	
	elif current_state in [STATE.ATTACKING, STATE.HURTED]:
		player_hitbox_col.disabled = true
		current_state = STATE.IDLE

func _on_daño_body_entered(body: Node2D) -> void:
	if invulnerable:
		return
		
	if isUltiActive:
		return

	if body.is_in_group("enemies") and not body.isDead:
		take_damage(body.global_position)

func _on_damage_timer_timeout() -> void:
	invulnerable = false

func _on_recolect_body_entered(body: Node2D) -> void:
	if !object and body!=lastobject: #Esta linea se agregó para evitar el bug del throwobject
		if body.is_in_group("objects"):
			object = body
			#print("nuevo objeto")
		
		
	#print("ENTRÓ:", body)
	#if body.is_in_group("objects"):
		#object = body

func _on_enemy_killed():
	kill_count += 1
	SignalManager.kill_count.emit(kill_count)
	print("Kills:", kill_count)

	if kill_count >= ulti_kills_required:
		isUltiAvailable = true
		print("ULTI LISTA")
