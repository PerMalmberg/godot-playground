class_name WallManager

var Wall : PackedScene = load("res://Wall.tscn")

var walls : Array = Array()
var screen_size : Vector2

var time_between_walls : float
var time_to_move_across_screen : float = 5

func _init(screen_size : Vector2, time_between_walls : float):
	self.screen_size = screen_size
	self.time_between_walls = time_between_walls

func create_wall_pair(parent : Node2D) -> void:
		
	if has_space_to_previous_wall():
		# 10 - 40 pixels wide
		var width : float = 11 + randi() % 100
		# Get the center of the opening, somewhere in the middle 75% of the screen
		var y_center = screen_size.y * clamp(randf(), 0.125, 0.75)
		
		# Opeing height: 25%
		var opening : float = screen_size.y * 0.25;

		# Upper
		var wall = Wall.instance()
		var height = y_center - opening / 2;
		wall.set_position(Vector2(screen_size.x, 0))
		wall.set_size(Vector2(width, height))		
		walls.push_back(wall)
		parent.add_child(wall)
		wall.connect("exited_screen", self, "on_wall_exited_screen")
		
		# Lower
		wall = Wall.instance()
		height = screen_size.y - (y_center + opening / 2)	
		wall.set_position(Vector2(screen_size.x, screen_size.y - height))
		wall.set_size(Vector2(width, height))	
		wall.set_size(Vector2(width, height))
		walls.push_back(wall)
		parent.add_child(wall)
		wall.connect("exited_screen", self, "on_wall_exited_screen")
		
func move_walls(delta : float) -> void:
	var distance = Vector2(-calculate_move_distance(delta), 0)
	for w in walls:		
		w.set_position(w.get_position() + distance)
		
func on_wall_exited_screen(wall: StaticBody2D):
	remove_wall(wall)

func remove_wall(wall : StaticBody2D) -> void:
	var index : int = walls.find(wall)
	if index >= 0:
		walls.remove(index)
		
func has_space_to_previous_wall() -> bool:
	var res : bool = false
	
	# Check if the last wall has moved enough to the left so that
	# there is room for the next wall.
	
	if walls.size() == 0:
		# No previous wall so just add one
		res = true
	else:
		# How many walls fit on the screen? -> time to traverse the screen / time between each wall
		var wall_count = time_to_move_across_screen / time_between_walls
		# How far is it between each wall (not counting the wall width)?
		var distance_between_walls = screen_size.x / wall_count
		
		# Where is the right most wall?
		var prev : StaticBody2D = walls[walls.size()-1]
		var pos = prev.get_position().x
		
		# If the wall has moved far enough to the left, allow another wall.
		res = pos < screen_size.x - distance_between_walls
	
	return res
	
func calculate_move_distance(delta : float) -> float:
	# Calculate the speed the walls needs to have to move from right to left in the given time.
	return screen_size.x / time_to_move_across_screen * delta
	
func clear():
	for w in walls:
		remove_wall(w)
		w.queue_free()
	