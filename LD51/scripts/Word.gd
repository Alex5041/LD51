class_name MyWord
extends Area2D

var rects = {
	"heart": Rect2(0, 40, 32, 24),
	"speed": Rect2(40, 48, 40, 40),
	"ruler": Rect2(120, 56, 40, 24),
	"plus": Rect2(80, 48, 40, 40),
	"minus": Rect2(0, 72, 40, 8),
	"bullet": Rect2(0, 0, 24, 16),
	"tree": Rect2(0, 128, 32, 32)}
var sig = false
var is_mod = false
var type = null
var blink = 10
var phase = 1

func upgrade():
	pass

func create(type, pos = global_position):
	if type == null:
		queue_free()
		return
	global_position = pos
	self.sig =  type == "minus" or type == "plus"
	is_mod = type == "heart" or type == "speed" or type == "ruler"
	self.type = type
	$Sprite.region_rect = rects[type]
	$Tween.interpolate_property(self, "scale", \
		Vector2(1.4,1.4), Vector2(1,1),\
		0.15, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func _on_Word_body_entered(body: Node) -> void:
	$Sprite.set_modulate(Color(2,2,2))
	if !body.picked.has(self):
		body.picked.append(self)

func _on_Word_body_exited(body: Node) -> void:
	$Sprite.set_modulate(Color.white)
	body.picked.erase(self)

func nullify():
	$Sprite.region_rect = Rect2(0,0,0,0)
	type = null

func blink():
	$Tween.interpolate_property(self, "modulate",\
	Color(1,1,1,1), Color(1,1,1,0), 0.1,\
	Tween.TRANS_BACK,Tween.EASE_IN_OUT)
	$Tween.start()


func _on_Tween_tween_completed(object: Object, key: NodePath) -> void:
	if str(key) == ":modulate":
		blink -= 1
		if blink >= 0:
			blink()
		else:
			queue_free()
