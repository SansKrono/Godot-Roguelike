extends ItemPickup

func _on_collected(player: Player) -> void:
	player.hp += 1
