extends Camera2D

@onready var loadscene_animation: AnimatedSprite2D = $AnimatedSprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadscene_animation.play("loadscene2")




func _on_animated_sprite_2d_animation_finished() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/level_base.tscn")
