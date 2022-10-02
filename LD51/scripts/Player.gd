class_name Player
extends KinematicBody2D
const DEFAULT_SPEED = 150

var hp = 3
var speed = DEFAULT_SPEED

var velocity = Vector2.ZERO
var direction = Vector2.ZERO
var leg_rotation = 0
var flip = 1
var is_right = 1
var can_shoot = true
var shots = 0

var bullets = []
var picked = []

func _ready() -> void:
	add_child(Global.gun.instance())
	get_node("Gun/Sprite").region_rect = Rect2(167, 88, 41, 32)

func upgrade():
	set_scale(Global.upgrades['Player']['scale'])
	speed = Global.upgrades['Player']['speed']
	hp += Global.upgrades['Player']['hp']
	set_hp()

func hit():
	if !Global.muted_sounds:
		$PlayerHit.play()
	Global.ideal = false
	$Tween.interpolate_property($Sprite, "modulate", Color(3,3,3),\
		Color(1,1,1), 0.2,\
		Tween.TRANS_BACK,Tween.EASE_IN)
	$Tween.interpolate_property(self, "global_position",\
		global_position-Vector2(0,-5),\
		global_position, 0.2,\
		Tween.TRANS_BACK,Tween.EASE_IN)
	hp -= 1
	set_hp()
	if hp <= 0:
		$Tween.interpolate_property($Sprite, "rotation",0, -PI/2, 0.2,\
			Tween.TRANS_BACK,Tween.EASE_IN)
		get_parent().shootable.erase(self)
	$Tween.start()

func set_hp():
	if get_parent().get_node("Down/Panel/HP").get_child_count() < hp:
		var node = get_parent().get_node("Down/Panel/HP").get_child(0)
		for i in hp - get_parent().get_node("Down/Panel/HP").get_child_count():
			get_parent().get_node("Down/Panel/HP").add_child(node.duplicate())
	else:
		if hp >= 0:
			for i in get_parent().get_node("Down/Panel/HP").get_child_count() - hp:
				var last = get_parent().get_node("Down/Panel/HP").get_children().back()
				get_parent().get_node("Down/Panel/HP").remove_child(last)
				last.queue_free()
		if hp <= 0:
			get_parent().note("Dead.")
			get_parent().gameover(false, "all hp lost")
			

func get_input(delta):
	velocity = Vector2.ZERO
	if Input.is_action_just_pressed("mute"):
		Global.mute()
	if Input.is_action_just_pressed("mute_sounds"):
		Global.muted_sounds = !Global.muted_sounds
	if Input.is_action_just_pressed("restart"):
		Global.restart()
		get_tree().reload_current_scene()
		#get_tree().change_scene_to(load("res://scenes/Main.tscn"))
		print(get_tree().get_root().get_child_count())
	if get_parent().lost:
		return
	if Input.is_action_pressed('right'):
		is_right = 1
		velocity.x += 1
		#$Apple.play("move")
	if Input.is_action_pressed('left'):
		is_right = -1
		velocity.x -= 1
		#$Apple.play("move")
	if Input.is_action_pressed('down'):
		velocity.y += 1
		#$Apple.play("move")
	if Input.is_action_pressed('up'):
		velocity.y -= 1
		#$Apple.play("move")
	if Input.is_action_just_pressed("swap"):
		get_parent().swap_words()
	if Input.is_action_pressed('shoot') and can_shoot and !Global.in_gui:
		$Timer.start(0.5)
		can_shoot = false
		shots += Global.upgrades["Player"]["bullet"]
		if shots <= 0:
			get_parent().note(" I can't shoot!")
		else:
			shoot()
	if Input.is_action_just_pressed("pick") \
		and picked.size() > 0 and !Global.in_gui:
		if !Global.muted_sounds:
			get_parent().get_node("Swap").play()
		var first = picked.front()
		picked.erase(first)

		first.get_parent().remove_child(first)
		var added_to = get_parent().get_node("Down/Panel/Words/Item1/")
		var new_pos = get_parent().get_node("Down/Panel/Words/Item1").get_child(1).global_position
		if first.sig:
			added_to = get_parent().get_node("Down/Panel/Words/Item0/")
			new_pos = get_parent().get_node("Down/Panel/Words/Item0/").get_child(1).global_position
			get_parent().get_node("Down/Panel/Words/Item0/").get_child(1).queue_free()
#		elif first.is_mod:
#			added_to = get_parent().get_node("Down/Panel/Words/Item2/")
#			new_pos = get_parent().get_node("Down/Panel/Words/Item2/").get_child(1).global_position
#			get_parent().get_node("Down/Panel/Words/Item2/").get_child(1).queue_free()
#		elif get_parent().get_node("Down/Panel/Words/Item2").get_child(1).type != null:
#			added_to = get_parent().get_node("Down/Panel/Words/Item1/")
#			new_pos = get_parent().get_node("Down/Panel/Words/Item1/").get_child(1).global_position
#			get_parent().get_node("Down/Panel/Words/Item1/").get_child(1).queue_free()
		else:
			var moved = added_to.get_child(1)
			moved.get_parent().remove_child(moved)
			get_parent().get_node("Down/Panel/Words/Item2").get_child(1).queue_free()
			get_parent().get_node("Down/Panel/Words/Item2/").add_child(moved)
			#moved.global_position += Vector2(60, 0)
		added_to.add_child(first)
		first.global_position = new_pos

func _physics_process(delta):
	get_input(delta)
	# Make sure diagonal movement isn't faster
	velocity = velocity.normalized() * speed
	if velocity != Vector2.ZERO:
		leg_rotation = wrapf(leg_rotation + delta * 16, 0, 2 * PI)
		var origin = global_position + Vector2((-2 + (flip - 1) * 4) * scale.x, 18 * scale.x)
		$Left.global_position = origin - 4 * scale.x * Vector2(1,0)\
			.rotated(is_right * leg_rotation)
		$Right.global_position = origin + Vector2(16,0) * scale.x \
			- 3 * scale.x * Vector2(1,0).rotated(is_right * leg_rotation + PI)
	velocity = move_and_slide(velocity)
	var mouse_pos = get_global_mouse_position()
	get_node("Gun").rotate_gun(global_position, \
		global_position.angle_to_point(mouse_pos))
	if mouse_pos.x < global_position.x and flip == 1:
		flip = -1
		_flip_sprites(true)
	elif mouse_pos.x > global_position.x and flip != 1:
		flip = 1
		_flip_sprites(false)

func _flip_sprites(flipping):
	$Sprite.flip_h = flipping
	$Left.flip_h = flipping
	$Right.flip_h = flipping
	get_node("Gun/Sprite").flip_v = flipping

func shoot():
	$ShootTimer.start(0.15)
	if !Global.muted_sounds:
		get_parent().get_node("Shot").play()
	get_node("Gun").shoot()
	var shot_bullet = Global.bullet.instance()
	get_parent().add_child(shot_bullet)
	shot_bullet.player = true
	shot_bullet.upgrade()
	shot_bullet.shoot(self)

func _on_Timer_timeout() -> void:
	can_shoot = true

func _on_ShootTimer_timeout() -> void:
	shots -= 1
	if shots <= 0:
		shots = 0
		return
	else:
		shoot()
