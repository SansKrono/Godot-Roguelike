extends Hitbox


@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")


func _ready() -> void:
	super()
	animation_player.play("pierce")


func _collide(body: Node2D) -> void:
	if is_instance_valid(body) and not body.flying:
		knockback_direction = (body.global_position - global_position).normalized()
		body.take_damage(damage, knockback_direction, knockback_force)
