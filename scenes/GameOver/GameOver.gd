extends Node

@onready var header_ui = $UILayer/HeaderUI

func _ready():
	var ui_container : HBoxContainer = header_ui.ui_container
	header_ui.timer_display.visible = false
	ui_container.add_theme_constant_override("separation", 505)
