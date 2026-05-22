extends CharacterBody2D

signal died

const MAX_SPEED := 60.0

@export var max_health: int = 5
@export var boss_projectile_scene : PackedScene
@onready var shoot_timer : Timer = $ShootTimer
@onready var anim = $AnimatedSprite2D
@onready var player = get_tree().get_first_node_in_group("player")

var health: int
var is_dead: bool = false

enum STATE {
	CHASING,
	DEAD
}

var current_state: STATE = STATE.CHASING

func _ready() -> void:
	health = max_health
	shoot_timer.wait_time = 10.0
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	anim.play("Idle")
	var player  = get_tree().get_first_node_in_group("player")
	#if player:
		#self.died.connect(player._on_enemy_killed)

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
		return(player_node.global_position - global_position).normalized()
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
	var random_head = enemy_heads.pick_random()
	projectile.set_projectile_texture(random_head["texture"])
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position
	print("Boss disparo misil")
	
func die(hit):
	if hit is Player_Hitbox and !is_dead:
		health -= 1
		if player:
			player.audio_manager.play_punch()
		flash_damage()
		queue_redraw()
		
		if health <= 0:
			is_dead = true
			GameManager.timeToUlt += 1
			current_state = STATE.DEAD
			shoot_timer.stop()
			velocity = Vector2.ZERO
			set_physics_process(false)
			anim.play("death")
			await anim.animation_finished
			emit_signal("died")
			SignalManager.boss_defeated.emit()
			
func flash_damage():
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
func _process(delta):
	if current_state != STATE.DEAD:
		flip_sprite()
	
func flip_sprite():
	anim.flip_h = player.global_position.x < global_position.x
	
var enemy_heads = [
	{
		"texture": preload("res://Scenes/Enemies/Boss/IA_CHatgps.png"),
	},
	{
		"texture": preload("res://Scenes/Enemies/Boss/IA_Damage_yarbis1.png"),
	},
	{
		"texture": preload("res://Scenes/Enemies/Boss/IA_DeepSeek_Hurt1.png"),
	},
	{
		"texture": preload("res://Scenes/Enemies/Boss/IA_SimSimi_Hurt1.png"),
	},
	{ 
		"texture": preload("res://Scenes/Enemies/Boss/IA_Siri_Hurt1.png"),
	},
	{
		"texture": preload("res://Scenes/Enemies/Boss/Cabeza_copilot.png"),
	},
]
