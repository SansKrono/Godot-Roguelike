extends ItemPickup

@export var min_value: int = 1
@export var max_value: int = 5

func _on_collected(player: Player) -> void:
	var value: int = randi_range(min_value, max_value)
	player.coins += value
	SavedData.coins += value
