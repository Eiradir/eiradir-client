@tool
extends RefCounted
class_name CharacterListTask

signal completed(characters: Array, error: EiradirError)

func execute(request: HTTPRequest, baseUrl: String):
	reference() # refcount this until request completes in case caller doesn't keep track of it
	request.request_completed.connect(_on_http_request_completed.bind(request))
	var endpoint: String = baseUrl + "/characters"
	var headers: PackedStringArray = [
		"Authorization: Bearer " + Eiradir.tokens.access_token
	]
	request.request(endpoint, headers, HTTPClient.METHOD_GET)
	
func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, request: HTTPRequest):
	unreference()
	request.queue_free()
	var body_text = body.get_string_from_utf8()
	var error: EiradirError = Eiradir.handle_request_error(result, response_code, body_text)
	var json: Dictionary = JSON.parse_string(body_text) if !error else {}
	completed.emit(json.get("characters", []), error)
