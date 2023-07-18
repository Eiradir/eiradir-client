extends Control

var login_scene
var select_character_scene
var create_character_scene
var join_scene
var create_account_scene
var forgot_password_scene
var info_scene
var current

func _ready():
	login_scene = preload("res://interface/start/login.tscn")
	select_character_scene = preload("res://interface/start/select_character.tscn")
	create_character_scene = preload("res://interface/start/create_character/create_character.tscn")
	create_account_scene = preload("res://interface/start/create_account.tscn")
	join_scene = preload("res://interface/start/join.tscn")
	forgot_password_scene = preload("res://interface/start/forgot_password.tscn")
	info_scene = preload("res://interface/start/info.tscn")
	_to_login()


func _to_create_account():
	OS.shell_open(Eiradir.config.auth_url + "/protocol/openid-connect/registrations?client_id=eiradir-account&response_type=code")
	#var email = ""
	#var password = ""
	#if current != null:
	#	remove_child(current)
	#	current.queue_free()
	#	email = current.get_email() if current.has_method("get_email") else ""
	#	password = current.get_password() if current.has_method("get_password") else ""
	#current = create_account_scene.instantiate()
	#current.to_login.connect(_to_login)
	#current.to_select_character.connect(_to_select_character)
	#current.init(email, password)
	#add_child(current)
	
func _to_forgot_password():
	OS.shell_open(Eiradir.config.auth_url + "/login-actions/reset-credentials")
	#var email = ""
	#if current != null:
	#	remove_child(current)
	#	current.queue_free()
	#	email = current.get_email() if current.has_method("get_email") else ""
	#current = forgot_password_scene.instantiate()
	#current.to_login.connect(_to_login)
	#current.to_info.connect(_to_info.bind(_to_login))
	#current.init(email)
	#add_child(current)
	
func _to_login():
	var email = ""
	var password = ""
	if current != null:
		remove_child(current)
		current.queue_free()
		email = current.get_email() if current.has_method("get_email") else ""
		password = current.get_password() if current.has_method("get_password") else ""
	current = login_scene.instantiate()
	current.to_create_account.connect(_to_create_account)
	current.to_forgot_password.connect(_to_forgot_password)
	current.to_select_character.connect(_to_select_character)
	current.init(email, password)
	add_child(current)

func _to_info(title, message, back_handler):
	if current != null:
		remove_child(current)
		current.queue_free()
	current = info_scene.instantiate()
	current.init(title, message)
	current.to_login.connect(back_handler)
	add_child(current)
	
func _to_select_character():
	if current != null:
		remove_child(current)
		current.queue_free()
	current = select_character_scene.instantiate()
	current.to_create_character.connect(_to_create_character)
	current.character_selected.connect(_character_selected)
	add_child(current)

func _to_create_character(server: String):
	if current != null:
		remove_child(current)
		current.queue_free()
	current = create_character_scene.instantiate()
	current.to_select_character.connect(_to_select_character)
	current.character_created.connect(_character_created)
	current.init(server)
	add_child(current)
	
func _character_selected(server: String, id: int):
	to_join(server, id)

func _character_created(server: String, id: int):
	to_join(server, id)
	
func to_join(server: String, id: int):
	if current != null:
		remove_child(current)
		current.queue_free()
	current = join_scene.instantiate()
	current.to_select_character.connect(_to_select_character)
	current.to_info.connect(_to_info.bind(_to_select_character))
	current.to_game.connect(_to_game)
	current.init(server, id)
	add_child(current)

func _to_game(game: Node):
	if current != null:
		remove_child(current)
		current.queue_free()
	game.show()
	queue_free()