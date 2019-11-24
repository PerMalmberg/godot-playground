extends Camera

onready var player: KinematicBody = get_tree().get_root().get_node("Level/Player");

const min_camera_distance : float = 5.0
const max_camera_distance : float = 30.0
var camera_distance: float = 10
var rotation_speed : float = TAU / 8
var mouse_movement_delta_x : float = 0
const max_camera_height : int = 30
const min_camera_height : int = 3
var camera_height : float = min_camera_height

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("right_mouse_button"):
		var mouse_event: InputEventMouseMotion = event as InputEventMouseMotion
		
		mouse_movement_delta_x -= mouse_event.relative.x
		
		# Since there's a limit to camera height, we have to handle the case where the mouse moves outside the limits.
		# If we don't, the user has to move the mouse a bit before we start seeing any camera movement.
		camera_height += mouse_event.relative.y * 0.1
		camera_height = clamp(camera_height, min_camera_height, max_camera_height)
		
	elif event is InputEventMouseButton:
		if Input.is_action_pressed("zoom_in"):
			camera_distance -= 1
		elif Input.is_action_pressed("zoom_out"):
			camera_distance += 1
			
		camera_distance = clamp(camera_distance, min_camera_distance, max_camera_distance)

func _process(delta: float) -> void:
		
	# https://docs.godotengine.org/en/3.1/tutorials/3d/using_transforms.html

	# Place camera on top of player
	transform.origin = player.transform.origin
	transform.origin.y += 5
	# Rotate camera around Y
	rotate_object_local(Vector3.UP, mouse_movement_delta_x * rotation_speed * delta)
	mouse_movement_delta_x = 0
	
	# Calculate the vector with a length of camera_distance along the local "forward"
	var y_angle = get_rotation().y
	
	var displacement = Vector3(camera_distance * sin(y_angle), camera_height, camera_distance * cos(y_angle))
	# Move camera along that vector (backwards; negative values is forward)
	transform.origin = player.transform.origin + displacement
	
	# Adjust camera so it is looking down towards the player
	transform = transform.looking_at(player.transform.origin, Vector3.UP)
		
	# Prevent inaccuracies from accumulating 
	transform = transform.orthonormalized()
	
	# Don't allow the player to turn while in the air
	player.set_direction(y_angle)
	