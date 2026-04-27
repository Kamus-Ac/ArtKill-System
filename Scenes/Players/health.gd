class_name Player_Health
extends Node

signal max_health_changed(diff: int)
signal health_changed(diff: int)
signal health_depleted

var max_health: int
var health: int

var invulnerable: bool = false : set = set_invulnerable, get = get_invulnerable 
var invulnerable_timer: Timer = null


func _ready() -> void:
	max_health = GameManager.selected_character.max_health
	health = max_health
	print("Max ",max_health)
	print("health ",health)
	
func set_max_health(value: int):
	var clamped_value = 1 if value <= 0 else value	
	if not clamped_value == max_health:
		var difference = clamped_value - max_health
		max_health = clamped_value
		max_health_changed.emit(difference)
		
		if health > max_health:
			health = max_health

func get_max_health() -> int:
	return max_health

func set_invulnerable(value: bool):
	invulnerable = value

func get_invulnerable() -> bool:
	return invulnerable
	
func set_health(value: int):
	if value < health and invulnerable:
		return
	var clamped_value = clampi(value, 0, max_health)
	
	if clamped_value != health:
		var difference = clamped_value - health
		health = clamped_value
		health_changed.emit(difference)
		
		if health == 0:
			health_depleted.emit()

func get_health():
	return health
	
func apply_damage(damage: int):
	set_health(health - damage)

func set_temporary_invulnerable(time: float):
	if invulnerable_timer == null:
		invulnerable_timer = Timer.new()
		invulnerable_timer.one_shot = true
		add_child(invulnerable_timer)
	
	if invulnerable_timer.timeout.is_connected(set_invulnerable):
		invulnerable_timer.timeout.disconnect(set_invulnerable)
	
	invulnerable_timer.set_wait_time(time)
	invulnerable_timer.timeout.connect(set_invulnerable.bind(false))
	invulnerable = true
	invulnerable_timer.start()
		
