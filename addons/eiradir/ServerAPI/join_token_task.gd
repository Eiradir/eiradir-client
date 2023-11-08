@tool
extends RefCounted
class_name JoinTokenTask

signal completed(username: String, joinToken: String, gameHost: String, gamePort: int, error: String)

func execute(request: HTTPRequest, baseUrl: String):
	reference() # refcount this until request completes in case caller doesn't keep track of it
	request.request_completed.connect(_on_http_request_completed.bind(request))
	var endpoint: String = baseUrl + "/authorize"
	var headers: PackedStringArray = [
		"Authorization: Bearer " + Eiradir.tokens.access_token
	]
	request.request(endpoint, headers, HTTPClient.METHOD_POST)
	
func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, request: HTTPRequest):
	unreference()
	request.queue_free()
	var body_text = body.get_string_from_utf8()
	var error: EiradirError = Eiradir.handle_request_error(result, response_code, body_text)
	var json: Dictionary = JSON.parse_string(body_text) if !error else {}
	completed.emit(json.get("username", ""), json.get("login_token", ""), json.get("game_server_host", ""), json.get("game_server_port", 0), error)
