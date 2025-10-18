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
func _ready():
	transition_texture.visible = true
	#play_transition(transitions["square_grid_rotate"], Direction.OUT)

#func _process(delta):
	#if current_effect != null:
		#Log.pr("progress: ", transition_texture.material.get_shader_parameter("progress"))
		#Log.pr("rotation: ", transition_texture.material.get_shader_parameter("rotation_angle"))
	#
	
func transition_to_scene(scene_path, effect_in: TransitionEffect = null, effect_out: TransitionEffect = null, random_effect: bool = false) -> void:
	if effect_out == null:
		effect_out = effect_in

	if random_effect:
		effect_in = get_rand_effect()
		effect_out = get_rand_effect()

	var new_scene
	if typeof(scene_path) == TYPE_STRING:
		new_scene = load(scene_path).instantiate()
	else: new_scene = scene_path
	
	##TRANSITION OUT
	await play_transition(effect_out, Direction.OUT)
	
	##CHANGE SCENE
	var tree := get_tree()
	if tree.current_scene:
		tree.current_scene.queue_free()
	tree.root.add_child(new_scene)
	tree.current_scene = new_scene
	
	##TRANSITION IN
	await  play_transition(effect_in, Direction.IN)
	
	transition_texture.visible = false


func get_rand_effect()-> TransitionEffect:
	var rand_effect = transitions.keys().pick_random()
	var effect: TransitionEffect = transitions[rand_effect]
	Log.pr("random effect: ", effect.resource_path)
	return effect


func play_transition(effect: TransitionEffect, dir: Direction) -> Signal:
	var clock_type = effect.shader.get_shader_parameter("transition_type") == 3
	transition_texture.visible = true
	current_effect = effect.duplicate(true)
	transition_parameters = current_effect.params
	
	transition_texture.texture = effect.x_texture
	transition_texture.material = effect.shader.duplicate(true)
	
	match dir:
		Direction.OUT: 
			transition_texture.material.set_shader_parameter("invert", false if clock_type else true)
		Direction.IN: 
			transition_texture.material.set_shader_parameter("invert", true if clock_type else false)


	var tween : Tween = create_tween().set_parallel()
	
	for param in transition_parameters:
		var start_value = transition_parameters[param][0]
		var end_value = transition_parameters[param][1]
		var duration = current_effect.duration
		transition_texture.material.set_shader_parameter(param, start_value)

		tween.tween_property(transition_texture.material, "shader_parameter/%s" % param, start_value, 0.0)
		tween.tween_property(transition_texture.material, "shader_parameter/%s" % param, end_value, duration)
		tween.finished.connect(func():
			_on_transition_ended(dir)
			Log.pr("tween finished for %s" % param))

	await tween.finished
	transition_texture.visible = false
	return tween.finished


func _on_transition_ended(dir) -> void:
	match dir:
		Direction.IN:
			EventHub.game.transition_in_ended.emit()
		Direction.OUT:
			EventHub.game.transition_out_ended.emit()
