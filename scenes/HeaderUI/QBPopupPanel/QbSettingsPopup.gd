extends PopupPanel

@onready var mainVBox : VBoxContainer = $MainVBox
@onready var qb_settings_popup = $"."

func _ready():
	pass


func _on_check_button_toggled(toggled_on):
	EventHub.ui_events.show_stats.emit(toggled_on)


func _on_new_game_pressed():
	qb_settings_popup.visible = false
	var new_game_scene = load("res://scenes/Main.tscn").instantiate()
	await TransitionManager.transition_to_scene(new_game_scene, TransitionManager.transitions["grid_flip"])
	EventHub.game.new_game.emit()
