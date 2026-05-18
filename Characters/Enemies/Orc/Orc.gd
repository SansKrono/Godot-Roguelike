extends Enemy

const MAX_DISTANCE_TO_PLAYER: int = 40

var distance_to_player: float

func _on_PathTimer_timeout() -> void:
	if is_instance_valid(player):
		distance_to_player = (player.position - global_position).length()
		_get_path_to_player()
	else:
		mov_direction = Vector2.ZERO
