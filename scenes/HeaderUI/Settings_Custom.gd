extends MenuButton
@onready var settings = $"."

enum MenuItems {
	SETTINGS, 
	NEW_GAME, 
	CHANGE_THEME,
	QUIT_GAME
}

var menu : PopupMenu

func _ready():
	button_pressed = false
	menu = get_popup()
	menu.add_separator("Settings", MenuItems.SETTINGS)
	menu.add_item("New Game", MenuItems.NEW_GAME)
	menu.add_item("Switch Theme", MenuItems.CHANGE_THEME)
	menu.add_item("Quit Game", MenuItems.QUIT_GAME)
	menu.hide_on_item_selection = false
	menu.id_pressed.connect(_on_id_pressed)

func _on_id_pressed(id):
	match id:
		MenuItems.NEW_GAME:
			EventHub.game.new_game.emit()
		MenuItems.CHANGE_THEME:
			ThemeManager.next_theme()
