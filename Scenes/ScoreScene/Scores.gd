class_name ScoresSaved
extends Resource

@export var names: Array[String] = []
@export var scores: Array[int] = []

const SAVE_GAME_BASE_PATH := "user://SaveFile"


func write_savegame() -> void:
	var result = ResourceSaver.save(self, get_save_path())
	print("SAVE RESULT: ", result)


static func save_exists() -> bool:
	return ResourceLoader.exists(get_save_path())


static func load_savegame() -> ScoresSaved:
	var save_path := get_save_path()
	return ResourceLoader.load(save_path, "", ResourceLoader.CACHE_MODE_IGNORE)

static func get_save_path() -> String:
	var extension := ".tres" if OS.is_debug_build() else ".res"
	return SAVE_GAME_BASE_PATH + extension