extends Node

var ot_is_get_reward = true

func _ready():
	Main.reward_amount = 1
	
	MusicManager.select_music(MusicManager.WIN)
	MusicManager.play_music()
	
	updated_x2()
	update_text()
	
	if Main.debug and Main.current_chapter == null:
		Main.current_chapter = 1
		Main.current_stage = Main.THEORY
	
	if not (Main.data["GoogleGames"] and Main.google_games != null):
		 $Leaderboard.hide()
		
	# Guarda en google games
	if Main.data["GoogleGames"] and Main.google_games != null:
		Main.google_games.submit_leaderboard(Main.data["Score"], "CgkI1raHjpUfEAIQBA")

func _on_X2_pressed():
	SoundManager.select_sound(SoundManager.BUTTON)
	SoundManager.play_sound()
	
	if Main.firebase != null:
		Main.firebase.show_rewarded_video()
		
	$X2.hide()

func _on_Timer_timeout():
	updated_x2()
	
	if ot_is_get_reward and is_get_reward():
		ot_is_get_reward = false
		
		Main.win_money *= Main.reward_amount
		Main.win_score *= Main.reward_amount
		
		update_text()
	
func updated_x2():
	if Main.firebase != null and Main.admob_video_is_loaded and Main.reward_amount == 1:
		$X2.show()
	else:
		$X2.hide()
	
	update_text()
	
func is_get_reward():
	if Main.reward_amount > 1:
		return true
	return false
	
func update_text():
	$WinScore.text = str("Puntaje Ganado: ", Main.win_score)
	$WinMoney.text = str("Dinero Ganado: ", Main.win_money)
	
	if not Main.data.empty():
		# NOTE: El score no se añade en este momento, primero hay que saber
		# si el player le da al botón X2
		$TotalScore.text = str("Puntaje Total: ", Main.data["Score"] + Main.win_score)
		$TotalMoney.text = str("Dinero Total: ", Main.data["Money"] + Main.win_money)

func save_all(is_continue = false):
	Main.data["Score"] += Main.win_score
	Main.data["Money"] += Main.win_money

	var cap = str("Cap", Main.current_chapter)
	
	if Main.current_stage == Main.THEORY:
		if Main.data["Chapters"][cap]["ScoreValueForDialogue"] > 1:
			Main.data["Chapters"][cap]["ScoreValueForDialogue"] -= 1
		if Main.data["Chapters"][cap]["MoneyValueForDialogue"] > 1:
			Main.data["Chapters"][cap]["MoneyValueForDialogue"] -= 1
	elif Main.current_stage == Main.PRACTICE:
		if Main.data["Chapters"][cap]["ScoreValueForAnswer"] > 1:
			Main.data["Chapters"][cap]["ScoreValueForAnswer"] -= 1
		if Main.data["Chapters"][cap]["MoneyValueForAnswer"] > 1:
			Main.data["Chapters"][cap]["MoneyValueForAnswer"] -= 1

	if Main.firebase != null:
		Main.firebase.earn_currency("Money", Main.win_money)
	
	if is_continue == true:
		MusicManager.select_music(MusicManager.THEORY)
		MusicManager.play_music()
	else:
		MusicManager.select_music(MusicManager.MENU)
		MusicManager.play_music()
	
	$Timer.stop() # Para el tiempo para que no se actualice el texto
	
	if Main.current_stage == Main.THEORY and Main.current_chapter != 1:
		Main.data["Chapters"][cap]["TheoryCompleted"] = true
		Main.current_stage = Main.PRACTICE
		Persistence.save_data(Main.current_user)
		
		if is_continue:
			var scene_path = str("res://Game/Levels/Pseudocode/Cap", Main.current_chapter, "Practice.tscn")
			get_tree().change_scene(scene_path)
		
	elif Main.current_chapter == 1:
		Main.data["Chapters"][cap]["TheoryCompleted"] = true
		Main.current_chapter = 2
		Main.current_stage = Main.THEORY
		
		if Main.data["PseudocodePastsLevels"] == 1:
			Main.data["PseudocodePastsLevels"] += 1
		
		Persistence.save_data(Main.current_user)
		
		ChaptersData.create_data(Main.current_chapter)
		
		if is_continue:
			var scene_path = str("res://Game/Levels/Pseudocode/Cap", Main.current_chapter, "Theory.tscn")
			get_tree().change_scene(scene_path)
	else: # Si es practica?
		Main.data["Chapters"][cap]["PracticeCompleted"] = true
		Main.current_chapter += 1
		Main.current_stage = Main.THEORY
		
		if Main.current_chapter > Main.data["PseudocodePastsLevels"]:
			Main.data["PseudocodePastsLevels"] += 1
		
		Persistence.save_data(Main.current_user)
		
		ChaptersData.create_data(Main.current_chapter)
		
		if is_continue:
			var scene_path = str("res://Game/Levels/Pseudocode/Cap", Main.current_chapter, "Theory.tscn")
			
			var file = File.new()
			
			if file.file_exists(scene_path):
				get_tree().change_scene(scene_path)
			else:
				get_tree().change_scene("res://Game/MainScreens/Credits.tscn")

func _on_Back_pressed():
	SoundManager.select_sound(SoundManager.BUTTON)
	SoundManager.play_sound()
	
	if Main.firebase != null:
		Main.firebase.show_banner_ad(true)

	save_all()
	
	get_tree().change_scene("res://Game/Levels/Pseudocode/History.tscn")
	
func _on_Continue_pressed():
	SoundManager.select_sound(SoundManager.BUTTON)
	SoundManager.play_sound()
	
	$Continue.hide()
	
	save_all(true)
	
func _on_Leaderboard_pressed():
	Main.google_games.show_leaderboard("CgkI1raHjpUfEAIQBA")
