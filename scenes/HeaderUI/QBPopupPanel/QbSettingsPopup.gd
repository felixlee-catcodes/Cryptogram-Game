extends PopupPanel

@onready var mainVBox : VBoxContainer = $MainVBox


func _ready():
	pass


func _on_check_button_toggled(toggled_on):
	EventHub.ui_events.show_stats.emit(toggled_on)
