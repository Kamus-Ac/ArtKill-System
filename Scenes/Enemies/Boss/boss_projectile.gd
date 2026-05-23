extends Node2D

const SPEED := 200.0
const LIFETIME := 5.0
const BLINK_START := 1.5
const EXPLOSION_RADIUS := 60.0
const CONTACT_DISTANCE := 30.0
const EXPLOSION_DAMAGE := 1

@onready var life_timer: Timer = $LifeTimer
@onready var proyectil: Sprite2D = $Sprite2D
@onready var explosion_anim: AnimatedSprite2D = $ExplosionAnim
var is_exploded: bool = false

func _ready():
	life_timer.wait_time = LIFETIME
	life_timer.one_shot = true
	life_timer.start()
	life_timer.timeout.connect(_on_life_timer_timeout)

func _physics_process(delta):
	if is_exploded:
		return

	#perseguir al jugador
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player:
		var direction = (player.global_position - global_position).normalized()
		global_position += direction * SPEED * delta

		#explotar si te toca
		if global_position.distance_to(player.global_position) <= CONTACT_DISTANCE:
			explode()
			return

	#advertencia al explotar (parpadeo que acelera)
	var time_left = life_timer.time_left
	if time_left <= BLINK_START and time_left > 0:
		var ratio = 1.0 - (time_left / BLINK_START)
		var blink_speed = lerp(6.0, 25.0, ratio)
		visible = sin(Time.get_ticks_msec() * 0.001 * blink_speed * TAU) > 0.0

func _on_life_timer_timeout():
	explode()

func explode():
	if is_exploded:
		return
	is_exploded = true
	visible = true
	set_physics_process(false)
	#verificar si el jugador está dentro del radio de explosión y aplicar daño
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance <= EXPLOSION_RADIUS:
			# acceder al componente de salud del jugador
			var health_comp = player.health_component
			if health_comp and not player.isInvulnerable:
				health_comp.apply_damage(EXPLOSION_DAMAGE)
				health_comp.set_temporary_invulnerable(1.5)
				player.apply_knockback(global_position, 250.0)
				print("Proyectil del Boss hizo daño al jugador")
	proyectil.visible = false 
	explosion_anim.visible = true
	explosion_anim.play("explode")
	await explosion_anim.animation_finished
	queue_free()
	
func set_projectile_texture(texture):
	$Sprite2D.texture = texture
	
	
