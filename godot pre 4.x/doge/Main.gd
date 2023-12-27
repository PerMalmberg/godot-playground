extends Node

export (PackedScene) var Mob

var score : int

func _ready():
	randomize()

func game_over():
	$MobTimer.stop()
	$Hud.update_score(score)
	$Hud.show_game_over()
	$Music.stop();
	$DeathSound.play();
	
func new_game():
	score = 0
	$Hud.update_score(score)
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$Music.play();


func _on_MobTimer_timeout():
	$MobPath/MobSpawnLocation.set_offset(randi())
	var mob = Mob.instance()
	add_child(mob)
	var direction = $MobPath/MobSpawnLocation.rotation + PI / 2
	mob.position = $MobPath/MobSpawnLocation.position
	direction += rand_range(-PI / 4, PI / 4)
	mob.rotation = direction
	mob.linear_velocity = Vector2(rand_range(mob.min_speed, mob.max_speed), 0)
	mob.linear_velocity = mob.linear_velocity.rotated(direction)
	score += 1
	$Hud.update_score(score)
	

func _on_StartTimer_timeout():
	$MobTimer.start()
	$Player.show()
