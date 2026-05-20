extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
func _ready() -> void:
	
	add_to_group("curaciones")
	if(anim.sprite_frames):
		anim.play("idle")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):

	if body.is_in_group("player"):

		if body.health_component:

			body.health_component.heal(1)

		queue_free()
