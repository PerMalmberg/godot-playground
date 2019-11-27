extends Node

class_name JumpTerminator

var remaining_time : float = 0

func start(total_time : float) -> void:
	remaining_time = total_time
	
func inhibit_jump(delta: float):
	