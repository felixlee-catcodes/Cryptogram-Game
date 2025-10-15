extends Node
# MAIN
@onready var word_unit = preload("res://scenes/WordUnit/WordUnit.tscn")
@onready var game_manager = $GameManager
@onready var quote_scene = %QuoteScene
@onready var encrypted_message_display = $EncryptedMessageDisplay
#@onready var game_over_scene : GameOverScene 
@onready var keyboard_panel_container : PanelContainer = $KeyboardPanelContainer
@onready var texture_rect: TextureRect = $TextureRect
@onready var transition_image : TextureRect = $TransitionImage
@onready var header_ui = $UILayer/HeaderUI

@export var bg_image_texture : Texture2D
@export var transition_texture : Texture2D
@export var keyboard_panel_color : Color

var transition_animations : Array = ["Transition1", "Transition2", "Transition3"]

func _ready():
	ThemeManager.connect("theme_changed", Callable(self, "_on_theme_changed"))
	if ThemeManager.active_theme != null:
		_on_theme_changed(ThemeManager.active_theme)
	set_panel_styling()
	EventHub.game.new_game.connect(_on_new_game)
	EventHub.game.game_over.connect(_on_game_over)
	setup_puzzle()
	play_transition_anim()


func play_transition_anim() -> void:
	var rand_idx = randi_range(0, transition_animations.size() - 1)
	var rand_anim = transition_animations[rand_idx]
	Log.pr("anim name: ", rand_anim)
	$TransitionAnim.play("Transition2")
	$TransitionAnim.animation_finished


func set_panel_styling() -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = keyboard_panel_color
	keyboard_panel_container.add_theme_stylebox_override("panel", style)
	texture_rect.set_texture(bg_image_texture)
	transition_image.set_texture(transition_texture)


func _on_theme_changed(theme: ColorTheme):
	bg_image_texture = theme.bg_texture
	keyboard_panel_color = theme.panel_color
	#transition_texture = theme.bg_texture


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


func _on_game_over(_time, puzzle):
	var game_over_scene = load("res://scenes/GameOver/GameOverDisplay.tscn").instantiate()
	game_over_scene.finished_puzzle = puzzle
	game_over_scene.curr_time = _time
	
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(game_over_scene)
	get_tree().current_scene = game_over_scene


func split_text(quote: String) -> Array:
	return quote.split(" ")


func _on_transition_anim_animation_finished(anim_name):
	transition_image.queue_free()
	game_manager.start_game()
