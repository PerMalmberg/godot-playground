extends KinematicBody

const normal: = Vector3(0, 1, 0)

const min_player_speed: = 8
const max_player_speed: = 30.0
var player_speed: float = 0

const player_gravity: = 10
var current_player_gravity = player_gravity


const rot_speed: = 1
var y_rotation : float = 0.0

# Note: Expecting SphereShape
onready var radius: float = $CollisionShape.shape.radius

func _ready() -> void:
	pass
	
func set_direction(angle : float):
	if is_on_floor():
		y_rotation = angle

func update_velocity(delta: float) -> Vector3:
	var up: = Input.is_action_pressed("ui_up")
	var down: = Input.is_action_pressed("ui_down")
	var left: = Input.is_action_pressed("ui_left")
	var right: = Input.is_action_pressed("ui_right")
	var accelerate: = Input.is_action_pressed("accelerate")
	var jump: = Input.is_action_pressed("jump")
	
	var velocity = Vector3(player_speed, 0, player_speed)

	var sideways : float = 0

	if left and right:
		pass
	elif left:
		sideways = -1
	elif right:
		sideways = 1

	# Invert angle when moving backwards
	var invert_sideway: = 1 if down else -1

	# Add +/-45 degrees when pressing left/right
	if left and right:
		pass
	elif left:
		y_rotation += TAU / 8 * sideways * invert_sideway
	elif right:
		y_rotation += TAU / 8 * sideways * invert_sideway

	# Calcualte resulting vector
	velocity.x *= sin(y_rotation)
	velocity.z *= cos(y_rotation)

	$front_collision_detector.set_cast_to(velocity.normalized() * (radius + 0.2) )
	var hitting_wall = $front_collision_detector.is_colliding()

	# Can only jump or accelerate when on floor
	var target_speed: float = 0
	if is_on_floor():
		if hitting_wall:
			target_speed = 0
			player_speed = 0
		else:
			if accelerate:
				target_speed = max_player_speed
			else:
				target_speed = min_player_speed

		if jump:
			current_player_gravity = - player_gravity
	else:
		# Increase gravity to create a slowly arcing jump
		current_player_gravity = lerp(current_player_gravity, player_gravity, 1.5 * delta)

	if up and down:
		player_speed = lerp(player_speed, 0, 0.1  * delta)
	elif up:
		player_speed = lerp(player_speed, -target_speed, delta)
	elif down:
		player_speed = lerp(player_speed, target_speed, delta)
	else:
		player_speed = lerp(player_speed, 0, 0.1 * delta)
	
	if hitting_wall:
		velocity = Vector3(0, -current_player_gravity, 0)
	else:
		velocity.y -= current_player_gravity

	if Vector2(velocity.x, velocity.z).length() > 0:
		var spin: = deg2rad(rot_speed * player_speed)
		if up:
			$MeshInstance.rotate_z(-spin * sin(y_rotation))
			$MeshInstance.rotate_x(spin * cos(y_rotation))
		else:
			$MeshInstance.rotate_z(-spin * sin(y_rotation))
			$MeshInstance.rotate_x(spin * cos(y_rotation))

	return velocity

func _physics_process(delta: float) -> void:
	var velocity = update_velocity(delta)
	
	# warning-ignore:return_value_discarded
	move_and_slide(velocity, normal)