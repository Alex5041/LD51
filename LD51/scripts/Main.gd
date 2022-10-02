extends Node2D

var shootable: Dictionary
var phase = true
var killed = 0
var end = false
var lost = false
var time = 120

func _ready():
	randomize()
	shootable = {$Player: true}
	$Player.upgrade()
	reset_statement()
	if Global.level == 1:
		level1()
	elif Global.level == 2:
		level2()
	elif Global.level == 3:
		level3()
	elif Global.level == 4:
		level4()
	elif Global.level == 5:
		level5()
	$CameraTween.interpolate_property($Camera2D, "zoom", Vector2(0.4, 0.4),\
		Vector2(1, 1), 1, Tween.TRANS_CUBIC,Tween.EASE_IN)
	$CameraTween.start()
#	var word = Global.word.instance()
#	word.create("plus", Vector2(200, 200))
#	add_child(word)
#	var word2 = Global.word.instance()
#	word2.create("bullet", Vector2(200, 200))
#	add_child(word2)
#	word = Global.word.instance()
#	word.create("heart", Vector2(200, 200))
#	add_child(word)

func level1():
	$Down/Panel/Label.visible = false
	note("need to grow a forest")
	set_level1();
	create_scattered_trees(4)
	set_hide($Down/Up/Panel/Levels/HBoxContainer3/Item0)
	set_hide($Down/Up/Panel/Levels/HBoxContainer3/Item1)
	set_hide($Down/Up/Panel/Levels/HBoxContainer2/Item0)
	set_hide($Down/Up/Panel/Levels/HBoxContainer2/Item1)
	set_hide($Down/Up/Panel/Levels/HBoxContainer2/Item2)
	set_hide($Down/Up/Panel/Levels/HBoxContainer5/Item0)
	set_hide($Down/Up/Panel/Levels/HBoxContainer6/Item0/)
	set_opened($Down/Up/Panel/Levels/HBoxContainer/Item0)

func level3():
	note("Wanna shoot faster")
	set_level1(); set_level2(); set_level3()
	create_scattered_trees(2)

func level2():
	$Down/Panel/Label.text = "can use 2 boots too"
	note("Need to be faster")
	set_level1()
	set_level2()
	create_scattered_trees(1)

func level4():
	note("Birds are annoying")
	set_level1(); set_level2(); set_level3(); set_level4()
	$Down/Up/Panel/Levels/HBoxContainer5/Label.visible = true
	$Down/Up/Panel/Levels/HBoxContainer5/Item0\
		.get("custom_styles/panel").bg_color = Color(1,1,1,0)
	create_scattered_trees(5)

func level5():
	note("Have to protect the portal.")
	set_level1(); set_level2(); set_level3(); set_level4()
	$Level5Timer.start(1)
	$Down/Up/Panel/Levels/HBoxContainer6/Label.visible = true
	set_done($Down/Up/Panel/Levels/HBoxContainer5/Item0)
	set_opened($Down/Up/Panel/Levels/HBoxContainer6/Item0/)
	$Down/Up/Panel/Levels/HBoxContainer5/Item0\
		.get("custom_styles/panel").bg_color = Color(1,1,1,0)
	create_scattered_trees(5)
	$Down/Panel/HP2.visible = true

func set_level1():
	if Global.level != 5:
		$Portal.queue_free()
	$Player.hp = Global.saved_hp
	$Player.set_hp()
	$Down/Up/Panel/Levels/HBoxContainer/Item0/Word.create("tree")
	$Down/Up/Panel/Levels/HBoxContainer/Item1/Word.create("tree")

func set_level3():
	$Down/Up/Panel/Levels/HBoxContainer2/Item0/Word.create("plus")
	$Down/Up/Panel/Levels/HBoxContainer2/Item1/Word.create("bullet")
	$Down/Up/Panel/Levels/HBoxContainer2/Item2/Word.create("speed")
	set_opened($Down/Up/Panel/Levels/HBoxContainer2/Item0)
	set_opened($Down/Up/Panel/Levels/HBoxContainer2/Item1)
	set_opened($Down/Up/Panel/Levels/HBoxContainer2/Item2)
	set_done($Down/Up/Panel/Levels/HBoxContainer3/Item0)

func set_level2():
	$Down/Up/Panel/Levels/HBoxContainer3/Item0/Word.create("plus")
	$Down/Up/Panel/Levels/HBoxContainer3/Item1/Word.create("speed")
	set_opened($Down/Up/Panel/Levels/HBoxContainer3/Item0)
	set_opened($Down/Up/Panel/Levels/HBoxContainer3/Item1)
	set_done($Down/Up/Panel/Levels/HBoxContainer/Item0)

func set_level4():
	if !Global.muted:
		Audio.get_node("Start").stop()
		Audio.get_node("Finish").play()
	set_opened($Down/Up/Panel/Levels/HBoxContainer5/Item0)
	set_done($Down/Up/Panel/Levels/HBoxContainer2/Item0)
	$Down/Panel/Label.visible = false

func set_hide(panel:Panel):
	panel.get("custom_styles/panel").bg_color = Color(1, 1, 1, 0)
	panel.get_child(0).visible = false

func set_opened(panel:Panel):
	panel.get("custom_styles/panel").bg_color = Color("#b1a58d")
	panel.get_child(0).visible = true

func set_done(panel:Panel):
	panel.get("custom_styles/panel").bg_color = Color("#5d7275")

func reset_statement():
	$Down/Panel/Words/Item0.get_child(1).nullify()
	$Down/Panel/Words/Item1.get_child(1).nullify()
	$Down/Panel/Words/Item2.get_child(1).nullify()

func spawn_enemy():
	var arr = [[Vector2(100, 0), \
		Vector2(-50,Global.rnd.randi_range(120, 470))],\
		 [Vector2(-100, 0), \
		Vector2(850,Global.rnd.randi_range(120, 470))],\
		[Vector2(0, 100), 
		Vector2(Global.rnd.randi_range(20, 680),120)],\
		[Vector2(0, -100),
		Vector2(Global.rnd.randi_range(20, 680), 470)]]
	arr.shuffle()
	var dir = arr.front()
	var enemy = Global.enemy.instance()
	add_child(enemy)
	enemy.global_position = dir[1]
	enemy.start_position = enemy.global_position
	enemy.update_target_position(dir[0])
	enemy.upgrade()

func get_random():
	return get_children()[Global.rnd.randi() % get_children().size()]

func get_random_for_shoot():
	if shootable.size() == 0: 
		return null
	return shootable.keys()[Global.rnd.randi() % shootable.size()]

func create_scattered_trees(quantity):
	for i in quantity:
		var tree = Global.tree.instance()
		add_tree(tree, Global.random_pos())

func add_tree(tree, pos):
	shootable[tree] = true
	tree.global_position = pos
	add_child(tree)
	tree.hp += 1
	tree.hit()

func get_statement():
	return {"sign":$Down/Panel/Words/Item0.get_child(1).type,
		"target": $Down/Panel/Words/Item1.get_child(1).type,
		"mod":$Down/Panel/Words/Item2.get_child(1).type}

func interpret(player = true):
	var statement = get_statement()
	print(statement)
	var count_nulls = 0
	for i in statement.values():
		if i == null:
			count_nulls += 1
	if count_nulls > 1:
		return "Need 2 or more tokens"
	if statement["sign"] == null:
		if statement["target"] != statement["mod"]:
			return "No sign => words are same"
		# two same words
		elif statement["target"] == "tree":
			create_scattered_trees(Global.rnd.randi_range(3, 5))
		elif statement["target"] == "bullet":
			Global.pre_upgrades["Player" if phase else "Enemy"]["bullet"] += 1
			print(Global.pre_upgrades["Player" if phase else "Enemy"]["bullet"])
		elif statement["target"] == "heart":
			Global.set_new_hp(1, "Player" if phase else "Enemy")
		elif statement["target"] == "speed":
			Global.set_new_speed(1, "Player" if phase else "Enemy")
		elif statement["target"] == "ruler":
			Global.set_new_size(1, "Player" if phase else "Enemy")
	else:
		# sign & one word
		if statement["mod"] == null or statement["target"] == null \
			or (statement["mod"] == statement["target"]):
				statement["changed"] = statement["target"] \
					if statement["mod"] == null else statement["mod"]
				if statement["changed"] == "tree":
					mod_trees(statement["sign"])
				elif statement["changed"] == "speed":
					Global.set_new_speed(1 if statement["sign"] == "plus" else -1,\
						"Player" if phase else "Enemy")
				elif statement["changed"] == "ruler":
					Global.set_new_size(1 if statement["sign"] == "plus" else -1,\
						"Player" if phase else "Enemy")
				# heart, bullet
				else:
					mod_number(statement["sign"], statement["changed"])
		else:
			var targ = statement["target"]
			var mod = statement["mod"]
			if targ == "ruler" or targ == "heart" or targ == "speed":
				statement["mod"] = targ
				statement["target"] = mod
			if statement["target"] == "tree" \
				and statement["mod"] == "bullet":
				note("bullet with tree")
				Global.bullet_with_tree = true if statement["sign"] == "plus"\
					else false
			elif statement["target"] == "bullet" \
				and statement["mod"] == "tree":
				note("bullet with tree")
				Global.bullet_with_tree = true if statement["sign"] == "plus"\
					else false
			if statement["target"] == "bullet":
				statement["target"] = "PlayerBullet" if phase else "EnemyBullet"
			if statement["mod"] == "ruler":
				Global.set_new_size(1 if statement["sign"] == "plus" else -1,\
					statement["target"])
			elif statement["mod"] == "speed":
				Global.set_new_speed(1 if statement["sign"] == "plus" else -1,\
					statement["target"])
			elif statement["mod"] == "heart":
				Global.set_new_hp(1 if statement["sign"] == "plus" else -1,\
					statement["target"])
			else:
				print("Error")
				print(statement)
	return ""

func mod_trees(sig):
	if sig == "plus":
		create_scattered_trees(Global.rnd.randi_range(3, 5))
	else:
		var removed = Global.rnd.randi_range(3, 5)
		var trees = []
		for i in shootable:
			if is_instance_valid(i) and i is MyTree and i.hp > 0:
				trees.append(i)
		trees.shuffle()
		for i in removed:
			if trees.size() > 0 and is_instance_valid(trees.back()) and trees.back().hp > 0:
				trees.back().hp = 0
				trees.back().hit()
				trees.remove(trees.size() - 1)

func mod_number(sig, word):
	var target_here = "Player" if phase else "Enemy"
	var changed_word = "hp" if word == "heart" else word
	Global.pre_upgrades[target_here][changed_word] += \
		1 if sig == "plus" else -1
	var val = Global.pre_upgrades[target_here][changed_word]
	if val > 3 and changed_word == "bullet":
		Global.pre_upgrades[target_here][changed_word] = 3
	elif val < 1 and changed_word == "bullet":
		Global.pre_upgrades[target_here][changed_word] = 1

func swap_words():
	if !Global.muted_sounds:
		$Swap.play()
	var first = $Down/Panel/Words/Item1.get_child(1)
	var second = $Down/Panel/Words/Item2.get_child(1)
	$Down/Panel/Words/Item1.remove_child(first)
	$Down/Panel/Words/Item2.remove_child(second)
	$Down/Panel/Words/Item1.add_child(second)
	$Down/Panel/Words/Item2.add_child(first)

func change_target():
	$Down/Panel/Target.region_rect = Rect2(96, 0, 48, 40)\
		 if phase else Rect2(56, 0, 40, 40)

func next_phase():
	var res = interpret()
	note(res)
	if res == "":
		reset_statement()
	if !Global.muted_sounds:
		$Phase.play()
	var trees = 0
	Global.upgrades = Global.pre_upgrades.duplicate(true)
	for i in get_children():
		if i is Player or i is Enemy or i is Bullet or i is MyTree:
			if i is MyTree:
				trees += 1
			i.upgrade()
		elif i is MyWord:
			if i.phase >= 3:
				i.blink()
			i.phase += 1
	if trees >= 7 and Global.level == 1:
		next_level()
	elif Global.upgrades["Player"]["speed"] > 150 and Global.level == 2:
		next_level()
	elif Global.upgrades["PlayerBullet"]["speed"] > 100\
		 and Global.level == 3:
		next_level()
	elif int($Down/Up/Panel/Levels/HBoxContainer5/Label.text) <= 0 \
		and Global.level == 4:
			if Global.ideal:
				next_level()
			else:
				gameover(true, "Maybe that's enough")
	if Global.level > 1 and Global.level < 4:
		var q = Global.level
		for i in q:
			spawn_enemy()
	elif Global.level > 1:
		for i in 3:
			spawn_enemy()
	if Global.level > 2:
		phase = !phase
		change_target()
	Global.pre_upgrades["Enemy"]["hp"] = 0
	Global.pre_upgrades["EnemyBullet"]["hp"] = 0
	Global.pre_upgrades["PlayerBullet"]["hp"] = 0
	Global.pre_upgrades["tree"]["hp"] = 0
	Global.pre_upgrades["Player"]["hp"] = 0

func next_level():
	note("I did it!")
	end = true

func portal_hit():
	var removed = $Down/Panel/HP2.get_children().back()
	$Down/Panel/HP2.remove_child(removed)
	if $Down/Panel/HP2.get_child_count() == 0:
		gameover(false, "portal destroyed")
		$Portal.queue_free()

func _on_PhaseTimer_timeout() -> void:
	pass # Replace with function body.

func _on_Item0_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("pick"):
		if !Global.muted_sounds:
			$Swap.play()
		$Down/Panel/Words/Item0.get_child(1).nullify()

func _on_Item1_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("pick"):
		if !Global.muted_sounds:
			$Swap.play()
		$Down/Panel/Words/Item1.get_child(1).nullify()

func _on_Item2_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("pick"):
		if !Global.muted_sounds:
			$Swap.play()
		$Down/Panel/Words/Item2.get_child(1).nullify()

func gameover(cond, reason):
	if !cond:
		lost = true
		$Down/Panel/Label.text = "R to restart"
		$Down/Panel/Label.visible = true
	else:
		$Rect.visible = true
		$Rect/Tween.interpolate_property(\
			$Rect/ColorRect, "modulate",
			Color(1,1,1, 0),Color(1,1,1,1), 5,Tween.TRANS_CUBIC,Tween.EASE_IN)
		$Rect/Tween.start()
	note(reason)
	shootable.clear()
	

func note(word):
	if word == "":
		return
	$Player/N/Panel/Label.rect_size = Vector2(0,0)
	$Player/N/Panel/Label.text = word
	$Player/N/Panel.rect_size = Vector2(\
		$Player/N/Panel/Label.text.length() * 10, 20)
	$Player/N/Panel.modulate = Color(1, 1, 1, 1)
	$NoteTimer.start(2)
	print(word)

func _on_Words_mouse_entered() -> void:
	Global.in_gui = true

func _on_Words_mouse_exited() -> void:
	Global.in_gui = false

func _on_NoteTimer_timeout() -> void:
	$NoteTween.interpolate_property($Player/N/Panel, "modulate", 
	  Color(1, 1, 1, 1), Color(1, 1, 1, 0), 2.0, 
	  Tween.TRANS_LINEAR, Tween.EASE_IN)
	$NoteTween.start()
	if end:
		Global.level += 1
		Global.saved_hp = $Player.hp
		get_tree().change_scene("res://scenes/Main.tscn")

func _on_Countdown_timeout() -> void:
	if $Down/Up/Panel/Label.text == "0":
		$Down/Up/Panel/Label.text = "10"
		next_phase()
	else:
		$Down/Up/Panel/Label.text = str(int($Down/Up/Panel/Label.text) - 1)
	$Countdown.start(0.7)


func _on_CameraTween_tween_all_completed() -> void:
	$Countdown.start()
	if Global.level > 1 and Global.level < 4:
		for i in 2:
			spawn_enemy()
	elif Global.level > 1:
		for i in 3:
			spawn_enemy()

func _on_Level5Timer_timeout() -> void:
	time -= 1
	var time_text = $Down/Up/Panel/Levels/HBoxContainer6/Label
	time_text.text = str(time / 60) + ":" + str(time % 60)
	if time > 0:
		$Level5Timer.start(1)
	else:
		gameover(true, "Thank you for playing")


func _on_Tween_tween_all_completed() -> void:
	get_tree().change_scene("res://scenes/Credits.tscn")
	pass # Replace with function body.
