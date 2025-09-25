extends MenuButton
@onready var settings = $"."

enum MenuItems {
	SETTINGS, 
	RESET_GAME, 
	GET_HINT,
	CHECK_GAME,
	NEW_GAME, 
	CHANGE_THEME,
	QUIT_GAME
}

var menu : PopupMenu
var last_hint_time : float = 0.0
var hint_cooldown : float = 5.0

func _ready():
	button_pressed = false
	menu = get_popup()
	menu.add_separator("Settings", MenuItems.SETTINGS)
	menu.add_item("Reset Game", MenuItems.RESET_GAME)
	menu.add_item("Get Hint", MenuItems.GET_HINT)
	menu.add_item("Check Game", MenuItems.CHECK_GAME)
	menu.add_item("New Game", MenuItems.NEW_GAME)
	menu.add_item("Switch Theme", MenuItems.CHANGE_THEME)
	menu.add_item("Quit Game", MenuItems.QUIT_GAME)
	menu.hide_on_item_selection = false
	menu.id_pressed.connect(_on_id_pressed)

func _on_id_pressed(id):
	var now = Time.get_ticks_msec() / 1000.0
	match id:
		MenuItems.NEW_GAME:
			EventHub.game.new_game.emit()
		MenuItems.RESET_GAME:
			EventHub.game.reset_game.emit()
		MenuItems.GET_HINT: 
			if now - last_hint_time >= hint_cooldown:
				EventHub.game.get_hint.emit()
				last_hint_time = now
		MenuItems.CHECK_GAME:
			EventHub.game.check_game.emit()
			menu.hide()
		MenuItems.CHANGE_THEME:
			ThemeManager.next_theme()
