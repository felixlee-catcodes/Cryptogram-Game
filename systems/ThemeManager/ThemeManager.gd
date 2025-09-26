extends Node

signal theme_changed(new_theme : ColorTheme)

@export var themes : Array[ColorTheme] = []
var current_index : int = 0
var active_theme : ColorTheme

func _ready():
	Log.pr("themes size: ", themes.size())
	
	if themes.size() > 0:
		set_theme(0)


func set_theme(index: int):
	Log.pr("set theme called")
	if index < 0 or themes.size() == 1:
		active_theme = themes[0]
		emit_signal("theme_changed", active_theme)
		Log.pr("active theme: ",ThemeManager.active_theme.theme_name)
		return
	current_index = index
	active_theme = themes[current_index]
	Log.pr("active theme: ",ThemeManager.active_theme.theme_name)
	emit_signal("theme_changed", active_theme)


func next_theme():
	if themes.size() == 0:
		return
	var next_index = (current_index + 1) % themes.size()
	set_theme(next_index)


func prev_theme():
	if themes.size() == 0:
		return
	var prev_index = (current_index - 1 + themes.size()) % themes.size()
	set_theme(prev_index)
