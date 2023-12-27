extends Sprite2D

func _init() -> void:
	hide()

func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	pass

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Light"):
		show()

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("Light"):
		hide()
