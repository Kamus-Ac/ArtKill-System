extends Node

@onready var footstep_player = $FootstepsSoundPlayer
@onready var ability_player = $AbilitySoundPlayer
@onready var character_player = $CharacterSoundPlayer

var footstep_sounds = [
	preload("res://Scenes/Audio/footsteps/footstep2.wav"),
	preload("res://Scenes/Audio/footsteps/footstep3.wav")
]

var idol_attack_sounds = [
	preload("res://Scenes/Audio/attacks/idol/idol_attack1.wav"),
	preload("res://Scenes/Audio/attacks/idol/idol_attack2.wav")
]

@export var min_footstep_pitch := 0.9
@export var max_footstep_pitch := 1.1

@export var min_idol_pitch := 0.9
@export var max_idol_pitch := 1.1

func play_footstep():
	if footstep_sounds.is_empty():
		return

	# choos random sound
	var random_sound = footstep_sounds[randi() % footstep_sounds.size()]
	footstep_player.stream = random_sound

	# random pitch
	footstep_player.pitch_scale = randf_range(min_footstep_pitch, max_footstep_pitch)

	# play
	footstep_player.play()

func play_idol_attack():
	if idol_attack_sounds.is_empty():
		return

	# choos random sound
	var random_sound = idol_attack_sounds[randi() % idol_attack_sounds.size()]
	character_player.stream = random_sound

	# random pitch
	character_player.pitch_scale = randf_range(min_idol_pitch, max_idol_pitch)

	# play
	character_player.play()
