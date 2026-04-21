class_name Enemy_Hitbox
extends Area2D

var damage: int = 1

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
