extends KinematicBody

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

const turn_time_seconds: float = 1.0 # Time for one turn
const angle_per_second: float = TAU / turn_time_seconds # Radians per seconds
var curr_x : float = 0
var curr_y : float = 0
var curr_z : float = 0

onready var org_trans: Transform = transform

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var angle_delta := angle_per_second * delta
		
	if Input.is_action_pressed("ui_up"):
		curr_y = wrapf( curr_y + angle_delta, 0, TAU);
	
	if Input.is_action_pressed("ui_right"):
		curr_x = wrapf(curr_x + angle_delta, 0, TAU);
		
	if Input.is_action_pressed("ui_left"):
		curr_z = wrapf(curr_z + angle_delta, 0, TAU);
		
	transform = org_trans.rotated(Vector3.RIGHT, curr_x)
	transform = transform.rotated(Vector3.UP, curr_y)
	transform = transform.rotated(Vector3.FORWARD, curr_z)
	
func map_range(value: float, source_min: float, source_max: float, target_min: float, target_max: float):
	return (value / (source_max - source_min)) * (target_max - target_min)