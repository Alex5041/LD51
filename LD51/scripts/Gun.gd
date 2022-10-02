extends Node2D
var gun_rotation = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func rotate_gun(origin, dir):
	rotation = dir - PI
	var offset = 40 * Vector2(1,0).rotated(dir)
	global_position = origin - offset + offset.tangent() / 2

func shoot():
	$Tween.interpolate_property(self, "global_position", \
		global_position - Vector2(1,0).rotated(rotation) * 10, global_position,\
		0.2, Tween.TRANS_BACK, Tween.EASE_IN)
	$Tween.start()
