class_name PlayerStats
extends Resource

var total_games : int
var solve_times : Array = []
var completion_record : Array[Dictionary]
var best_time : int


func update_best_time(new_time: int):
	if best_time == 0 or new_time < best_time:
		best_time = new_time

func get_daily_averages():
	pass
