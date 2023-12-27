extends RigidBody2D
class_name Scuttler

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as float
var direction := Vector2(randf_range( - 1, 1), randf_range( - 1, 1)).normalized()
var death_time := Time.get_unix_time_from_system() + randf_range(2, 10)

func _ready() -> void:
	apply_central_impulse(direction * gravity * 0.5)
	
func _bounds() -> void:
	var viewport := get_viewport_rect()
	if !viewport.has_point(position):
		apply_central_impulse( (viewport.get_center() - global_position).normalized() * gravity * 0.5)

func _process(_delta:float) -> void:
	if death_time < Time.get_unix_time_from_system():
		queue_free()

func _physics_process(_delta: float) -> void:
	_bounds()
	
func _integrate_forces(state : PhysicsDirectBodyState2D) -> void:
	rotation_degrees = 0	
