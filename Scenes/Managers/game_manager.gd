extends Node

var selected_character: CharacterData = null
var ulti_kills_required: float = 5
var timeToUlt:float = 0
var ult_tries:int = 0
var score:float = 100
var current_wave:int
var playtime:float = 0.0


func get_tiempo() -> String:
	var minutos: int = int(playtime) / 60
	var segundos: int = int(playtime) % 60
	
	return "%02d:%02d" % [minutos, segundos]
