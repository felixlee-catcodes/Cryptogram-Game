class_name PlayerStats
extends Resource

@export var total_games : int
@export var completion_record : Array[Dictionary]
@export var best_time : int
@export var all_time_avg : int

func update_best_time(new_time: int):
	if best_time == 0 or new_time < best_time:
		best_time = new_time


func get_daily_averages():
	pass


func all_time_avg_calc() -> int:
	Log.pr("calculate avg called")
	var total_time : int = 0
	for record in completion_record:
		record["time"] += total_time
	all_time_avg = int(total_time/completion_record.size())
	
	return all_time_avg
