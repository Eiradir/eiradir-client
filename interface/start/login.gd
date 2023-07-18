extends Control

signal to_create_account
signal to_select_character
signal to_forgot_password

func init(email, password):
	%Email.text = email
	%Password.text = password

func restore_credentials():
	var config = ConfigFile.new()
	var err = config.load("user://credentials.cfg")
	if err != OK:
		return
	var storedLogin = config.get_value("credentials", "login", "")
	var storedPassword = config.get_value("credentials", "password", "")
	var wasStored = !storedLogin.is_empty() || !storedPassword.is_empty()
	if %Email.text.is_empty():
		%Email.text = storedLogin
	if %Password.text.is_empty():
		%Password.text = storedPassword
	%RememberMe.set_pressed(wasStored)
	updateButtonState()
	
	
func store_credentials():
	var config = ConfigFile.new()
	config.set_value("credentials", "login", %Email.text)
	config.set_value("credentials", "password", %Password.text)
	config.save("user://credentials.cfg")
	
func clear_credentials():
	var config = ConfigFile.new()
	config.save("user://credentials.cfg")
	
func _ready():
	restore_credentials()
	%Email.grab_focus()
	%Email.caret_column = %Email.text.length()


func updateButtonState():
	%LoginButton.set_disabled(%Email.text.is_empty() || %Password.text.is_empty())
	

func _on_create_account_button_pressed():
	to_create_account.emit()


func _on_forgot_password_button_pressed():
	to_forgot_password.emit()

func _on_email_text_changed(_new_text):
	updateButtonState()


func _on_password_text_changed(_new_text):
	updateButtonState()


func _on_login_button_pressed():
	%LoginButton.set_disabled(true)
	var result = await Eiradir.auth.authorize(%Email.text, %Password.text).completed
	var tokens = result[0]
	var error = result[1]
	if error:
		_on_error(error)
		return
	_on_signed_in(tokens)

func _on_signed_in(tokens):
	if %RememberMe.is_pressed():
		store_credentials()
	else:
		clear_credentials()
	Eiradir.tokens = tokens
	to_select_character.emit()

func _on_error(error):
	print(error)
	%LoginButton.set_disabled(false)
	%Error.show()
	%Error.text = tr("LOGIN_ERROR_" + error.type.to_upper())

func get_email():
	return %Email.text
	
func get_password():
	return %Password.text
