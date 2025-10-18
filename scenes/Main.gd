extends Node
# MAIN
@onready var word_unit = preload("res://scenes/WordUnit/WordUnit.tscn")
@onready var game_manager = $GameManager
@onready var quote_scene = %QuoteScene
@onready var encrypted_message_display = $EncryptedMessageDisplay
@onready var keyboard_panel_container : PanelContainer = $KeyboardPanelContainer
@onready var texture_rect: TextureRect = $TextureRect
@onready var header_ui = $UILayer/HeaderUI

@export var bg_image_texture : Texture2D
@export var keyboard_panel_color : Color

func _ready():
	ThemeManager.connect("theme_changed", Callable(self, "_on_theme_changed"))
	if ThemeManager.active_theme != null:
		_on_theme_changed(ThemeManager.active_theme)
	set_panel_styling()
	EventHub.game.new_game.connect(_on_new_game)
	EventHub.game.game_over.connect(_on_game_over)
	EventHub.game.transition_in_ended.connect(_on_transition_in_ended)
	setup_puzzle()
	
	TransitionManager.play_transition(TransitionManager.transitions["6_grid_clock"], TransitionManager.Direction.IN)


func set_panel_styling() -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = keyboard_panel_color
	keyboard_panel_container.add_theme_stylebox_override("panel", style)
	texture_rect.set_texture(bg_image_texture)


func _on_theme_changed(theme: ColorTheme):
	bg_image_texture = theme.bg_texture
	keyboard_panel_color = theme.panel_color


func setup_puzzle():
	var puzzle = game_manager.get_new_puzzle()
	#Log.pr("new puzzle? ",puzzle)
	var cipher_text = split_text(puzzle.cipherText)
	quote_scene.word_array = cipher_text
	quote_scene.author = puzzle.author
	quote_scene.quote = puzzle.plainText
	quote_scene.compile_quote()


func _on_new_game():
	get_tree().reload_current_scene()

func _on_transition_in_ended():
	game_manager.start_game()


func _on_game_over(_time, puzzle):
	var game_over_scene = load("res://scenes/GameOver/GameOverDisplay.tscn").instantiate()
	game_over_scene.finished_puzzle = puzzle
	game_over_scene.curr_time = _time
	var effect_in = TransitionManager.transitions["square_grid_rotate"]
	var effect_out = TransitionManager.transitions["grid_flip"]

	await TransitionManager.transition_to_scene(game_over_scene, effect_in, effect_out)



func split_text(quote: String) -> Array:
	return quote.split(" ")
