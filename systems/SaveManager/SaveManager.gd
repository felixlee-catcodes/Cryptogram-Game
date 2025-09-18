extends Node
# SAVE MANAGER

var stats : PlayerStats

const SAVE_PATH : String = "user://save/PlayerStats.tres"

func _ready():
	load_stats()


func load_stats() -> void:
	stats = load(SAVE_PATH) as PlayerStats
	if not stats:
		stats = PlayerStats.new()
		save_stats()


func save_stats() -> void:
	ResourceSaver.save(stats, SAVE_PATH)


func record_solve(solve_time: int) -> void:
	var date : String = "%d-%02d-%02d" % [
		Time.get_datetime_dict_from_system()["year"],
		Time.get_datetime_dict_from_system()["month"], 
		Time.get_datetime_dict_from_system()["day"]
	]
	
	var record : Dictionary = {"date": date, "time": solve_time}
	stats.completion_record.append(record)
	stats.total_games += 1
	stats.update_best_time(solve_time)
	save_stats()
