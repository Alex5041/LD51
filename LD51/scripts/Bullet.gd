# layers:
# 1: player
# 2: enemy
# 3: tree
# 4: enemy bullet
# 5: portal
# 6: drop
# tree self detection
# 8 player bullet

# player bullet mask: 234
# enemy bullet mask: 1358
class_name Bullet
extends Area2D
var player = false
var dir = 0
var shot = false

var speed = 160
var hp = 1
var drop = ["bullet", null]

func _ready() -> void:
	pass # Replace with function body.

func shoot(shooter):
	dir = shooter.get_node("Gun").rotation + PI
	global_position = \
		shooter.get_node("Gun").global_position \
		- Vector2(1,0).rotated(dir).tangent() * 20
	rotation = dir + PI
	shot = true
	collision_layer = 0b00000000000010000000 if shooter is Player \
		else 0b00000000000000001000
	collision_mask = 0b00000000000000001110 if shooter is Player \
		else 0b00000000000010010101
 
func hit():
	hp -= 1
	if hp <= 0:
		queue_free()

func _physics_process(delta: float) -> void:
	if shot:
		global_position += Vector2.ONE.rotated(dir - PI*1.25) * delta * speed

func upgrade():
	var word = "PlayerBullet" if player else "EnemyBullet"
	set_scale(Global.upgrades[word].scale)
	hp += Global.upgrades[word]["hp"]
	speed = Global.upgrades[word]["speed"]

func _on_Bullet_area_shape_entered(area_id: int, area: Area2D, \
	area_shape: int, local_shape: int) -> void:
	if area.get_class() == self.get_class()\
		and self.get_index() > area.get_index():
		if area.get_child_count() == 3:
			get_tree().get_root().get_node("Map").call_deferred("portal_hit")
		else:
			area.hit()
		if Global.bullet_with_tree:
			var tree = Global.tree.instance()
			tree.empty = true
			get_tree().get_root().get_node("Map").call_deferred("add_tree",\
				tree, global_position)
		if !Global.muted_sounds:
			get_parent().get_node("Explosion").play()
		var word = Global.word.instance()
		hit()
		get_tree().get_root().get_node("Map").call_deferred("add_child", word)
		word.call_deferred("create",\
			drop[Global.rnd.randi_range(0, drop.size()-1)], global_position)

func _on_Bullet_body_entered(body: Node) -> void:
	body.hit()
	self.hit()
