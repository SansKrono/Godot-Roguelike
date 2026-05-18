extends StaticBody2D
class_name Chest

@export var loot_table: LootTable

var is_opened: bool = false
var spawned_upgrade: UpgradePickup = null
var upgrade_glow: Sprite2D = null
var interaction_delay_timer: Timer

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var interaction_area: Area2D = get_node_or_null("InteractionArea")

func _ready() -> void:
	if not sprite or not collision_shape or not interaction_area:
		push_warning("Chest node '%s' is missing required child nodes (Sprite2D, CollisionShape2D, or InteractionArea). If you added this node using the Add Node dialog, please use the 'Instantiate Child Scene' button (chain link icon) and select 'Chest.tscn' instead." % name)
		return
		
	if not interaction_area.body_entered.is_connected(_on_body_entered):
		interaction_area.body_entered.connect(_on_body_entered)
	
	interaction_delay_timer = Timer.new()
	interaction_delay_timer.one_shot = true
	add_child(interaction_delay_timer)

func _on_body_entered(body: Node2D) -> void:
	if is_opened and body is Player and spawned_upgrade and interaction_delay_timer.is_stopped():
		spawned_upgrade._on_collected(body)
		var ui_node = get_tree().current_scene.get_node_or_null("UI")
		if ui_node:
			ui_node.show_item_banner(spawned_upgrade.get_upgrade_name())
		spawned_upgrade.queue_free()
		upgrade_glow.queue_free()
		spawned_upgrade = null
		return

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
		
	if item_instance is UpgradePickup:
		spawned_upgrade = item_instance
		item_instance.position = Vector2.ZERO
		call_deferred("add_child", item_instance)
	else:
		get_parent().call_deferred("add_child", item_instance)
	
	if item_instance is UpgradePickup:
		upgrade_glow = Sprite2D.new()
		upgrade_glow.texture = preload("res://Art/19+ icons/white.png")
		upgrade_glow.modulate = Color(1, 0.84, 0) # Gold
		upgrade_glow.scale = Vector2(0.04, 0.04)
		upgrade_glow.position = Vector2.ZERO
		item_instance.add_child(upgrade_glow)
		item_instance.move_child(upgrade_glow, 0)
		
		interaction_delay_timer.start(1.0)
	
	# Wait for item_instance to enter the tree to animate it
	item_instance.ready.connect(func():
		var start_pos: Vector2 = item_instance.global_position
		
		# Parabolic trajectory variables
		var landing_pos: Vector2
		if item_instance is UpgradePickup:
			landing_pos = start_pos + Vector2(0, -16) # Land one tile above the chest center
		else:
			var space_state = get_world_2d().direct_space_state
			var valid_pos_found: bool = false
			
			for i in range(10):
				var random_angle: float = randf_range(0, 2 * PI)
				var distance: float = randf_range(24, 36)
				var candidate_pos: Vector2 = start_pos + Vector2.from_angle(random_angle) * distance
				
				var query = PhysicsPointQueryParameters2D.new()
				query.position = candidate_pos
				query.collision_mask = 1 # Check against World layer
				var result = space_state.intersect_point(query)
				
				if result.is_empty():
					landing_pos = candidate_pos
					valid_pos_found = true
					break
				
				if i == 9:
					landing_pos = candidate_pos

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
			if is_instance_valid(detector) and not item_instance is UpgradePickup:
				detector.set_deferred("monitoring", true)
			if is_instance_valid(spawned_upgrade):
				interaction_area.set_deferred("monitoring", true)
				var hover_tween = create_tween().set_loops()
				hover_tween.tween_property(item_instance, "position:y", -2, 1.0).as_relative().set_trans(Tween.TRANS_SINE)
				hover_tween.tween_property(item_instance, "position:y", 2, 1.0).as_relative().set_trans(Tween.TRANS_SINE)
		)
	)
