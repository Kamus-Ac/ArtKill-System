class_name Enemy_Hitbox
extends Area2D

var damage: int = 1

#collision mask en 0 porque no detecta nada
#collision layer en 2 porque puede ser detectada en otras areas 
#monitoring puede ser falso porque la hitbox no necesita detectar 
#nada, no importa en que mask este, el area no emitira señalees.

func _ready() -> void:	
	collision_layer = 2
	collision_mask = 0
