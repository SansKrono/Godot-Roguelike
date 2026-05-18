extends Node

var num_floor: int = 0

var hp: int = 4
var max_hp: int = 4
var max_speed: int = 100
var accerelation: int = 40
var coins: int = 0
var weapons: Array = []
var equipped_weapon_index: int = 0

var num_projectiles: int = 1
var projectile_speed: int = 400
var projectile_damage: int = 1
var fire_rate: float = 0.6 # Default wait time for timer
var has_dot: bool = false
var dot_damage: int = 1
var dot_duration: float = 3.0

func reset_data() -> void:
	num_floor = 0
	hp = 4
	max_hp = 4
	max_speed = 100
	accerelation = 40
	coins = 0
	weapons = []
	equipped_weapon_index = 0
	num_projectiles = 1
	projectile_speed = 400
	projectile_damage = 1
	fire_rate = 0.6
	has_dot = false
	dot_damage = 1
	dot_duration = 3.0
