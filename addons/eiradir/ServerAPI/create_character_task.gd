@tool
extends RefCounted
class_name CreateCharacterTask

signal completed(id: int, error: String)

func execute(request: HTTPRequest, baseUrl: String, body: Dictionary):
	reference() # refcount this until request completes in case caller doesn't keep track of it
	request.request_completed.connect(_on_http_request_completed.bind(request))
	var endpoint: String = baseUrl + "/characters"
	var headers: PackedStringArray = [
		"Authorization: Bearer " + Eiradir.tokens.access_token,
		"Content-Type: application/json"
	]
	request.request(endpoint, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	
func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, request: HTTPRequest):
	unreference()
	request.queue_free()
	var body_text = body.get_string_from_utf8()
	var error: EiradirError = Eiradir.handle_request_error(result, response_code, body_text)
	var json: Dictionary = JSON.parse_string(body_text) if !error else {}
	completed.emit(json.get("id"), error)
