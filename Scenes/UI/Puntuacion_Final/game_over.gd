extends Node

@onready var Final_Score_Panel = $"."
@onready var final_score: Label = $Label/Final_Score
@onready var Tiempo_Jugando_final = $Label4/Label

func _ready() -> void:
	SignalManager.gameOver.connect(gameOver)
	if Final_Score_Panel:
		Final_Score_Panel.visible = false



func gameOver()->void:
	GameManager.esta_contando = false
	Tiempo_Jugando_final.text = GameManager.get_tiempo()
	final_score.text = "%d"%[GameManager.score]
	Final_Score_Panel.visible = true
	

func Reintentar() -> void:
	get_tree().paused = false
	GameManager.score=0
	#GameManager.kill_count = 0 
	get_tree().reload_current_scene()


func Seleccion_de_personaje() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/character_select.tscn")
