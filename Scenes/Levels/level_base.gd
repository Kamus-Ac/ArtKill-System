extends Node2D

var i = 0

@onready var texture_rect: TextureRect = $CanvasLayer/TextureRect
@onready var label_score: RichTextLabel = $CanvasLayer/Score
@onready var label_combo: RichTextLabel = $CanvasLayer/Combo
@onready var first_wall: StaticBody2D = $NorthWall
@onready var mini_map: TextureRect = $CanvasLayer/MiniMap
@onready var pause_menu: Control = $GameCamera/CanvasLayer2/pause_menu

@export var point1: Vector2 = Vector2(-550,-150)
@export var point2: Vector2 = Vector2(-30,115)

var curacion = preload("res://Scenes/Objects/Curacion/Curacion.tscn")

var percentage_ult: float = 0
var ult_bar_scale: float = 244.0

var reload: bool = false
var timer: Timer
var dynamictimer: Timer 
var tween_combo : Tween

var paused = false
var kill_acumulated : int
var time_forCombo: float = 4.0
var dynamic_score : float
var previous_score: float

# NUEVO
var spawn_timer: Timer
const MAX_CURACIONES := 5


func get_random_point(p1: Vector2, p2: Vector2) -> Vector2:

	var x: float = randf_range(p1.x, p2.x)
	var y: float = randf_range(p1.y, p2.y)

	return Vector2(x, y)





func _ready() -> void:
	
	randomize()

	SignalManager.ult_used.connect(ult_reset)
	SignalManager.score_update.connect(reloadScore)
	SignalManager.kill_count.connect(kill_score)
	SignalManager.unlockedzones.connect(unlock_zones)

	pause_menu.hide()

	label_score.process_mode = Node.PROCESS_MODE_DISABLED

	GameManager.score = 0

	# TIMER DE SPAWN
	spawn_timer = Timer.new()

	add_child(spawn_timer)

	spawn_timer.wait_time = 3.0
	spawn_timer.one_shot = false

	spawn_timer.timeout.connect(spawn_curacion)

	spawn_timer.start()

	get_viewport().canvas_cull_mask = 1



func _process(_delta: float) -> void:

	ult_bar()

	if Input.is_action_just_pressed("Pausa"):
		pauseMenu()



func spawn_curacion():

	var current_curaciones := 0

	for child in get_children():

		if child.is_in_group("curaciones"):
			current_curaciones += 1

	print("ACTIVAS: ", current_curaciones)

	if current_curaciones >= MAX_CURACIONES:
		print("MAXIMO ALCANZADO")
		return

	var curacionInstance = curacion.instantiate()

	add_child(curacionInstance)

	var spawnLocation = get_random_point(point1, point2)

	curacionInstance.global_position = spawnLocation

	print("SPAWN EN: ", spawnLocation)
	

func ult_bar():

	if percentage_ult < 244.0:

		percentage_ult = GameManager.timeToUlt / GameManager.ulti_kills_required * ult_bar_scale

		texture_rect.size.x = percentage_ult


func ult_reset():

	texture_rect.size.x = 0
	percentage_ult = 0


func pauseMenu():

	paused = !paused

	if paused:

		pause_menu.show()
		get_tree().paused = true

	else:

		pause_menu.hide()
		get_tree().paused = false


func reloadScore() -> void:

	
	if !timer:

		kill_acumulated=0
		dynamic_score = 0
		label_combo.visible = false
		label_score.process_mode = Node.PROCESS_MODE_INHERIT

		label_score.text = """ [font=res://Scenes/UI/Puntuacion_Final/JetBrainsMono-Italic.ttf][font_size=64] [matrix]%d[/matrix]
		[/font_size] 
		[/font]
		""" % previous_score

		timer = Timer.new()

		add_child(timer)

		timer.timeout.connect(_on_timer_timeout)

		timer.one_shot = true

		timer.start(3.0)


func activeScore() -> void:
	reload = true


func _on_timer_timeout():
	label_score.text = """[font=res://Scenes/UI/Puntuacion_Final/JetBrainsMono-Italic.ttf][font_size=64]%d[/font_size]
	[/font]
	""" % [GameManager.score]

	label_score.process_mode = Node.PROCESS_MODE_DISABLED

	timer.queue_free()

	timer = null

func kill_score()->void:
	if dynamictimer:
		dynamictimer.stop()
		dynamictimer.queue_free()
		dynamictimer = null
	kill_acumulated+=1
	dynamictimer = Timer.new()
	add_child(dynamictimer)
	dynamictimer.timeout.connect(making_dynamic_score)
	dynamictimer.one_shot = true
	dynamictimer.start(time_forCombo)

	label_combo.visible = true
	label_combo.text = """[center][font=res://Scenes/UI/Puntuacion_Final/JetBrainsMono-Italic.ttf][font_size=64]
	[color=gold][shake]Combo= %d[/shake][/color][/font_size][/font][/center]""" %[kill_acumulated]
	update_combo_tween()


func making_dynamic_score()->void:
	tween_combo.kill()
	label_combo.modulate.a = 1.0
	for j in range(kill_acumulated):
		if j ==0:
			dynamic_score = 100
		else:
			dynamic_score = dynamic_score*2
	previous_score = GameManager.score
	GameManager.score += dynamic_score
	SignalManager.score_update.emit()

func update_combo_tween()->void:
	if tween_combo:
		tween_combo.kill()
		
	if not dynamictimer or dynamictimer.is_stopped():
		return
	
	var t = dynamictimer.time_left / time_forCombo         
	var speed = lerp(0.05, 0.4, t)
	
	tween_combo = create_tween()
	tween_combo.tween_property(label_combo, "modulate:a", 0.1, speed)
	tween_combo.tween_property(label_combo, "modulate:a", 1.0, speed)
	tween_combo.tween_callback(update_combo_tween)          

func reset_gamedata():
	pass

func unlock_zones(zone:int):
	match zone:
		2:
			mini_map.visible=false
			first_wall.get_child(0).get_child(0).visible = true
			await get_tree().create_timer(8.0).timeout
			first_wall.queue_free()
			mini_map.visible = true
			print("primera zona liberada")

