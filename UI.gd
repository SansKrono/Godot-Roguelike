extends CanvasLayer

const INVENTORY_ITEM_SCENE: PackedScene = preload("res://InventoryItem.tscn")

const MIN_HEALTH: int = 23

var max_hp: int = 4

@onready var player: CharacterBody2D = get_parent().get_node("Player")
@onready var health_bar: TextureProgressBar = get_node("HealthBar")

@onready var inventory: HBoxContainer = get_node("PanelContainer/Inventory")
@onready var coin_label: Label = get_node("CoinCounter/Label")
var banner_label: Label


func _ready() -> void:
	max_hp = player.max_hp
	_update_health_bar(100)
	player.coins_changed.connect(_on_Player_coins_changed)
	_on_Player_coins_changed(player.coins)
	
	banner_label = Label.new()
	banner_label.visible = false
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	banner_label.add_theme_font_size_override("font_size", 16)
	banner_label.add_theme_color_override("font_outline_color", Color.BLACK)
	banner_label.add_theme_constant_override("outline_size", 4)
	banner_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	banner_label.position.y = 40
	add_child(banner_label)

func show_item_banner(item_name: String) -> void:
	banner_label.text = item_name
	banner_label.visible = true
	await get_tree().create_timer(2.0).timeout
	banner_label.visible = false


func _update_health_bar(new_value: int) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(health_bar, "value", new_value, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)


func _on_Player_hp_changed(new_hp: int) -> void:
	var new_health: int = int((100 - MIN_HEALTH) * float(new_hp) / max_hp) + MIN_HEALTH
	_update_health_bar(new_health)


func _on_Player_weapon_switched(prev_index: int, new_index: int) -> void:
	inventory.get_child(prev_index).deselect()
	inventory.get_child(new_index).select()


func _on_Player_weapon_picked_up(weapon_texture: Texture2D) -> void:
	var new_inventory_item: TextureRect = INVENTORY_ITEM_SCENE.instantiate()
	inventory.add_child(new_inventory_item)
	new_inventory_item.initialize(weapon_texture)


func _on_Player_weapon_droped(index: int) -> void:
	inventory.get_child(index).queue_free()


func _on_Player_coins_changed(new_coins: int) -> void:
	coin_label.text = "x " + str(new_coins)
