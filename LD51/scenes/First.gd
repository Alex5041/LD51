extends Node2D

var lost = true
var notes = 0

func _ready():
	$Player.get_node("Gun").visible = false
	$NoteTimer.start(2)

func note(word):
	if word == "":
		return
	$Player/N/Panel/Label.rect_size = Vector2(0,0)
	$Player/N/Panel/Label.text = word
	$Player/N/Panel.rect_size = Vector2(\
		$Player/N/Panel/Label.text.length() * 10, 20)
	$Player/N/Panel.modulate = Color(1, 1, 1, 1)
	if word.find("\n") != -1:
		var l = word.substr(0,word.find("\n")).length()
		$Player/N/Panel.rect_size = Vector2(\
		max(l, word.length() - l) * 10, 45)
	$NoteTimer.start(2)
	print(word)

func _on_NoteTimer_timeout() -> void:
	if !Global.muted_sounds:
		$Peep.set_pitch_scale(randf() / 4 + 0.9)
		$Peep.play()
	if notes == 0:
		note("There is a legend\nabout a portal...")
	elif notes == 1:
		note("The One that\ngrants wishes")
	elif notes == 2:
		note("Being near will make\nyour words the truth")
	elif notes == 3:
		note("They want to destroy it")
	elif notes == 4:
		note("I won't let it happen!")
	else:
		get_tree().change_scene("res://scenes/Main.tscn")
	notes += 1
	$NoteTimer.start(3)
