extends Node

const RES_X = 1280
const RES_Y = 720

var version = "v0.1.0"
var firebase

func _ready():
	firebase_config()
	firebase_auth_config()
	
func firebase_config():
	firebase = Engine.get_singleton("FireBase");
	
	if OS.get_name() == "Android":
		var file = File.new()
		file.open("res://godot-firebase-config.json", file.READ)
		var content = file.get_as_text()
		file.close()
		
		firebase.init(content, get_instance_id())

func firebase_auth_config():
	if firebase != null:
		firebase.authConfig("'Google':true,'Facebook':true")
	
func _receive_message(tag, from, key, data):
	if tag == "FireBase":
		print("From: ", from, " Key: ", key, " Data: ", data)