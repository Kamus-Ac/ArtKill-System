extends Node2D

var hearts_list: Array = []
var i = 0
@onready var texture_rect: TextureRect = $CanvasLayer/TextureRect
var percentage_ult: float = 0
var ult_max: float = 7
var ult_bar_scale: float = 244.0
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")

	SignalManager.took_damage.connect(Callable(self, "update_hearts"))
	SignalManager.kill_count.connect(ult_bar)
	SignalManager.ult_used.connect(ult_reset)
	
	create_hearts(player.max_health)
	update_hearts(player.health, player.max_health)
	
	
func create_hearts(max_health):
	var hearts_parent = $CanvasLayer/HBoxContainer
	
	for child in hearts_parent.get_children():
		child.queue_free()
	
	hearts_list.clear()

	for j in range(max_health):
		var heart = preload("res://Scenes/UI/heart.tscn").instantiate()
		hearts_parent.add_child(heart)
		hearts_list.append(heart)


func update_hearts(health, max_health):
	for idx in range(hearts_list.size()):
		var anim = hearts_list[idx].get_node("AnimatedSprite2D")

		if idx < health:
			anim.play("vivo")
		else:
			anim.play("muerto")

func ult_bar(kill:int):
	if (percentage_ult<244.0):
		percentage_ult = kill/ult_max * ult_bar_scale
		texture_rect.size.x = percentage_ult
		print(texture_rect.size.x)

func ult_reset():
	texture_rect.size.x=0
	percentage_ult = 0
	
	
