extends KinematicBody

const GRAVITY = -24.8
const MAX_SPEED = 20
const JUMP_SPEED = 18
const JUMP_DURATION = 2

const ACCEL = 4.5
const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40

var velocity : Vector3
var direction : Vector3

onready var camera = $Rotation_Helper/Camera
onready var rotation_helper = $Rotation_Helper

const MOUSE_SENSITIVITY = 0.05

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	process_input(delta)
	process_movement(delta)

func process_input(delta : float):
	
	# Based on input, setup movement along the ground plane
	# where Y is forward, X is sideways.
	var input_movement_vector = Vector2()
	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1
		
	# Make sure diagonal movement isn't faster than along X/Z
	input_movement_vector = input_movement_vector.normalized()
	
	# Get global camera direction along the x/z plane, i.e. ground plane.
	var cam_xform = camera.get_global_transform()
	direction = Vector3()
	# In 3D, Z is forward/backwards, X sideways. Z is 'reversed', so negate it.
	direction += -cam_xform.basis.z * input_movement_vector.y
	direction += cam_xform.basis.x * input_movement_vector.x
	direction = direction.normalized()

	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			velocity.y = JUMP_SPEED
			
	# Capture/free cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		print(Input.get_mouse_mode())
	
func process_movement(delta : float):
	# https://docs.godotengine.org/en/3.1/tutorials/3d/fps_tutorial/part_one.html#tutorial-introduction
	
	# Decrease vertical velocity each frame to end a jump
	velocity.y += GRAVITY * delta
	
	print(velocity.y)
	
	var horizontal_velocity : Vector3 = velocity
	horizontal_velocity.y = 0
	
	var target : Vector3 = direction * MAX_SPEED
	
	var acceleration = ACCEL if direction.dot(horizontal_velocity) > 0 else DEACCEL
		
	horizontal_velocity = horizontal_velocity.linear_interpolate(target, acceleration * delta)
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	
	velocity = move_and_slide(velocity, Vector3.UP)

func _input(event):
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
        self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

        var camera_rot = rotation_helper.rotation_degrees
        camera_rot.x = clamp(camera_rot.x, -70, 70)
        rotation_helper.rotation_degrees = camera_rot
