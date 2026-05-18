extends Enemy

const MAGIC_SCENE: PackedScene = preload("res://Characters/Enemies/Wizard/WizardMagic.tscn")

const MAX_DISTANCE_TO_PLAYER: int = 280
const MIN_DISTANCE_TO_PLAYER: int = 140

@export var projectile_speed: int = 280

var can_attack: bool = true
var distance_to_player: float

@onready var attack_timer: Timer = get_node("AttackTimer")
@onready var aim_raycast: RayCast2D = get_node("AimRayCast")

func _on_PathTimer_timeout() -> void:
	if is_instance_valid(player):
		distance_to_player = (player.position - global_position).length()
		if distance_to_player > MAX_DISTANCE_TO_PLAYER:
			_get_path_to_player()
		elif distance_to_player < MIN_DISTANCE_TO_PLAYER:
			_get_path_to_move_away_from_player()
		else:
			mov_direction = Vector2.ZERO
			aim_raycast.target_position = (player.position - global_position) / scale.x
			if can_attack and state_machine.state == state_machine.states.idle and not aim_raycast.is_colliding():
				can_attack = false
				state_machine.set_state(state_machine.states.attack)
				attack_timer.start()
	else:
		mov_direction = Vector2.ZERO

func _get_path_to_move_away_from_player() -> void:
	var dir: Vector2 = (global_position - player.position).normalized()
	navigation_agent.target_position = global_position + dir * 100

func spawn_magic() -> void:
	if not is_instance_valid(player): return
	var projectile: Area2D = MAGIC_SCENE.instantiate()
	projectile.launch(global_position, (player.position - global_position).normalized(), projectile_speed)
	get_tree().current_scene.add_child(projectile)

func _on_AttackTimer_timeout() -> void:
	can_attack = true
