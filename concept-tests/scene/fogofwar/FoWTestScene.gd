extends Node2D

var scuttler: PackedScene = preload ("res://scene/fogofwar/Scuttler.tscn") as PackedScene

func _physics_process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_SPACE):
		var s := scuttler.instantiate() as Scuttler
		s.global_position = get_global_mouse_position()
		%Scuttlers.add_child(s)
