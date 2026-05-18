extends DungeonRoom

const CHEST_SCENE: PackedScene = preload("res://Rooms/Chest.tscn")
const DOOR_SCENE: PackedScene = preload("res://Rooms/Furniture and Traps/Door.tscn")
const COMMON_LOOT_TABLE: Resource = preload("res://Rooms/CommonLootTable.tres")

func generate() -> void:
	var width = randi_range(9, 15)
	var height = randi_range(9, 15)
	
	var main_tilemap: TileMap = get_node("TileMap")
	var tilemap2: TileMap = get_node("TileMap2") # DungeonRoom's tilemap variable is also this
	var furniture_tilemap: TileMap = get_node("FurnitureTileMap")
	var entrance_node: Node2D = get_node("Entrance")
	var door_container_node: Node2D = get_node("Doors")
	var enemy_positions_node: Node2D = get_node("EnemyPositions")
	var player_detector_node: Area2D = get_node("PlayerDetector")
	
	# Clear existing data
	main_tilemap.clear()
	tilemap2.clear()
	furniture_tilemap.clear()
	
	# Fill floor and walls in main_tilemap
	# Indices: Floor: 14, Top: 1, Left: 6, Right: 5, TL: 7, TR: 13, BL: 4, BR: 3
	for x in range(width):
		for y in range(height):
			var tile = 14 # Floor
			if x == 0:
				if y == 0: tile = 7 # TL
				elif y == height - 1: tile = 4 # BL
				else: tile = 6 # L Wall
			elif x == width - 1:
				if y == 0: tile = 13 # TR
				elif y == height - 1: tile = 3 # BR
				else: tile = 5 # R Wall
			elif y == 0:
				tile = 1 # Top Wall
			# Bottom wall is handled differently or left as floor for now in main_tilemap
			
			main_tilemap.set_cell(0, Vector2i(x, y), tile, Vector2i.ZERO)

	# Bottom wall in TileMap2
	# Indices: Straight: 10, Left of gap: 9, Right of gap: 11
	for x in range(1, width - 1):
		tilemap2.set_cell(0, Vector2i(x, height - 1), 10, Vector2i.ZERO)

	var door_x = width / 2
	var entrance_x = width / 2

	# Door at the top
	main_tilemap.set_cell(0, Vector2i(door_x - 1, 0), 14, Vector2i.ZERO)
	main_tilemap.set_cell(0, Vector2i(door_x, 0), 14, Vector2i.ZERO)
	
	# Top archways in TileMap2 (aesthetic matching Room0.tscn)
	tilemap2.set_cell(0, Vector2i(door_x - 1, 0), 37, Vector2i.ZERO)
	tilemap2.set_cell(0, Vector2i(door_x, 0), 38, Vector2i.ZERO)
	
	var door = DOOR_SCENE.instantiate()
	door.name = "Door" # Critical for Rooms.gd to find it
	door.position = Vector2(door_x * 16, 16)
	door_container_node.add_child(door)

	# Entrance at the bottom
	main_tilemap.set_cell(0, Vector2i(entrance_x - 1, height - 1), 14, Vector2i.ZERO)
	main_tilemap.set_cell(0, Vector2i(entrance_x, height - 1), 14, Vector2i.ZERO)
	
	# Fix bottom wall in TileMap2 around entrance
	tilemap2.erase_cell(0, Vector2i(entrance_x - 1, height - 1))
	tilemap2.erase_cell(0, Vector2i(entrance_x, height - 1))
	tilemap2.set_cell(0, Vector2i(entrance_x - 2, height - 1), 9, Vector2i.ZERO)
	tilemap2.set_cell(0, Vector2i(entrance_x + 1, height - 1), 11, Vector2i.ZERO)
	
	# Entrance markers
	var m1 = Marker2D.new()
	m1.position = Vector2((entrance_x - 1) * 16 + 8, (height - 1) * 16 + 8)
	entrance_node.add_child(m1)
	
	var m2 = Marker2D.new()
	m2.name = "Position2D2" # Critical for Rooms.gd to align rooms
	m2.position = Vector2(entrance_x * 16 + 8, (height - 1) * 16 + 8)
	entrance_node.add_child(m2)
	
	# Player Detector
	var collision_shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(32, 16)
	collision_shape.shape = rect
	collision_shape.position = Vector2(entrance_x * 16, (height - 1) * 16)
	player_detector_node.add_child(collision_shape)
	
	# --- Procedural Variety (Interior structures) ---
	var variety_type = randi() % 3
	if variety_type == 1:
		# Poured-in pillars
		var px1 = 2
		var px2 = width - 3
		var py1 = 2
		var py2 = height - 3
		var pillars = [Vector2i(px1, py1), Vector2i(px2, py1), Vector2i(px1, py2), Vector2i(px2, py2)]
		for p in pillars:
			if p.x > 0 and p.x < width - 1 and p.y > 0 and p.y < height - 1:
				furniture_tilemap.set_cell(0, p, 24, Vector2i.ZERO)
				
	elif variety_type == 2:
		# Scattered obstacles
		for x in range(2, width - 2):
			for y in range(2, height - 3):
				if randf() < 0.05:
					# Maintain a clear path in the center columns
					if x == door_x or x == door_x - 1:
						continue
					var tile_id = [24, 25, 26].pick_random()
					furniture_tilemap.set_cell(0, Vector2i(x, y), tile_id, Vector2i.ZERO)

	# Enemy positions
	var num_enemy_pos = randi_range(2, 5)
	for i in range(num_enemy_pos):
		var pos = Marker2D.new()
		# Pick random position that isn't inside a furniture tile if possible
		var rx = randi_range(2, width - 3)
		var ry = randi_range(2, height - 3)
		pos.position = Vector2(rx * 16 + 8, ry * 16 + 8)
		enemy_positions_node.add_child(pos)
		
	# Chests
	if randf() < 0.3:
		var chest = CHEST_SCENE.instantiate()
		var cx = randi_range(2, width - 3)
		var cy = randi_range(2, height - 3)
		chest.position = Vector2(cx * 16 + 8, cy * 16 + 8)
		chest.loot_table = COMMON_LOOT_TABLE
		add_child(chest)
	
	# Player Spawn Pos (for if it's used as a spawn room)
	var spawn_pos = Marker2D.new()
	spawn_pos.name = "PlayerSpawnPos"
	spawn_pos.position = Vector2(entrance_x * 16 + 8, (height - 2) * 16 + 8)
	add_child(spawn_pos)
	
	# Update num_enemies for DungeonRoom._ready
	num_enemies = enemy_positions_node.get_child_count()
