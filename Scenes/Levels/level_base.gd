extends Node2D

var i = 0
@onready var texture_rect: TextureRect = $CanvasLayer/TextureRect
var percentage_ult: float = 0
var ult_bar_scale: float = 244.0
@onready var label_score: RichTextLabel = $CanvasLayer/Score
var reload:bool = false
var timer:Timer
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	#var player = get_tree().get_first_node_in_group("player")
	SignalManager.ult_used.connect(ult_reset)
	SignalManager.kill_count.connect(reloadScore)
	pause_menu.hide()
	label_score.process_mode = Node.PROCESS_MODE_DISABLED
	GameManager.score = 0
	
	
func _process(_delta: float) -> void:
	ult_bar()
	if Input.is_action_just_pressed("Pausa"):
			pauseMenu()

func ult_bar():
	if (percentage_ult<244.0):
		percentage_ult = GameManager.timeToUlt/GameManager.ulti_kills_required * ult_bar_scale
		texture_rect.size.x = percentage_ult
	else:
		return

func ult_reset():
	texture_rect.size.x=0
	percentage_ult = 0
	
@onready var pause_menu: Control = $GameCamera/CanvasLayer2/pause_menu

var paused = false
			
func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
		
	paused = !paused

func reloadScore()-> void:
	if !timer:
		label_score.process_mode= Node.PROCESS_MODE_INHERIT
		label_score.text= """[center] [font=res://Scenes/UI/Puntuacion_Final/JetBrainsMono-Italic.ttf][font_size=64] [matrix]%d[/matrix]
		[/font_size] 
		[/font]
		[/center]"""%[GameManager.score]
		timer = Timer.new()
		add_child(timer)
		timer.timeout.connect(_on_timer_timeout)
		timer.one_shot = true
		timer.start(3.0)

func activeScore()->void:
	reload=true

func _on_timer_timeout():
	label_score.text= """[center] [font=res://Scenes/UI/Puntuacion_Final/JetBrainsMono-Italic.ttf][font_size=64]%d[/font_size]
	[/font]
	[/center]"""%[GameManager.score]
	label_score.process_mode=Node.PROCESS_MODE_DISABLED
	timer.queue_free()

		
	
	
func reset_gamedata():
		pass
