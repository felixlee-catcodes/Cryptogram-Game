extends Node
# SAVE MANAGER

var stats : PlayerStats

const SAVE_PATH : String = "user://save/PlayerStats.tres"

func _ready():
	load_stats()
	#Log.pr("load player stats")

func load_stats() -> void:
	Log.pr("load stats called")
	stats = load(SAVE_PATH) as PlayerStats
	if not stats:
		stats = PlayerStats.new()
		save_stats()
	Log.pr("stats loaded? ", stats.total_games)

func save_stats() -> void:
	var dir := DirAccess.open("user://")
	if not dir.dir_exists("save"):
		dir.make_dir("save")
		Log.pr("save directory created")
		
	var err = ResourceSaver.save(stats, SAVE_PATH)
	if err != OK:
		push_error("Failed to save stats: %s" % err)
	else:
		Log.pr("save stats called")


func record_solve(solve_time: int) -> void:
	Log.pr("solve time: ", solve_time)
	var date : String = "%d-%02d-%02d" % [
		Time.get_datetime_dict_from_system()["year"],
		Time.get_datetime_dict_from_system()["month"], 
		Time.get_datetime_dict_from_system()["day"]
	]
	
	var record : Dictionary = {"date": date, "time": solve_time}
	stats.completion_record.append(record)
	stats.all_time_avg_calc()
	stats.total_games += 1
	stats.update_best_time(solve_time)
	save_stats()
