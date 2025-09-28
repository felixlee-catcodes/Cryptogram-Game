extends PanelContainer

@onready var ui_container = $UIContainer
@onready var settings : MenuButton = $UIContainer/Settings
@export var header_color : Color

func _ready():
	ThemeManager.connect("theme_changed", Callable(self, "_on_theme_changed"))
	if ThemeManager.active_theme != null:
		_on_theme_changed(ThemeManager.active_theme)
	
	set_header_styling()


func _on_theme_changed(_theme : ColorTheme):
	header_color = _theme.basic_ui_color


func set_header_styling():
	var style = StyleBoxFlat.new()
	style.bg_color = header_color
	self.add_theme_stylebox_override("panel", style)
