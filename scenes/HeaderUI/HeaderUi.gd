extends PanelContainer

@onready var timer_display = $UIContainer/TimerDisplay
@onready var ui_container = $UIContainer
@onready var settings : MenuButton = $UIContainer/Settings

func _ready():
	EventHub.ui_events.update_timer.connect(_update_timer_display)
	EventHub.game.get_hint.connect(_on_get_hint)

func _on_get_hint() -> void:
	var tween :Tween
	tween = create_tween().set_loops(2)
	tween.tween_property(timer_display, "modulate", Color.CRIMSON, 0.3)
	tween.tween_property(timer_display, "modulate", Color.GHOST_WHITE, 0.3)
	
	
func _update_timer_display(time):
	var m = int(time / 60.0)
	var s = time - m * 60
	timer_display.text = '%02d:%02d' % [m, s]
