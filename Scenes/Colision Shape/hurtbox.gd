class_name Player_Hurtbox
extends Area2D

signal received_damage(damage: int)
@export var health: Player_Health

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	monitorable = false
	collision_layer = 0
	collision_mask = 2
	

#func _on_area_entered(hit_area: Area2D) -> void:
	#if hit_area is Enemy_Hitbox:
		#var player = get_tree().get_first_node_in_group("player")
		#if player:
			#player.take_damage(hit_area.damage)
			
func _on_area_entered(hitbox: Area2D) -> void:
	if hitbox != null and hitbox is Enemy_Hitbox:
		print("Health antes:", health.get_health())
		health.apply_damage(hitbox.damage)
		print("Health después:", health.get_health())
		received_damage.emit(hitbox.damage)
