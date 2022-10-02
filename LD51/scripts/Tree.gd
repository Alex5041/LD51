class_name MyTree
extends KinematicBody2D

var hp = 2
var speed = 0
var repositions = 0
var end = false
var empty = false

func _ready():
	var x = Global.rnd.randi_range(0, 2)
	$Sprite.region_rect = Rect2(40*x,88,40,40)

func upgrade():
	hp += Global.upgrades["tree"]["hp"]
	speed = Global.upgrades["tree"]["speed"]
	set_scale(Global.upgrades["tree"]["scale"])
	
func _physics_process(delta: float) -> void:
	if speed == 0:
		return
	else:
		return

func hit():
	if !Global.muted_sounds:
		$Hit.play()
	$Tween.interpolate_property($Sprite, "modulate", Color(3,3,3),\
		Color(1,1,1), 0.2,\
		Tween.TRANS_BACK,Tween.EASE_IN)
	$Tween.interpolate_property($Sprite, "global_position",\
		global_position-Vector2(0,-5),\
		global_position, 0.2,\
		Tween.TRANS_BACK,Tween.EASE_IN)
	hp -= 1
	if hp <= 0 and !end:
		end = true
		get_parent().shootable.erase(self)
		if !empty:
			var word = Global.word.instance()
			get_tree().get_root().get_node("Map")\
				.call_deferred("add_child", word)
			word.call_deferred("create", "tree", global_position)
	$Tween.start()

func _on_Area2D_area_entered(area: Area2D) -> void:
	if self.get_index() > area.get_index() and repositions < 5:
		repositions += 1
		global_position = Global.random_pos()
		$Sprite.global_position = global_position


func _on_Hit_finished() -> void:
	if hp <= 0:
		queue_free()

func _on_Tween_tween_all_completed() -> void:
	$Sprite.global_position = global_position
