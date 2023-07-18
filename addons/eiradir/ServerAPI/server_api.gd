@tool
class_name EiradirServerAPI
extends Node

var _config: Dictionary = {}

func _init(conf: Dictionary) -> void:
	_config = conf
	
func fetch_join_token(base_url: String) -> JoinTokenTask:
	var task = JoinTokenTask.new()
	var http = HTTPRequest.new()
	add_child(http)
	task.execute(http, base_url)
	return task

func fetch_character_list(base_url: String) -> CharacterListTask:
	var task = CharacterListTask.new()
	var http = HTTPRequest.new()
	add_child(http)
	task.execute(http, base_url)
	return task

func fetch_character_creation_options(base_url: String) -> CharacterCreationOptionsTask:
	var task = CharacterCreationOptionsTask.new()
	var http = HTTPRequest.new()
	add_child(http)
	task.execute(http, base_url)
	return task 

func create_character(base_url: String, character: Dictionary) -> CreateCharacterTask:
	var task = CreateCharacterTask.new()
	var http = HTTPRequest.new()
	add_child(http)
	task.execute(http, base_url, character)
	return task