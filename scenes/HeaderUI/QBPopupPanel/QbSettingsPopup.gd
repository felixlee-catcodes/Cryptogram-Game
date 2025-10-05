extends PopupPanel

@onready var mainVBox : VBoxContainer = $MainVBox


func _ready():
	pass


func _on_check_button_toggled(toggled_on):
	EventHub.ui_events.show_stats.emit(toggled_on)


func _on_new_game_pressed():
	EventHub.game.new_game.emit()
	
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
