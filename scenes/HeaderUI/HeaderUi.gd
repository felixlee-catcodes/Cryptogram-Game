extends PanelContainer

@onready var timer_display = $UIContainer/TimerDisplay
@onready var ui_container = $UIContainer
@onready var settings : MenuButton = $UIContainer/Settings

func _ready():
	EventHub.ui_events.update_timer.connect(_update_timer_display)


func _update_timer_display(time):
	var m = int(time / 60.0)
	var s = time - m * 60
	timer_display.text = '%02d:%02d' % [m, s]
