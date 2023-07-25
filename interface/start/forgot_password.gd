extends Control

signal to_login
signal to_info(title, message)

func init(email):
	%Email.text = email

func _ready():
	%Email.grab_focus()
	%Email.caret_column = %Email.text.length()
	updateButtonState()


func _on_back_to_login_button_pressed():
	to_login.emit()


func _on_reset_password_button_pressed():
	%ResetPasswordButton.set_disabled(true)


func _on_reset_email_sent():
	to_info.emit(tr("PASSWORD_RESET_SENT_TITLE"), tr("PASSWORD_RESET_SENT"))

func updateButtonState():
	%ResetPasswordButton.set_disabled(%Email.text.is_empty())

func _on_email_edit_text_changed(_new_text):
	updateButtonState()


func get_email():
	return %Email.text
