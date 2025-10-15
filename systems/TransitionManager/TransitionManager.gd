extends CanvasLayer

enum Direction { IN, OUT}
@onready var transition_texture: TextureRect = $TransitionTexture

var current_effect : TransitionEffect
var transition_parameters : Dictionary
var transitions : Dictionary = {
	"grid_flip": preload("res://resources/Transitions/grid_flip_test.tres"),
	"6_grid_clock": preload("res://resources/Transitions/6_grid_clock.tres"),
	"square_grid_rotate": preload("res://resources/Transitions/square_grid_rotate.tres")
}
#func _ready():
	#play_transition(transitions["square_grid_rotate"], Direction.IN)


func play_transition(effect: TransitionEffect, dir: Direction):
	current_effect = effect.duplicate(true)
	Log.pr(current_effect.resource_path)
	transition_parameters = current_effect.params
	Log.prn(transition_parameters)
	transition_texture.texture = effect.x_texture
	transition_texture.material = effect.shader.duplicate(true)
	var tween : Tween = create_tween().set_parallel()
	for param in transition_parameters:
		
		var start_value = transition_parameters[param][0]
		var end_value = transition_parameters[param][1]
		var duration = current_effect.duration
		
		tween.tween_property(transition_texture.material, "shader_parameter/%s" % param, start_value, 0.0)
		tween.tween_property(transition_texture.material, "shader_parameter/%s" % param, end_value, duration)
		tween.finished.connect(func():
			EventHub.game.transition_ended.emit()
			Log.pr("tween finished"))
