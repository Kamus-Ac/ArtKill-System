class_name EnemyHurtBox
extends Area2D


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	monitorable = false
	collision_layer = 2
	collision_mask = 1


func _on_area_entered(hit_area: Area2D) -> void:
	if owner.has_method("die") and hit_area is Player_Hitbox:
		owner.die(hit_area)
