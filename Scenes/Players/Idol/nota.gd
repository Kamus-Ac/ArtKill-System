extends CharacterBody2D



func _physics_process(_delta: float) -> void:
	# Add the gravity.

	move_and_slide()
