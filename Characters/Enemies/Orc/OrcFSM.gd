extends FiniteStateMachine

@onready var hitbox: Area2D = parent.get_node("Hitbox")

func _init() -> void:
	_add_state("idle")
	_add_state("move")
	_add_state("attack")
	_add_state("hurt")
	_add_state("dead")

func _ready() -> void:
	set_state(states.move)

func _state_logic(_delta: float) -> void:
	if state == states.move:
		parent.chase()
		parent.move()

func _get_transition() -> int:
	match state:
		states.idle:
			if parent.distance_to_player > parent.MAX_DISTANCE_TO_PLAYER:
				return states.move
			elif parent.distance_to_player <= parent.MAX_DISTANCE_TO_PLAYER:
				return states.attack
		states.move:
			if parent.distance_to_player <= parent.MAX_DISTANCE_TO_PLAYER:
				return states.attack
		states.attack:
			if not animation_player.is_playing():
				return states.idle
		states.hurt:
			if not animation_player.is_playing():
				return states.move
	return -1

func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.idle:
			animation_player.play("idle")
		states.move:
			animation_player.play("move")
		states.attack:
			if is_instance_valid(parent.player):
				hitbox.knockback_direction = (parent.player.global_position - parent.global_position).normalized()
			animation_player.play("attack")
		states.hurt:
			animation_player.play("hurt")
		states.dead:
			animation_player.play("dead")
