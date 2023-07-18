extends Control

signal to_login

var title = ""
var message = ""

func init(init_title, init_message):
	title = init_title
	message = init_message

func _ready():
	%Title.text = title
	%Message.text = message


func _on_back_to_login_button_pressed():
	to_login.emit()
