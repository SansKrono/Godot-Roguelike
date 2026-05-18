extends ItemPickup
class_name UpgradePickup

enum UpgradeType { MAX_HP, SPEED, DAMAGE, FIRE_RATE, ADDITIONAL_PROJECTILES, PROJECTILE_SPEED, DOT }

@export var upgrade_type: UpgradeType = UpgradeType.MAX_HP

@onready var sprite: Sprite2D = get_node("Sprite2D")

func _ready() -> void:
	super()
	_update_visuals()

func _update_visuals() -> void:
	if not is_inside_tree() or not sprite:
		return
	match upgrade_type:
		UpgradeType.SPEED:
			sprite.texture = preload("res://Art/v1.1 dungeon crawler 16x16 pixel pack/props_itens/potion_green.png")
		UpgradeType.DAMAGE:
			sprite.texture = preload("res://Art/v1.1 dungeon crawler 16x16 pixel pack/props_itens/potion_red.png")
		UpgradeType.FIRE_RATE:
			sprite.texture = preload("res://Art/v1.1 dungeon crawler 16x16 pixel pack/props_itens/flag_green.png")
		UpgradeType.ADDITIONAL_PROJECTILES:
			sprite.texture = preload("res://Art/v1.1 dungeon crawler 16x16 pixel pack/props_itens/flag_red.png")
		UpgradeType.PROJECTILE_SPEED:
			sprite.texture = preload("res://Art/v1.1 dungeon crawler 16x16 pixel pack/props_itens/potion_red.png")
		UpgradeType.DOT:
			sprite.texture = preload("res://Art/v1.1 dungeon crawler 16x16 pixel pack/props_itens/potion_green.png")
			sprite.modulate = Color(0.5, 0, 0.5) # Purple for poison
		_:
			sprite.texture = preload("res://Art/v1.1 dungeon crawler 16x16 pixel pack/props_itens/potion_yellow.png")

func get_upgrade_name() -> String:
	match upgrade_type:
		UpgradeType.SPEED: return "Speed Up"
		UpgradeType.DAMAGE: return "Damage Up"
		UpgradeType.FIRE_RATE: return "Fire Rate Up"
		UpgradeType.ADDITIONAL_PROJECTILES: return "Extra Projectile"
		UpgradeType.PROJECTILE_SPEED: return "Projectile Speed Up"
		UpgradeType.DOT: return "Poison Shots"
		_: return "Health Up"

func _on_collected(player: Player) -> void:
	match upgrade_type:
		UpgradeType.SPEED:
			player.max_speed = int(player.max_speed * 1.15)
			player.accerelation = int(player.accerelation * 1.15)
			SavedData.max_speed = player.max_speed
			SavedData.accerelation = player.accerelation
		UpgradeType.DAMAGE:
			SavedData.projectile_damage += 1
			for weapon in player.weapons.get_children():
				if weapon is Weapon:
					weapon.projectile_damage = SavedData.projectile_damage
				if weapon.has_node("Node2D/Sprite2D/Hitbox"):
					var hitbox = weapon.get_node("Node2D/Sprite2D/Hitbox")
					hitbox.damage += 1
		UpgradeType.FIRE_RATE:
			SavedData.fire_rate = max(0.1, SavedData.fire_rate * 0.85)
			for weapon in player.weapons.get_children():
				if weapon.has_node("CoolDownTimer"):
					var timer = weapon.get_node("CoolDownTimer")
					timer.wait_time = SavedData.fire_rate
				if weapon is Weapon:
					weapon.animation_player.speed_scale = 0.6 / SavedData.fire_rate
		UpgradeType.ADDITIONAL_PROJECTILES:
			SavedData.num_projectiles += 1
			for weapon in player.weapons.get_children():
				if weapon is Weapon:
					weapon.num_projectiles = SavedData.num_projectiles
		UpgradeType.PROJECTILE_SPEED:
			SavedData.projectile_speed += 50
			for weapon in player.weapons.get_children():
				if weapon is Weapon:
					weapon.projectile_speed = SavedData.projectile_speed
		UpgradeType.DOT:
			SavedData.has_dot = true
			SavedData.dot_damage += 1
			for weapon in player.weapons.get_children():
				if weapon is Weapon:
					weapon.has_dot = SavedData.has_dot
					weapon.dot_damage = SavedData.dot_damage
		_:
			player.max_hp += 1
			player.hp = player.max_hp
			SavedData.max_hp = player.max_hp
			SavedData.hp = player.hp
