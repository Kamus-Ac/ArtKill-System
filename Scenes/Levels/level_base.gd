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
@onready var label_score: RichTextLabel = $CanvasLayer/Score
var reload:bool = false
var timer:Timer
@onready var label_tiempo = $Label3/Tiempo_jugado
@onready var label_tiempo_final = $Label4/Label



# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	
	randomize()

	SignalManager.ult_used.connect(ult_reset)
	SignalManager.score_update.connect(reloadScore)
	SignalManager.kill_count.connect(kill_score)
	SignalManager.unlockedzones.connect(unlock_zones)

	pause_menu.hide()

	label_score.process_mode = Node.PROCESS_MODE_DISABLED

	GameManager.score = 0
	GameManager.tiempo_jugado = 0.0
	GameManager.esta_contando = true
	
	
func _process(_delta: float) -> void:

	ult_bar()

	if Input.is_action_just_pressed("Pausa"):
		pauseMenu()
	if GameManager.esta_contando:
		GameManager.tiempo_jugado += _delta
		actualizar_texto_tiempo()

func actualizar_texto_tiempo() -> void:
	if label_tiempo != null:
		label_tiempo.text = GameManager.get_tiempo()

  
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


func activeScore()->void:
	reload=true

func _on_timer_timeout():
	label_score.text = """[font=res://Scenes/UI/Puntuacion_Final/JetBrainsMono-Italic.ttf][font_size=64]%d[/font_size]
	[/font]
	""" % [GameManager.score]

	label_score.process_mode = Node.PROCESS_MODE_DISABLED

	timer.queue_free()
