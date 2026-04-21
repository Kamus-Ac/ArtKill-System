extends Node2D

var i = 0
@onready var texture_rect: TextureRect = $CanvasLayer/TextureRect
var percentage_ult: float = 0
var ult_max: float = 7
var ult_bar_scale: float = 244.0
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	SignalManager.kill_count.connect(ult_bar)
	SignalManager.ult_used.connect(ult_reset)
	
	
	

func ult_bar(kill:int):
	if (percentage_ult<244.0):
		percentage_ult = kill/ult_max * ult_bar_scale
		texture_rect.size.x = percentage_ult
		print(texture_rect.size.x)

func ult_reset():
	texture_rect.size.x=0
	percentage_ult = 0
	
	
