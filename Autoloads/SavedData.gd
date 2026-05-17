extends Node

var num_floor: int = 0

var hp: int = 4
var max_hp: int = 4
var max_speed: int = 100
var accerelation: int = 40
var coins: int = 0
var weapons: Array = []
var equipped_weapon_index: int = 0

func reset_data() -> void:
	num_floor = 0
	hp = 4
	max_hp = 4
	max_speed = 100
	accerelation = 40
	coins = 0
	weapons = []
	equipped_weapon_index = 0
