extends Node2D

@export_category("Oscillation")
@export var lightColor := Color(1, 1, 1, 1)
@export var minScale: float = 1
@export var maxScale: float = 2
@export_exp_easing("inout")
var curve: float = -0.5 # 1 = Linear
@export
var frequency: float = 1 # Hz

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Body.material = %Body.material.duplicate()
	%Body.material.set_shader_parameter("color", lightColor)
	%Body.scale = Vector2(minScale, minScale)
	%PulsatingLight.set_texture( %PulsatingLight.get_texture().duplicate())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Times two since we do abs() to keep on the positive side
	var mul := abs(sin(Time.get_unix_time_from_system() * frequency * 2)) as float
	var newScale := minScale + (maxScale - minScale) * ease(mul, curve)

	%PulsatingLight.texture_scale = newScale
	%PulsatingLight.color = lightColor
