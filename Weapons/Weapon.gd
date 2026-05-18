@icon("res://Art/v1.1 dungeon crawler 16x16 pixel pack/heroes/knight/weapon_sword_1.png")

extends Node2D
class_name Weapon

@export var on_floor: bool = false

@export var ranged_weapon: bool = true
@export var rotation_offset: int = 0

@export var projectile_scene: PackedScene = preload("res://Weapons/Arrow.tscn")
@export var num_projectiles: int = 1
@export var projectile_speed: int = 400
@export var projectile_damage: int = 1
@export var spread_angle: float = 15.0

@export var has_dot: bool = false
@export var dot_damage: int = 1
@export var dot_duration: float = 3.0

var can_active_ability: bool = true

var tween: Tween = null
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var hitbox: Area2D = get_node("Node2D/Sprite2D/Hitbox")
@onready var charge_particles: GPUParticles2D = get_node("Node2D/Sprite2D/ChargeParticles")
@onready var player_detector: Area2D = get_node("PlayerDetector")
@onready var cool_down_timer: Timer = get_node("CoolDownTimer")
@onready var ui: CanvasLayer = get_node("UI")
@onready var ability_icon: TextureProgressBar = ui.get_node("AbilityIcon")


func _ready() -> void:
	if not on_floor:
		player_detector.set_collision_mask_value(1, false)
		player_detector.set_collision_mask_value(2, false)

	draw.connect(_on_show)
	hidden.connect(_on_hide)


func get_input() -> void:
	if Input.is_action_just_pressed("ui_attack") and not animation_player.is_playing():
		animation_player.play("charge")
	elif Input.is_action_just_released("ui_attack"):
		if animation_player.is_playing() and animation_player.current_animation == "charge":
			animation_player.play("attack")
		elif charge_particles.emitting:
			animation_player.play("strong_attack")
	elif Input.is_action_just_pressed("ui_active_ability") and animation_player.has_animation("active_ability") and not is_busy() and can_active_ability:
		can_active_ability = false
		cool_down_timer.start()
		ui.recharge_ability_animation(cool_down_timer.wait_time)
		animation_player.play("active_ability")


func move(mouse_direction: Vector2) -> void:
	rotation_degrees = rad_to_deg(mouse_direction.angle()) + rotation_offset


func cancel_attack() -> void:
	animation_player.play("RESET")


func is_busy() -> bool:
	if animation_player.is_playing() or charge_particles.emitting:
		return true
	return false


func shoot(offset: float = 0.0) -> void:
	if not projectile_scene:
		return
		
	var start_index = - (num_projectiles - 1) / 2.0
	for i in range(num_projectiles):
		var p: Node2D = projectile_scene.instantiate()
		get_tree().current_scene.add_child(p)
		
		var angle_offset = (start_index + i) * spread_angle
		var dir = Vector2.LEFT.rotated(deg_to_rad(rotation_degrees + offset + angle_offset))
		
		if p.has_method("launch"):
			p.launch(global_position, dir, projectile_speed)
		
		if "damage" in p:
			p.damage = projectile_damage
			
		if p.has_method("set_dot"):
			p.set_dot(has_dot, dot_damage, dot_duration)


func _on_PlayerDetector_body_entered(body: PhysicsBody2D) -> void:
	if body != null:
		if tween:
			tween.kill()
		player_detector.set_collision_mask_value(1, false)
		player_detector.set_collision_mask_value(2, false)
		body.pick_up_weapon(self)
		position = Vector2.ZERO
	else:
		if tween:
			tween.kill()
		player_detector.set_collision_mask_value(2, true)


func interpolate_pos(initial_pos: Vector2, final_pos: Vector2) -> void:
	position = initial_pos
	tween = create_tween()
	tween.tween_property(self, "position", final_pos, 0.8).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_on_Tween_tween_completed)
	player_detector.set_collision_mask_value(1, true)


func _on_Tween_tween_completed() -> void:
	player_detector.set_collision_mask_value(2, true)


func _on_CoolDownTimer_timeout() -> void:
	can_active_ability = true


func _on_show() -> void:
	ability_icon.show()


func _on_hide() -> void:
	ability_icon.hide()


func get_texture() -> Texture2D:
	return get_node("Node2D/Sprite2D").texture
