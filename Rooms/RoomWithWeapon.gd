extends DungeonRoom

const CHEST_SCENE: PackedScene = preload("res://Rooms/Chest.tscn")
const REWARD_LOOT_TABLE: LootTable = preload("res://Rooms/RewardLootTable.tres")

@onready var weapon_pos: Marker2D = get_node("WeaponPos")


func _ready() -> void:
	var chest: Chest = CHEST_SCENE.instantiate()
	chest.position = weapon_pos.position
	chest.loot_table = REWARD_LOOT_TABLE
	add_child(chest)
