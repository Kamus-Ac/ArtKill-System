extends Node2D

var i = 0
@onready var texture_rect: TextureRect = $CanvasLayer/TextureRect
var percentage_ult: float = 0
var ult_bar_scale: float = 244.0
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	#var player = get_tree().get_first_node_in_group("player")
	SignalManager.ult_used.connect(ult_reset)
	pause_menu.hide()
	
func _process(_delta: float) -> void:
	ult_bar()

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

func _process(delta):
	if Input.is_action_just_pressed("Pausa"):
			pauseMenu()
			
func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
		
	paused = !paused
			
	
	
	
