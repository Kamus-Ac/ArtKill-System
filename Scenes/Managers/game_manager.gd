extends Node

var selected_character: CharacterData = null
var ulti_kills_required: float = 5
var timeToUlt:float = 0
var score:float = 0
var tiempo_jugado: float = 0
var esta_contando: bool = true


func get_tiempo() -> String:
	var minutos: int = int(tiempo_jugado) / 60
	var segundos: int = int(tiempo_jugado) % 60
	return "%02d:%02d" % [minutos, segundos]
