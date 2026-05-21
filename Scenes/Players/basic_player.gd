extends CharacterBody2D

signal animation_done

#Areas

var areas: Node2D 
var player_hitbox_col: CollisionShape2D  #Player Hitbox
var ulti_area: CollisionShape2D #Player Hitbox de la Ulti
var damage_area: Area2D #Player Hurtbox
var recolect: Area2D #Recolección de Objetos

#Particles
var dashParticles: GPUParticles2D


#Vida
var health_component: Player_Health



@onready var anim: AnimatedSprite2D = $Flip/AnimatedSprite2D
@onready var flip: Node2D = $Flip
@onready var marker_2d: Marker2D = $Marker2D
@onready var character_holder: Node2D = $CharacterScene
@onready var dust_particles_position: Marker2D = $ParticlesPosition
@export var character_data: CharacterData
var dust_particles_scene = preload("res://Scenes/Particles/DustStepParticles.tscn")
var character_loaded : Node2D


@onready var audio_manager = $AudioManager
var footstep_timer := 0.0
@export var footstep_interval := 0.28
var character_sound_played := false
var ability_sound_played := false

var current_dir : DIRECTION

#Ulti
var ulti_script: Node2D
var isUltiActive : bool = false
var isUltiAvailable : bool = false
var kill_count : int = 0
const ULT_COOLDOWN := 10.0 #tiempo en segundos
var isInvulnerable : bool = false
var state_locked : bool = false
var is_ulti_recovery := false
var ulti_in_progress := false

#No estoy de acuerdo con esto que voy a hacer, pero es lo más rápido.
var up : bool = false
var down : bool = false
var left : bool = false
var right : bool = false
var look_dir: Vector2 = Vector2.ZERO

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
var knockback_decay := 700.0 # qué tan rápido se detiene el empujón

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
		if anim == null:
			print("ERROR: anim es null")
		else:
			anim.sprite_frames = GameManager.selected_character.sprite
		
		load_character(GameManager.selected_character.character_scene)

	# asegurar que la animación ataque no esté en loop desde el editor
	# conectar la señal para volver a idle al terminar
	if anim:
		anim.animation_finished.connect(_on_anim_finished)
		
	add_to_group("player")

	
	
func load_character(module_scene: PackedScene):
	character_loaded = module_scene.instantiate()
	
	dashParticles = character_loaded.get_node("UltiParticles")
	if dashParticles:
		dashParticles.emitting = false
	character_holder.add_child(character_loaded)
	health_component = character_loaded.get_node("Player_Health")
	health_component.health_depleted.connect(_on_health_health_depleted)
	ulti_script = character_loaded.get_node("UltiScript")
	player_hitbox_col = character_loaded.get_node("Areas/Player_Hitbox/CollisionShape2D")
	ulti_area = character_loaded.get_node("Areas/Ulti_Area/CollisionShape2D")
	damage_area = character_loaded.get_node("Areas/Player_Hurtbox")
	damage_area.received_damage.connect(_on_player_received_damage)
	areas = character_loaded.get_node("Areas")
	recolect = character_loaded.get_node("Areas/Recolect")
	recolect.body_entered.connect(_on_recolect_body_entered)



func _physics_process(delta: float) -> void:
	
	if isUltiActive:
		ulti_script.ulti_move(delta)
		
	if current_state == STATE.DEAD:
		return
	
# knockback siempre suma fuerza, no cancela movimiento
	if knockback.length() > 10:
		knockback = knockback.move_toward(Vector2.ZERO, knockback_decay* delta)
	else:
		knockback = Vector2.ZERO
	
	# Si se está moviendo
	if current_dir != DIRECTION.STILL:
		footstep_timer += delta

		if footstep_timer >= footstep_interval:
			audio_manager.play_footstep()
			footstep_timer = 0.0
			
			#particulas
			var particles_instance = dust_particles_scene.instantiate()
			particles_instance.global_position = dust_particles_position.global_position
			get_tree().current_scene.add_child(particles_instance)
			
	else:
		# si se detiene, reinicia el timer
		footstep_timer = 0.0
	
	get_input()
	set_direction()
	match_states(delta)
	grab_and_throw()
	flip_sprite()
	rotate_object()
	_loading_ult(delta)

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
	if current_state != STATE.HURTED and current_state != STATE.ATTACKING and !isUltiActive:
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
				anim.play("diagonalArriba")
			DIRECTION.UP_RIGHT:
				normal_velocity = cartesian_to_isometric(Vector2(0, -MAX_SPEED))
				anim.play("diagonalArriba")
			DIRECTION.DOWN_LEFT:
				normal_velocity = cartesian_to_isometric(Vector2(0, MAX_SPEED))
				anim.play("diagonalAbajo")
			DIRECTION.DOWN_RIGHT:
				normal_velocity = cartesian_to_isometric(Vector2(MAX_SPEED, 0))
				anim.play("diagonalAbajo")
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
				character_sound_played = false
				current_state = STATE.ATTACKING
			
			elif Input.is_action_just_pressed("Ulti") and isUltiAvailable and !ulti_in_progress:
				ulti_in_progress = true
				ability_sound_played = false
				current_state = STATE.ATTACKING_ULTI
				
		STATE.RUNNING:
			
			if normal_velocity == Vector2.ZERO:
				current_state = STATE.IDLE
			
			elif Input.is_action_just_pressed("BasicAttack"):
				character_sound_played = false
				current_state = STATE.ATTACKING
			
			elif Input.is_action_just_pressed("Ulti") and isUltiAvailable and !ulti_in_progress:
				ulti_in_progress = true
				ability_sound_played = false
				current_state = STATE.ATTACKING_ULTI
				
		STATE.ATTACKING:
			
			match current_dir:
				DIRECTION.UP, DIRECTION.UP_LEFT, DIRECTION.UP_RIGHT:
					anim.play("basicAttackDiagonalArriba")
			
				DIRECTION.DOWN, DIRECTION.DOWN_LEFT, DIRECTION.DOWN_RIGHT:
					anim.play("basicAttackDiagonalAbajo")
				
				DIRECTION.LEFT, DIRECTION.RIGHT:
					anim.play("basicAttack")
						
			player_hitbox_col.disabled = false
			
			if !character_sound_played:
				character_sound_played = true
				match GameManager.selected_character.character_name:
					"Dani":
						audio_manager.play_idol_attack()
			
		STATE.ATTACKING_ULTI:

			if !isUltiActive:
			
				isUltiActive = true
				isUltiAvailable = false
	
				ulti_script.start(self)
			
				# invulnerabilidad
				isInvulnerable = true
				# evitar movimiento normal
				normal_velocity = Vector2.ZERO
				velocity = Vector2.ZERO
				
				if dashParticles:
					dashParticles.emitting = true

				ulti_area.disabled = false

				if !ability_sound_played:
					ability_sound_played = true

					match GameManager.selected_character.character_name:
						"Dani":
							audio_manager.play_idol_ability()
			
				anim.play("ulti")
			
		STATE.HURTED:
			pass
			
		STATE.DEAD:
			pass
		
	move(delta)


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
	object.apply_impulse(look_dir * factor* 50)

	lastobject= object
	object = null
	grabbing = false
	lastClickState = false
	factor = 1.0

func flip_sprite():
	areas.scale.x = 1 if look_dir.x > 0 else -1
	flip.scale.x = 1 if look_dir.x > 0 else -1
	dashParticles.scale.x = 1 if look_dir.x > 0 else -1

func rotate_object():
	if look_dir.length() > 0.0:
		marker_2d.look_at(global_position + look_dir * 100.0)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if !event.relative.is_zero_approx():
			look_dir = (get_global_mouse_position()-global_position).normalized()
	if event is InputEventJoypadMotion:
		if event.axis == JOY_AXIS_RIGHT_X or event.axis== JOY_AXIS_RIGHT_Y:
			look_dir = Input.get_vector("LookLeft", "LookRight", "LookUp", "LookDown")



func apply_knockback(from_position: Vector2, force := 180.0):
	var direction = (global_position - from_position).normalized()
	knockback = direction * force


func _finish_ulti_recovery():
	isInvulnerable = false
	state_locked = false
	is_ulti_recovery = false
	isUltiActive = false
	ulti_area.disabled = true
	if dashParticles:
		dashParticles.emitting = false

	kill_count = 0
	GameManager.timeToUlt = 0
	SignalManager.ult_used.emit()
	current_state = STATE.IDLE
	anim.play("idle")

#---SEÑALES---#

func _on_anim_finished():
	emit_signal("animation_done")

	if current_state == STATE.ATTACKING_ULTI:
		isUltiActive = false
		ulti_area.disabled = true
		
		if dashParticles:
			dashParticles.emitting = false
		
		kill_count = 0
		GameManager.timeToUlt = 0
		isUltiAvailable = false
		ulti_in_progress = false
		SignalManager.ult_used.emit()
		
		current_state = STATE.IDLE
		await get_tree().create_timer(2.0).timeout
		isInvulnerable = false
		
	elif current_state in [STATE.ATTACKING, STATE.HURTED]:
		player_hitbox_col.disabled = true
		current_state = STATE.IDLE


func _on_recolect_body_entered(body: Node2D) -> void:
	if !object and body!=lastobject: #Esta linea se agregó para evitar el bug del throwobject
		if body.is_in_group("objects"):
			object = body


func _on_health_health_depleted():

	if isInvulnerable:
		return
	
	if current_state == STATE.DEAD:
		return

	current_state = STATE.DEAD

	anim.play("death")

	velocity = Vector2.ZERO

	await anim.animation_finished

	SignalManager.gameOver.emit()

	visible = false

func _on_player_received_damage(_damage: int, from_position: Vector2):

	if isInvulnerable:
		return

	apply_knockback(from_position)

	anim.modulate = Color(1, 0.2, 0.2)

	await get_tree().create_timer(0.12).timeout

	anim.modulate = Color(1, 1, 1)


func _on_enemy_killed():
	audio_manager.play_punch()
	GameManager.timeToUlt += 1
	print("timeToUlt: %.2f" %GameManager.timeToUlt)

func _loading_ult(_delta: float):
	GameManager.timeToUlt+=_delta
	if GameManager.timeToUlt >= GameManager.ulti_kills_required:
		isUltiAvailable=true
