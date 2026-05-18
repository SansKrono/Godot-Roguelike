extends Weapon


func triple_shoot() -> void:
	var original_num = num_projectiles
	num_projectiles = max(3, num_projectiles * 2) # Make it "extra" strong
	shoot(0)
	num_projectiles = original_num
