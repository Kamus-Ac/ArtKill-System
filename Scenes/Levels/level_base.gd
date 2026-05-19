extends Node2D

var i = 0

@onready var texture_rect: TextureRect = $CanvasLayer/TextureRect
@onready var label_score: RichTextLabel = $CanvasLayer/Score

@onready var pause_menu: Control = $GameCamera/CanvasLayer2/pause_menu

@export var point1: Vector2 = Vector2(-550,-150)
@export var point2: Vector2 = Vector2(-30,115)

var curacion = preload("res://Scenes/Objects/Curacion/Curacion.tscn")

var percentage_ult: float = 0
var ult_bar_scale: float = 244.0

var reload: bool = false
var timer: Timer

var paused = false

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
	SignalManager.kill_count.connect(reloadScore)

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

		label_score.process_mode = Node.PROCESS_MODE_INHERIT

		label_score.text = """[center] [font=res://Scenes/UI/Puntuacion_Final/JetBrainsMono-Italic.ttf][font_size=64] [matrix]%d[/matrix]
		[/font_size] 
		[/font]
		[/center]""" % [GameManager.score]

		timer = Timer.new()

		add_child(timer)

		timer.timeout.connect(_on_timer_timeout)

		timer.one_shot = true

		timer.start(3.0)


func activeScore() -> void:
	reload = true


func _on_timer_timeout():

	label_score.text = """[center] [font=res://Scenes/UI/Puntuacion_Final/JetBrainsMono-Italic.ttf][font_size=64]%d[/font_size]
	[/font]
	[/center]""" % [GameManager.score]

	label_score.process_mode = Node.PROCESS_MODE_DISABLED

	timer.queue_free()

	timer = null


func reset_gamedata():
	pass
