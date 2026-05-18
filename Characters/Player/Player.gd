extends Character
class_name Player

const DUST_SCENE: PackedScene = preload("res://Characters/Player/Dust.tscn")

enum {UP, DOWN}

var current_weapon: Node2D
var coins: int = 0: set = set_coins

signal weapon_switched(prev_index, new_index)
signal weapon_picked_up(weapon_texture)
signal weapon_droped(index)
signal coins_changed(new_coins)

@onready var parent: Node2D = get_parent()
@onready var weapons: Node2D = get_node("Weapons")
@onready var dust_position: Marker2D = get_node("DustPosition")


func _ready() -> void:
	emit_signal("weapon_picked_up", weapons.get_child(0).get_texture())

	_restore_previous_state()


func set_coins(new_coins: int) -> void:
	coins = new_coins
	emit_signal("coins_changed", coins)


func _restore_previous_state() -> void:
	self.max_hp = SavedData.max_hp
	self.hp = SavedData.hp
	self.max_speed = SavedData.max_speed
	self.accerelation = SavedData.accerelation
	self.coins = SavedData.coins
	
	for weapon in weapons.get_children():
		if weapon is Weapon:
			weapon.num_projectiles = SavedData.num_projectiles
			weapon.projectile_speed = SavedData.projectile_speed
			weapon.projectile_damage = SavedData.projectile_damage
			weapon.has_dot = SavedData.has_dot
			weapon.dot_damage = SavedData.dot_damage
			weapon.dot_duration = SavedData.dot_duration
			if weapon.has_node("CoolDownTimer"):
				weapon.get_node("CoolDownTimer").wait_time = SavedData.fire_rate
			if weapon.animation_player:
				weapon.animation_player.speed_scale = 0.6 / SavedData.fire_rate

	current_weapon = weapons.get_child(0)
	current_weapon.show()


func _process(_delta: float) -> void:
	var mouse_direction: Vector2 = (get_global_mouse_position() - global_position).normalized()

	if mouse_direction.x > 0 and animated_sprite.flip_h:
		animated_sprite.flip_h = false
	elif mouse_direction.x < 0 and not animated_sprite.flip_h:
		animated_sprite.flip_h = true

	current_weapon.move(mouse_direction)


func get_input() -> void:
	mov_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	current_weapon.get_input()


func _switch_weapon(direction: int) -> void:
	var prev_index: int = current_weapon.get_index()
	var index: int = prev_index
	if direction == UP:
		index -= 1
		if index < 0:
			index = weapons.get_child_count() - 1
	else:
		index += 1
		if index > weapons.get_child_count() - 1:
			index = 0

	current_weapon.hide()
	current_weapon = weapons.get_child(index)
	current_weapon.show()
	SavedData.equipped_weapon_index = index

	emit_signal("weapon_switched", prev_index, index)


func pick_up_weapon(weapon: Node2D) -> void:
	SavedData.weapons.append(weapon.duplicate())
	var prev_index: int = SavedData.equipped_weapon_index
	var new_index: int = weapons.get_child_count()
	SavedData.equipped_weapon_index = new_index
	weapon.get_parent().call_deferred("remove_child", weapon)
	weapons.call_deferred("add_child", weapon)
	weapon.set_deferred("owner", weapons)
	current_weapon.hide()
	current_weapon.cancel_attack()
	current_weapon = weapon

	emit_signal("weapon_picked_up", weapon.get_texture())
	emit_signal("weapon_switched", prev_index, new_index)


func _drop_weapon() -> void:
	SavedData.weapons.remove_at(current_weapon.get_index() - 1)
	var weapon_to_drop: Node2D = current_weapon
	_switch_weapon(UP)

	emit_signal("weapon_droped", weapon_to_drop.get_index())

	weapons.call_deferred("remove_child", weapon_to_drop)
	get_parent().call_deferred("add_child", weapon_to_drop)
	weapon_to_drop.set_owner(get_parent())
	await weapon_to_drop.tree_entered
	weapon_to_drop.show()

	var throw_dir: Vector2 = (get_global_mouse_position() - position).normalized()
	weapon_to_drop.interpolate_pos(position, position + throw_dir * 50)


func cancel_attack() -> void:
	current_weapon.cancel_attack()


func spawn_dust() -> void:
	var dust: Sprite2D = DUST_SCENE.instantiate()
	dust.position = dust_position.global_position
	parent.get_child(get_index() - 1).add_sibling(dust)


func switch_camera() -> void:
	var main_scene_camera: Camera2D = get_parent().get_node("Camera2D")
	main_scene_camera.position = position
	main_scene_camera.current = true
	get_node("Camera2D").current = false
