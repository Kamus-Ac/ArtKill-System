extends Node2D

var hearts_list: Array = []
var i = 0

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	#player.connect("died", Callable(self, "_on_player_died"))
	SignalManager.took_damage.connect(Callable(self, "update_hearts"))

	create_hearts(player.max_health)
	update_hearts(player.health, player.max_health)

func _on_player_died() -> void:
	await get_tree().create_timer(5.0).timeout  # espera 1 segundo
	get_tree().reload_current_scene()

	
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
