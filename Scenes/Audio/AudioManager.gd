extends Node

@onready var footstep_player = $FootstepsSoundPlayer
@onready var ability_player = $AbilitySoundPlayer
@onready var punch_player = $PunchSoundPlayer
@onready var character_player = $CharacterSoundPlayer
@onready var effect_player = $EffectSoundPlayer

var footstep_sounds = [
	preload("res://Scenes/Audio/footsteps/footstep2.wav"),
	preload("res://Scenes/Audio/footsteps/footstep3.wav")
]

var punch_sounds = [
	preload("res://Scenes/Audio/attacks/punch1.wav"),
	preload("res://Scenes/Audio/attacks/punch2.wav"),
	preload("res://Scenes/Audio/attacks/punch3.wav")
]

var idol_attack_sounds = [
	preload("res://Scenes/Audio/attacks/idol/idol_attack1.wav"),
	preload("res://Scenes/Audio/attacks/idol/idol_attack2.wav")
]

var idol_swing = preload("res://Scenes/Audio/attacks/idol/idol_swing.wav")

var idol_ability1 = preload("res://Scenes/Audio/abilities/idol_abilitySFX1.wav")
var idol_ability2 = preload("res://Scenes/Audio/abilities/idol_abilitySFX2.wav")
var last_idol_ability_sound := 0

@export var min_footstep_pitch := 0.9
@export var max_footstep_pitch := 1.1

@export var min_idol_pitch := 0.9
@export var max_idol_pitch := 1.1

@export var min_punch_pitch := 0.9
@export var max_punch_pitch := 1.1

func play_footstep():
	if footstep_sounds.is_empty():
		return

	# choose random sound
	var random_sound = footstep_sounds[randi() % footstep_sounds.size()]
	footstep_player.stream = random_sound

	# random pitch
	footstep_player.pitch_scale = randf_range(min_footstep_pitch, max_footstep_pitch)

	# play
	footstep_player.play()

func play_punch():
	if punch_sounds.is_empty():
		return
	
	var random_punch_sound = punch_sounds[randi() % punch_sounds.size()]
	punch_player.stream = random_punch_sound
	
	punch_player.pitch_scale = randf_range(min_punch_pitch, max_punch_pitch)
	
	punch_player.play()

func play_idol_attack():
	if idol_attack_sounds.is_empty():
		return

	# choose random sound
	var random_char_sound = idol_attack_sounds[randi() % idol_attack_sounds.size()]
	character_player.stream = random_char_sound
	
	effect_player.stream = idol_swing

	# random pitch
	character_player.pitch_scale = randf_range(min_idol_pitch, max_idol_pitch)

	# play
	character_player.play()
	effect_player.play()

func play_idol_ability():
	if last_idol_ability_sound == 0 or last_idol_ability_sound == 2:
		ability_player.stream = idol_ability1
		last_idol_ability_sound = 1
	else:
		ability_player.stream = idol_ability2
		last_idol_ability_sound = 2
	
	ability_player.play()
