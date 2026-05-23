class_name ScoresSaved
extends Resource

@export var names: Array[String] = []
@export var scores: Array[int] = []

const SAVE_GAME_PATH := "user://SaveFile.tres"


func write_savegame() -> void:
	ResourceSaver.save(self, SAVE_GAME_PATH)


static func save_exists() -> bool:
	return ResourceLoader.exists(SAVE_GAME_PATH)


static func load_savegame() -> ScoresSaved:
	if not ResourceLoader.exists(SAVE_GAME_PATH):
		return null
	
	return ResourceLoader.load(SAVE_GAME_PATH, "", ResourceLoader.CACHE_MODE_IGNORE) as ScoresSaved