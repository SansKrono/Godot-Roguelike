extends StaticBody2D
class_name Chest

@export var loot_table: LootTable

var is_opened: bool = false

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var interaction_area: Area2D = get_node_or_null("InteractionArea")

func _ready() -> void:
	if not sprite or not collision_shape or not interaction_area:
		push_warning("Chest node '%s' is missing required child nodes (Sprite2D, CollisionShape2D, or InteractionArea). If you added this node using the Add Node dialog, please use the 'Instantiate Child Scene' button (chain link icon) and select 'Chest.tscn' instead." % name)
		return
		
	if not interaction_area.body_entered.is_connected(_on_body_entered):
		interaction_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if is_opened:
		return
	if body is Player:
		open_chest()

func open_chest() -> void:
	if not sprite or not interaction_area:
		return
	is_opened = true
	interaction_area.set_deferred("monitoring", false)

	
	# Swap texture to open chest
	sprite.texture = preload("res://Art/v1.1 dungeon crawler 16x16 pixel pack/props_itens/chest_open.png")
	
	# Play juicy squash-and-stretch animation
	var tween: Tween = create_tween()
	sprite.scale = Vector2(1.2, 0.8)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	_spawn_loot()

func _spawn_loot() -> void:
	if not loot_table:
		return
		
	var item_scene: PackedScene = loot_table.get_random_item()
	if not item_scene:
		return
		
	var item_instance: Node2D = item_scene.instantiate()
	item_instance.global_position = global_position
	if "on_floor" in item_instance:
		item_instance.on_floor = true
		
	# Find and disable player detector/interaction area on the item initially so it can't be instantly collected
	var detector: Area2D = null
	if item_instance is Area2D:
		detector = item_instance
	elif item_instance.has_node("PlayerDetector"):
		detector = item_instance.get_node("PlayerDetector")
		
	if detector:
		detector.set_deferred("monitoring", false)
		
	get_parent().call_deferred("add_child", item_instance)
	
	# Wait for item_instance to enter the tree to animate it
	item_instance.ready.connect(func():
		var start_pos: Vector2 = item_instance.global_position
		
		# Parabolic trajectory variables
		var random_angle: float = randf_range(0, 2 * PI)
		var distance: float = randf_range(24, 36)
		var landing_pos: Vector2 = start_pos + Vector2.from_angle(random_angle) * distance
		var peak_y: float = min(start_pos.y, landing_pos.y) - randf_range(20, 32)
		
		# Scale up the item as it pops
		var pop_tween: Tween = item_instance.create_tween().set_parallel()
		item_instance.scale = Vector2.ZERO
		pop_tween.tween_property(item_instance, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
		# Horizontal slide
		pop_tween.tween_property(item_instance, "global_position:x", landing_pos.x, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
		# Vertical arc bounce
		var vert_tween: Tween = item_instance.create_tween()
		vert_tween.tween_property(item_instance, "global_position:y", peak_y, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		vert_tween.tween_property(item_instance, "global_position:y", landing_pos.y, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		
		# Re-enable collection when the landing is complete
		pop_tween.finished.connect(func():
			if is_instance_valid(detector):
				detector.set_deferred("monitoring", true)
		)
	)
