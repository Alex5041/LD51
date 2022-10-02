extends Node
const gun = preload ("res://scenes/Gun.tscn")
const bullet = preload ("res://scenes/Bullet.tscn")
const tree = preload ("res://scenes/Tree.tscn")
const word = preload ("res://scenes/Word.tscn")
const enemy = preload ("res://scenes/Enemy.tscn")
const cosmetic = preload ("res://scenes/Cosmetic.tscn")
const SIZE_INC = 0.3
const SPEED_INC = 2
const R_BOUND = 800
const D_BOUND = 600
var bullet_with_tree = false
var muted = false
var muted_sounds = false
var pre_upgrades = {
	"Enemy": {
		"scale": Vector2(1.0, 1.0),
		"speed":200,
		"hp": 0,
		"bullet": 1},
	"EnemyBullet": {
		"scale": Vector2(1.0, 1.0),
		"speed":160,
		"hp": 0},
	"PlayerBullet": {
		"scale": Vector2(1.0, 1.0),
		"speed":100,
		"hp": 0
	},
	"tree":{
		"scale": Vector2(2, 2),
		"speed":0,
		"hp": 0},
	"Player":{
		"scale": Vector2(1.0, 1.0),
		"speed":150,
		"hp": 0,
		"bullet":1}}
var saved_hp = 3
var upgrades = pre_upgrades.duplicate(true)

var rnd = RandomNumberGenerator.new()
var in_gui = false

var level = 1
var ideal = true

func restart():
	bullet_with_tree = false
	pre_upgrades = {
	"Enemy": {
		"scale": Vector2(1.0, 1.0),
		"speed":200,
		"hp": 0,
		"bullet": 1},
	"EnemyBullet": {
		"scale": Vector2(1.0, 1.0),
		"speed":160,
		"hp": 0},
	"PlayerBullet": {
		"scale": Vector2(1.0, 1.0),
		"speed":100,
		"hp": 0
	},
	"tree":{
		"scale": Vector2(2, 2),
		"speed":0,
		"hp": 0},
	"Player":{
		"scale": Vector2(1.0, 1.0),
		"speed":150,
		"hp": 0,
		"bullet":1}}
	saved_hp = 3
	upgrades = pre_upgrades.duplicate(true)
	in_gui = false
	level = 1
	ideal = true
	if !Audio.get_node("Start").playing:
		Audio.get_node("Finish").stop()
		Audio.get_node("Start").play()

func mute():
	muted = !muted
	if muted:
		Audio.get_node("Finish").stop()
		Audio.get_node("Start").stop()
	elif level < 4:
		Audio.get_node("Start").play()
	else:
		Audio.get_node("Finish").play()

func _ready() -> void:
	Audio.get_node("Start").play()

func set_new_size(val, node):
	pre_upgrades[node]["scale"] *= (1 + val * SIZE_INC)

func set_new_speed(val, node):
	if pre_upgrades[node]["speed"] == 0 and val == 1:
		pre_upgrades[node]["speed"] = 60
	else:
		pre_upgrades[node]["speed"] *= pow(Global.SPEED_INC, val)
		if pre_upgrades[node]["speed"] <= 60:
			pre_upgrades[node]["speed"] = 0

func set_new_hp(val, node):
	pre_upgrades[node]["hp"] += val

func random_pos():
	return Vector2(Global.rnd.randi_range(50, Global.R_BOUND - 50),\
			Global.rnd.randi_range(150, Global.D_BOUND - 150))

func get_random_drop(drop, max_chance = 100):
	var chance = rnd.randi_range(1, max_chance)
	for i in drop:
		if chance <= i[1]:
			return i[0]
		else:
			chance -= i[1]
	return drop.back()[0]
