@tool
class_name EiradirAuthAPI
extends Node

var _config: Dictionary = {}

func _init(conf: Dictionary) -> void:
	_config = conf
	
func authorize(username: String, password: String) -> AuthorizeTask:
	var task = AuthorizeTask.new()
	var http = HTTPRequest.new()
	add_child(http)
	task.execute(http, _config.auth_url, username, password)
	return task
