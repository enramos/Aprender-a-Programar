extends Node

var dialog_num = 1

func _ready():
	# El ready de $TheoryTemplate current_chapter es 1
	if Main.current_chapter == 1:
		Main.current_chapter = 6
	
	var rpg_dialog = $TheoryTemplate/RPGDialog

	var pet_name = Main.data["PetSelected"]
	
	$TheoryTemplate.start_dialog(pet_name, rpg_dialog)
	
	$AnyPet.walk()
	dialog_num += 1
	
func _on_RPGDialog_changed_text():
	print("dialog_num: ", dialog_num)
	
	if $Anim.has_animation(str("anim", dialog_num)):
		$Anim.play(str("anim", dialog_num))
	
	match dialog_num:
		2:
			$AnyPet.talk()
			
	dialog_num += 1

func _on_Anim_animation_finished(anim_name):
	if anim_name == "finish":
		get_tree().change_scene("res://Game/Levels/Win.tscn")
