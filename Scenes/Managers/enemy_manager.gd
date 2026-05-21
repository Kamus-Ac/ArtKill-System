extends Node

@export var enemy_scene: PackedScene
@export var spawn_radius := 950 #radio en el que spawnean
@export var initial_spawn_count := 3 #cuántos al inicio
@export var spawn_increase_per_wave := 15 #cuantos incrementan por ronda
@export var max_enemies_per_wave := 105 #cuantos puede haber por ronda 
@export var spawn_delay := 0.4  # timpo entre cada spawn

#var current_wave := 1
var enemies_alive := 0
var player
var waves_paused := false

func _ready():
	player = get_tree().get_first_node_in_group("player") as Node2D
	GameManager.current_wave = 1
	#conectar el boss
	SignalManager.boss_spawned.connect(_on_boss_spawned)
	SignalManager.boss_defeated.connect(_on_boss_defeated)
	start_wave()

func _on_boss_spawned():
	waves_paused = true
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in all_enemies:
		if "skins" in enemy:
			enemy.queue_free()
	enemies_alive = 0
	
func _on_boss_defeated():
	waves_paused = false
	if enemies_alive <= 0 and player:
		GameManager.current_wave += 1
		if GameManager.current_wave < 4:
			SignalManager.unlockedzones.emit(GameManager.current_wave)
		start_wave()
		
func start_wave():
	if waves_paused:
		return
		
	print("=== STARTING WAVE", GameManager.current_wave, "===")
	
	
	var enemies_to_spawn = min(
		initial_spawn_count + (GameManager.current_wave - 1) * spawn_increase_per_wave,
		max_enemies_per_wave
	)
	
	enemies_alive = enemies_to_spawn
	print("Enemies this wave:", enemies_to_spawn)
	
	spawn_wave(enemies_to_spawn)

func spawn_wave(count: int) -> void:
	if not player:
		push_warning("No player found in the scene!")
		return

	for i in range(count):
		if waves_paused:
			enemies_alive -= (count - i)
			break
			
		var dir := Vector2.RIGHT.rotated(randf_range(0, TAU))
		var spawn_pos = player.global_position + dir * (spawn_radius + randf_range(0,20))
		
		var enemy = enemy_scene.instantiate()
		get_parent().add_child.call_deferred(enemy)
		enemy.global_position = spawn_pos

		# Conectar señal de muerte
		enemy.died.connect(_on_enemy_died)

		# Esperar un poco antes de spawnear el siguiente
		if spawn_delay > 0:
			await get_tree().create_timer(spawn_delay).timeout

func _on_enemy_died():
	enemies_alive -= 1
	print("Enemy died. Alive:", enemies_alive)
	
	if enemies_alive <= 0 and player and not waves_paused:
		GameManager.current_wave += 1
		if GameManager.current_wave <4:
			#pausamos las waves
			waves_paused = true
			SignalManager.unlockedzones.emit(GameManager.current_wave)
		else:
			start_wave()
