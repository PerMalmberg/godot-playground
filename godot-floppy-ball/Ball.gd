extends RigidBody2D

signal hit_left_wall

onready var game_state = get_node("/root/GameState")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
const horizontal_force = 80.0
const vertical_force = 80.0
const bounce_multiplier = 20

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		apply_central_impulse(Vector2(0, -vertical_force))
	elif Input.is_action_pressed("ui_down"):
		apply_central_impulse(Vector2(0, vertical_force))
	
	if get_applied_force().x < horizontal_force && Input.is_action_pressed("ui_right"):
		apply_central_impulse(Vector2(horizontal_force, 0))
	elif Input.is_action_pressed("ui_left"):
		apply_central_impulse(Vector2(-horizontal_force, 0))
		
func body_shape_entered(body_id: int, body: Node, body_shape: int, local_shape: int) -> void:
	if body.get_name() == "left_wall":
		emit_signal("hit_left_wall")
	elif body.get_name() == "score_wall":
		game_state.score += 1
	
	# Add some bounce when running into walls
	if $left_side_detector.is_colliding():
		apply_central_impulse(Vector2(bounce_multiplier / 4 * horizontal_force, 0))
	if $right_side_detector.is_colliding():
		apply_central_impulse(Vector2(- bounce_multiplier * horizontal_force, 0))
	elif $up_side_detector.is_colliding():
		apply_central_impulse(Vector2(0, bounce_multiplier * vertical_force))
	elif $low_side_detector.is_colliding():
		apply_central_impulse(Vector2(0, - bounce_multiplier * vertical_force))

