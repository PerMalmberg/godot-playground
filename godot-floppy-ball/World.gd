extends Node2D

var walls : WallManager
onready var game_state = get_node("/root/GameState")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	walls = WallManager.new(get_viewport_rect().size, 1)
	$Ball.connect("hit_left_wall", self, "on_game_over")
	game_state.score = 0

func _process(delta) -> void:
	walls.create_wall_pair(self)
	walls.move_walls(delta)
	$hud/score.set_text("Score: " + str(game_state.score))

func on_game_over():
	get_tree().change_scene("res://game_over.tscn")

