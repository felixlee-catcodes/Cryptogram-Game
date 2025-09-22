extends MarginContainer

func _ready():
	add_theme_constant_override("margin_top", 110)

func _on_new_game_pressed():
	EventHub.game.new_game.emit()
