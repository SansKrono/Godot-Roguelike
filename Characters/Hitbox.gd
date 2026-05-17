extends Area2D
class_name Hitbox

@export var damage: int = 1
var knockback_direction: Vector2 = Vector2.ZERO
@export var knockback_force: int = 300

var bodies_inside: Array[Node2D] = []

@onready var collision_shape: CollisionShape2D = get_child(0)
@onready var timer: Timer = Timer.new()


func _init() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _ready() -> void:
	assert(collision_shape != null)
	timer.wait_time = 1.0
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)


func _on_body_entered(body: Node2D) -> void:
	if not bodies_inside.has(body):
		bodies_inside.append(body)
		_collide(body)
		if timer.is_stopped():
			timer.start()


func _on_body_exited(body: Node2D) -> void:
	bodies_inside.erase(body)
	if bodies_inside.is_empty():
		timer.stop()


func _on_timer_timeout() -> void:
	var to_remove: Array[Node2D] = []
	for body in bodies_inside:
		if not is_instance_valid(body):
			to_remove.append(body)
			continue
		_collide(body)
	
	for body in to_remove:
		bodies_inside.erase(body)
		
	if bodies_inside.is_empty():
		timer.stop()


func _collide(body: Node2D) -> void:
	if not is_instance_valid(body) or not body.has_method("take_damage"):
		queue_free()
	else:
		body.take_damage(damage, knockback_direction, knockback_force)
