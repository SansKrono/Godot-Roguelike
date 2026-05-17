extends ItemPickup

enum UpgradeType { MAX_HP, SPEED }

@export var upgrade_type: UpgradeType = UpgradeType.MAX_HP

@onready var sprite: Sprite2D = get_node("Sprite2D")

func _ready() -> void:
	super()
	_update_visuals()

func _update_visuals() -> void:
	if not is_inside_tree() or not sprite:
		return
	if upgrade_type == UpgradeType.SPEED:
		sprite.texture = preload("res://Art/v1.1 dungeon crawler 16x16 pixel pack/props_itens/potion_green.png")
	else:
		sprite.texture = preload("res://Art/v1.1 dungeon crawler 16x16 pixel pack/props_itens/potion_yellow.png")

func _on_collected(player: Player) -> void:
	if upgrade_type == UpgradeType.SPEED:
		player.max_speed = int(player.max_speed * 1.15)
		player.accerelation = int(player.accerelation * 1.15)
		SavedData.max_speed = player.max_speed
		SavedData.accerelation = player.accerelation
	else:
		player.max_hp += 1
		player.hp = player.max_hp
		SavedData.max_hp = player.max_hp
		SavedData.hp = player.hp
