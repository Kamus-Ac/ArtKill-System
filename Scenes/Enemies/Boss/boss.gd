extends CharacterBody2D

signal died

const MAX_SPEED := 60.0

@export var max_health: int = 5
@export var boss_projectile_scene : PackedScene

@onready var shoot_timer : Timer = $ShootTimer

var health: int
var is_dead: bool = false

enum STATE {
	CHASING,
	DEAD
}

var current_state: STATE = STATE.CHASING

func _ready() -> void:
	health = max_health
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	
	var player  = get_tree().get_first_node_in_group("player")
	if player:
		self.died.connect(player._on_enemy_killed)

func _physics_process(_delta):
	match current_state:
		STATE.CHASING:
			var direction = get_direction_to_player()
			velocity = direction * MAX_SPEED
			move_and_slide()
		STATE.DEAD:
			velocity = Vector2.ZERO
			
func get_direction_to_player() -> Vector2:
	var player_node = get_tree().get_first_node_in_group("player") as Node2D
	if player_node != null:
		return(player_node.global_position - global_position).noramlized()
	return Vector2.ZERO
	
func _on_shoot_timer_timeout():
	if current_state == STATE.DEAD:
		return
	shoot_projectile()
	
func shoot_projectile():
	if boss_projectile_scene == null:
		push_warning("Boss: boss_projectile_scene no asignada!")
		return
	
	var projectile = boss_projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position
	print("Boss disparo misil")
	
func die(hit):
	if hit is Player_Hitbox and !is_dead:
		health -= 1
		flash_damage()
		queue_redraw()
		
		if health <= 0:
			is_dead = true
			current_state = STATE.DEAD
			shoot_timer.stop()
			emit_signal("died")
			SignalManager.boss_defeated.emit()
			queue_free()
			
func flash_damage():
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	#prueba, quitar al poner los sprites
func _draw():
	# Cuerpo del boss - círculo rojo grande
	draw_circle(Vector2(0, -15), 22, Color(0.15, 0.15, 0.15))
	draw_circle(Vector2(0, -15), 20, Color(0.8, 0.1, 0.1))
	draw_circle(Vector2(0, -15), 16, Color(1.0, 0.2, 0.2))

	# Corona para indicar que es el boss
	var crown_points = PackedVector2Array([
		Vector2(-10, -40), Vector2(-6, -34), Vector2(-2, -42),
		Vector2(2, -34), Vector2(6, -40), Vector2(10, -34),
		Vector2(10, -30), Vector2(-10, -30)
	])
	draw_colored_polygon(crown_points, Color(1.0, 0.85, 0.0))

	# Barra de vida - fondo
	var bar_width := 40.0
	var bar_height := 4.0
	var bar_y := -50.0
	draw_rect(Rect2(-bar_width / 2, bar_y, bar_width, bar_height), Color(0.2, 0.2, 0.2))

	# Barra de vida - relleno
	var health_ratio := float(health) / float(max_health)
	var fill_color: Color
	if health_ratio > 0.5:
		fill_color = Color(0.0, 1.0, 0.0)
	elif health_ratio > 0.25:
		fill_color = Color(1.0, 0.5, 0.0)
	else:
		fill_color = Color(1.0, 0.0, 0.0)
	draw_rect(Rect2(-bar_width / 2, bar_y, bar_width * health_ratio, bar_height), fill_color)
	
