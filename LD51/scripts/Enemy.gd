class_name Enemy
extends KinematicBody2D

enum {
	IDLE,
	WANDER
}

var hp = 2
var picked = []
var drop = [["plus", 25], ["minus", 35], ["speed", 17],\
	["ruler", 17], ["heart", 6]]

var velocity = Vector2.ZERO
var state = WANDER
var player = false
var leg_rotation = 0
var shots = 0

var flip = 1
var waiting = false

var ACCELERATION = 200
const MAX_SPEED = 1000
const TOLERANCE = 4.0

onready var start_position = global_position
onready var target_position = global_position
onready var shoot_angle = 0
onready var shoot_target = self

func upgrade():
	hp += Global.upgrades["Enemy"]["hp"]
	set_scale(Global.upgrades['Enemy']['scale'])
	ACCELERATION = Global.upgrades["Enemy"]["speed"]

func _ready() -> void:
	add_child(Global.gun.instance())
	$Timer.start(Global.rnd.randf_range(1, 3))

func update_target_position(vec = null):
	var target_vector = vec if vec != null else \
		Vector2(rand_range(-32 * ACCELERATION/200, 32* ACCELERATION/200),\
		 rand_range(-32* ACCELERATION/200, 32* ACCELERATION/200))
	target_position = start_position + target_vector
	target_position = Vector2(min(max(target_position.x,0),Global.R_BOUND),\
		min(max(target_position.y,100),Global.D_BOUND-100))

func is_at_target_position(): 
	# Stop moving when at target +/- tolerance
	return (target_position - global_position).length() < TOLERANCE

func _physics_process(delta):
	if hp == 0:
		return
	match state:
		IDLE:
			if !waiting:
				velocity = Vector2.ZERO
				waiting = true
				$IdleTimer.start(Global.rnd.randf_range(1, 3))
		WANDER:
			accelerate_to_point(target_position, ACCELERATION * delta)
			if is_at_target_position():
				state = IDLE
				waiting = false
	velocity = move_and_slide(velocity)
	if velocity != Vector2.ZERO:
		leg_rotation = wrapf(leg_rotation + delta * 16, 0, 2 * PI)
		var origin = global_position + Vector2(-2 + (flip - 1) * 4, 18) * scale.x
		$Left.global_position = origin - 4 * Vector2(1,0).rotated(flip * leg_rotation) * scale.x
		$Right.global_position = origin + Vector2(16,0) * scale.x \
			- 3 * Vector2(1,0).rotated(flip * leg_rotation + PI) * scale.x

func accelerate_to_point(point, acceleration_scalar):
	var direction = (point - global_position).normalized()
	var acceleration_vector = direction * acceleration_scalar
	accelerate(acceleration_vector)

func accelerate(acceleration_vector):
	velocity += acceleration_vector
	velocity = velocity.clamped(MAX_SPEED)

func shoot():
	$ShootTimer.start(0.15)
	if !Global.muted_sounds:
		$Shoot.play()
	get_node("Gun").shoot()
	var shot_bullet = Global.bullet.instance()
	get_parent().add_child(shot_bullet)
	shot_bullet.upgrade()
	shot_bullet.shoot(self)

func hit():
	$Tween.interpolate_property($Sprite, "modulate", Color(3,3,3),\
		Color(1,1,1), 0.2,\
		Tween.TRANS_BACK,Tween.EASE_IN)
	$Tween.interpolate_property(self, "global_position",\
		global_position-Vector2(0,-5),\
		global_position, 0.2,\
		Tween.TRANS_BACK,Tween.EASE_IN)
	hp -= 1
	if hp == 0:
		$Tween.interpolate_property($Sprite, "rotation",0, -PI/2, 0.2,\
			Tween.TRANS_BACK,Tween.EASE_IN)
		if !Global.muted_sounds:
			$Chirp.play()
		if Global.level == 4:
			var label = get_parent().get_node(\
				"Down/Up/Panel/Levels/HBoxContainer5/Label")
			label.text = str(int(label.text) - 1)
	else:
		if !Global.muted_sounds:
			$SmallChirp.play()
	$Tween.start()

func _on_Timer_timeout() -> void:
	if is_instance_valid(self) and hp > 0:
		var shot = get_parent().get_random_for_shoot()
		if shot != null:
			get_node("Gun").rotate_gun(global_position, \
				global_position.angle_to_point(shot.global_position))
			shots += Global.upgrades["Enemy"]["bullet"]
			shoot()
		$Timer.start(Global.rnd.randf_range(1, 3))

func _on_IdleTimer_timeout() -> void:
	waiting = false
	update_target_position()
	state = WANDER

func _on_Chirp_finished() -> void:
	var word = Global.word.instance()

	get_tree().get_root().get_node("Map")\
		.call_deferred("add_child", word)
	word.call_deferred("create", Global.get_random_drop(drop), global_position)
	if Global.bullet_with_tree:
		var tree = Global.tree.instance()
		tree.empty = true
		get_tree().get_root().get_node("Map").call_deferred("add_tree",\
			tree, global_position)
	queue_free()


func _on_ShootTimer_timeout() -> void:
	shots -= 1
	if shots <= 0:
		shots = 0
		return
	else:
		shoot()
