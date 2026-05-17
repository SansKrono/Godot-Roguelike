extends Area2D
class_name ItemPickup

@onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		collision_shape.set_deferred("disabled", true)
		_on_collected(body)
		_animate_collection()

# To be overridden by subclasses
func _on_collected(_player: Player) -> void:
	pass

func _animate_collection() -> void:
	var tween: Tween = create_tween().set_parallel()
	modulate.a = 1
	tween.tween_property(self, "modulate:a", 0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", position.y - 16, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(queue_free)
