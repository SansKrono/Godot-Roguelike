extends Resource
class_name LootTable

@export var loot_items: Array[PackedScene] = []
@export var weights: Array[float] = []

func get_random_item() -> PackedScene:
	if loot_items.is_empty():
		return null
		
	var actual_weights: Array[float] = []
	var total_weight: float = 0.0
	for i in range(loot_items.size()):
		var w: float = weights[i] if i < weights.size() else 1.0
		actual_weights.append(w)
		total_weight += w
		
	if total_weight <= 0.0:
		return loot_items.pick_random()
		
	var roll: float = randf_range(0.0, total_weight)
	var current_sum: float = 0.0
	for i in range(loot_items.size()):
		current_sum += actual_weights[i]
		if roll <= current_sum:
			return loot_items[i]
			
	return loot_items.back()
