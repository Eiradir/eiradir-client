extends Control

signal to_login
signal to_select_character

func init(email, password):
	%Email.text = email
	%Password.text = password

func _ready():
	Supabase.auth.signed_up.connect(_on_signed_up)
	%Email.grab_focus()
	%Email.caret_column = %Email.text.length()
	updateButtonState()


func _on_back_to_login_button_pressed():
	to_login.emit()


func _on_create_account_button_pressed():
	Supabase.auth.sign_up(%Email.text, %Password.text)

func updateButtonState():
	%CreateAccountButton.set_disabled(%Email.text.is_empty() || %Password.text.is_empty() || !%Rules.is_pressed())


func _on_email_edit_text_changed(_new_text):
	updateButtonState()


func _on_password_edit_text_changed(_new_text):
	updateButtonState()


func _on_remember_me_pressed():
	updateButtonState()

func _on_signed_up(_user):
	to_select_character.emit()


func get_email():
	return %Email.text
	
func get_password():
	return %Password.text
