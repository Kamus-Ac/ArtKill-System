extends Node


@onready var scoreboard_panel = $"."
@onready var Puntuacion_Actual: Label = $Label/Puntuacion_Actual
@onready var Tiempo_Jugando = $Label3/Tiempo_jugado


func _ready() -> void:
	if scoreboard_panel:
		scoreboard_panel.visible = false

func _process(delta: float) -> void:
	if scoreboard_panel.visible:
		actualizar_texto_tiempo()


func score()->void:
	Puntuacion_Actual.text = "%d"%[GameManager.score]

func actualizar_texto_tiempo() -> void:
	Tiempo_Jugando.text = GameManager.get_tiempo() 
	   
func _unhandled_input(event):
	if event.is_action_pressed("Scoreboard"):
		score()
		scoreboard_panel.visible = !scoreboard_panel.visible
	if event.is_action_released("Scoreboard"):
		scoreboard_panel.visible = false
