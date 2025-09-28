extends Panel

@onready var text_label = $CenterContainer/VBoxContainer/TextLabel
@onready var source_label = $CenterContainer/VBoxContainer/SourceLabel

func _ready():
	pass

func set_quote_text(_text: String, source: String) -> void:
	var text_label : Label = $CenterContainer/VBoxContainer.get_node("TextLabel")
	var source_label : Label = $CenterContainer/VBoxContainer.get_node("SourceLabel")
	text_label.add_theme_font_size_override("font_size", 32)
	text_label.add_theme_color_override("font_color", ThemeManager.active_theme.panel_color)
	source_label.add_theme_font_size_override("font_size", 32)
	source_label.add_theme_color_override("font_color", ThemeManager.active_theme.panel_color)
	
	text_label.text = "\"%s\"" % _text
	source_label.text = "- %s" % source
