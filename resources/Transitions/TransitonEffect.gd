extends Resource
class_name TransitionEffect

@export var x_texture : Texture2D
@export var shader : ShaderMaterial
@export var duration : float
@export var params : Dictionary = {
	"progress" : [0.0, 1.0]
}
@export var description : String = ""
