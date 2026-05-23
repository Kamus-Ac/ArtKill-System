extends Node2D

var player: CharacterBody2D
var dash_direction := Vector2.ZERO
var isActive : bool = false
var time: float = 0
var factor: float = 0
var duration: float = 0
var reverse: bool 

var start_position := Vector2.ZERO
var note:PackedScene= preload("res://Scenes/Players/Idol/Nota.tscn")
var pack_notes: Array[CharacterBody2D]
var delay= 0.1
var count: int = 1
func start(p: CharacterBody2D):
	player = p
	start_position = player.global_position
	isActive = true
	time = 0
	factor = 0
	reverse = false
	count = 1
	duration=0
	pack_notes.clear()

	for i in range(10):
		var new_note = note.instantiate()
		player.add_child(new_note)
		pack_notes.append(new_note)

	queue_redraw()

	GameManager.ult_tries+=1


func ulti_move(delta: float) -> void:
	if !reverse:
		time+=delta
		factor+=delta;
	if factor>=2.5:
		time-=delta;
		reverse=true;
	if duration>=4.9:
		isActive=false
		for nota in pack_notes:
			if not is_instance_valid(nota):
				continue
			nota.queue_free()
	duration+=delta
	queue_redraw()
	move_notes()

func _draw() -> void:
	if isActive:

		var delays:Array[float] = [0.0,0.5,1.0,1.5,2.0]

		for d in delays:
			var t= time - d
			if t>0:
				var radius = t* 100
				draw_arc(Vector2.ZERO, radius, 0, TAU, 64, Color.BLACK, 2.0)


func move_notes()->void:
	if isActive:
		var i:int = 0
		for nota in pack_notes:
			if not is_instance_valid(nota):
				continue
			var t=time-(delay*i)
			if t>0:
				nota.position.x =  (t*50)*cos(t*7.5) 
				nota.position.y =  (t*50)*sin(t*7.5) 
			i+=1
				
