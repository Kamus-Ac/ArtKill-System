class_name Player_Hurtbox
extends Area2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	monitorable = false
	collision_layer = 1
	collision_mask = 2
	

func _on_area_entered(hit_area: Area2D) -> void:
	if hit_area is Enemy_Hitbox:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.take_damage(hit_area.damage)
