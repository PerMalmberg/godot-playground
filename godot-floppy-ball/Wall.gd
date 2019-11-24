extends StaticBody2D

class_name Wall

signal exited_screen

var manager

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func exited_screen():
	# Wall exited the screen, remove it.
	emit_signal("exited_screen", self)
	queue_free()

func set_size(size : Vector2):
	$ColorRect.set_position(Vector2())
	$ColorRect.set_size(size)
	$CollisionShape2D.get_shape().set_extents(size/2);
	$CollisionShape2D.set_position(Vector2($ColorRect.get_size().x/2, $ColorRect.get_size().y /2))
